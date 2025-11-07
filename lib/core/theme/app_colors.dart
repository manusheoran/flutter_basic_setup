import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Orange/Yellow Theme from mockup)
  static const Color primaryOrange = Color(0xFFFFA726);
  static const Color lightOrange = Color(0xFFFFB74D);
  static const Color darkOrange = Color(0xFFF57C00);
  
  // Status Colors for scoring
  static const Color greenSuccess = Color(0xFF4CAF50); // >80%
  static const Color orangeWarning = Color(0xFFFF9800); // 60-80%
  static const Color yellowWarning = Color(0xFFFDD835); // 40-60%
  static const Color maroonDanger = Color(0xFF880E4F); // <40%
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightBorder = Color(0xFFE0E0E0);
  
  // Alias for text styles
  static const Color textPrimaryLight = lightTextPrimary;
  static const Color textSecondaryLight = lightTextSecondary;
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCardBackground = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkBorder = Color(0xFF404040);
  
  // Alias for text styles
  static const Color textPrimaryDark = darkTextPrimary;
  static const Color textSecondaryDark = darkTextSecondary;
  static const Color textOnPrimary = white;
  
  // Common Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;
  
  // Activity Icon Colors
  static const Color iconNindra = Color(0xFFFFA726);
  static const Color iconWakeUp = Color(0xFFFDD835);
  static const Color iconDaySleep = Color(0xFF9C27B0);
  static const Color iconJapa = Color(0xFFFF6F00);
  static const Color iconPathan = Color(0xFFFDD835);
  static const Color iconSravan = Color(0xFF4CAF50);
  static const Color iconSeva = Color(0xFFFF9800);
  
  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFFFFA726),
    Color(0xFFFF6F00),
    Color(0xFFFDD835),
    Color(0xFF4CAF50),
    Color(0xFF9C27B0),
    Color(0xFFFF5722),
    Color(0xFF03A9F4),
  ];
  
  // Helper method to get color based on score percentage
  static Color getScoreColor(double percentage) {
    if (percentage >= 80) {
      return greenSuccess;
    } else if (percentage >= 60) {
      return orangeWarning;
    } else if (percentage >= 40) {
      return yellowWarning;
    } else {
      return maroonDanger;
    }
  }
}