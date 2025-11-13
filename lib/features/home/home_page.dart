import 'dart:ui';

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

        return CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _HomeHeaderDelegate(
                maxExtentHeight: 246,
                minExtentHeight: 148,
                dateSelectorBuilder: (context, progress) =>
                    _buildDateSelector(controller, progress),
                scoreCardBuilder: (context, progress) =>
                    _buildScoreCard(controller, progress),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppConstants.kDefaultPadding,
                  AppConstants.kSpacingS,
                  AppConstants.kDefaultPadding,
                  AppConstants.kSpacingS,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child:
                          Divider(color: AppColors.lightBorder, thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.kSpacingS,
                      ),
                      child: const Text(
                        'Activity',
                        style: TextStyle(
                          color: AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Expanded(
                      child:
                          Divider(color: AppColors.lightBorder, thickness: 1),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppConstants.kDefaultPadding,
                AppConstants.kSpacingS,
                AppConstants.kDefaultPadding,
                AppConstants.kSpacing3XL + 72,
              ),
              sliver: SliverToBoxAdapter(
                child: _buildActivityCards(controller, context),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUnsavedChangesBar(controller),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _buildBottomNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(
      HomeController controller, double collapseProgress) {
    final bool isCollapsed = collapseProgress > 0.45;

    if (isCollapsed) {
      return Obx(() {
        final visibleDates = controller.visibleDates;
        final selectedKey =
            DateFormat('yyyy-MM-dd').format(controller.selectedDate.value);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.kSpacingS,
            vertical: AppConstants.kSpacingXS,
          ),
          decoration: null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: visibleDates.map((date) {
                          final key = DateFormat('yyyy-MM-dd').format(date);
                          final bool isSelected = key == selectedKey;
                          final bool isToday = key ==
                              DateFormat('yyyy-MM-dd').format(DateTime.now());
                          return Padding(
                            padding: const EdgeInsets.only(
                                right: AppConstants.kSpacingS),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.kRadiusFull),
                              onTap: () => controller.changeDate(date),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.kSpacingM,
                                  vertical: AppConstants.kSpacingXS,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryOrange
                                      : AppColors.lightPeach,
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.kRadiusFull),
                                ),
                                child: Text(
                                  isToday
                                      ? 'Today'
                                      : DateFormat('EEE, dd').format(date),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_calendar_outlined, size: 20),
                    color: AppColors.primaryOrange,
                    onPressed: () async {
                      final context = Get.context;
                      if (context == null) return;
                      final earliestDate = DateTime.now().subtract(
                        Duration(days: AppConstants.datePickerLookbackDays),
                      );
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: controller.selectedDate.value,
                        firstDate: earliestDate,
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        controller.changeDate(pickedDate);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      });
    }

    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SingleChildScrollView(
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
                          padding: const EdgeInsets.only(right: 10),
                          child: InkWell(
                            onTap: () => controller.changeDate(date),
                            borderRadius:
                                BorderRadius.circular(AppConstants.kRadiusM),
                            child: AnimatedContainer(
                              width: 80,
                              alignment: Alignment.center,
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryOrange
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.kRadiusM,
                                ),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryOrange
                                      : AppColors.lightBorder.withOpacity(0.5),
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primaryOrange
                                              .withOpacity(0.3),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateFormat('EEE')
                                        .format(date)
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('dd').format(date),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? (isSelected
                                              ? Colors.white.withOpacity(0.2)
                                              : AppColors.accentPeach
                                                  .withOpacity(0.6))
                                          : Colors.white.withOpacity(0.0),
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.kRadiusFull,
                                      ),
                                    ),
                                    child: Text(
                                      isToday
                                          ? 'Today'
                                          : DateFormat('MMM').format(date),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.primaryOrange,
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
                ),
                const SizedBox(width: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
                  onTap: () async {
                    final currentContext = Get.context;
                    if (currentContext == null) return;

                    final earliestDate = DateTime.now().subtract(
                      Duration(days: AppConstants.datePickerLookbackDays),
                    );

                    final pickedDate = await showDatePicker(
                      context: currentContext,
                      initialDate: controller.selectedDate.value,
                      firstDate: earliestDate,
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      controller.changeDate(pickedDate);
                    }
                  },
                  child: AnimatedContainer(
                    width: 68,
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: controller.visibleDates.any((d) =>
                              DateFormat('yyyy-MM-dd').format(d) ==
                              DateFormat('yyyy-MM-dd')
                                  .format(controller.selectedDate.value))
                          ? Colors.white
                          : AppColors.primaryOrange,
                      borderRadius:
                          BorderRadius.circular(AppConstants.kRadiusM),
                      border: Border.all(
                        color: controller.visibleDates.any((d) =>
                                DateFormat('yyyy-MM-dd').format(d) ==
                                DateFormat('yyyy-MM-dd')
                                    .format(controller.selectedDate.value))
                            ? AppColors.lightBorder.withOpacity(0.5)
                            : AppColors.primaryOrange,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.edit_calendar_outlined,
                          size: 18,
                          color: controller.visibleDates.any((d) =>
                                  DateFormat('yyyy-MM-dd').format(d) ==
                                  DateFormat('yyyy-MM-dd')
                                      .format(controller.selectedDate.value))
                              ? AppColors.primaryOrange
                              : Colors.white,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pick',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: controller.visibleDates.any((d) =>
                                    DateFormat('yyyy-MM-dd').format(d) ==
                                    DateFormat('yyyy-MM-dd')
                                        .format(controller.selectedDate.value))
                                ? AppColors.primaryOrange
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (!controller.visibleDates.any((d) =>
                            DateFormat('yyyy-MM-dd').format(d) ==
                            DateFormat('yyyy-MM-dd')
                                .format(controller.selectedDate.value)))
                          Text(
                            DateFormat('dd MMM')
                                .format(controller.selectedDate.value),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildScoreCard(HomeController controller, double collapseProgress) {
    return Obx(() {
      final double percentageValue = controller.percentage.value.isNaN
          ? 0.0
          : controller.percentage.value.clamp(0.0, 100.0);
      final bool showCompact = collapseProgress > 0.35;

      final totalScore = controller.totalScore.value.toStringAsFixed(1);
      final maxScore = controller.maxTotalScore.value.toStringAsFixed(0);
      final percentLabel = percentageValue.toStringAsFixed(1);

      final double paddingVertical = showCompact ? 8.0 : AppConstants.kSpacingS;
      final double valueFontSize = showCompact ? 18 : 28;
      final double percentFontSize = showCompact ? 18 : 28;
      final double dividerHeight = showCompact ? 30 : 60;

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.kRadiusXL),
          gradient: LinearGradient(
            colors: [
              AppColors.lightPeach,
              AppColors.lightSurface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.lightOrangeWarning.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 10,
              offset: Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 6,
              offset: Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.kSpacingL,
            vertical: paddingVertical,
          ),
          child: showCompact
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          totalScore,
                          style: TextStyle(
                            color: AppColors.primaryOrange,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          '/$maxScore',
                          style: TextStyle(
                            color: AppColors.lightTextSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$percentLabel%',
                      style: TextStyle(
                        color: AppColors.primaryOrange,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ScoreColumn(
                        title: 'Total Points',
                        value: totalScore,
                        subtitle: 'of $maxScore points',
                        valueFontSize: valueFontSize,
                        compact: showCompact,
                        alignment: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: showCompact
                            ? AppConstants.kSpacingS
                            : AppConstants.kSpacingM,
                      ),
                      child: Container(
                        width: 1,
                        height: dividerHeight,
                        color: AppColors.lightBorder,
                      ),
                    ),
                    Expanded(
                      child: _ScoreColumn(
                        title: 'Completion',
                        value: '$percentLabel%',
                        subtitle: '',
                        valueFontSize: percentFontSize,
                        compact: showCompact,
                        alignment: TextAlign.center,
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }

  Widget _buildActivityWithScore(
      HomeController controller, Widget activityWidget, String activityKey,
      {required String title, required IconData icon, required Color color}) {
    return Obx(() {
      final bool canEdit = controller.canEditSelectedDate;
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
        score: score,
        maxScore: maxScore,
        child: _wrapActivityChild(activityWidget, canEdit, controller),
      );
    });
  }

  Widget _wrapActivityChild(
      Widget child, bool canEdit, HomeController controller) {
    if (child is TimestampPicker) {
      return TimestampPicker(
        title: child.title,
        selectedTime: child.selectedTime,
        onTimeChanged: child.onTimeChanged,
        minTime: child.minTime,
        defaultTime: child.defaultTime,
        enabled: canEdit,
        onDisabledTap: controller.notifyEditNotAllowed,
      );
    } else if (child is DurationPicker) {
      return DurationPicker(
        title: child.title,
        subtitle: child.subtitle,
        value: child.value,
        onChanged: child.onChanged,
        maxHours: child.maxHours,
        enabled: canEdit,
        onDisabledTap: controller.notifyEditNotAllowed,
      );
    } else if (child is RoundsPicker) {
      return RoundsPicker(
        title: child.title,
        value: child.value,
        onChanged: child.onChanged,
        enabled: canEdit,
        onDisabledTap: controller.notifyEditNotAllowed,
      );
    } else if (child is Column) {
      return Column(
        mainAxisSize: child.mainAxisSize,
        mainAxisAlignment: child.mainAxisAlignment,
        crossAxisAlignment: child.crossAxisAlignment,
        children: child.children
            .map((widget) => _wrapActivityChild(widget, canEdit, controller))
            .toList(),
      );
    }
    return child;
  }

  Widget _buildActivityCards(HomeController controller, BuildContext context) {
    return Obx(() {
      final bool canEdit = controller.canEditSelectedDate;
      final bool showPlaceholder =
          !canEdit && controller.documentNotFound.value;

      if (showPlaceholder) {
        return _buildNoActivityPlaceholder();
      }

      return Column(
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

          // Japa with time and rounds in the same card
          if (controller.shouldShowActivity('japa')) ...[
            _buildActivityWithScore(
              controller,
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TimestampPicker(
                    title: '',
                    selectedTime: controller.japaTime,
                    onTimeChanged: (val) {
                      controller.japaTime.value = val;
                      controller.calculateScores();
                    },
                    defaultTime: '07:00',
                  ),
                  const SizedBox(height: AppConstants.kSpacingS),
                  RoundsPicker(
                    title: 'Rounds (Optional)',
                    value: controller.japaRounds,
                    onChanged: (val) {
                      controller.japaRounds.value = val;
                    },
                  ),
                ],
              ),
              'japa',
              title: 'Japa (Chanting)',
              icon: Icons.self_improvement,
              color: AppColors.activityJapa,
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
      );
    });
  }

  Widget _buildNoActivityPlaceholder() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.kDefaultPadding,
        vertical: AppConstants.kSpacingL,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.kSpacingL),
            decoration: BoxDecoration(
              color: AppColors.lightPeach,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy,
              size: 40,
              color: AppColors.primaryOrange,
            ),
          ),
          const SizedBox(height: AppConstants.kSpacingL),
          const Text(
            'No activity recorded for this day',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.kSpacingS),
          const Text(
            'This date is locked for editing. Activity tracking resumes on allowed dates.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsavedChangesBar(HomeController controller) {
    return Obx(() {
      final showBar = controller.hasUnsavedChanges.value;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: showBar ? null : 0,
        child: showBar
            ? SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppConstants.kDefaultPadding,
                    right: AppConstants.kDefaultPadding,
                    bottom: AppConstants.kSpacingXS,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.kSpacingM,
                      vertical: AppConstants.kSpacingS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.sageLight,
                      borderRadius:
                          BorderRadius.circular(AppConstants.kRadiusXL),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowMedium,
                          blurRadius: 14,
                          offset: Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.accentSage.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.coralDanger.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.pending_actions,
                            color: AppColors.coralDanger,
                          ),
                        ),
                        const SizedBox(width: AppConstants.kSpacingM),
                        Expanded(
                          child: Text(
                            'Progress updated',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.deepTeal,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: controller.isSaving.value
                              ? null
                              : controller.discardChanges,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.coralDanger,
                          ),
                          child: const Text('Discard'),
                        ),
                        const SizedBox(width: AppConstants.kSpacingS),
                        ElevatedButton(
                          onPressed: controller.isSaving.value
                              ? null
                              : controller.saveActivity,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentSage,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.kSpacingL,
                              vertical: AppConstants.kSpacingS,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppConstants.kRadiusL),
                            ),
                          ),
                          child: controller.isSaving.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      );
    });
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

class _ScoreColumn extends StatelessWidget {
  const _ScoreColumn({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.valueFontSize,
    required this.compact,
    required this.alignment,
  });

  final String title;
  final String value;
  final String subtitle;
  final double valueFontSize;
  final bool compact;
  final TextAlign alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment == TextAlign.end
          ? CrossAxisAlignment.end
          : (alignment == TextAlign.center
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start),
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textOrange,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
          textAlign: alignment,
        ),
        SizedBox(height: compact ? 1 : 6),
        Text(
          value,
          style: TextStyle(
            color: AppColors.primaryOrange,
            fontSize: valueFontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
          ),
          textAlign: alignment,
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w400,
            ),
            textAlign: alignment,
          ),
        ],
      ],
    );
  }
}

class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  _HomeHeaderDelegate({
    required this.maxExtentHeight,
    required this.minExtentHeight,
    required this.dateSelectorBuilder,
    required this.scoreCardBuilder,
  });

  final double maxExtentHeight;
  final double minExtentHeight;
  final Widget Function(BuildContext, double) dateSelectorBuilder;
  final Widget Function(BuildContext, double) scoreCardBuilder;

  @override
  double get maxExtent => maxExtentHeight;

  @override
  double get minExtent => minExtentHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double availableExtent = (maxExtentHeight - shrinkOffset)
        .clamp(minExtentHeight, maxExtentHeight);
    final double normalized = ((availableExtent - minExtentHeight) /
            (maxExtentHeight - minExtentHeight))
        .clamp(0.0, 1.0);
    final double collapseT = 1 - normalized;

    final EdgeInsets padding = EdgeInsets.fromLTRB(
      AppConstants.kDefaultPadding,
      lerpDouble(AppConstants.kSpacingS, AppConstants.kSpacingXS, collapseT)!,
      AppConstants.kDefaultPadding,
      lerpDouble(AppConstants.kSpacingS, AppConstants.kSpacingXS, collapseT)!,
    );

    final double spacing =
        lerpDouble(AppConstants.kSpacingS, AppConstants.kSpacingXS, collapseT)!;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: availableExtent,
          child: Padding(
            padding: padding,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: dateSelectorBuilder(context, collapseT),
                    ),
                    SizedBox(height: spacing),
                    Align(
                      alignment: Alignment.topCenter,
                      child: scoreCardBuilder(context, collapseT),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HomeHeaderDelegate oldDelegate) {
    return maxExtentHeight != oldDelegate.maxExtentHeight ||
        minExtentHeight != oldDelegate.minExtentHeight ||
        dateSelectorBuilder != oldDelegate.dateSelectorBuilder ||
        scoreCardBuilder != oldDelegate.scoreCardBuilder;
  }
}
