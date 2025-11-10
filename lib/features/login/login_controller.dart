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
        print('✅ Signup successful!');
        // Show success message
        if (Get.currentRoute == '/login') {
          Get.snackbar(
            'Success! 🎉',
            'Account created! Now try to login - we\'ll send a verification email that you need to click before you can access the app.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 7),
          );
        }
        // Switch to login mode
        toggleMode();
        emailController.clear();
        passwordController.clear();
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
  
  Future<void> signInWithGoogle() async {
    if (isLoading.value) {
      print('⚠️ Google Sign-In already in progress, ignoring duplicate request');
      return;
    }
    
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
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
    print('🔐 Attempting Google Sign-In');
    
    try {
      final error = await _authService!.signInWithGoogle();
      
      if (error != null) {
        print('❌ Google Sign-In failed: $error');
        if (Get.currentRoute == '/login') {
          Get.snackbar(
            'Google Sign-In Failed',
            error,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      } else {
        print('✅ Google Sign-In successful! AuthService will handle navigation');
      }
    } catch (e) {
      print('❌ Unexpected error during Google Sign-In: $e');
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
  
  void showForgotPasswordDialog() {
    final TextEditingController emailResetController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailResetController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              emailResetController.dispose();
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailResetController.text.trim();
              
              if (email.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter your email',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              
              if (_authService == null) return;
              
              Get.back(); // Close dialog
              
              final error = await _authService!.sendPasswordResetEmail(email);
              
              if (error != null) {
                Get.snackbar(
                  'Error',
                  error,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'Success',
                  'Password reset email sent! Check your inbox.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 4),
                );
              }
              
              emailResetController.dispose();
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }
}
