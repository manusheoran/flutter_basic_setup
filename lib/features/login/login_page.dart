import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.kSpacingL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeroSection(context),
                const SizedBox(height: AppConstants.kSpacingXL),
                Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(AppConstants.kSpacingXL),
                  decoration: BoxDecoration(
                    color: AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(AppConstants.kRadiusXL),
                    border: Border.all(
                      color: AppColors.lightBorder,
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 20,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Obx(
                    () => controller.isSignUpMode.value
                        ? _buildSignUpForm(context)
                        : _buildLoginForm(context),
                  ),
                ),
                const SizedBox(height: AppConstants.kSpacingL),
                _buildModeToggleRow(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children:  [
        // Email Field
        TextField(
          controller: controller.emailController,
          decoration: _fieldDecoration(
            label: 'Email',
            hint: 'Enter your email',
            prefixIcon: Icons.email_outlined,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppConstants.kSpacingM),

        // Password Field
        Obx(() => TextField(
              controller: controller.passwordController,
              decoration: _fieldDecoration(
                label: 'Password',
                hint: 'Enter your password',
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordHidden.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
              ),
              obscureText: controller.isPasswordHidden.value,
            )),
        const SizedBox(height: AppConstants.kSpacingS),

        // Forgot Password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: controller.showForgotPasswordDialog,
            child: Text(
              'Forgot password?',
              style: AppTextStyles.bodySmall(context).copyWith(
                color: AppColors.primaryOrange,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.kSpacingL),

        // Login Button
        Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.login,
                style: _primaryButtonStyle(),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Log In'),
              ),
            )),
        const SizedBox(height: AppConstants.kSpacingM),

        // Divider with OR
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.kSpacingM),
              child: Text(
                'OR',
                style: AppTextStyles.bodySmall(context).copyWith(
                  color: AppColors.lightTextSecondary,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: AppConstants.kSpacingM),

        // Google Sign-In Button
        Obx(() => SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.signInWithGoogle,
                style: _secondaryButtonStyle(),
                icon: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Image.network(
                        'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                        height: 24,
                        width: 24,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.login),
                      ),
                label: const Text('Continue with Google'),
              ),
            )),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Obx(() {
      final isSignUp = controller.isSignUpMode.value;
      final iconData = isSignUp ? Icons.person_add : Icons.wb_sunny;
      final title = isSignUp ? 'Create Account' : 'Welcome Back';

      return Column(
        children: [
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
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              iconData,
              size: 56,
              color: AppColors.primaryOrange,
            ),
          ),
          const SizedBox(height: AppConstants.kSpacingL),
          Text(
            title,
            style: AppTextStyles.heading1(context).copyWith(
              color: AppColors.textOrange,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    });
  }

  Widget _buildModeToggleRow(BuildContext context) {
    return Obx(() {
      final isSignUp = controller.isSignUpMode.value;
      final prompt = isSignUp ? 'Already have an account? ' : "Don't have an account? ";
      final actionLabel = isSignUp ? 'Log In' : 'Sign Up';

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            prompt,
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: AppColors.lightTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextButton(
            onPressed: controller.toggleMode,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryOrange,
              textStyle: AppTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(actionLabel),
          ),
        ],
      );
    });
  }

  Widget _buildSignUpForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name Field
        TextField(
          controller: controller.nameController,
          decoration: _fieldDecoration(
            label: 'Name',
            hint: 'Enter your name',
            prefixIcon: Icons.person_outline,
          ),
        ),
        const SizedBox(height: AppConstants.kSpacingM),

        // Email Field
        TextField(
          controller: controller.emailController,
          decoration: _fieldDecoration(
            label: 'Email',
            hint: 'Enter your email',
            prefixIcon: Icons.email_outlined,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppConstants.kSpacingM),

        // Password Field
        Obx(() => TextField(
              controller: controller.passwordController,
              decoration: _fieldDecoration(
                label: 'Password',
                hint: 'Create a password',
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordHidden.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
              ),
              obscureText: controller.isPasswordHidden.value,
            )),
        const SizedBox(height: AppConstants.kSpacingM),

        // Sign Up Button
        Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.signUp,
                style: _primaryButtonStyle(),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Sign Up'),
              ),
            )),
      ],
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
        borderSide:
            const BorderSide(color: AppColors.primaryOrange, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.kSpacingM,
        vertical: AppConstants.kSpacingS,
      ),
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryOrange,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
      ),
    );
  }

  ButtonStyle _secondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 12),
      side: const BorderSide(color: AppColors.lightBorder),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
      ),
      foregroundColor: AppColors.lightTextPrimary,
    );
  }
}
