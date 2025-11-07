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
                _buildRangeChip('Last 15 Days', controller, () {
                  final end = DateTime.now();
                  final start = end.subtract(const Duration(days: 14));
                  controller.selectDateRange('Last 15 Days', start, end);
                }),
                _buildRangeChip('Last 30 Days', controller, () {
                  final end = DateTime.now();
                  final start = end.subtract(const Duration(days: 29));
                  controller.selectDateRange('Last 30 Days', start, end);
                }),
                _buildRangeChip('This Month', controller, () {
                  final now = DateTime.now();
                  final start = DateTime(now.year, now.month, 1);
                  final end = DateTime.now();
                  controller.selectDateRange('This Month', start, end);
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
                  Text(
                    controller.selectedRangeLabel.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${controller.activities.length} days',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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
          child: _buildStatCard(
            title: 'Avg. %',
            value: '${controller.avgPercentage.value.toStringAsFixed(1)}%',
            subtitle: 'Last 7 days',
            color: AppColors.getScoreColor(controller.avgPercentage.value),
          ),
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
    return Card(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.kSpacingL),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
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

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.kSpacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Score Trend (Last 7 Days)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppConstants.kSpacingL),
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
                          return FlSpot(entry.key.toDouble(), entry.value.totalScore);
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
                    minY: 0,
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
