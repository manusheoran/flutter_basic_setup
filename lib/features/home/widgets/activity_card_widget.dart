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
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Container(
            padding: const EdgeInsets.all(AppConstants.kSpacingM),
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.kRadiusL),
                topRight: Radius.circular(AppConstants.kRadiusL),
              ),
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
                    border: Border.all(
                      color: color.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.kSpacingS),
                // Title
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightTextPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                // Score badge
                if (score != null && maxScore != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: score! < 0 ? AppColors.coralDanger : AppColors.primaryOrange,
                      borderRadius: BorderRadius.circular(AppConstants.kRadiusFull),
                      boxShadow: [
                        BoxShadow(
                          color: (score! < 0 ? AppColors.maroonDanger : color)
                              .withOpacity(0.2),
                          blurRadius: 6,
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
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Content area
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.kSpacingM,
              vertical: AppConstants.kSpacingS,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
