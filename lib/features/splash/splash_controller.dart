import 'package:get/get.dart';
import '../../data/services/auth_service.dart';

class SplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  RxBool isAuthenticating = false.obs;
  RxBool authenticationFailed = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkBiometricAuthentication();
  }

  Future<void> _checkBiometricAuthentication() async {
    // Wait a moment for splash screen to show
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if user is logged in and biometric is enabled
    if (_authService.isLoggedIn && _authService.isBiometricEnabled.value) {
      print('🔐 Biometric authentication enabled - prompting user');
      isAuthenticating.value = true;

      final authenticated = await _authService.authenticateWithBiometrics();
      
      isAuthenticating.value = false;

      if (!authenticated) {
        print('❌ Biometric authentication failed');
        authenticationFailed.value = true;
        
        // Sign out user and redirect to login
        await _authService.signOut();
        return;
      }

      print('✅ Biometric authentication successful');
    }

    // AuthService will handle navigation based on auth state
  }

  void retryBiometricAuth() {
    authenticationFailed.value = false;
    _checkBiometricAuthentication();
  }

  void skipBiometricAndLogout() async {
    await _authService.signOut();
  }
}
