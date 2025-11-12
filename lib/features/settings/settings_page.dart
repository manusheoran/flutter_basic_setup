import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/services/auth_service.dart';
import 'profile_edit_dialog.dart';
import 'scoring_rules_page.dart';
import 'parameter_tracking_page.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});
  
  final SettingsController controller = Get.put(SettingsController());
  final AuthService _authService = Get.find<AuthService>();

  @override
  Widget build(BuildContext context) {
    // Load user if not already loaded
    _ensureUserLoaded();
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false, // Remove back button
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(context),
            const SizedBox(height: AppConstants.kSpacingL),
            _buildActivityTrackingCard(),
            const SizedBox(height: AppConstants.kSpacingL),
            _buildScoringRulesCard(),
            const SizedBox(height: AppConstants.kSpacingL),
            _buildSecurityCard(context),
            const SizedBox(height: AppConstants.kSpacingL),
            _buildThemeCard(),
            const SizedBox(height: AppConstants.kSpacingL),
            _buildMentorCard(),
            const SizedBox(height: AppConstants.kSpacingL),
            _buildLogoutButton(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Obx(() {
      final user = Get.find<AuthService>().currentUser.value;
      
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.kRadiusL),
          border: Border.all(
            color: AppColors.lightBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.kSpacingL),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColors.primaryOrange,
                  child: Text(
                    user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.kSpacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'User',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          user?.role?.toUpperCase() ?? 'USER',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    print('🔧 Edit button clicked');
                    if (user == null) {
                      print('❌ User is null');
                      Get.snackbar(
                        'Error',
                        'User profile not loaded',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    
                    print('✅ Opening profile edit dialog for: ${user.name}');
                    await showDialog(
                      context: context,
                      builder: (ctx) => ProfileEditDialog(user: user),
                    );
                  },
                  icon: const Icon(Icons.edit, color: AppColors.primaryOrange),
                  tooltip: 'Edit Profile',
                ),
              ],
            ),
            if (user?.phoneNumber != null || user?.occupation != null || user?.gender != null) ...[
              const Divider(height: 24),
              Column(
                children: [
                  if (user?.phoneNumber != null)
                    _buildInfoRow(Icons.phone, 'Phone', user!.phoneNumber!),
                  if (user?.occupation != null)
                    _buildInfoRow(Icons.work, 'Occupation', user!.occupation!),
                  if (user?.gender != null)
                    _buildInfoRow(Icons.wc, 'Gender', user!.gender!),
                ],
              ),
            ],
          ],
        ),
      ),
      );
    });
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.kSpacingM),
        child: Obx(() {
          final user = _authService.firebaseUser.value;
          final isEmailProvider = user?.providerData.any((p) => p.providerId == 'password') ?? false;
          final isEmailVerified = user?.emailVerified ?? true;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Security',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppConstants.kSpacingM),
              
              // Email Verification Status (only for email/password users)
              if (isEmailProvider && !isEmailVerified) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Email Not Verified',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Please verify your email to secure your account',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.email, size: 18),
                          label: const Text('Resend Verification Email'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                          ),
                          onPressed: () async {
                            final error = await _authService.resendVerificationEmail();
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
                                'Verification email sent! Check your inbox.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
              ],
              
              // Reset Password (only for email/password users)
              if (isEmailProvider) ...[
                ListTile(
                  leading: const Icon(Icons.lock_reset),
                  title: const Text('Reset Password'),
                  subtitle: const Text('Change your password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showResetPasswordDialog(context),
                ),
                const Divider(),
              ],
              
            ],
          );
        }),
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context) {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    final RxBool isLoading = false.obs;
    final RxBool showCurrentPassword = false.obs;
    final RxBool showNewPassword = false.obs;
    final RxBool showConfirmPassword = false.obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Reset Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => TextField(
                controller: currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  hintText: 'Enter current password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showCurrentPassword.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () => showCurrentPassword.value = !showCurrentPassword.value,
                  ),
                ),
                obscureText: !showCurrentPassword.value,
              )),
              const SizedBox(height: 16),
              Obx(() => TextField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter new password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showNewPassword.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () => showNewPassword.value = !showNewPassword.value,
                  ),
                ),
                obscureText: !showNewPassword.value,
              )),
              const SizedBox(height: 16),
              Obx(() => TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  hintText: 'Confirm new password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showConfirmPassword.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () => showConfirmPassword.value = !showConfirmPassword.value,
                  ),
                ),
                obscureText: !showConfirmPassword.value,
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              currentPasswordController.dispose();
              newPasswordController.dispose();
              confirmPasswordController.dispose();
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
            onPressed: isLoading.value
                ? null
                : () async {
                    final currentPassword = currentPasswordController.text;
                    final newPassword = newPasswordController.text;
                    final confirmPassword = confirmPasswordController.text;

                    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Please fill in all fields',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    if (newPassword != confirmPassword) {
                      Get.snackbar(
                        'Error',
                        'New passwords do not match',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    if (newPassword.length < 6) {
                      Get.snackbar(
                        'Error',
                        'Password must be at least 6 characters',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    isLoading.value = true;

                    final error = await _authService.resetPassword(
                      currentPassword: currentPassword,
                      newPassword: newPassword,
                    );

                    isLoading.value = false;

                    Get.back(); // Close dialog

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
                        'Password updated successfully',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    }

                    currentPasswordController.dispose();
                    newPasswordController.dispose();
                    confirmPasswordController.dispose();
                  },
            child: isLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Update Password'),
          )),
        ],
      ),
    );
  }

  Widget _buildThemeCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.kRadiusL),
        border: Border.all(
          color: AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.kSpacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appearance',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppConstants.kSpacingM),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              trailing: Obx(() => Switch(
                value: controller.isDarkMode.value,
                onChanged: (value) => controller.toggleTheme(),
                activeColor: AppColors.primaryOrange,
              )),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              subtitle: Obx(() => Text(controller.selectedLanguage.value)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageDialog(),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: controller.selectedLocale.value,
              onChanged: (value) async {
                await controller.changeLanguage('English', 'en');
                Get.back();
              },
              activeColor: AppColors.primaryOrange,
            )),
            Obx(() => RadioListTile<String>(
              title: const Text('हिंदी (Hindi)'),
              value: 'hi',
              groupValue: controller.selectedLocale.value,
              onChanged: (value) async {
                await controller.changeLanguage('हिंदी', 'hi');
                Get.back();
              },
              activeColor: AppColors.primaryOrange,
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTrackingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.kRadiusL),
        border: Border.all(
          color: AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.to(() => const ParameterTrackingPage()),
        borderRadius: BorderRadius.circular(AppConstants.kRadiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.kSpacingL),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.toggle_on,
                  color: AppColors.primaryOrange,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppConstants.kSpacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Set Parameter Tracking',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Configure which activities to track',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoringRulesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.kRadiusL),
        border: Border.all(
          color: AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.to(() => const ScoringRulesPage()),
        borderRadius: BorderRadius.circular(AppConstants.kRadiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.kSpacingL),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: AppColors.primaryOrange,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppConstants.kSpacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'View Scoring Rules',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Learn how points are calculated',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMentorCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.kRadiusL),
        border: Border.all(
          color: AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.kSpacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mentor Connection',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppConstants.kSpacingM),
            TextField(
              controller: controller.mentorIdController,
              decoration: InputDecoration(
                labelText: 'Mentor User ID',
                hintText: 'Enter your mentor\'s user ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.kRadiusS),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: AppConstants.kSpacingM),
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.isRequestingMentor.value
                    ? null
                    : () => controller.requestMentor(),
                icon: controller.isRequestingMentor.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: const Text('Request Mentor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Get.find<AuthService>().signOut();
        },
        icon: const Icon(Icons.logout),
        label: const Text('Log Out'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 2,
      selectedItemColor: AppColors.primaryOrange,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      onTap: (index) {
        if (index == 0) Get.toNamed('/home');
        if (index == 1) Get.toNamed('/dashboard');
      },
    );
  }

  void _ensureUserLoaded() {
    if (_authService.currentUser.value == null && _authService.currentUserId != null) {
      print('⚠️ Settings: User not loaded, loading now...');
      _authService.loadCurrentUser(_authService.currentUserId!);
    }
  }
}
