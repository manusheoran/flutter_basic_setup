import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/firestore_service.dart';

class SettingsController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  
  RxBool isDarkMode = false.obs;
  RxString selectedLanguage = 'English'.obs;
  RxString selectedLocale = 'en'.obs;
  RxBool isRequestingMentor = false.obs;
  
  final mentorIdController = TextEditingController();
  
  // Activity tracking toggles (all active by default)
  RxMap<String, bool> trackedActivities = <String, bool>{
    'nindra': true,
    'wake_up': true,
    'day_sleep': true,
    'japa': true,
    'pathan': true,
    'sravan': true,
    'seva': true,
  }.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }
  
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('app_locale') ?? 'en';
    final savedLanguage = prefs.getString('app_language') ?? 'English';
    
    selectedLocale.value = savedLocale;
    selectedLanguage.value = savedLanguage;
    
    // Apply saved locale
    Get.updateLocale(Locale(savedLocale));
  }
  
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
  
  Future<void> changeLanguage(String language, String locale) async {
    selectedLanguage.value = language;
    selectedLocale.value = locale;
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', locale);
    await prefs.setString('app_language', language);
    
    // Update app locale
    var newLocale = Locale(locale);
    Get.updateLocale(newLocale);
    
    Get.snackbar(
      'Success',
      'Language changed to $language',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
  
  Future<void> requestMentor() async {
    final userId = _authService.currentUserId;
    final currentUserData = _authService.currentUser.value;
    final userName = currentUserData?.name ?? 'Unknown';
    final userEmail = currentUserData?.email ?? '';
    
    if (userId == null || mentorIdController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a Mentor ID');
      return;
    }
    
    isRequestingMentor.value = true;
    
    try {
      // First get master details
      final masterData = await _firestoreService.getUserById(mentorIdController.text);
      if (masterData == null) {
        throw Exception('Master not found');
      }
      
      await _firestoreService.requestMentor(
        userId,                    // discipleUid
        userName,                  // discipleName
        userEmail,                 // discipleEmail
        masterData.uid,            // masterUid
        masterData.name,           // masterName
        masterData.email,          // masterEmail
      );
      
      Get.snackbar(
        'Success',
        'Mentor request sent successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      mentorIdController.clear();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send mentor request: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isRequestingMentor.value = false;
    }
  }
  
  // Toggle activity tracking for today only
  Future<void> toggleActivityTracking(String activityKey) async {
    final userId = _authService.currentUserId;
    if (userId == null) return;
    
    // Toggle the local state
    final currentState = trackedActivities[activityKey] ?? true;
    trackedActivities[activityKey] = !currentState;
    
    // If turning OFF, remove from today's activity
    if (!trackedActivities[activityKey]!) {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await _firestoreService.removeActivityForDate(userId, today, activityKey);
      
      Get.snackbar(
        'Tracking Disabled',
        'Activity removed from today\'s tracking',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Tracking Enabled',
        'You can now track this activity for today',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }
  
  @override
  void onClose() {
    mentorIdController.dispose();
    super.onClose();
  }
}
