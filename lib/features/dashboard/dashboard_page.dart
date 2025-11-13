import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dashboard_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../reports/report_page.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false, // Remove back button
        title: const Text('My Dashboard'),
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
              _buildTabSelector(controller),
              const SizedBox(height: AppConstants.kSpacingL),
              _buildDateRangeSelector(controller, context),
              const SizedBox(height: AppConstants.kSpacingL),
              _buildAverageCards(controller),
              const SizedBox(height: AppConstants.kSpacingL),
              _buildLineChart(controller),
              const SizedBox(height: AppConstants.kSpacingL),
              _buildBarChart(controller),
              const SizedBox(height: AppConstants.kSpacingL),
              _buildRadarChart(controller),
              const SizedBox(height: AppConstants.kSpacingL),
              _buildActivityBreakdown(controller),
              const SizedBox(height: AppConstants.kSpacingL),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportPage(
                          initialStartDate: controller.startDate.value,
                          initialEndDate: controller.endDate.value,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export Reports'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryOrange,
                    side: const BorderSide(color: AppColors.primaryOrange),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTabSelector(DashboardController controller) {
    return Obx(() => Row(
          children: [
            Expanded(
              child: _buildTabButton(
                label: 'My Progress',
                isSelected: controller.selectedTab.value == 0,
                onTap: () => controller.changeTab(0),
              ),
            ),
            const SizedBox(width: AppConstants.kSpacingM),
            Expanded(
              child: _buildTabButton(
                label: 'Mentor View',
                isSelected: controller.selectedTab.value == 1,
                onTap: () => controller.changeTab(1),
              ),
            ),
          ],
        ));
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOrange : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
          border: Border.all(
            color: isSelected ? AppColors.primaryOrange : AppColors.lightBorder,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.lightTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector(
      DashboardController controller, BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Time Range',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildRangeChip('last7', 'Last 7 Days', controller, () {
                  final end = DateTime.now();
                  final start = end.subtract(const Duration(days: 6));
                  controller.selectDateRange(
                    type: 'last7',
                    label: 'Last 7 Days',
                    start: start,
                    end: end,
                  );
                }),
                _buildRangeChip('last30', 'Last 30 Days', controller, () {
                  final end = DateTime.now();
                  final start = end.subtract(const Duration(days: 29));
                  controller.selectDateRange(
                    type: 'last30',
                    label: 'Last 30 Days',
                    start: start,
                    end: end,
                  );
                }),
                _buildRangeChip('custom', 'Custom', controller, () async {
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now(),
                    initialDateRange: DateTimeRange(
                      start: controller.startDate.value,
                      end: controller.endDate.value,
                    ),
                  );
                  if (picked != null) {
                    controller.selectCustomDateRange(picked.start, picked.end);
                  }
                }),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              final summaryTitle = controller.selectedRangeLabel.value;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.sageLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.date_range,
                        color: AppColors.deepTeal, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            summaryTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.deepTeal,
                            ),
                          ),
                          Text(
                            'Data for ${controller.actualDaysCount.value} days',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeChip(String type, String label,
      DashboardController controller, VoidCallback onTap) {
    return Obx(() {
      final isSelected = controller.selectedRangeType.value == type;
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected ? AppColors.primaryOrange : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isSelected ? AppColors.primaryOrange : AppColors.lightBorder,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.lightTextPrimary,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAverageCards(DashboardController controller) {
    return Obx(() => Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Avg. Score',
                value: controller.avgScore.value.toStringAsFixed(1),
                subtitle: '/ ${controller.maxTotalScore.value.toInt()}',
                color: AppColors.getScoreColor(controller.avgPercentage.value),
              ),
            ),
            const SizedBox(width: AppConstants.kSpacingM),
            Expanded(
              child: Obx(() => _buildStatCard(
                    title: 'Avg. %',
                    value:
                        '${controller.avgPercentage.value.toStringAsFixed(1)}%',
                    subtitle: controller.selectedRangeLabel.value,
                    color:
                        AppColors.getScoreColor(controller.avgPercentage.value),
                  )),
            ),
          ],
        ));
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        border: Border.all(
            color: AppColors.primaryOrange.withOpacity(0.35), width: 1),
        borderRadius: BorderRadius.circular(AppConstants.kRadiusL),
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
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.kSpacingM,
          vertical: AppConstants.kSpacingM,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textOrange,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.primaryOrange,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(DashboardController controller) {
    return Obx(() {
      if (controller.activities.isEmpty) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.kSpacingXL),
            child: Center(
              child: Text(
                'No data available',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        );
      }

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
          padding: const EdgeInsets.all(AppConstants.kSpacingXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Score Trend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppConstants.kSpacingXL),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 44,
                          interval: 50,
                          getTitlesWidget: (value, meta) {
                            // Clamp to configured bounds to avoid stray labels
                            if (value < -20 || value > 280) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            if (value < 0 ||
                                value > controller.activities.length - 1 ||
                                value != value.toInt().toDouble()) {
                              return const SizedBox.shrink();
                            }

                            final index = value.toInt();
                            final date = DateTime.parse(
                                controller.activities[index].date);
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('MM/dd').format(date),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: (controller.activities.length - 1).toDouble(),
                    lineBarsData: [
                      LineChartBarData(
                        spots:
                            controller.activities.asMap().entries.map((entry) {
                          return FlSpot(
                              entry.key.toDouble(), entry.value.totalPoints);
                        }).toList(),
                        isCurved: true,
                        color: AppColors.primaryOrange,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          applyCutOffY: true,
                          cutOffY: 0,
                          color: AppColors.primaryOrange.withOpacity(0.18),
                        ),
                      ),
                    ],
                    minY: -20,
                    maxY: 280,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBarChart(DashboardController controller) {
    return Obx(() {
      if (controller.activities.isEmpty) {
        return const SizedBox.shrink();
      }

      final dynamicMaxY = [
            controller.getMaxPoints('nindra'),
            controller.getMaxPoints('wake_up'),
            controller.getMaxPoints('day_sleep'),
            controller.getMaxPoints('japa'),
            controller.getMaxPoints('pathan'),
            controller.getMaxPoints('sravan'),
            controller.getMaxPoints('seva'),
          ].reduce((a, b) => a > b ? a : b) +
          5;

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
          padding: const EdgeInsets.all(AppConstants.kSpacingXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Activity Scores Comparison',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Red = Negative score',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.kSpacingL),
              SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    minY: -10, // Allow negative scores
                    maxY: dynamicMaxY, // dynamic max + padding
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final activities = [
                            'Nindra',
                            'Wake',
                            'Sleep',
                            'Japa',
                            'Pathan',
                            'Sravan',
                            'Seva'
                          ];
                          return BarTooltipItem(
                            '${activities[group.x.toInt()]}\n${rod.toY.toStringAsFixed(1)} pts',
                            const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const activities = [
                              'Nindra',
                              'Wake',
                              'Sleep',
                              'Japa',
                              'Pathan',
                              'Sravan',
                              'Seva'
                            ];
                            if (value.toInt() >= 0 &&
                                value.toInt() < activities.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  activities[value.toInt()],
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(
                            toY: controller.avgNindra.value,
                            color: controller.avgNindra.value < 0
                                ? Colors.red
                                : AppColors.getScoreColor(
                                    controller.getMaxPoints('nindra') > 0
                                        ? (controller.avgNindra.value /
                                                controller
                                                    .getMaxPoints('nindra')) *
                                            100
                                        : 0),
                            width: 16)
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(
                            toY: controller.avgWakeUp.value,
                            color: controller.avgWakeUp.value < 0
                                ? Colors.red
                                : AppColors.getScoreColor(
                                    controller.getMaxPoints('wake_up') > 0
                                        ? (controller.avgWakeUp.value /
                                                controller
                                                    .getMaxPoints('wake_up')) *
                                            100
                                        : 0),
                            width: 16)
                      ]),
                      BarChartGroupData(x: 2, barRods: [
                        BarChartRodData(
                            toY: controller.avgDaySleep.value,
                            color: controller.avgDaySleep.value < 0
                                ? Colors.red
                                : AppColors.getScoreColor(
                                    controller.getMaxPoints('day_sleep') > 0
                                        ? (controller.avgDaySleep.value /
                                                controller.getMaxPoints(
                                                    'day_sleep')) *
                                            100
                                        : 0),
                            width: 16)
                      ]),
                      BarChartGroupData(x: 3, barRods: [
                        BarChartRodData(
                            toY: controller.avgJapa.value,
                            color: controller.avgJapa.value < 0
                                ? Colors.red
                                : AppColors.getScoreColor(
                                    controller.getMaxPoints('japa') > 0
                                        ? (controller.avgJapa.value /
                                                controller
                                                    .getMaxPoints('japa')) *
                                            100
                                        : 0),
                            width: 16)
                      ]),
                      BarChartGroupData(x: 4, barRods: [
                        BarChartRodData(
                            toY: controller.avgPathan.value,
                            color: controller.avgPathan.value < 0
                                ? Colors.red
                                : AppColors.getScoreColor(
                                    controller.getMaxPoints('pathan') > 0
                                        ? (controller.avgPathan.value /
                                                controller
                                                    .getMaxPoints('pathan')) *
                                            100
                                        : 0),
                            width: 16)
                      ]),
                      BarChartGroupData(x: 5, barRods: [
                        BarChartRodData(
                            toY: controller.avgSravan.value,
                            color: controller.avgSravan.value < 0
                                ? Colors.red
                                : AppColors.getScoreColor(
                                    controller.getMaxPoints('sravan') > 0
                                        ? (controller.avgSravan.value /
                                                controller
                                                    .getMaxPoints('sravan')) *
                                            100
                                        : 0),
                            width: 16)
                      ]),
                      BarChartGroupData(x: 6, barRods: [
                        BarChartRodData(
                            toY: controller.avgSeva.value,
                            color: controller.avgSeva.value < 0
                                ? Colors.red
                                : AppColors.getScoreColor(
                                    controller.getMaxPoints('seva') > 0
                                        ? (controller.avgSeva.value /
                                                controller
                                                    .getMaxPoints('seva')) *
                                            100
                                        : 0),
                            width: 16)
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildRadarChart(DashboardController controller) {
    return Obx(() {
      if (controller.activities.isEmpty) {
        return const SizedBox.shrink();
      }

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
          padding: const EdgeInsets.all(AppConstants.kSpacingXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Performance Radar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Visual representation of activity balance (negative scores normalized to 0)',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: AppConstants.kSpacingL),
              SizedBox(
                height: 300,
                child: RadarChart(
                  RadarChartData(
                    dataSets: [
                      // 100% reference ring
                      RadarDataSet(
                        fillColor: Colors.transparent,
                        borderColor: Colors.grey.withOpacity(0.25),
                        borderWidth: 1,
                        entryRadius: 0,
                        dataEntries: const [
                          RadarEntry(value: 5),
                          RadarEntry(value: 5),
                          RadarEntry(value: 5),
                          RadarEntry(value: 5),
                          RadarEntry(value: 5),
                          RadarEntry(value: 5),
                          RadarEntry(value: 5),
                        ],
                      ),
                      RadarDataSet(
                        fillColor: AppColors.getScoreColor(
                                controller.avgPercentage.value)
                            .withOpacity(0.3),
                        borderColor: AppColors.getScoreColor(
                            controller.avgPercentage.value),
                        entryRadius: 3,
                        dataEntries: [
                          // Normalize to 0-5 scale using activity max; negatives shown as 0
                          (() {
                            final max = controller.getMaxPoints('nindra');
                            final v = controller.avgNindra.value;
                            final val = v < 0 ? 0 : v;
                            final ratio = max > 0 ? (val / max) : 0.0;
                            return RadarEntry(
                                value: (ratio.clamp(0.0, 1.0)) * 5);
                          }()),
                          (() {
                            final max = controller.getMaxPoints('wake_up');
                            final v = controller.avgWakeUp.value;
                            final val = v < 0 ? 0 : v;
                            final ratio = max > 0 ? (val / max) : 0.0;
                            return RadarEntry(
                                value: (ratio.clamp(0.0, 1.0)) * 5);
                          }()),
                          (() {
                            final max = controller.getMaxPoints('day_sleep');
                            final v = controller.avgDaySleep.value;
                            final val = v < 0 ? 0 : v;
                            final ratio = max > 0 ? (val / max) : 0.0;
                            return RadarEntry(
                                value: (ratio.clamp(0.0, 1.0)) * 5);
                          }()),
                          (() {
                            final max = controller.getMaxPoints('japa');
                            final v = controller.avgJapa.value;
                            final val = v < 0 ? 0 : v;
                            final ratio = max > 0 ? (val / max) : 0.0;
                            return RadarEntry(
                                value: (ratio.clamp(0.0, 1.0)) * 5);
                          }()),
                          (() {
                            final max = controller.getMaxPoints('pathan');
                            final v = controller.avgPathan.value;
                            final val = v < 0 ? 0 : v;
                            final ratio = max > 0 ? (val / max) : 0.0;
                            return RadarEntry(
                                value: (ratio.clamp(0.0, 1.0)) * 5);
                          }()),
                          (() {
                            final max = controller.getMaxPoints('sravan');
                            final v = controller.avgSravan.value;
                            final val = v < 0 ? 0 : v;
                            final ratio = max > 0 ? (val / max) : 0.0;
                            return RadarEntry(
                                value: (ratio.clamp(0.0, 1.0)) * 5);
                          }()),
                          (() {
                            final max = controller.getMaxPoints('seva');
                            final v = controller.avgSeva.value;
                            final val = v < 0 ? 0 : v;
                            final ratio = max > 0 ? (val / max) : 0.0;
                            return RadarEntry(
                                value: (ratio.clamp(0.0, 1.0)) * 5);
                          }()),
                        ],
                      ),
                    ],
                    radarBackgroundColor: Colors.transparent,
                    borderData: FlBorderData(show: false),
                    radarBorderData:
                        const BorderSide(color: Colors.transparent),
                    titlePositionPercentageOffset: 0.18,
                    titleTextStyle: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w500),
                    getTitle: (index, angle) {
                      String label;
                      double pct;
                      switch (index) {
                        case 0:
                          label = 'Nindra';
                          pct = controller.getMaxPoints('nindra') > 0
                              ? ((controller.avgNindra.value < 0
                                          ? 0
                                          : controller.avgNindra.value) /
                                      controller.getMaxPoints('nindra')) *
                                  100
                              : 0;
                          break;
                        case 1:
                          label = 'Wake Up';
                          pct = controller.getMaxPoints('wake_up') > 0
                              ? ((controller.avgWakeUp.value < 0
                                          ? 0
                                          : controller.avgWakeUp.value) /
                                      controller.getMaxPoints('wake_up')) *
                                  100
                              : 0;
                          break;
                        case 2:
                          label = 'Day Sleep';
                          pct = controller.getMaxPoints('day_sleep') > 0
                              ? ((controller.avgDaySleep.value < 0
                                          ? 0
                                          : controller.avgDaySleep.value) /
                                      controller.getMaxPoints('day_sleep')) *
                                  100
                              : 0;
                          break;
                        case 3:
                          label = 'Japa';
                          pct = controller.getMaxPoints('japa') > 0
                              ? ((controller.avgJapa.value < 0
                                          ? 0
                                          : controller.avgJapa.value) /
                                      controller.getMaxPoints('japa')) *
                                  100
                              : 0;
                          break;
                        case 4:
                          label = 'Pathan';
                          pct = controller.getMaxPoints('pathan') > 0
                              ? ((controller.avgPathan.value < 0
                                          ? 0
                                          : controller.avgPathan.value) /
                                      controller.getMaxPoints('pathan')) *
                                  100
                              : 0;
                          break;
                        case 5:
                          label = 'Sravan';
                          pct = controller.getMaxPoints('sravan') > 0
                              ? ((controller.avgSravan.value < 0
                                          ? 0
                                          : controller.avgSravan.value) /
                                      controller.getMaxPoints('sravan')) *
                                  100
                              : 0;
                          break;
                        case 6:
                          label = 'Seva';
                          pct = controller.getMaxPoints('seva') > 0
                              ? ((controller.avgSeva.value < 0
                                          ? 0
                                          : controller.avgSeva.value) /
                                      controller.getMaxPoints('seva')) *
                                  100
                              : 0;
                          break;
                        default:
                          label = '';
                          pct = 0;
                      }
                      final showPct = pct > 0;
                      String display;
                      if (index == 2 || index == 5) {
                        // Wrap percentage on a new line for Day Sleep and Sravan
                        display = showPct
                            ? '$label\n(${pct.toStringAsFixed(0)}%)'
                            : label;
                      } else {
                        display = showPct
                            ? '$label (${pct.toStringAsFixed(0)}%)'
                            : label;
                      }
                      return RadarChartTitle(text: display);
                    },
                    tickCount: 5,
                    ticksTextStyle: const TextStyle(
                        fontSize: 10, color: Colors.transparent),
                    tickBorderData: BorderSide(
                        color: Colors.grey.withOpacity(0.3), width: 1),
                    gridBorderData: BorderSide(
                        color: Colors.grey.withOpacity(0.3), width: 1),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.kSpacingM),
              _buildRadarLegend(controller),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildRadarLegend(DashboardController controller) {
    final items = [
      ['Nindra', controller.avgNindra.value, controller.getMaxPoints('nindra')],
      [
        'Wake Up',
        controller.avgWakeUp.value,
        controller.getMaxPoints('wake_up')
      ],
      [
        'Day Sleep',
        controller.avgDaySleep.value,
        controller.getMaxPoints('day_sleep')
      ],
      ['Japa', controller.avgJapa.value, controller.getMaxPoints('japa')],
      ['Pathan', controller.avgPathan.value, controller.getMaxPoints('pathan')],
      ['Sravan', controller.avgSravan.value, controller.getMaxPoints('sravan')],
      ['Seva', controller.avgSeva.value, controller.getMaxPoints('seva')],
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((e) {
        final label = e[0] as String;
        final val = (e[1] as double);
        final max = (e[2] as double);
        final safe = val < 0 ? 0 : val;
        final pct = max > 0 ? (safe / max) * 100 : 0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.lightBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$label: ${pct.toStringAsFixed(0)}% (${safe.toStringAsFixed(1)}/${max.toStringAsFixed(0)})',
            style: const TextStyle(fontSize: 11),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivityBreakdown(DashboardController controller) {
    return Obx(() {
      if (controller.activities.isEmpty) {
        return const SizedBox.shrink();
      }

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.kSpacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Average Activity Scores',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${controller.activities.length} days',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.kSpacingM),
              Text(
                '(Negative scores normalized to 0 for visual bar.)',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: AppConstants.kSpacingM),
              _buildActivityRow(
                controller,
                key: 'nindra',
                label: 'Nindra',
                icon: Icons.bedtime,
                color: AppColors.activityNindra,
                score: controller.avgNindra.value,
              ),
              _buildActivityRow(
                controller,
                key: 'wake_up',
                label: 'Wake Up',
                icon: Icons.wb_sunny,
                color: AppColors.activityWakeUp,
                score: controller.avgWakeUp.value,
              ),
              _buildActivityRow(
                controller,
                key: 'day_sleep',
                label: 'Day Sleep',
                icon: Icons.hotel,
                color: AppColors.activityDaySleep,
                score: controller.avgDaySleep.value,
              ),
              _buildActivityRow(
                controller,
                key: 'japa',
                label: 'Japa',
                icon: Icons.self_improvement,
                color: AppColors.activityJapa,
                score: controller.avgJapa.value,
              ),
              _buildActivityRow(
                controller,
                key: 'pathan',
                label: 'Pathan',
                icon: Icons.menu_book,
                color: AppColors.activityPathan,
                score: controller.avgPathan.value,
              ),
              _buildActivityRow(
                controller,
                key: 'sravan',
                label: 'Sravan',
                icon: Icons.headset,
                color: AppColors.activitySravan,
                score: controller.avgSravan.value,
              ),
              _buildActivityRow(
                controller,
                key: 'seva',
                label: 'Seva',
                icon: Icons.volunteer_activism,
                color: AppColors.activitySeva,
                score: controller.avgSeva.value,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActivityRow(DashboardController controller,
      {required String key,
      required String label,
      required IconData icon,
      required Color color,
      required double score}) {
    final max = controller.getMaxPoints(key);
    double ratio;
    if (max <= 0) {
      ratio = 0;
    } else {
      // For the horizontal bar, treat negatives as 0 so the bar never goes backward
      ratio = (score <= 0 ? 0 : score) / max;
    }
    ratio = ratio.clamp(0.0, 1.0);
    final percentage = ratio * 100;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: Colors.grey[200],
              valueColor:
                  AlwaysStoppedAnimation(AppColors.getScoreColor(percentage)),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 40,
            child: Text(
              score.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 1,
      selectedItemColor: AppColors.primaryOrange,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      onTap: (index) {
        if (index == 0) Get.toNamed('/home');
        if (index == 2) Get.toNamed('/settings');
      },
    );
  }
}
