import 'package:flutter/material.dart';

/// Shared color palette for the entire app.
/// Like a design tokens / theme file in React (e.g., theme.js or variables.css).
/// Having all colors in one place makes it easy to change the look of the whole app.
class AppColors {
  // Prevent instantiation — this class is just a namespace for constants.
  AppColors._();

  static const Color background = Color(0xFF1A1A2E);    // Dark navy blue
  static const Color surface = Color(0xFF16213E);        // Slightly lighter (AppBar, cards)
  static const Color accent = Color(0xFF5B9BD5);         // Pleasant blue (circle)
  static const Color button = Color(0xFF2C5F8A);         // Steel blue (buttons)
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0BEC5);  // Muted white for subtitles
}
