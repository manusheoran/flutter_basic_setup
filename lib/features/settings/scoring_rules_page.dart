import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class ScoringRulesPage extends StatelessWidget {
  const ScoringRulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Scoring Rules'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppConstants.kSpacingL),
            _buildTotalScoreCard(),
            const SizedBox(height: AppConstants.kSpacingL),
            _buildTimestampActivitiesSection(),
            const SizedBox(height: AppConstants.kSpacingL),
            _buildDurationActivitiesSection(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.kSpacingL),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppConstants.kRadiusL),
        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.35), width: 1),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowMedium, blurRadius: 10, offset: Offset(0, 4)),
          BoxShadow(color: AppColors.shadowLight, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🕉️ Sādhana Scoring System',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryOrange,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Track your spiritual progress with our comprehensive point system',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalScoreCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.kRadiusL),
        side: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.kSpacingL),
        child: Column(
          children: [
            const Text(
              'Maximum Total Score',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Text(
              '230',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryOrange,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Points Per Day',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScoreBreakdown('Timestamp', '100', '4 activities'),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _buildScoreBreakdown('Duration', '130', '3 activities'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBreakdown(String label, String points, String count) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          points,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryOrange,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTimestampActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '⏰ Time-Based Activities',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Scored based on when you complete the activity',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: AppConstants.kSpacingM),
        _buildActivityCard(
          icon: '🌙',
          title: 'Nindra (To Bed)',
          maxPoints: 25,
          description: 'Evening sleep time',
          rules: [
            {'range': '09:45 - 10:00 PM', 'points': '25'},
            {'range': '10:00 - 10:15 PM', 'points': '20'},
            {'range': '10:15 - 10:30 PM', 'points': '15'},
            {'range': '10:30 - 10:45 PM', 'points': '10'},
            {'range': '10:45 - 11:00 PM', 'points': '5'},
            {'range': '11:00 - 11:15 PM', 'points': '0'},
            {'range': 'After 11:15 PM', 'points': '-5', 'isNegative': true},
          ],
        ),
        const SizedBox(height: AppConstants.kSpacingM),
        _buildActivityCard(
          icon: '🌅',
          title: 'Wake Up Time',
          maxPoints: 25,
          description: 'Morning wake up time',
          rules: [
            {'range': '03:45 - 04:00 AM', 'points': '25'},
            {'range': '04:00 - 04:15 AM', 'points': '20'},
            {'range': '04:15 - 04:30 AM', 'points': '15'},
            {'range': '04:30 - 04:45 AM', 'points': '10'},
            {'range': '04:45 - 05:00 AM', 'points': '5'},
            {'range': '05:00 - 05:15 AM', 'points': '0'},
            {'range': 'After 05:15 AM', 'points': '-5', 'isNegative': true},
          ],
        ),
        const SizedBox(height: AppConstants.kSpacingM),
        _buildActivityCard(
          icon: '📿',
          title: 'Japa',
          maxPoints: 25,
          description: 'When you complete your japa rounds',
          rules: [
            {'range': 'Before 07:15 AM', 'points': '25'},
            {'range': '07:15 - 09:30 AM', 'points': '20'},
            {'range': '09:30 AM - 01:00 PM', 'points': '15'},
            {'range': '01:00 - 07:00 PM', 'points': '10'},
            {'range': '07:00 - 09:00 PM', 'points': '5'},
            {'range': '09:00 - 11:00 PM', 'points': '0'},
            {'range': 'After 11:00 PM', 'points': '-5', 'isNegative': true},
          ],
        ),
      ],
    );
  }

  Widget _buildDurationActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '⏱️ Duration-Based Activities',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Scored based on how long you spend on the activity',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: AppConstants.kSpacingM),
        _buildActivityCard(
          icon: '😴',
          title: 'Day Sleep',
          maxPoints: 25,
          description: 'Total sleep during daytime',
          rules: [
            {'range': '0 min (not entered)', 'points': '0'},
            {'range': '1 - 60 min (≤ 1 hr)', 'points': '25'},
            {'range': '61 - 75 min', 'points': '20'},
            {'range': '76 - 90 min', 'points': '15'},
            {'range': '91 - 105 min', 'points': '10'},
            {'range': '106 - 120 min', 'points': '5'},
            {'range': '121 - 135 min', 'points': '0'},
            {'range': '> 135 min', 'points': '-5', 'isNegative': true},
          ],
        ),
        const SizedBox(height: AppConstants.kSpacingM),
        _buildActivityCard(
          icon: '📖',
          title: 'Pathan (Reading/Study)',
          maxPoints: 30,
          description: 'Reading spiritual texts',
          rules: [
            {'range': '> 60 min (> 1 hr)', 'points': '30', 'isBonus': true},
            {'range': '45 - 60 min', 'points': '25'},
            {'range': '35 - 44 min', 'points': '20'},
            {'range': '25 - 34 min', 'points': '15'},
            {'range': '15 - 24 min', 'points': '10'},
            {'range': '5 - 14 min', 'points': '5'},
            {'range': '< 5 min', 'points': '0'},
          ],
        ),
        const SizedBox(height: AppConstants.kSpacingM),
        _buildActivityCard(
          icon: '👂',
          title: 'Sravan (Listening)',
          maxPoints: 30,
          description: 'Listening to spiritual discourses',
          rules: [
            {'range': '> 60 min (> 1 hr)', 'points': '30', 'isBonus': true},
            {'range': '45 - 60 min', 'points': '25'},
            {'range': '35 - 44 min', 'points': '20'},
            {'range': '25 - 34 min', 'points': '15'},
            {'range': '15 - 24 min', 'points': '10'},
            {'range': '5 - 14 min', 'points': '5'},
            {'range': '< 5 min', 'points': '0'},
          ],
        ),
        const SizedBox(height: AppConstants.kSpacingM),
        _buildActivityCard(
          icon: '🙏',
          title: 'Seva (Service)',
          maxPoints: 100,
          description: 'Selfless service to others',
          rules: [
            {
              'range': '> 210 min (> 3.5 hrs)',
              'points': '100',
              'isBonus': true
            },
            {'range': '181 - 210 min', 'points': '80'},
            {'range': '151 - 180 min', 'points': '60'},
            {'range': '121 - 150 min', 'points': '40'},
            {'range': '91 - 120 min', 'points': '20'},
            {'range': '0 - 90 min', 'points': '0'},
          ],
        ),
      ],
    );
  }

  Widget _buildActivityCard({
    required String icon,
    required String title,
    required int maxPoints,
    required String description,
    required List<Map<String, dynamic>> rules,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.kRadiusL),
        side: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.kSpacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$maxPoints pts',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.kSpacingM),
            const Divider(),
            const SizedBox(height: AppConstants.kSpacingS),
            ...rules.map((rule) => _buildRuleRow(
                  rule['range'] as String,
                  rule['points'] as String,
                  isNegative: rule['isNegative'] as bool? ?? false,
                  isBonus: rule['isBonus'] as bool? ?? false,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleRow(String range, String points,
      {bool isNegative = false, bool isBonus = false}) {
    Color pointsColor = AppColors.lightTextPrimary;
    if (isNegative) pointsColor = AppColors.coralDanger;
    if (isBonus) pointsColor = AppColors.deepTeal;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              range,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isNegative
                  ? AppColors.coralDanger.withOpacity(0.1)
                  : isBonus
                      ? AppColors.sageLight
                      : Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                if (isBonus)
                  const Icon(Icons.star, size: 14, color: AppColors.deepTeal),
                if (isBonus) const SizedBox(width: 4),
                Text(
                  '$points pts',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: pointsColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
