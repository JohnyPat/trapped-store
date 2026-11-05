import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'trapped_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.line),
                ),
                child: Icon(icon, size: 26, color: AppColors.ink),
              ),
              const SizedBox(height: 22),
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTextStyles.label.copyWith(
                  fontSize: 11,
                  letterSpacing: 2.6,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted.copyWith(height: 1.7),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 22),
                SizedBox(
                  width: 230,
                  child: TrappedButton(
                    label: actionLabel!,
                    onPressed: onAction,
                    height: 44,
                  ),
                ),
              ],
              if (secondaryLabel != null && onSecondary != null) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: onSecondary,
                  child: Text(
                    secondaryLabel!.toUpperCase(),
                    style: AppTextStyles.micro.copyWith(
                      fontSize: 8.5,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.ink,
                      decorationThickness: 1,
                    ),
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
