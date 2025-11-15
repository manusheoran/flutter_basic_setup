import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/activity_model.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/parameter_service.dart';

class DashboardController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();
  final ParameterService _parameterService = Get.find<ParameterService>();
  
  RxInt selectedTab = 0.obs;
  RxList<DailyActivity> activities = <DailyActivity>[].obs;
  RxBool isLoading = false.obs;
  RxDouble maxTotalScore = 0.0.obs;
  final Map<String, double> _activityMax = {};
  final Map<String, double> _activityMin = {};
  
  // Overall averages
  RxDouble avgScore = 0.0.obs;
  RxDouble avgPercentage = 0.0.obs;
  RxInt actualDaysCount = 0.obs; // Actual number of days with data
  Rx<DateTime?> firstActivityDate = Rx<DateTime?>(null);
  
  // Individual activity averages
  RxDouble avgNindra = 0.0.obs;
  RxDouble avgWakeUp = 0.0.obs;
  RxDouble avgDaySleep = 0.0.obs;
  RxDouble avgJapa = 0.0.obs;
  RxDouble avgPathan = 0.0.obs;
  RxDouble avgSravan = 0.0.obs;
  RxDouble avgSeva = 0.0.obs;
  
  // Date range selection
  Rx<DateTime> startDate = DateTime.now().subtract(const Duration(days: 29)).obs;
  Rx<DateTime> endDate = DateTime.now().obs;
  RxString selectedRangeLabel = 'Last 30 Days'.obs;
  RxString selectedRangeType = 'last30'.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initAsync();
  }

  Future<void> _initAsync() async {
    await _loadParameterMeta();
    loadFirstActivityDate();
    loadActivitiesForDateRange();
  }
  
  @override
  void onReady() {
    super.onReady();
    // Reload data when dashboard is opened (in case data changed)
    refreshData(silent: true);
  }
  
  // Refresh all data
  Future<void> refreshData({bool silent = false}) async {
    print('🔄 Refreshing dashboard data...');
    await loadFirstActivityDate();
    await loadActivitiesForDateRange(silent: silent);
  }
  
  // Load user's first activity date to calculate smart averages
  Future<void> loadFirstActivityDate() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;
    
    try {
      firstActivityDate.value = await _firestoreService.getFirstActivityDate(userId);
      if (firstActivityDate.value != null) {
        print('📅 First activity date: ${firstActivityDate.value}');
      }
    } catch (e) {
      print('❌ Error loading first activity date: $e');
    }
  }
  
  void selectDateRange({
    required String type,
    required String label,
    required DateTime start,
    required DateTime end,
    bool adjustToFirstActivity = true,
  }) {
    selectedRangeType.value = type;

    DateTime adjustedStart = start;

    if (adjustToFirstActivity && firstActivityDate.value != null) {
      final firstDate = firstActivityDate.value!;
      if (adjustedStart.isBefore(firstDate)) {
        adjustedStart = firstDate;
      }
    }

    if (adjustedStart.isAfter(end)) {
      adjustedStart = end;
    }

    startDate.value = adjustedStart;
    endDate.value = end;
    selectedRangeLabel.value = label;
    loadActivitiesForDateRange();
  }
  
  void selectCustomDateRange(DateTime start, DateTime end) {
    final sameYear = start.year == end.year;
    final startFormatter = DateFormat(sameYear ? 'MMM dd' : 'MMM dd, yyyy');
    final endFormatter = DateFormat('MMM dd, yyyy');
    final label = '${startFormatter.format(start)} - ${endFormatter.format(end)}';
    selectDateRange(
      type: 'custom',
      label: label,
      start: start,
      end: end,
      adjustToFirstActivity: false,
    );
  }
  
  Future<void> loadActivitiesForDateRange({bool silent = false}) async {
    if (!silent) {
      isLoading.value = true;
    }
    
    final userId = _authService.currentUserId;
        
    if (userId == null) {
      isLoading.value = false;
      _resetAverages();
      activities.value = [];
      return;
    }
    
    try {
      final fetchedActivities = await _firestoreService.getActivitiesInRange(
        userId,
        startDate.value,
        endDate.value,
      );
      
      // Sort activities by date descending
      fetchedActivities.sort((a, b) => b.dateString.compareTo(a.dateString));
      
      activities.value = fetchedActivities;
      calculateAllAverages();
      
      print('✅ Loaded ${fetchedActivities.length} activities from ${DateFormat('MMM dd').format(startDate.value)} to ${DateFormat('MMM dd').format(endDate.value)}');
    } catch (e) {
      print('❌ Error loading dashboard data: $e');
      activities.value = [];
      _resetAverages();
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> _loadParameterMeta() async {
    try {
      await _parameterService.ensureLoaded();
      maxTotalScore.value = _parameterService.getTotalMaxPoints();
      final keys = ['nindra', 'wake_up', 'day_sleep', 'japa', 'pathan', 'sravan', 'seva'];
      for (final k in keys) {
        _activityMax[k] = _parameterService.getMaxPoints(k);
        final param = _parameterService.getParameter(k);
        double minVal = 0;
        if (param != null && param.scoring.isNotEmpty) {
          minVal = param.scoring.values.reduce((a, b) => a < b ? a : b);
        }
        _activityMin[k] = minVal;
      }
    } catch (e) {
      print('❌ Error loading parameter metadata: $e');
    }
  }

  double getMaxPoints(String key) => _activityMax[key] ?? 0;
  double getMinPoints(String key) => _activityMin[key] ?? 0;

  void calculateAllAverages() {
    if (activities.isEmpty) {
      _resetAverages();
      actualDaysCount.value = 0;
      return;
    }
    
    double totalScore = 0.0;
    double totalPercentage = 0.0;
    double totalNindra = 0.0;
    double totalWakeUp = 0.0;
    double totalDaySleep = 0.0;
    double totalJapa = 0.0;
    double totalPathan = 0.0;
    double totalSravan = 0.0;
    double totalSeva = 0.0;
    
    for (var activity in activities) {
      totalScore += activity.totalPoints;
      totalPercentage += activity.percentage;
      totalNindra += activity.getActivity('nindra')?.analytics?.pointsAchieved ?? 0;
      totalWakeUp += activity.getActivity('wake_up')?.analytics?.pointsAchieved ?? 0;
      totalDaySleep += activity.getActivity('day_sleep')?.analytics?.pointsAchieved ?? 0;
      totalJapa += activity.getActivity('japa')?.analytics?.pointsAchieved ?? 0;
      totalPathan += activity.getActivity('pathan')?.analytics?.pointsAchieved ?? 0;
      totalSravan += activity.getActivity('sravan')?.analytics?.pointsAchieved ?? 0;
      totalSeva += activity.getActivity('seva')?.analytics?.pointsAchieved ?? 0;
    }
    
    final count = activities.length.toDouble();
    actualDaysCount.value = activities.length;
    avgScore.value = totalScore / count;
    avgPercentage.value = totalPercentage / count;
    avgNindra.value = totalNindra / count;
    avgWakeUp.value = totalWakeUp / count;
    avgDaySleep.value = totalDaySleep / count;
    avgJapa.value = totalJapa / count;
    avgPathan.value = totalPathan / count;
    avgSravan.value = totalSravan / count;
    avgSeva.value = totalSeva / count;
    
    print('📊 Calculated averages for $actualDaysCount days');
    print('   Avg Score: ${avgScore.value.toStringAsFixed(1)} (${avgPercentage.value.toStringAsFixed(1)}%)');
  }
  
  void _resetAverages() {
    avgScore.value = 0.0;
    avgPercentage.value = 0.0;
    avgNindra.value = 0.0;
    avgWakeUp.value = 0.0;
    avgDaySleep.value = 0.0;
    avgJapa.value = 0.0;
    avgPathan.value = 0.0;
    avgSravan.value = 0.0;
    avgSeva.value = 0.0;
  }
  
  void changeTab(int index) {
    selectedTab.value = index;
    loadActivitiesForDateRange();
  }
}
