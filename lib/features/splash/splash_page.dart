import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'splash_controller.dart';

class SplashPage extends StatelessWidget {
  SplashPage({super.key});
  
  final SplashController controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Center(
        child: Obx(() {
          final isAuthFailed = controller.authenticationFailed.value;
          final isAuthenticating = controller.isAuthenticating.value;

          return Container(
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.all(AppConstants.kSpacingXL),
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(AppConstants.kRadiusXL),
              border: Border.all(
                color: AppColors.primaryOrange.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowMedium,
                  blurRadius: 18,
                  offset: Offset(0, 12),
                ),
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Logo/Icon
                Container(
                  padding: const EdgeInsets.all(AppConstants.kSpacingL),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.sageLight,
                    border: Border.all(
                      color: AppColors.accentSage.withOpacity(0.6),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentSage.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    isAuthenticating ? Icons.fingerprint : Icons.self_improvement,
                    size: 64,
                    color: AppColors.primaryOrange,
                  ),
                ),
                const SizedBox(height: AppConstants.kSpacingL),
                // App Name
                Text(
                  'Sādhana',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textOrange,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppConstants.kSpacingS),
                // Status Text
                Text(
                  isAuthFailed
                      ? 'Authentication failed'
                      : isAuthenticating
                          ? 'Please authenticate to continue'
                          : 'Track your spiritual journey',
                  style: TextStyle(
                    fontSize: 14,
                    color: isAuthFailed ? AppColors.coralDanger : AppColors.deepTeal,
                    letterSpacing: 0.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.kSpacingXL),
                if (isAuthFailed) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.retryBiometricAuth,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry Authentication'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.kSpacingM),
                  TextButton(
                    onPressed: controller.skipBiometricAndLogout,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryOrange,
                    ),
                    child: const Text('Sign out instead'),
                  ),
                ] else ...[
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
                    strokeWidth: 3,
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}
