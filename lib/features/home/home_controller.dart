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
  
  @override
  void onInit() {
    super.onInit();
    _initializeVisibleDates();
    loadActivityForDate(selectedDate.value);
  }
  
  void _initializeVisibleDates() {
    visibleDates.clear();
    final now = DateTime.now();
    // Add today and previous days based on constant
    for (int i = 0; i < AppConstants.visibleActivityDays; i++) {
      visibleDates.add(now.subtract(Duration(days: i)));
    }
  }
  
  Future<void> loadActivityForDate(DateTime date) async {
    isLoading.value = true;
    
    final userId = _authService.currentUserId;
    if (userId == null) return;
    
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    var activity = await _firestoreService.getActivityByDate(userId, dateStr);
    
    // If activity doesn't exist, create default one
    if (activity == null) {
      await _firestoreService.createDefaultActivity(userId, dateStr);
      activity = await _firestoreService.getActivityByDate(userId, dateStr);
    }
    
    if (activity != null) {
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
      
      // Always recalculate scores based on current values and parameter service rules
      // Don't use stored values to ensure accuracy
      calculateScores();
    } else {
      currentActivity.value = null;
      clearFields();
    }
    
    isLoading.value = false;
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
  
  void changeDate(int daysAgo) {
    selectedDate.value = DateTime.now().subtract(Duration(days: daysAgo));
    loadActivityForDate(selectedDate.value);
  }
  
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
