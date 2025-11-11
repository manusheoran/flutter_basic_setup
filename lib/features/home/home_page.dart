import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'home_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'widgets/activity_card_widget.dart';
import '../../data/services/parameter_service.dart';
import '../../data/services/auth_service.dart';
import '../../widgets/time_duration_pickers.dart';

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
        automaticallyImplyLeading: false, // Remove back button
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
    return Obx(() => Container(
          margin: const EdgeInsets.only(bottom: AppConstants.kSpacingM),
          decoration: BoxDecoration(
            color: AppColors.lightCardBackground,
            borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.kSpacingM,
              vertical: AppConstants.kSpacingS,
            ),
            child: Row(
              children: controller.visibleDates.map((date) {
                final isSelected = DateFormat('yyyy-MM-dd').format(date) ==
                    DateFormat('yyyy-MM-dd').format(controller.selectedDate.value);
                final isToday = DateFormat('yyyy-MM-dd').format(date) ==
                    DateFormat('yyyy-MM-dd').format(DateTime.now());

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      controller.selectedDate.value = date;
                      controller.setupActivityStream(date);
                    },
                    borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
                    child: Container(
                      width: 70,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.primaryOrange 
                            : AppColors.accentPeach,
                        borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
                        border: isToday && !isSelected
                            ? Border.all(color: AppColors.primaryOrange, width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('EEE').format(date),
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? Colors.white : AppColors.lightTextSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('dd').format(date),
                            style: TextStyle(
                              fontSize: 20,
                              color: isSelected ? Colors.white : AppColors.lightTextPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isToday)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.3)
                                    : AppColors.primaryOrange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Today',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isSelected ? Colors.white : AppColors.darkOrange,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ));
  }

  Widget _buildScoreCard(HomeController controller) {
    return Obx(() => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.kRadiusXL),
            gradient: LinearGradient(
              colors: [
                AppColors.getScoreColor(controller.percentage.value),
                AppColors.getScoreColor(controller.percentage.value).withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.getScoreColor(controller.percentage.value).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.kSpacingL,
              vertical: AppConstants.kSpacingM,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Score',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${controller.totalScore.value.toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'of ${controller.maxTotalScore.value.toStringAsFixed(0)} points',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: Colors.white.withOpacity(0.2),
                  margin: const EdgeInsets.symmetric(horizontal: AppConstants.kSpacingM),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Completion',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${controller.percentage.value.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'today',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildActivityWithScore(
      HomeController controller, Widget activityWidget, String activityKey,
      {required String title, required IconData icon, required Color color}) {
    return Obx(() {
      double score = 0;
      double maxScore = 0;

      switch (activityKey) {
        case 'nindra':
          score = controller.nindraTime.value.isNotEmpty
              ? Get.find<ParameterService>()
                  .calculateScore('nindra', controller.nindraTime.value)
              : 0;
          maxScore = Get.find<ParameterService>().getMaxPoints('nindra');
          break;
        case 'wake_up':
          score = controller.wakeUpTime.value.isNotEmpty
              ? Get.find<ParameterService>()
                  .calculateScore('wake_up', controller.wakeUpTime.value)
              : 0;
          maxScore = Get.find<ParameterService>().getMaxPoints('wake_up');
          break;
        case 'day_sleep':
          score = controller.daySleepMinutes.value > 0
              ? Get.find<ParameterService>()
                  .calculateScore('day_sleep', controller.daySleepMinutes.value)
              : 0;
          maxScore = Get.find<ParameterService>().getMaxPoints('day_sleep');
          break;
        case 'japa':
          score = controller.japaTime.value.isNotEmpty
              ? Get.find<ParameterService>()
                  .calculateScore('japa', controller.japaTime.value)
              : 0;
          maxScore = Get.find<ParameterService>().getMaxPoints('japa');
          break;
        case 'pathan':
          score = controller.pathanMinutes.value > 0
              ? Get.find<ParameterService>()
                  .calculateScore('pathan', controller.pathanMinutes.value)
              : 0;
          maxScore = Get.find<ParameterService>().getMaxPoints('pathan');
          break;
        case 'sravan':
          score = controller.sravanMinutes.value > 0
              ? Get.find<ParameterService>()
                  .calculateScore('sravan', controller.sravanMinutes.value)
              : 0;
          maxScore = Get.find<ParameterService>().getMaxPoints('sravan');
          break;
        case 'seva':
          score = controller.sevaMinutes.value > 0
              ? Get.find<ParameterService>()
                  .calculateScore('seva', controller.sevaMinutes.value)
              : 0;
          maxScore = Get.find<ParameterService>().getMaxPoints('seva');
          break;
      }

      return ActivityCardWidget(
        title: title,
        icon: icon,
        color: color,
        score: score != 0 ? score : null,
        maxScore: score != 0 ? maxScore : null,
        child: activityWidget,
      );
    });
  }

  Widget _buildActivityCards(HomeController controller, BuildContext context) {
    return Obx(() => Column(
      children: [
        // Timestamp Activities (with 12-hour format + AM/PM)
        if (controller.shouldShowActivity('nindra')) ...[
          _buildActivityWithScore(
            controller,
            TimestampPicker(
              title: '',
              selectedTime: controller.nindraTime,
              onTimeChanged: (val) {
                controller.nindraTime.value = val;
                controller.calculateScores();
              },
              minTime: '21:45', // 9:45 PM minimum
              defaultTime: '21:45',
            ),
            'nindra',
            title: 'Nindra (To Bed)',
            icon: Icons.bedtime,
            color: AppColors.activityNindra,
          ),
          const SizedBox(height: AppConstants.kSpacingM),
        ],
        
        if (controller.shouldShowActivity('wake_up')) ...[
          _buildActivityWithScore(
            controller,
            TimestampPicker(
              title: '',
              selectedTime: controller.wakeUpTime,
              onTimeChanged: (val) {
                controller.wakeUpTime.value = val;
                controller.calculateScores();
              },
              minTime: '03:45', // 3:45 AM minimum
              defaultTime: '03:45',
            ),
            'wake_up',
            title: 'Wake Up Time',
            icon: Icons.wb_sunny,
            color: AppColors.activityWakeUp,
          ),
          const SizedBox(height: AppConstants.kSpacingM),
        ],

        // Duration Activities (Hours + Minutes, no AM/PM)
        if (controller.shouldShowActivity('day_sleep')) ...[
          _buildActivityWithScore(
            controller,
            DurationPicker(
              title: '',
              subtitle: 'Total sleep during the day',
              value: controller.daySleepMinutes,
              onChanged: (val) {
                controller.daySleepMinutes.value = val;
                controller.calculateScores();
              },
              maxHours: 4, // Max 4 hours
            ),
            'day_sleep',
            title: 'Day Sleep',
            icon: Icons.hotel,
            color: AppColors.activityDaySleep,
          ),
          const SizedBox(height: AppConstants.kSpacingM),
        ],

        // Japa with both rounds and completion time
        if (controller.shouldShowActivity('japa')) ...[
          _buildActivityWithScore(
            controller,
            TimestampPicker(
              title: '',
              selectedTime: controller.japaTime,
              onTimeChanged: (val) {
                controller.japaTime.value = val;
                controller.calculateScores();
              },
              defaultTime: '07:00',
            ),
            'japa',
            title: 'Japa (Chanting)',
            icon: Icons.self_improvement,
            color: AppColors.activityJapa,
          ),
          const SizedBox(height: AppConstants.kSpacingS),
          RoundsPicker(
            title: '📿 Japa Rounds (optional)',
            value: controller.japaRounds,
            onChanged: (val) {
              controller.japaRounds.value = val;
            },
          ),
          const SizedBox(height: AppConstants.kSpacingM),
        ],

        if (controller.shouldShowActivity('pathan')) ...[
          _buildActivityWithScore(
            controller,
            DurationPicker(
              title: '',
              subtitle: 'Scripture reading time',
              value: controller.pathanMinutes,
              onChanged: (val) {
                controller.pathanMinutes.value = val;
                controller.calculateScores();
              },
              maxHours: 2, // Max 2 hours
            ),
            'pathan',
            title: 'Pathan (Reading)',
            icon: Icons.menu_book,
            color: AppColors.activityPathan,
          ),
          const SizedBox(height: AppConstants.kSpacingM),
        ],
        
        if (controller.shouldShowActivity('sravan')) ...[
          _buildActivityWithScore(
            controller,
            DurationPicker(
              title: '',
              subtitle: 'Spiritual audio/lecture time',
              value: controller.sravanMinutes,
              onChanged: (val) {
                controller.sravanMinutes.value = val;
                controller.calculateScores();
              },
              maxHours: 3, // Max 3 hours
            ),
            'sravan',
            title: 'Sravan (Listening)',
            icon: Icons.headset,
            color: AppColors.activitySravan,
          ),
          const SizedBox(height: AppConstants.kSpacingM),
        ],
        
        if (controller.shouldShowActivity('seva')) ...[
          _buildActivityWithScore(
            controller,
            DurationPicker(
              title: '',
              subtitle: 'Service hours',
              value: controller.sevaMinutes,
              onChanged: (val) {
                controller.sevaMinutes.value = val;
                controller.calculateScores();
              },
              maxHours: 12, // Max 12 hours
            ),
            'seva',
            title: 'Seva (Service)',
            icon: Icons.volunteer_activism,
            color: AppColors.activitySeva,
          ),
        ],
      ],
    ));
  }

  Widget _buildSaveButton(HomeController controller) {
    return Obx(() => Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
            borderRadius: BorderRadius.circular(AppConstants.kRadiusL),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryOrange.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: controller.isSaving.value
                ? null
                : () => controller.saveActivity(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.kRadiusL),
              ),
            ),
            child: controller.isSaving.value
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                : const Text(
                    'Save Activity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
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
