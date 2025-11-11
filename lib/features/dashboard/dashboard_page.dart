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
          color: isSelected ? AppColors.primaryOrange : Colors.grey[200],
          borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector(DashboardController controller, BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                _buildRangeChip('Last 7 Days', controller, () {
                  final end = DateTime.now();
                  final start = end.subtract(const Duration(days: 6));
                  controller.selectDateRange('Last 7 Days', start, end);
                }),
                _buildRangeChip('Last 30 Days', controller, () {
                  final end = DateTime.now();
                  final start = end.subtract(const Duration(days: 29));
                  controller.selectDateRange('Last 30 Days', start, end);
                }),
                _buildRangeChip('Custom', controller, () async {
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
            Obx(() => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range, color: AppColors.primaryOrange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.selectedRangeLabel.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                        if (controller.actualDaysCount.value > 0)
                          Text(
                            'Data for ${controller.actualDaysCount.value} days',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeChip(String label, DashboardController controller, VoidCallback onTap) {
    return Obx(() {
      final isSelected = controller.selectedRangeLabel.value == label;
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryOrange : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
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
            subtitle: '/ ${AppConstants.maxTotalScore}',
            color: AppColors.getScoreColor(controller.avgPercentage.value),
          ),
        ),
        const SizedBox(width: AppConstants.kSpacingM),
        Expanded(
          child: Obx(() => _buildStatCard(
            title: 'Avg. %',
            value: '${controller.avgPercentage.value.toStringAsFixed(1)}%',
            subtitle: controller.selectedRangeLabel.value,
            color: AppColors.getScoreColor(controller.avgPercentage.value),
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
        gradient: LinearGradient(
          colors: [AppColors.primaryOrange, AppColors.lightOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.kRadiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 8,
            offset: const Offset(0, 3),
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
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
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
              Obx(() => Text(
                'Score Trend (${controller.selectedRangeLabel.value})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightTextPrimary,
                  letterSpacing: -0.5,
                ),
              )),
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
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < controller.activities.length) {
                              final date = DateTime.parse(controller.activities[value.toInt()].date);
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat('MM/dd').format(date),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: controller.activities.asMap().entries.map((entry) {
                          return FlSpot(entry.key.toDouble(), entry.value.totalPoints);
                        }).toList(),
                        isCurved: true,
                        color: AppColors.primaryOrange,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primaryOrange.withOpacity(0.2),
                        ),
                      ),
                    ],
                    minY: -20, // Allow negative scores
                    maxY: AppConstants.maxTotalScore.toDouble(),
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
                    'Red = Negative score (below target)',
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
                    maxY: 105, // Max is 100 for Seva, add 5 for padding
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final activities = ['Nindra', 'Wake', 'Sleep', 'Japa', 'Pathan', 'Sravan', 'Seva'];
                          return BarTooltipItem(
                            '${activities[group.x.toInt()]}\n${rod.toY.toStringAsFixed(1)} pts',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                            const activities = ['Nindra', 'Wake', 'Sleep', 'Japa', 'Pathan', 'Sravan', 'Seva'];
                            if (value.toInt() >= 0 && value.toInt() < activities.length) {
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
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [BarChartRodData(
                        toY: controller.avgNindra.value, 
                        color: controller.avgNindra.value < 0 ? Colors.red : AppColors.primaryOrange, 
                        width: 16
                      )]),
                      BarChartGroupData(x: 1, barRods: [BarChartRodData(
                        toY: controller.avgWakeUp.value, 
                        color: controller.avgWakeUp.value < 0 ? Colors.red : Colors.blue, 
                        width: 16
                      )]),
                      BarChartGroupData(x: 2, barRods: [BarChartRodData(
                        toY: controller.avgDaySleep.value, 
                        color: controller.avgDaySleep.value < 0 ? Colors.red : Colors.purple, 
                        width: 16
                      )]),
                      BarChartGroupData(x: 3, barRods: [BarChartRodData(
                        toY: controller.avgJapa.value, 
                        color: controller.avgJapa.value < 0 ? Colors.red : Colors.green, 
                        width: 16
                      )]),
                      BarChartGroupData(x: 4, barRods: [BarChartRodData(
                        toY: controller.avgPathan.value, 
                        color: controller.avgPathan.value < 0 ? Colors.red : Colors.teal, 
                        width: 16
                      )]),
                      BarChartGroupData(x: 5, barRods: [BarChartRodData(
                        toY: controller.avgSravan.value, 
                        color: controller.avgSravan.value < 0 ? Colors.red : Colors.indigo, 
                        width: 16
                      )]),
                      BarChartGroupData(x: 6, barRods: [BarChartRodData(
                        toY: controller.avgSeva.value, 
                        color: controller.avgSeva.value < 0 ? Colors.red : Colors.red.shade400, 
                        width: 16
                      )]),
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
                      RadarDataSet(
                        fillColor: AppColors.primaryOrange.withOpacity(0.3),
                        borderColor: AppColors.primaryOrange,
                        entryRadius: 3,
                        dataEntries: [
                          // Normalize to 0-5 scale, treating negative as 0 for radar visualization
                          RadarEntry(value: ((controller.avgNindra.value.clamp(-5, 25) + 5) / 30) * 5),
                          RadarEntry(value: ((controller.avgWakeUp.value.clamp(-5, 25) + 5) / 30) * 5),
                          RadarEntry(value: ((controller.avgDaySleep.value.clamp(-5, 25) + 5) / 30) * 5),
                          RadarEntry(value: ((controller.avgJapa.value.clamp(0, 25)) / 25) * 5),
                          RadarEntry(value: ((controller.avgPathan.value.clamp(0, 30)) / 30) * 5),
                          RadarEntry(value: ((controller.avgSravan.value.clamp(0, 30)) / 30) * 5),
                          RadarEntry(value: ((controller.avgSeva.value.clamp(0, 100)) / 100) * 5),
                        ],
                      ),
                    ],
                    radarBackgroundColor: Colors.transparent,
                    borderData: FlBorderData(show: false),
                    radarBorderData: const BorderSide(color: Colors.transparent),
                    titlePositionPercentageOffset: 0.2,
                    titleTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    getTitle: (index, angle) {
                      switch (index) {
                        case 0:
                          return const RadarChartTitle(text: 'Nindra');
                        case 1:
                          return const RadarChartTitle(text: 'Wake Up');
                        case 2:
                          return const RadarChartTitle(text: 'Day Sleep');
                        case 3:
                          return const RadarChartTitle(text: 'Japa');
                        case 4:
                          return const RadarChartTitle(text: 'Pathan');
                        case 5:
                          return const RadarChartTitle(text: 'Sravan');
                        case 6:
                          return const RadarChartTitle(text: 'Seva');
                        default:
                          return const RadarChartTitle(text: '');
                      }
                    },
                    tickCount: 5,
                    ticksTextStyle: const TextStyle(fontSize: 10, color: Colors.transparent),
                    tickBorderData: const BorderSide(color: Colors.grey, width: 1),
                    gridBorderData: const BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              _buildActivityRow('🌙 Nindra (Sleep)', controller.avgNindra.value),
              _buildActivityRow('🌅 Wake Up Time', controller.avgWakeUp.value),
              _buildActivityRow('😴 Day Sleep', controller.avgDaySleep.value),
              _buildActivityRow('📿 Japa Rounds', controller.avgJapa.value),
              _buildActivityRow('📖 Pathan Reading', controller.avgPathan.value),
              _buildActivityRow('👂 Sravan Listening', controller.avgSravan.value),
              _buildActivityRow('🙏 Seva Service', controller.avgSeva.value),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActivityRow(String label, double score) {
    final percentage = (score / AppConstants.maxActivityScore) * 100;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(AppColors.getScoreColor(percentage)),
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
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      onTap: (index) {
        if (index == 0) Get.toNamed('/home');
        if (index == 2) Get.toNamed('/settings');
      },
    );
  }
}
