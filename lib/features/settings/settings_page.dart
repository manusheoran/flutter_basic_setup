import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/services/auth_service.dart';
import 'profile_edit_dialog.dart';

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
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(context),
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
      
      return Card(
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
            if (user?.phone != null || user?.occupation != null || user?.gender != null) ...[
              const Divider(height: 24),
              Column(
                children: [
                  if (user?.phone != null)
                    _buildInfoRow(Icons.phone, 'Phone', user!.phone!),
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

  Widget _buildThemeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.kSpacingM),
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

  Widget _buildMentorCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.kSpacingM),
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
