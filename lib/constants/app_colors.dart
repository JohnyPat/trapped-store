import 'package:flutter/material.dart';

/// The monochrome [trapped] palette. No colour is used for decoration;
/// red is reserved for destructive/error feedback.
abstract final class AppColors {
  static const Color ink = Color(0xFF0B0B0B);
  static const Color inkSoft = Color(0xFF1A1A1A);
  static const Color paper = Color(0xFFFFFFFF);
  static const Color canvas = Color(0xFFF7F6F2);
  static const Color soft = Color(0xFFF0EEE8);
  static const Color line = Color(0xFFE3E0D8);
  static const Color lineDark = Color(0xFFC9C5BA);
  static const Color muted = Color(0xFF77746C);
  static const Color faint = Color(0xFFA9A59B);
  static const Color error = Color(0xFF9B2C2C);
  static const Color errorSoft = Color(0xFFF7EDED);
  static const Color success = Color(0xFF315D43);
  static const Color successSoft = Color(0xFFEDF3EE);
  static const Color warning = Color(0xFF856327);
  static const Color warningSoft = Color(0xFFF8F2E4);
  static const Color danger = Color(0xFFEF4443);
}
