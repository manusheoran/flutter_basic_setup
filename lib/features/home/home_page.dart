import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'home_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/services/auth_service.dart';
import '../../widgets/improved_ios_pickers.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Sadhana Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              Get.find<AuthService>().signOut();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateSelector(controller),
              const SizedBox(height: AppConstants.kSpacingL),
              _buildScoreCard(controller),
              const SizedBox(height: AppConstants.kSpacingL),
              _buildActivityCards(controller, context),
              const SizedBox(height: AppConstants.kSpacingXL),
              _buildSaveButton(controller),
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDateSelector(HomeController controller) {
    return Obx(() => Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.kSpacingM),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                controller.selectedDate.value = controller.selectedDate.value.subtract(const Duration(days: 1));
                controller.loadActivityForDate(controller.selectedDate.value);
              },
            ),
            Text(
              DateFormat('MMM dd, yyyy').format(controller.selectedDate.value),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                if (controller.selectedDate.value.isBefore(DateTime.now())) {
                  controller.selectedDate.value = controller.selectedDate.value.add(const Duration(days: 1));
                  controller.loadActivityForDate(controller.selectedDate.value);
                }
              },
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildScoreCard(HomeController controller) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(AppConstants.kSpacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.getScoreColor(controller.percentage.value),
            AppColors.getScoreColor(controller.percentage.value).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.kRadiusL),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text(
                'Total Score',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                controller.totalScore.value.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '/ ${AppConstants.maxTotalScore}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 60,
            color: Colors.white30,
          ),
          Column(
            children: [
              const Text(
                'Percentage',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                '${controller.percentage.value.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildActivityCards(HomeController controller, BuildContext context) {
    return Column(
      children: [
        ImprovedIOSTimePicker(
          title: '🌙 Nindra (Sleep Time)',
          selectedTime: controller.nindraTime,
          onTimeChanged: (val) {
            controller.nindraTime.value = val;
            controller.calculateScores();
          },
        ),
        const SizedBox(height: AppConstants.kSpacingM),
        ImprovedIOSTimePicker(
          title: '🌅 Wake Up Time',
          selectedTime: controller.wakeUpTime,
          onTimeChanged: (val) {
            controller.wakeUpTime.value = val;
            controller.calculateScores();
          },
        ),
        const SizedBox(height: AppConstants.kSpacingM),
        ImprovedIOSDurationPicker(
          title: '😴 Day Sleep',
          subtitle: 'Duration in minutes',
          value: controller.daySleepMinutes,
          onChanged: (val) {
            controller.daySleepMinutes.value = val;
            controller.calculateScores();
          },
          maxValue: 240,
          unit: 'min',
        ),
        const SizedBox(height: AppConstants.kSpacingM),
        ImprovedIOSRoundsPicker(
          title: '📿 Japa',
          value: controller.japaRounds,
          onChanged: (val) {
            controller.japaRounds.value = val;
            controller.calculateScores();
          },
        ),
        const SizedBox(height: AppConstants.kSpacingM),
        ImprovedIOSDurationPicker(
          title: '📖 Pathan (Reading)',
          subtitle: 'Duration in minutes',
          value: controller.pathanMinutes,
          onChanged: (val) {
            controller.pathanMinutes.value = val;
            controller.calculateScores();
          },
          maxValue: 180,
          unit: 'min',
        ),
        const SizedBox(height: AppConstants.kSpacingM),
        ImprovedIOSDurationPicker(
          title: '👂 Sravan (Listening)',
          subtitle: 'Duration in minutes',
          value: controller.sravanMinutes,
          onChanged: (val) {
            controller.sravanMinutes.value = val;
            controller.calculateScores();
          },
          maxValue: 180,
          unit: 'min',
        ),
        const SizedBox(height: AppConstants.kSpacingM),
        ImprovedIOSHoursPicker(
          title: '🙏 Seva (Service)',
          value: controller.sevaHours,
          onChanged: (val) {
            controller.sevaHours.value = val;
            controller.calculateScores();
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton(HomeController controller) {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: controller.isSaving.value
            ? null
            : () => controller.saveActivity(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
          ),
        ),
        child: controller.isSaving.value
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Save Activity',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    ));
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: AppColors.primaryOrange,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      onTap: (index) {
        if (index == 1) Get.toNamed('/dashboard');
        if (index == 2) Get.toNamed('/settings');
      },
    );
  }
}
