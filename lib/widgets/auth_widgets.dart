import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return SizedBox(
      height: 46,
      child: TextButton(
        onPressed: enabled ? onPressed : null,
        style: TextButton.styleFrom(
          backgroundColor: enabled ? AppColors.paper : AppColors.faint,
          foregroundColor: AppColors.ink,
          disabledBackgroundColor: AppColors.faint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
            side: const BorderSide(color: AppColors.paper),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: AppColors.ink,
                ),
              )
            : Text(
                label.toUpperCase(),
                style: AppTextStyles.micro.copyWith(
                  fontSize: 9.5,
                  letterSpacing: 2,
                  color: AppColors.ink,
                ),
              ),
      ),
    );
  }
}

class AuthOutlineButton extends StatelessWidget {
  const AuthOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.paper,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
            side: const BorderSide(color: AppColors.paper),
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTextStyles.micro.copyWith(
            fontSize: 9.5,
            letterSpacing: 2,
            color: AppColors.paper,
          ),
        ),
      ),
    );
  }
}

class AuthLink extends StatelessWidget {
  const AuthLink({
    super.key,
    required this.label,
    required this.onTap,
    this.underline = false,
    this.align = TextAlign.center,
  });

  final String label;
  final VoidCallback onTap;
  final bool underline;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          label,
          textAlign: align,
          style: AppTextStyles.micro.copyWith(
            fontSize: 8.5,
            letterSpacing: 1.4,
            color: AppColors.paper,
            fontWeight: FontWeight.w400,
            decoration: underline ? TextDecoration.underline : null,
            decorationColor: AppColors.paper,
            decorationThickness: 0.8,
          ),
        ),
      ),
    );
  }
}

class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.22),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.paper, size: 15),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.small.copyWith(
                color: AppColors.paper,
                fontSize: 9.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
