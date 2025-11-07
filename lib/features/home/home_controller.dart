import 'package:get/get.dart';
import '../../data/models/activity_model.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/scoring_service.dart';
import '../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();
  
  Rx<ActivityModel?> currentActivity = Rx<ActivityModel?>(null);
  Rx<DateTime> selectedDate = DateTime.now().obs;
  RxBool isLoading = false.obs;
  RxBool isSaving = false.obs;
  
  // Activity input values
  RxString nindraTime = ''.obs;
  RxString wakeUpTime = ''.obs;
  RxInt daySleepMinutes = 0.obs;
  RxInt japaRounds = 0.obs;
  RxInt pathanMinutes = 0.obs;
  RxInt sravanMinutes = 0.obs;
  RxDouble sevaHours = 0.0.obs;
  
  RxDouble totalScore = 0.0.obs;
  RxDouble percentage = 0.0.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadActivityForDate(selectedDate.value);
  }
  
  Future<void> loadActivityForDate(DateTime date) async {
    isLoading.value = true;
    
    final userId = _authService.currentUserId;
    if (userId == null) return;
    
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final activity = await _firestoreService.getActivityByDate(userId, dateStr);
    
    if (activity != null) {
      currentActivity.value = activity;
      // Populate fields from activity
      nindraTime.value = activity.nindra.time ?? '';
      wakeUpTime.value = activity.wakeUp.time ?? '';
      daySleepMinutes.value = activity.daySleep.minutes ?? 0;
      japaRounds.value = activity.japa.rounds ?? 0;
      pathanMinutes.value = activity.pathan.minutes ?? 0;
      sravanMinutes.value = activity.sravan.minutes ?? 0;
      sevaHours.value = activity.seva.hours ?? 0.0;
      totalScore.value = activity.totalScore;
      percentage.value = activity.percentage;
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
    pathanMinutes.value = 0;
    sravanMinutes.value = 0;
    sevaHours.value = 0.0;
    totalScore.value = 0.0;
    percentage.value = 0.0;
  }
  
  void calculateScores() {
    final nindraScore = ScoringService.calculateNindraScore(nindraTime.value);
    final wakeUpScore = ScoringService.calculateWakeUpScore(wakeUpTime.value);
    final daySleepScore = ScoringService.calculateDaySleepScore(daySleepMinutes.value);
    final japaScore = ScoringService.calculateJapaScore(japaRounds.value);
    final pathanScore = ScoringService.calculatePathanScore(pathanMinutes.value);
    final sravanScore = ScoringService.calculateSravanScore(sravanMinutes.value);
    final sevaScore = ScoringService.calculateSevaScore(sevaHours.value);
    
    final scores = ScoringService.calculateTotalScore(
      nindra: nindraScore,
      wakeUp: wakeUpScore,
      daySleep: daySleepScore,
      japa: japaScore,
      pathan: pathanScore,
      sravan: sravanScore,
      seva: sevaScore,
    );
    
    totalScore.value = scores['totalScore']!;
    percentage.value = scores['percentage']!;
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
      final nindraScore = ScoringService.calculateNindraScore(nindraTime.value);
      final wakeUpScore = ScoringService.calculateWakeUpScore(wakeUpTime.value);
      final daySleepScore = ScoringService.calculateDaySleepScore(daySleepMinutes.value);
      final japaScore = ScoringService.calculateJapaScore(japaRounds.value);
      final pathanScore = ScoringService.calculatePathanScore(pathanMinutes.value);
      final sravanScore = ScoringService.calculateSravanScore(sravanMinutes.value);
      final sevaScore = ScoringService.calculateSevaScore(sevaHours.value);
      
      final activity = ActivityModel(
        id: '${userId}_$dateStr',
        userId: userId,
        date: dateStr,
        nindra: ActivityData(time: nindraTime.value, score: nindraScore),
        wakeUp: ActivityData(time: wakeUpTime.value, score: wakeUpScore),
        daySleep: ActivityData(minutes: daySleepMinutes.value, score: daySleepScore),
        japa: ActivityData(rounds: japaRounds.value, score: japaScore),
        pathan: ActivityData(minutes: pathanMinutes.value, score: pathanScore),
        sravan: ActivityData(minutes: sravanMinutes.value, score: sravanScore),
        seva: ActivityData(hours: sevaHours.value, score: sevaScore),
        totalScore: totalScore.value,
        percentage: percentage.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _firestoreService.saveActivity(activity);
      
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
}
