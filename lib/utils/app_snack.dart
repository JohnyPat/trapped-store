import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

abstract final class AppSnack {
  static void show(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  static void success(BuildContext context, String message) {
    _colored(context, message, AppColors.success);
  }

  static void error(BuildContext context, String message) {
    _colored(context, message, AppColors.error);
  }

  static void _colored(BuildContext context, String message, Color accent) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.ink,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
          content: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.paper,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
