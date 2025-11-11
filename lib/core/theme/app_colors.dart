import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Bright Orange & Peach (Warm & Vibrant)
  static const Color primaryOrange = Color(0xFFFF8C42); // Vibrant orange
  static const Color lightOrange = Color(0xFFFFAA6B); // Light orange
  static const Color darkOrange = Color(0xFFE67021); // Dark bright orange
  static const Color accentPeach = Color(0xFFFFE5CC); // Soft peach
  static const Color lightPeach = Color(0xFFFFF5ED); // Very light peach
  static const Color textOrange = Color(0xFFD4631C); // Dark orange for text
  
  // Status Colors - Warm orange progression
  static const Color orangeSuccess = Color(0xFFFF8C42); // Vibrant orange >80%
  static const Color lightOrangeWarning = Color(0xFFFFAA6B); // Light orange 60-80%
  static const Color peachWarning = Color(0xFFFFCC99); // Peach 40-60%
  static const Color coralDanger = Color(0xFFFF6B6B); // Coral red <40%
  
  // Gradient Colors - Warm orange tones
  static const Color gradientStart = Color(0xFFFF8C42); // Vibrant orange
  static const Color gradientMiddle = Color(0xFFFFAA6B); // Light orange
  static const Color gradientEnd = Color(0xFFFFE5CC); // Soft peach
  
  // Light Theme Colors - Warm peachy tones
  static const Color lightBackground = Color(0xFFFFF8F0); // Light peach background
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white
  static const Color lightCardBackground = Color(0xFFFFFBF7); // Light cream card
  static const Color lightCardAlt = Color(0xFFFFE5CC); // Peach card
  static const Color lightTextPrimary = Color(0xFF2C2416); // Dark brown
  static const Color lightTextSecondary = Color(0xFF8B7355); // Warm brown
  static const Color lightBorder = Color(0xFFFFDDB3); // Peach border
  static const Color lightDivider = Color(0xFFFFF0E0); // Light peach divider
  
  // Shadows for depth - subtle and visible
  static const Color shadowLight = Color(0x14000000); // 8% black shadow
  static const Color shadowMedium = Color(0x1F000000); // 12% black shadow
  static const Color shadowStrong = Color(0x29000000); // 16% black shadow
  
  // Alias for text styles
  static const Color textPrimaryLight = lightTextPrimary;
  static const Color textSecondaryLight = lightTextSecondary;
  
  // Dark Theme Colors - Warm dark mode
  static const Color darkBackground = Color(0xFF1A1310); // Warm dark brown
  static const Color darkSurface = Color(0xFF2C1F1A);
  static const Color darkCardBackground = Color(0xFF3E2C24);
  static const Color darkTextPrimary = Color(0xFFFFF3E0);
  static const Color darkTextSecondary = Color(0xFFFFCC80);
  static const Color darkBorder = Color(0xFF5D4037);
  
  // Alias for text styles
  static const Color textPrimaryDark = darkTextPrimary;
  static const Color textSecondaryDark = darkTextSecondary;
  static const Color textOnPrimary = white;
  
  // Common Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;
  
  // Activity Colors - Vibrant orange theme
  static const Color activityNindra = Color(0xFFFF8C42); // Vibrant orange
  static const Color activityWakeUp = Color(0xFFFF8C42); // Vibrant orange
  static const Color activityDaySleep = Color(0xFFFF8C42); // Vibrant orange
  static const Color activityJapa = Color(0xFFFF8C42); // Vibrant orange
  static const Color activityPathan = Color(0xFFFF8C42); // Vibrant orange
  static const Color activitySravan = Color(0xFFFF8C42); // Vibrant orange
  static const Color activitySeva = Color(0xFFFF8C42); // Vibrant orange
  
  // Chart Colors - Warm orange palette
  static const List<Color> chartColors = [
    Color(0xFFFF8C42), // Vibrant orange
    Color(0xFFFFAA6B), // Light orange
    Color(0xFFFFCC99), // Peach
    Color(0xFFE67021), // Dark orange
    Color(0xFFFF6B6B), // Coral
    Color(0xFFD4631C), // Burnt orange
    Color(0xFFFFDDB3), // Light peach
  ];
  
  // Surface elevation colors - peach tones
  static const Color elevation1 = Color(0xFFFFFFFF); // Pure white
  static const Color elevation2 = Color(0xFFFFFBF7); // Light peach
  static const Color elevation3 = Color(0xFFFFE5CC); // Peach
  
  // Helper method to get color based on score percentage
  static Color getScoreColor(double percentage) {
    if (percentage >= 80) {
      return orangeSuccess; // Vibrant orange
    } else if (percentage >= 60) {
      return lightOrangeWarning; // Light orange
    } else if (percentage >= 40) {
      return peachWarning; // Peach
    } else {
      return coralDanger; // Coral
    }
  }

  // Alias for backward compatibility
  static const Color greenSuccess = orangeSuccess;
  static const Color maroonDanger = coralDanger;
}