import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'home_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/parameter_service.dart';
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
    return Obx(() => Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.kSpacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Date',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: controller.visibleDates.map((date) {
                      final isSelected =
                          DateFormat('yyyy-MM-dd').format(date) ==
                              DateFormat('yyyy-MM-dd')
                                  .format(controller.selectedDate.value);
                      final isToday = DateFormat('yyyy-MM-dd').format(date) ==
                          DateFormat('yyyy-MM-dd').format(DateTime.now());

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () {
                            controller.selectedDate.value = date;
                            controller.loadActivityForDate(date);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryOrange
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: isToday
                                  ? Border.all(
                                      color: AppColors.primaryOrange, width: 2)
                                  : null,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  DateFormat('EEE').format(date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd').format(date),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                if (isToday)
                                  Text(
                                    'Today',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.primaryOrange,
                                      fontWeight: FontWeight.w600,
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
                AppColors.getScoreColor(controller.percentage.value)
                    .withOpacity(0.7),
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
                    '/ ${controller.maxTotalScore.value.toStringAsFixed(0)}',
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

  Widget _buildActivityWithScore(
      HomeController controller, Widget activityWidget, String activityKey) {
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

      return Stack(
        children: [
          activityWidget,
          if (score != 0)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: score < 0 ? Colors.red : AppColors.primaryOrange,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (score < 0 ? Colors.red : AppColors.primaryOrange)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      score < 0 ? Icons.arrow_downward : Icons.star,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${score.toStringAsFixed(0)}/${maxScore.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildActivityCards(HomeController controller, BuildContext context) {
    return Column(
      children: [
        // Timestamp Activities (with 12-hour format + AM/PM)
        _buildActivityWithScore(
          controller,
          TimestampPicker(
            title: '🌙 Nindra (To Bed)',
            selectedTime: controller.nindraTime,
            onTimeChanged: (val) {
              controller.nindraTime.value = val;
              controller.calculateScores();
            },
            minTime: '21:45', // 9:45 PM minimum
            defaultTime: '21:45',
          ),
          'nindra',
        ),
        const SizedBox(height: AppConstants.kSpacingM),
        _buildActivityWithScore(
          controller,
          TimestampPicker(
            title: '🌅 Wake Up Time',
            selectedTime: controller.wakeUpTime,
            onTimeChanged: (val) {
              controller.wakeUpTime.value = val;
              controller.calculateScores();
            },
            minTime: '03:45', // 3:45 AM minimum
            defaultTime: '03:45',
          ),
          'wake_up',
        ),
        const SizedBox(height: AppConstants.kSpacingM),

        // Duration Activities (Hours + Minutes, no AM/PM)
        _buildActivityWithScore(
          controller,
          DurationPicker(
            title: '😴 Day Sleep',
            subtitle: 'Total sleep during the day',
            value: controller.daySleepMinutes,
            onChanged: (val) {
              controller.daySleepMinutes.value = val;
              controller.calculateScores();
            },
            maxHours: 4, // Max 4 hours
          ),
          'day_sleep',
        ),
        const SizedBox(height: AppConstants.kSpacingM),

        // Japa with both rounds and completion time
        _buildActivityWithScore(
          controller,
          TimestampPicker(
            title: '📿 Japa',
            selectedTime: controller.japaTime,
            onTimeChanged: (val) {
              controller.japaTime.value = val;
              controller.calculateScores();
            },
            defaultTime: '07:00',
          ),
          'japa',
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

        _buildActivityWithScore(
          controller,
          DurationPicker(
            title: '📖 Pathan (Reading)',
            subtitle: 'Reading duration',
            value: controller.pathanMinutes,
            onChanged: (val) {
              controller.pathanMinutes.value = val;
              controller.calculateScores();
            },
            maxHours: 5, // Max 5 hours
          ),
          'pathan',
        ),
        const SizedBox(height: AppConstants.kSpacingM),
        _buildActivityWithScore(
          controller,
          DurationPicker(
            title: '👂 Sravan (Listening)',
            subtitle: 'Listening duration',
            value: controller.sravanMinutes,
            onChanged: (val) {
              controller.sravanMinutes.value = val;
              controller.calculateScores();
            },
            maxHours: 5, // Max 5 hours
          ),
          'sravan',
        ),
        const SizedBox(height: AppConstants.kSpacingM),
        _buildActivityWithScore(
          controller,
          DurationPicker(
            title: '🙏 Seva (Service)',
            subtitle: 'Service duration',
            value: controller.sevaMinutes,
            onChanged: (val) {
              controller.sevaMinutes.value = val;
              controller.calculateScores();
            },
            maxHours: 12, // Max 12 hours
          ),
          'seva',
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
