import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final userName = _authService.currentUser.value?.name ?? 'Unknown';
    
    if (userId == null || mentorIdController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a Mentor ID');
      return;
    }
    
    isRequestingMentor.value = true;
    
    try {
      await _firestoreService.requestMentor(
        userId,
        mentorIdController.text,
        userName,
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
  
  @override
  void onClose() {
    mentorIdController.dispose();
    super.onClose();
  }
}
