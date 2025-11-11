import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/activity_model.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/auth_service.dart';

class DashboardController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();
  
  RxInt selectedTab = 0.obs;
  RxList<DailyActivity> activities = <DailyActivity>[].obs;
  RxBool isLoading = false.obs;
  
  // Overall averages
  RxDouble avgScore = 0.0.obs;
  RxDouble avgPercentage = 0.0.obs;
  
  // Individual activity averages
  RxDouble avgNindra = 0.0.obs;
  RxDouble avgWakeUp = 0.0.obs;
  RxDouble avgDaySleep = 0.0.obs;
  RxDouble avgJapa = 0.0.obs;
  RxDouble avgPathan = 0.0.obs;
  RxDouble avgSravan = 0.0.obs;
  RxDouble avgSeva = 0.0.obs;
  
  // Date range selection
  Rx<DateTime> startDate = DateTime.now().subtract(const Duration(days: 6)).obs;
  Rx<DateTime> endDate = DateTime.now().obs;
  RxString selectedRangeLabel = 'Last 7 Days'.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadActivitiesForDateRange();
  }
  
  void selectDateRange(String label, DateTime start, DateTime end) {
    selectedRangeLabel.value = label;
    startDate.value = start;
    endDate.value = end;
    loadActivitiesForDateRange();
  }
  
  void selectCustomDateRange(DateTime start, DateTime end) {
    final formatter = DateFormat('MMM dd');
    selectedRangeLabel.value = '${formatter.format(start)} - ${formatter.format(end)}';
    startDate.value = start;
    endDate.value = end;
    loadActivitiesForDateRange();
  }
  
  Future<void> loadActivitiesForDateRange() async {
    isLoading.value = true;
    
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
  
  void calculateAllAverages() {
    if (activities.isEmpty) {
      _resetAverages();
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
    avgScore.value = totalScore / count;
    avgPercentage.value = totalPercentage / count;
    avgNindra.value = totalNindra / count;
    avgWakeUp.value = totalWakeUp / count;
    avgDaySleep.value = totalDaySleep / count;
    avgJapa.value = totalJapa / count;
    avgPathan.value = totalPathan / count;
    avgSravan.value = totalSravan / count;
    avgSeva.value = totalSeva / count;
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
