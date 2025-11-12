import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class ActivityCardWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  final double? score;
  final double? maxScore;

  const ActivityCardWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
    this.score,
    this.maxScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.kRadiusXL),
        border: Border.all(
          color: AppColors.lightBorder.withOpacity(0.6),
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
            blurRadius: 12,
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
            // Header with icon, title and score
            Row(
              children: [
                // Icon in rounded square
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppConstants.kSpacingM),
                // Title
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightTextPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.kSpacingS),
                // Score badge
                if (score != null && maxScore != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: score! < 0
                          ? AppColors.coralDanger
                          : AppColors.primaryOrange,
                      borderRadius:
                          BorderRadius.circular(AppConstants.kRadiusFull),
                      boxShadow: [
                        BoxShadow(
                          color: (score! < 0 ? AppColors.maroonDanger : AppColors.primaryOrange)
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
                          score! < 0 ? Icons.trending_down : Icons.star,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${score!.toStringAsFixed(0)}/${maxScore!.toInt()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.kSpacingM),
            // Content area
            child,
          ],
        ),
      ),
    );
  }
}
