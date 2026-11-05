import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'trapped_button.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.title = 'SOMETHING WENT WRONG',
  });

  final String message;
  final VoidCallback? onRetry;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.errorSoft,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.error.withValues(alpha: .2)),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.label.copyWith(
                  fontSize: 10,
                  letterSpacing: 2.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted.copyWith(height: 1.7),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: 190,
                  child: TrappedButton(
                    label: 'TRY AGAIN',
                    onPressed: onRetry,
                    height: 42,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
