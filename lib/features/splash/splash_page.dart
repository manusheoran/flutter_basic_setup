import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import 'splash_controller.dart';

class SplashPage extends StatelessWidget {
  SplashPage({super.key});
  
  final SplashController controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryOrange,
      body: Center(
        child: Obx(() => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                controller.isAuthenticating.value 
                    ? Icons.fingerprint 
                    : Icons.self_improvement,
                size: 70,
                color: AppColors.primaryOrange,
              ),
            ),
            const SizedBox(height: 30),
            // App Name
            const Text(
              'Sadhana',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            // Status Text
            Text(
              controller.authenticationFailed.value
                  ? 'Authentication Failed'
                  : controller.isAuthenticating.value
                      ? 'Please Authenticate'
                      : 'Track Your Spiritual Journey',
              style: TextStyle(
                fontSize: 16,
                color: controller.authenticationFailed.value 
                    ? Colors.red[200]
                    : Colors.white70,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 50),
            // Loading Indicator or Action Buttons
            if (controller.authenticationFailed.value) ...[
              ElevatedButton.icon(
                onPressed: controller.retryBiometricAuth,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: controller.skipBiometricAndLogout,
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ] else ...[
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ],
          ],
        )),
      ),
    );
  }
}
