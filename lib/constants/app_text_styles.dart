import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Space Mono is bundled with the app so the brand typography is identical
/// on web, Android and iOS without a runtime font download.
abstract final class AppTextStyles {
  static const String family = 'SpaceMono';

  static const TextStyle display = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w700,
    fontSize: 42,
    height: 1.05,
    letterSpacing: -1.4,
    color: AppColors.ink,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w700,
    fontSize: 30,
    height: 1.12,
    letterSpacing: -0.8,
    color: AppColors.ink,
  );

  static const TextStyle title = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 1.3,
    letterSpacing: 0.4,
    color: AppColors.ink,
  );

  static const TextStyle body = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w400,
    fontSize: 13,
    height: 1.65,
    color: AppColors.ink,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.6,
    color: AppColors.muted,
  );

  static const TextStyle small = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w400,
    fontSize: 10.5,
    height: 1.5,
    letterSpacing: 0.5,
    color: AppColors.muted,
  );

  static const TextStyle micro = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w700,
    fontSize: 9,
    height: 1.4,
    letterSpacing: 2.2,
    color: AppColors.ink,
  );

  static const TextStyle label = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w700,
    fontSize: 11,
    height: 1.4,
    letterSpacing: 2.6,
    color: AppColors.ink,
  );

  static const TextStyle button = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w700,
    fontSize: 11,
    height: 1.2,
    letterSpacing: 2.2,
    color: AppColors.paper,
  );

  static const TextStyle buttonOutline = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w700,
    fontSize: 11,
    height: 1.2,
    letterSpacing: 2.2,
    color: AppColors.ink,
  );

  static const TextStyle price = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w700,
    fontSize: 12,
    height: 1.4,
    letterSpacing: 0.4,
    color: AppColors.ink,
  );

  static const TextStyle navLabel = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w400,
    fontSize: 8,
    height: 1.2,
    letterSpacing: 1.2,
  );
}