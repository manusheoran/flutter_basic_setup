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
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.kRadiusL),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(AppConstants.kSpacingXL),
                child: Obx(() => controller.isSignUpMode.value
                    ? _buildSignUpForm(context)
                    : _buildLoginForm(context)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children:  [
        // Sun Icon
        Container(
          padding: const EdgeInsets.all(AppConstants.kSpacingL),
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.wb_sunny,
            size: 60,
            color: AppColors.primaryOrange,
          ),
        ),
        const SizedBox(height: AppConstants.kSpacingL),
        
        // Welcome Back
        Text(
          'Welcome Back',
          style: AppTextStyles.heading1(context),
        ),
        const SizedBox(height: AppConstants.kSpacingXL),
        
        // Email Field
        TextField(
          controller: controller.emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppConstants.kSpacingM),
        
        // Password Field
        Obx(() => TextField(
          controller: controller.passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            prefixIcon: const Icon(Icons.lock_outline),
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
            onPressed: () {
              // TODO: Implement forgot password
            },
            child: Text(
              'Forgot password?',
              style: AppTextStyles.bodySmall(context),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.kSpacingL),
        
        // Login Button
        Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.login,
            child: controller.isLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Log In'),
          ),
        )),
        const SizedBox(height: AppConstants.kSpacingM),
        
        // Sign Up Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: AppTextStyles.bodyMedium(context),
            ),
            TextButton(
              onPressed: controller.toggleMode,
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignUpForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(AppConstants.kSpacingL),
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_add,
            size: 60,
            color: AppColors.primaryOrange,
          ),
        ),
        const SizedBox(height: AppConstants.kSpacingL),
        
        // Create Account
        Text(
          'Create Account',
          style: AppTextStyles.heading1(context),
        ),
        const SizedBox(height: AppConstants.kSpacingXL),
        
        // Name Field
        TextField(
          controller: controller.nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Enter your name',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: AppConstants.kSpacingM),
        
        // Email Field
        TextField(
          controller: controller.emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppConstants.kSpacingM),
        
        // Password Field
        Obx(() => TextField(
          controller: controller.passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Create a password',
            prefixIcon: const Icon(Icons.lock_outline),
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
        const SizedBox(height: AppConstants.kSpacingL),
        
        // Sign Up Button
        Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.signUp,
            child: controller.isLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Sign Up'),
          ),
        )),
        const SizedBox(height: AppConstants.kSpacingM),
        
        // Login Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: AppTextStyles.bodyMedium(context),
            ),
            TextButton(
              onPressed: controller.toggleMode,
              child: const Text('Log In'),
            ),
          ],
        ),
      ],
    );
  }
}
