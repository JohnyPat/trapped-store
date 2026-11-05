import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

enum TrappedButtonVariant { filled, outline, text, danger }

class TrappedButton extends StatefulWidget {
  const TrappedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = TrappedButtonVariant.filled,
    this.icon,
    this.expand = true,
    this.height = 48,
    this.loading = false,
    this.pill = false,
    this.fontSize = 11,
  });

  final String label;
  final VoidCallback? onPressed;
  final TrappedButtonVariant variant;
  final IconData? icon;
  final bool expand;
  final double height;
  final bool loading;
  final bool pill;
  final double fontSize;

  @override
  State<TrappedButton> createState() => _TrappedButtonState();
}

class _TrappedButtonState extends State<TrappedButton> {
  bool _hovered = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  Color get _background {
    if (!_enabled) {
      return widget.variant == TrappedButtonVariant.filled
          ? AppColors.faint
          : AppColors.soft;
    }
    switch (widget.variant) {
      case TrappedButtonVariant.filled:
        return _hovered ? AppColors.inkSoft : AppColors.ink;
      case TrappedButtonVariant.outline:
        return _hovered ? AppColors.ink : AppColors.paper;
      case TrappedButtonVariant.text:
        return Colors.transparent;
      case TrappedButtonVariant.danger:
        return _hovered ? AppColors.error : AppColors.paper;
    }
  }

  Color get _foreground {
    if (!_enabled) return AppColors.faint;
    switch (widget.variant) {
      case TrappedButtonVariant.filled:
        return AppColors.paper;
      case TrappedButtonVariant.outline:
        return _hovered ? AppColors.paper : AppColors.ink;
      case TrappedButtonVariant.text:
        return AppColors.ink;
      case TrappedButtonVariant.danger:
        return _hovered ? AppColors.paper : AppColors.error;
    }
  }

  Color get _borderColor {
    if (!_enabled) return AppColors.line;
    switch (widget.variant) {
      case TrappedButtonVariant.filled:
      case TrappedButtonVariant.text:
        return Colors.transparent;
      case TrappedButtonVariant.outline:
        return AppColors.ink;
      case TrappedButtonVariant.danger:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.pill ? 999 : 3);
    final button = MouseRegion(
      cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _enabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            color: _background,
            borderRadius: radius,
            border: Border.all(color: _borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.loading)
                SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(_foreground),
                  ),
                )
              else if (widget.icon != null)
                Icon(widget.icon, size: 16, color: _foreground),
              if (widget.loading || widget.icon != null)
                const SizedBox(width: 10),
              Text(
                widget.label.toUpperCase(),
                style: AppTextStyles.button.copyWith(
                  color: _foreground,
                  fontSize: widget.fontSize,
                  letterSpacing: widget.fontSize > 10 ? 2.2 : 1.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return widget.expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
