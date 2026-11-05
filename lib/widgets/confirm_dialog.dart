import 'package:flutter/material.dart';

import '../constants/app_text_styles.dart';
import 'trapped_button.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'CONFIRM',
  String cancelLabel = 'CANCEL',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 11,
                    letterSpacing: 2.4,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMuted.copyWith(height: 1.7),
                ),
                const SizedBox(height: 24),
                TrappedButton(
                  label: confirmLabel,
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  variant: destructive
                      ? TrappedButtonVariant.danger
                      : TrappedButtonVariant.filled,
                  height: 44,
                ),
                const SizedBox(height: 9),
                TrappedButton(
                  label: cancelLabel,
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  variant: TrappedButtonVariant.outline,
                  height: 44,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return result ?? false;
}

Future<void> showInfoDialog(
  BuildContext context, {
  required String title,
  required String message,
  String buttonLabel = 'CLOSE',
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTextStyles.label.copyWith(
                  fontSize: 11,
                  letterSpacing: 2.4,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted.copyWith(height: 1.7),
              ),
              const SizedBox(height: 22),
              TrappedButton(
                label: buttonLabel,
                onPressed: () => Navigator.of(dialogContext).pop(),
                height: 44,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
