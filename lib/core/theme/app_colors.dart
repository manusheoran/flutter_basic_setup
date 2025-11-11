import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Warm Orange (Analogous Scheme for Harmony)
  static const Color primaryOrange = Color(0xFFFFA94D); // Warm vibrant orange (like Health App)
  static const Color lightOrange = Color(0xFFFFBF7A); // Light warm orange
  static const Color darkOrange = Color(0xFFFF8C33); // Dark warm orange
  static const Color accentPeach = Color(0xFFFFE5CC); // Soft peach (desaturated)
  static const Color lightPeach = Color(0xFFFFF5ED); // Very light peach
  static const Color textOrange = Color(0xFFD47A1F); // Warm dark orange for text
  
  // Status Colors - Warm progression (Analogous)
  static const Color orangeSuccess = Color(0xFFFFA94D); // Warm orange >80%
  static const Color lightOrangeWarning = Color(0xFFFFBF7A); // Light orange 60-80%
  static const Color peachWarning = Color(0xFFFFD4A3); // Soft peach 40-60%
  static const Color coralDanger = Color(0xFFFF7A5C); // Warm coral <40%
  
  // Calming Accents - Sage and Deep Teal (spiritual, grounding)
  static const Color accentSage = Color(0xFF8DBF9F); // Calming sage accent
  static const Color sageLight = Color(0xFFEFF7F2); // Very light sage for badges/chips
  static const Color deepTeal = Color(0xFF2F7D73); // Deep teal for text on sage
  
  // Gradient Colors - Analogous warm tones (creates harmony)
  static const Color gradientStart = Color(0xFFFFA94D); // Warm orange
  static const Color gradientMiddle = Color(0xFFFFBF7A); // Light warm orange  
  static const Color gradientEnd = Color(0xFFFFE5CC); // Soft peach
  
  // Light Theme Colors - Clean white with orange accents
  static const Color lightBackground = Color(0xFFF5F5F5); // Slightly darker gray for contrast
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white
  static const Color lightCardBackground = Color(0xFFFFFFFF); // Pure white cards
  static const Color lightCardAlt = Color(0xFFFFF8F0); // Very subtle peach for variety
  static const Color lightTextPrimary = Color(0xFF1A1A1A); // Clean dark gray
  static const Color lightTextSecondary = Color(0xFF666666); // Medium gray
  static const Color lightBorder = Color(0xFFDDDDDD); // Darker border for visibility
  static const Color lightDivider = Color(0xFFEEEEEE); // Light gray divider
  
  // Shadows for depth - modern card shadows
  static const Color shadowLight = Color(0x0A000000); // 4% black shadow (subtle)
  static const Color shadowMedium = Color(0x14000000); // 8% black shadow (cards)
  static const Color shadowStrong = Color(0x1F000000); // 12% black shadow (elevated)
  
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
  
  // Activity Colors - Warm orange (consistent, high saturation for engagement)
  static const Color activityNindra = Color(0xFFFFA94D); // Warm orange
  static const Color activityWakeUp = Color(0xFFFFA94D); // Warm orange
  static const Color activityDaySleep = Color(0xFFFFA94D); // Warm orange
  static const Color activityJapa = Color(0xFFFFA94D); // Warm orange
  static const Color activityPathan = Color(0xFFFFA94D); // Warm orange
  static const Color activitySravan = Color(0xFFFFA94D); // Warm orange
  static const Color activitySeva = Color(0xFFFFA94D); // Warm orange
  
  // Chart Colors - Analogous warm palette (harmony + variety)
  static const List<Color> chartColors = [
    Color(0xFFFFA94D), // Warm orange
    Color(0xFFFFBF7A), // Light orange
    Color(0xFFFFD4A3), // Peach
    Color(0xFFFF8C33), // Dark orange
    Color(0xFFFF7A5C), // Coral
    Color(0xFFFFCC8F), // Light warm
    Color(0xFFFFE5CC), // Very light peach
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