import 'package:get/get.dart';

/// A utility class for responsive design.
/// You can create a base design width and height
/// and scale elements accordingly.

const double _designHeight = 812.0; // Example design height
const double _designWidth = 375.0; // Example design width

extension SizeExtensions on num {
  /// Scales the number based on the screen height.
  /// Use for vertical spacing, heights, font sizes.
  double get h {
    final screenHeight = Get.height;
    return (this / _designHeight) * screenHeight;
  }

  /// Scales the number based on the screen width.
  /// Use for horizontal spacing, widths.
  double get w {
    final screenWidth = Get.width;
    return (this / _designWidth) * screenWidth;
  }
}