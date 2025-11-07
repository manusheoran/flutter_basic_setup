import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/auth_service.dart';

class LoginController extends GetxController {
  AuthService? _authService;
  
  @override
  void onInit() {
    super.onInit();
    try {
      _authService = Get.find<AuthService>();
    } catch (e) {
      print('⚠️ LoginController: Running in preview mode without Firebase');
    }
  }
  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  
  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxBool isSignUpMode = false.obs;
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.onClose();
  }
  
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }
  
  void toggleMode() {
    isSignUpMode.value = !isSignUpMode.value;
    nameController.clear();
  }
  
  Future<void> login() async {
    // Prevent double submission
    if (isLoading.value) {
      print('⚠️ Login already in progress, ignoring duplicate request');
      return;
    }
    
    // Close any existing snackbars first
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    if (_authService == null) {
      Get.snackbar(
        'Preview Mode',
        'Firebase is not configured. Please run: flutterfire configure',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      return;
    }
    
    isLoading.value = true;
    print('🔐 Attempting login for: ${emailController.text.trim()}');
    
    try {
      final error = await _authService!.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      
      if (error != null) {
        print('❌ Login failed: $error');
        if (Get.currentRoute == '/login') {
          Get.snackbar(
            'Login Failed',
            error,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      } else {
        print('✅ Login successful! AuthService will handle navigation');
      }
    } catch (e) {
      print('❌ Unexpected error during login: $e');
      if (Get.currentRoute == '/login') {
        Get.snackbar(
          'Error',
          'An unexpected error occurred',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> signUp() async {
    // Prevent double submission
    if (isLoading.value) {
      print('⚠️ Signup already in progress, ignoring duplicate request');
      return;
    }
    
    // Close any existing snackbars first
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    
    if (emailController.text.isEmpty || 
        passwordController.text.isEmpty || 
        nameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    if (_authService == null) {
      Get.snackbar(
        'Preview Mode',
        'Firebase is not configured. Please run: flutterfire configure',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      return;
    }
    
    isLoading.value = true;
    print('📝 Attempting signup for: ${emailController.text.trim()}');
    
    try {
      final error = await _authService!.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        name: nameController.text.trim(),
      );
      
      if (error != null) {
        print('❌ Signup failed: $error');
        if (Get.currentRoute == '/login') {
          Get.snackbar(
            'Sign Up Failed',
            error,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      } else {
        print('✅ Signup successful! AuthService will handle navigation');
      }
    } catch (e) {
      print('❌ Unexpected error during signup: $e');
      if (Get.currentRoute == '/login') {
        Get.snackbar(
          'Error',
          'An unexpected error occurred',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}
