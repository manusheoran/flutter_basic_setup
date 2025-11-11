import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/firestore_service.dart';
import '../../core/theme/app_colors.dart';

class ParameterTrackingController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  RxBool isLoading = false.obs;
  RxBool isSaving = false.obs;

  // Track which parameters are enabled (local state before saving)
  RxMap<String, bool> trackedParameters = <String, bool>{
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
    loadUserParameterConfig();
  }

  // Load user's parameter configuration from Firestore
  Future<void> loadUserParameterConfig() async {
    isLoading.value = true;
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        isLoading.value = false;
        return;
      }

      final userData = await _firestoreService.getUserById(userId);
      if (userData != null && userData.activityTracking != null) {
        // Load user's saved configuration
        trackedParameters.value = Map<String, bool>.from(userData.activityTracking!);
      } else {
        // Default: all enabled
        trackedParameters.value = {
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
      print('❌ Error loading parameter config: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle parameter in local state (doesn't save immediately)
  void toggleParameter(String parameterKey) {
    final currentState = trackedParameters[parameterKey] ?? true;
    trackedParameters[parameterKey] = !currentState;
  }

  // Save all configuration at once
  Future<void> saveConfiguration() async {
    isSaving.value = true;
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // 1. Get list of enabled activities
      final enabledActivities = trackedParameters.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      // 2. Update user document with both fields
      await _firestoreService.updateUserActivityTracking(
        userId,
        Map<String, bool>.from(trackedParameters),
        enabledActivities,
      );

      // 3. Update today's daily_activities document
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await _firestoreService.updateDailyActivitiesForTracking(
        userId,
        today,
        Map<String, bool>.from(trackedParameters),
      );

      Get.back(); // Go back to settings page

      Get.snackbar(
        'Success',
        'Activity tracking configuration saved!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.greenSuccess,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('❌ Error saving configuration: $e');
      Get.snackbar(
        'Error',
        'Failed to save configuration: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.maroonDanger,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isSaving.value = false;
    }
  }

  // Get count of enabled parameters
  int get enabledCount {
    return trackedParameters.values.where((enabled) => enabled).length;
  }

  // Get count of disabled parameters
  int get disabledCount {
    return trackedParameters.values.where((enabled) => !enabled).length;
  }
}
