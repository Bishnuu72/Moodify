import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6A5AE0); // Soft Purple
  static const Color secondary = Color(0xFF9087E5); // Light Purple
  static const Color background = Color(0xFFF0F4F8); // Very light grey-blue
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937); // Dark Grey
  static const Color textSecondary = Color(0xFF6B7280); // Medium Grey
  static const Color error = Color(0xFFEF4444); // Red
  static const Color success = Color(0xFF10B981); // Green

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
