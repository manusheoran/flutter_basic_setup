import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // This is the base theme for Google Fonts
  static final _baseTextTheme = GoogleFonts.interTextTheme();

  // Helper methods for easy access to text styles
  static TextStyle heading1(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium ?? const TextStyle();
  }

  static TextStyle heading2(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall ?? const TextStyle();
  }

  static TextStyle bodyLargeStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
  }

  static TextStyle bodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
  }

  static TextStyle bodySmall(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall ?? const TextStyle();
  }

  static TextStyle caption(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall ?? const TextStyle();
  }

  static TextStyle button(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge ?? const TextStyle();
  }

  static TextTheme get lightTextTheme {
    return _baseTextTheme.copyWith(
      // For "Welcome Back"
      headlineMedium: _baseTextTheme.headlineMedium?.copyWith(
        color: AppColors.textPrimaryLight,
        fontWeight: FontWeight.w600,
        fontSize: 28.0,
      ),
      // For "My Dashboard"
      headlineSmall: _baseTextTheme.headlineSmall?.copyWith(
        color: AppColors.textPrimaryLight,
        fontWeight: FontWeight.w600,
        fontSize: 22.0,
      ),
      // For card titles "Total Avg. Score"
      titleMedium: _baseTextTheme.titleMedium?.copyWith(
        color: AppColors.textSecondaryLight,
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
      ),
      // For scores "8.5"
      displaySmall: _baseTextTheme.displaySmall?.copyWith(
        color: AppColors.textPrimaryLight,
        fontWeight: FontWeight.w700,
        fontSize: 32.0,
      ),
      // For button text "Log In"
      labelLarge: _baseTextTheme.labelLarge?.copyWith(
        color: AppColors.textOnPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
      ),
      // For "Email", "Password"
      bodySmall: _baseTextTheme.bodySmall?.copyWith(
        color: AppColors.textPrimaryLight,
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
      ),
      // For text field hints
      bodyLarge: _baseTextTheme.bodyLarge?.copyWith(
        color: AppColors.textSecondaryLight,
        fontSize: 16.0,
      ),
    ).apply(
      bodyColor: AppColors.textPrimaryLight,
      displayColor: AppColors.textPrimaryLight,
    );
  }

  static TextTheme get darkTextTheme {
    return _baseTextTheme.copyWith(
       headlineMedium: _baseTextTheme.headlineMedium?.copyWith(
        color: AppColors.textPrimaryDark,
        fontWeight: FontWeight.w600,
        fontSize: 28.0,
      ),
      headlineSmall: _baseTextTheme.headlineSmall?.copyWith(
        color: AppColors.textPrimaryDark,
        fontWeight: FontWeight.w600,
        fontSize: 22.0,
      ),
      titleMedium: _baseTextTheme.titleMedium?.copyWith(
        color: AppColors.textSecondaryDark,
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
      ),
      displaySmall: _baseTextTheme.displaySmall?.copyWith(
        color: AppColors.textPrimaryDark,
        fontWeight: FontWeight.w700,
        fontSize: 32.0,
      ),
      labelLarge: _baseTextTheme.labelLarge?.copyWith(
        color: AppColors.textOnPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
      ),
      bodySmall: _baseTextTheme.bodySmall?.copyWith(
        color: AppColors.textPrimaryDark,
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
      ),
      bodyLarge: _baseTextTheme.bodyLarge?.copyWith(
        color: AppColors.textSecondaryDark,
        fontSize: 16.0,
      ),
    ).apply(
      bodyColor: AppColors.textPrimaryDark,
      displayColor: AppColors.textPrimaryDark,
    );
  }
}