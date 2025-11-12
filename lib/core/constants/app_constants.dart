import 'package:flutter/material.dart';

class AppConstants {
  // Spacing - Modern 8-point grid system
  static const double kSpacingXS = 4.0;
  static const double kSpacingS = 8.0;
  static const double kSpacingM = 16.0;
  static const double kSpacingL = 24.0;
  static const double kSpacingXL = 32.0;
  static const double kSpacing2XL = 40.0;
  static const double kSpacing3XL = 48.0;
  static const double kDefaultPadding = 16.0;
  static const double kGutterPadding = 24.0;

  // Border Radius - Smooth, modern curves
  static const double kRadiusXS = 6.0;
  static const double kRadiusS = 8.0;
  static const double kRadiusM = 12.0;
  static const double kRadiusL = 16.0;
  static const double kRadiusXL = 20.0;
  static const double kRadius2XL = 24.0;
  static const double kRadiusFull = 9999.0; // For pills
  static const double kDefaultRadius = 12.0;

  // Icon Sizes
  static const double kIconS = 20.0;
  static const double kIconM = 24.0;
  static const double kIconL = 32.0;

  // Animation
  static const Duration kShortAnimationDuration = Duration(milliseconds: 300);
  static const Duration kMediumAnimationDuration = Duration(milliseconds: 500);

  // Security
  static const bool requireBiometricAuthentication = true;

  // Activity Settings
  static const int visibleActivityDays = 3; // Show today and 2 days before
  
  // Activity Parameters
  static const List<String> activities = [
    'nindra',
    'wakeUp',
    'daySleep',
    'japa',
    'pathan',
    'sravan',
    'seva',
  ];

  static const Map<String, String> activityNames = {
    'nindra': 'Nindra (Sleep Time)',
    'wakeUp': 'Wake Up',
    'daySleep': 'Day Sleep',
    'japa': 'Japa',
    'pathan': 'Pathan',
    'sravan': 'Sravan',
    'seva': 'Seva',
  };

  // Score thresholds (percentage)
  static const double excellentThreshold = 80.0;
  static const double goodThreshold = 60.0;
  static const double averageThreshold = 40.0;

  // Max scores
  static const int maxTotalScore = 260; // 4x25 (nindra+wakeup+daysleep+japa) + 2x30 (pathan+sravan) + 100 (seva)
  static const int maxActivityScore = 25;

  // User roles
  static const String roleUser = 'user';
  static const String roleMentor = 'mentor';
  static const String roleAdmin = 'admin';

  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String displayDateFormat = 'MMM dd, yyyy';
}