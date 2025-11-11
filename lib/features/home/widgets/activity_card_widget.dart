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
          color: AppColors.lightBorder.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 12,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.shadowStrong,
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Container(
            padding: const EdgeInsets.all(AppConstants.kSpacingL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.12),
                  color.withOpacity(0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.kRadiusL),
                topRight: Radius.circular(AppConstants.kRadiusL),
              ),
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.25), color.withOpacity(0.15)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.kRadiusM),
                    border: Border.all(
                      color: color.withOpacity(0.4),
                      width: 2,
                    ),
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
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: score! < 0
                            ? [
                                AppColors.maroonDanger,
                                AppColors.maroonDanger.withOpacity(0.8)
                              ]
                            : [color, color.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(AppConstants.kRadiusFull),
                      boxShadow: [
                        BoxShadow(
                          color: (score! < 0 ? AppColors.maroonDanger : color)
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
            padding: const EdgeInsets.all(AppConstants.kSpacingL),
            child: child,
          ),
        ],
      ),
    );
  }
}
