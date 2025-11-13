import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/models/activity_model.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/parameter_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();
  final ParameterService _parameterService = Get.find<ParameterService>();
  
  Rx<DailyActivity?> currentActivity = Rx<DailyActivity?>(null);
  Rx<DateTime> selectedDate = DateTime.now().obs;
  RxList<DateTime> visibleDates = <DateTime>[].obs; // Show multiple days
  RxBool isLoading = false.obs;
  RxBool isSaving = false.obs;
  RxBool documentNotFound = false.obs; // Track if document doesn't exist
  RxBool hasUnsavedChanges = false.obs;
  RxBool canEdit = true.obs;
  
  // User's activity tracking configuration
  RxMap<String, bool> userActivityTracking = <String, bool>{}.obs;
  
  // Activity input values
  RxString nindraTime = ''.obs;
  RxString wakeUpTime = ''.obs;
  RxInt daySleepMinutes = 0.obs;
  RxInt japaRounds = 0.obs;
  RxString japaTime = ''.obs;  // Time when japa was completed
  RxInt pathanMinutes = 0.obs;
  RxInt sravanMinutes = 0.obs;
  RxInt sevaMinutes = 0.obs;
  
  RxDouble totalScore = 0.0.obs;
  RxDouble percentage = 0.0.obs;
  RxDouble maxTotalScore = 260.0.obs; // Dynamic max score from ParameterService
  
  // Stream subscription
  StreamSubscription<DailyActivity?>? _activitySubscription;
  late final Worker _fieldChangeWorker;
  final Map<String, Map<String, dynamic>> _baselineSnapshots = {};
  bool _suppressDirtyCheck = false;
  
  @override
  void onInit() {
    super.onInit();
    _setupFieldListeners();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      await _parameterService.ensureLoaded();
      maxTotalScore.value = _parameterService.getTotalMaxPoints();
    } catch (e) {
      print('❌ Failed to load parameters before HomeController init: $e');
    }

    _initializeVisibleDates();
    await loadUserActivityConfig();
    _updateCanEdit(selectedDate.value, null);
    setupActivityStream(selectedDate.value);
  }
  
  @override
  void onClose() {
    _activitySubscription?.cancel();
    _fieldChangeWorker.dispose();
    super.onClose();
  }
  
  // Load user's activity tracking configuration
  Future<void> loadUserActivityConfig() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;
    
    try {
      final user = await _firestoreService.getUserById(userId);
      if (user != null && user.activityTracking != null) {
        userActivityTracking.value = user.activityTracking!;
      } else {
        // Default: all enabled
        userActivityTracking.value = {
          'nindra': true,
          'wake_up': true,
          'day_sleep': true,
          'japa': true,
          'pathan': true,
          'sravan': true,
          'seva': true,
        };
      }
    } catch (e) {
      print('❌ Error loading user activity config: $e');
    }
  }
  
  // Check if an activity is enabled for tracking
  bool isActivityEnabled(String key) {
    return userActivityTracking[key] ?? true;
  }
  
  // Check if activity should be shown in UI
  // Logic: If no document exists -> show all activities
  //        If document exists -> show only activities in the activities map
  bool shouldShowActivity(String key) {
    if (currentActivity.value == null) {
      // No document - show all activities so user can fill them
      return true;
    } else {
      // Document exists - show only activities that are being tracked
      // (present in the activities map)
      return currentActivity.value!.activities.containsKey(key);
    }
  }
  
  void _initializeVisibleDates() {
    visibleDates.clear();
    final now = DateTime.now();
    // Add today and previous days based on constant
    for (int i = 0; i < AppConstants.visibleActivityDays; i++) {
      visibleDates.add(now.subtract(Duration(days: i)));
    }
  }
  
  // Setup stream for real-time updates
  void setupActivityStream(DateTime date) {
    // Cancel existing subscription
    _activitySubscription?.cancel();
    
    isLoading.value = true;
    documentNotFound.value = false;
    
    final userId = _authService.currentUserId;
    if (userId == null) {
      isLoading.value = false;
      return;
    }
    
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    
    // Listen to activity stream
    _activitySubscription = _firestoreService
        .getActivityStreamByDate(userId, dateStr)
        .listen(
      (activity) {
        isLoading.value = false;
        
        _suppressDirtyCheck = true;
        if (activity == null) {
          documentNotFound.value = true;
          currentActivity.value = null;
          clearFields();
          print('📭 No document found for $dateStr');
          _updateCanEdit(date, null);
        } else {
          documentNotFound.value = false;
          currentActivity.value = activity;
          
          // Populate fields from activity
          nindraTime.value = activity.getActivity('nindra')?.extras['value']?.toString() ?? '';
          wakeUpTime.value = activity.getActivity('wake_up')?.extras['value']?.toString() ?? '';
          japaTime.value = activity.getActivity('japa')?.extras['time']?.toString() ?? '';
          daySleepMinutes.value = (activity.getActivity('day_sleep')?.extras['duration'] as num?)?.toInt() ?? 0;
          japaRounds.value = (activity.getActivity('japa')?.extras['rounds'] as num?)?.toInt() ?? 0;
          pathanMinutes.value = (activity.getActivity('pathan')?.extras['duration'] as num?)?.toInt() ?? 0;
          sravanMinutes.value = (activity.getActivity('sravan')?.extras['duration'] as num?)?.toInt() ?? 0;
          sevaMinutes.value = (activity.getActivity('seva')?.extras['duration'] as num?)?.toInt() ?? 0;
          
          // Always recalculate scores
          calculateScores();

          print('🔄 Activity updated from stream for $dateStr');
          _updateCanEdit(date, activity);
        }
        final snapshot = _snapshotCurrentValues();
        _storeBaseline(dateStr, snapshot);
        _suppressDirtyCheck = false;
        hasUnsavedChanges.value = false;
      },
      onError: (error) {
        isLoading.value = false;
        print('❌ Stream error: $error');
      },
    );
  }
  
  void clearFields() {
    nindraTime.value = '';
    wakeUpTime.value = '';
    daySleepMinutes.value = 0;
    japaRounds.value = 0;
    japaTime.value = '';
    pathanMinutes.value = 0;
    sravanMinutes.value = 0;
    sevaMinutes.value = 0;
    totalScore.value = 0.0;
    percentage.value = 0.0;
  }
  
  void calculateScores() {
    if (!_parameterService.isLoaded) {
      print('⚠️ ParameterService not ready, skipping score calculation');
      return;
    }

    final nindraScore = _parameterService.calculateScore('nindra', nindraTime.value);
    final wakeUpScore = _parameterService.calculateScore('wake_up', wakeUpTime.value);
    final daySleepScore = _parameterService.calculateScore('day_sleep', daySleepMinutes.value);
    final japaScore = _parameterService.calculateScore('japa', japaTime.value);
    final pathanScore = _parameterService.calculateScore('pathan', pathanMinutes.value);
    final sravanScore = _parameterService.calculateScore('sravan', sravanMinutes.value);
    final sevaScore = _parameterService.calculateScore('seva', sevaMinutes.value);
    
    print('🎯 Score Calculation:');
    print('  Nindra: $nindraScore (${nindraTime.value})');
    print('  Wake Up: $wakeUpScore (${wakeUpTime.value})');
    print('  Day Sleep: $daySleepScore (${daySleepMinutes.value} min)');
    print('  Japa: $japaScore (${japaTime.value})');
    print('  Pathan: $pathanScore (${pathanMinutes.value} min)');
    print('  Sravan: $sravanScore (${sravanMinutes.value} min)');
    print('  Seva: $sevaScore (${sevaMinutes.value} min)');
    
    final total = nindraScore + wakeUpScore + daySleepScore + japaScore + pathanScore + sravanScore + sevaScore;
    final maxTotal = _parameterService.getTotalMaxPoints();
    
    print('  TOTAL: $total / $maxTotal');
    print('  Percentage: ${maxTotal > 0 ? (total / maxTotal) * 100 : 0}%');
    
    totalScore.value = total;
    maxTotalScore.value = maxTotal; // Update dynamic max total
    percentage.value = maxTotal > 0 ? (total / maxTotal) * 100 : 0;
  }
  
  Future<void> saveActivity() async {
    if (!canEdit.value) {
      _showEditRestrictionMessage();
      return;
    }

    final userId = _authService.currentUserId;
    if (userId == null) {
      Get.snackbar('Error', 'User not logged in');
      return;
    }
    
    isSaving.value = true;
    calculateScores();
    
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      
      // Calculate individual scores
      final nindraScore = _parameterService.calculateScore('nindra', nindraTime.value);
      final wakeUpScore = _parameterService.calculateScore('wake_up', wakeUpTime.value);
      final daySleepScore = _parameterService.calculateScore('day_sleep', daySleepMinutes.value);
      final japaScore = _parameterService.calculateScore('japa', japaTime.value);
      final pathanScore = _parameterService.calculateScore('pathan', pathanMinutes.value);
      final sravanScore = _parameterService.calculateScore('sravan', sravanMinutes.value);
      final sevaScore = _parameterService.calculateScore('seva', sevaMinutes.value);
      
      // Build activities map
      final activitiesMap = <String, ActivityItem>{
        if (nindraTime.value.isNotEmpty)
          'nindra': ActivityItem(
            id: 'nindra',
            name: 'Night Sleep',
            type: 'time',
            extras: {'value': nindraTime.value},
            analytics: ActivityAnalytics(
              timestamp: _parseTime(nindraTime.value),
              pointsAchieved: nindraScore,
              maxAchievablePoints: _parameterService.getMaxPoints('nindra'),
              defaultValue: 0,
              status: 'active',
            ),
          ),
        if (wakeUpTime.value.isNotEmpty)
          'wake_up': ActivityItem(
            id: 'wake_up',
            name: 'Wake Up',
            type: 'time',
            extras: {'value': wakeUpTime.value},
            analytics: ActivityAnalytics(
              timestamp: _parseTime(wakeUpTime.value),
              pointsAchieved: wakeUpScore,
              maxAchievablePoints: _parameterService.getMaxPoints('wake_up'),
              defaultValue: 0,
              status: 'active',
            ),
          ),
        if (daySleepMinutes.value > 0 || daySleepScore > 0)
          'day_sleep': ActivityItem(
            id: 'day_sleep',
            name: 'Day Sleep',
            type: 'duration',
            extras: {'duration': daySleepMinutes.value},
            analytics: ActivityAnalytics(
              duration: daySleepMinutes.value.toDouble(),
              pointsAchieved: daySleepScore,
              maxAchievablePoints: _parameterService.getMaxPoints('day_sleep'),
              defaultValue: 0,
              status: 'active',
            ),
          ),
        if (japaRounds.value > 0 || japaTime.value.isNotEmpty)
          'japa': ActivityItem(
            id: 'japa',
            name: 'Japa',
            type: 'time',
            extras: {
              'rounds': japaRounds.value,
              'time': japaTime.value,
            },
            analytics: ActivityAnalytics(
              timestamp: _parseTime(japaTime.value),
              pointsAchieved: japaScore,
              maxAchievablePoints: _parameterService.getMaxPoints('japa'),
              defaultValue: 0,
              status: 'active',
            ),
          ),
        if (pathanMinutes.value > 0)
          'pathan': ActivityItem(
            id: 'pathan',
            name: 'Pathan',
            type: 'duration',
            extras: {'duration': pathanMinutes.value},
            analytics: ActivityAnalytics(
              duration: pathanMinutes.value.toDouble(),
              pointsAchieved: pathanScore,
              maxAchievablePoints: _parameterService.getMaxPoints('pathan'),
              defaultValue: 0,
              status: 'active',
            ),
          ),
        if (sravanMinutes.value > 0)
          'sravan': ActivityItem(
            id: 'sravan',
            name: 'Sravan',
            type: 'duration',
            extras: {'duration': sravanMinutes.value},
            analytics: ActivityAnalytics(
              duration: sravanMinutes.value.toDouble(),
              pointsAchieved: sravanScore,
              maxAchievablePoints: _parameterService.getMaxPoints('sravan'),
              defaultValue: 0,
              status: 'active',
            ),
          ),
        if (sevaMinutes.value > 0)
          'seva': ActivityItem(
            id: 'seva',
            name: 'Seva',
            type: 'duration',
            extras: {'duration': sevaMinutes.value},
            analytics: ActivityAnalytics(
              duration: sevaMinutes.value.toDouble(),
              pointsAchieved: sevaScore,
              maxAchievablePoints: _parameterService.getMaxPoints('seva'),
              defaultValue: 0,
              status: 'active',
            ),
          ),
      };
      
      // Use consistent docId format: userId_date
      final docId = '${userId}_$dateStr';
      
      final activity = DailyActivity(
        docId: docId,
        uid: userId,
        date: dateStr,
        activities: activitiesMap,
        analytics: DailyAnalytics(
          totalPointsAchieved: totalScore.value,
          totalMaxAchievablePoints: _parameterService.getTotalMaxPoints(),
        ),
        createdAt: currentActivity.value?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _firestoreService.saveDailyActivity(activity);
      
      Get.snackbar(
        'Success',
        'Activity saved successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.greenSuccess,
        colorText: AppColors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save activity: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.maroonDanger,
        colorText: AppColors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }
  
  void changeDate(DateTime date) {
    selectedDate.value = date;
    _updateCanEdit(date, null);
    setupActivityStream(date);
  }
  
  void discardChanges() {
    final dateKey = _dateKey(selectedDate.value);
    final baseline = _baselineSnapshots[dateKey];

    _suppressDirtyCheck = true;
    if (baseline == null) {
      clearFields();
    } else {
      nindraTime.value = (baseline['nindraTime'] as String?) ?? '';
      wakeUpTime.value = (baseline['wakeUpTime'] as String?) ?? '';
      daySleepMinutes.value = (baseline['daySleepMinutes'] as int?) ?? 0;
      japaRounds.value = (baseline['japaRounds'] as int?) ?? 0;
      japaTime.value = (baseline['japaTime'] as String?) ?? '';
      pathanMinutes.value = (baseline['pathanMinutes'] as int?) ?? 0;
      sravanMinutes.value = (baseline['sravanMinutes'] as int?) ?? 0;
      sevaMinutes.value = (baseline['sevaMinutes'] as int?) ?? 0;
    }
    calculateScores();
    _suppressDirtyCheck = false;
    hasUnsavedChanges.value = false;
  }

  void _setupFieldListeners() {
    _fieldChangeWorker = everAll([
      nindraTime,
      wakeUpTime,
      daySleepMinutes,
      japaRounds,
      japaTime,
      pathanMinutes,
      sravanMinutes,
      sevaMinutes,
    ], (_) => _evaluateDirtyState());
  }

  void _evaluateDirtyState() {
    if (_suppressDirtyCheck) {
      return;
    }

    final dateKey = _dateKey(selectedDate.value);
    final baseline = _baselineSnapshots[dateKey];
    final currentSnapshot = _snapshotCurrentValues();

    if (baseline == null) {
      hasUnsavedChanges.value = currentSnapshot.values.any((element) {
        if (element is String) return element.isNotEmpty;
        if (element is num) return element != 0;
        return element != null;
      });
    } else {
      hasUnsavedChanges.value = !mapEquals(baseline, currentSnapshot);
    }
  }

  Map<String, dynamic> _snapshotCurrentValues() {
    return {
      'nindraTime': nindraTime.value,
      'wakeUpTime': wakeUpTime.value,
      'daySleepMinutes': daySleepMinutes.value,
      'japaRounds': japaRounds.value,
      'japaTime': japaTime.value,
      'pathanMinutes': pathanMinutes.value,
      'sravanMinutes': sravanMinutes.value,
      'sevaMinutes': sevaMinutes.value,
    };
  }

  void _storeBaseline(String dateKey, Map<String, dynamic> snapshot) {
    _baselineSnapshots[dateKey] = Map<String, dynamic>.from(snapshot);
  }

  String _dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  void _updateCanEdit(DateTime date, DailyActivity? activity) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);

    final int dayDifference = today.difference(selected).inDays;
    final bool isWithinEditableWindow = dayDifference >= 0 && dayDifference <= 2;

    final String? status = activity?.status;
    final bool isUnblocked = status != null &&
        status.toLowerCase().contains('unblock');

    canEdit.value = isWithinEditableWindow || isUnblocked;
  }

  void notifyEditNotAllowed() {
    _showEditRestrictionMessage();
  }

  void _showEditRestrictionMessage() {
    Get.snackbar(
      'Not Allowed',
      editRestrictionMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.maroonDanger,
      colorText: AppColors.white,
    );
  }

  bool get canEditSelectedDate => canEdit.value;

  String get editRestrictionMessage => "Can't edit for this date";

  // Helper to parse time string (HH:mm) to DateTime
  DateTime? _parseTime(String timeStr) {
    if (timeStr.isEmpty) return null;
    try {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, hour, minute);
      }
    } catch (e) {
      print('Error parsing time: $e');
    }
    return null;
  }
}
