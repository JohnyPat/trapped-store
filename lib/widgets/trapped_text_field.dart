import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class TrappedTextField extends StatefulWidget {
  const TrappedTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffix,
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled = true,
    this.autofillHints,
    this.readOnly = false,
    this.initialValue,
    this.pill = false,
    this.labelColor = AppColors.muted,
    this.fillColor = AppColors.paper,
    this.textColor = AppColors.ink,
    this.borderColor = AppColors.lineDark,
    this.hintColor = AppColors.faint,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int maxLines;
  final IconData? prefixIcon;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final bool readOnly;
  final String? initialValue;
  final bool pill;
  final Color labelColor;
  final Color fillColor;
  final Color textColor;
  final Color borderColor;
  final Color hintColor;

  @override
  State<TrappedTextField> createState() => _TrappedTextFieldState();
}

class _TrappedTextFieldState extends State<TrappedTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.pill ? 999 : 2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: AppTextStyles.micro.copyWith(
            color: widget.labelColor,
            fontSize: 8.5,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.obscureText ? _obscured : false,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofillHints: widget.autofillHints,
          style: AppTextStyles.body.copyWith(
            fontSize: 12.5,
            letterSpacing: 0.3,
            color: widget.textColor,
          ),
          cursorHeight: 16,
          cursorColor: widget.textColor,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.small.copyWith(color: widget.hintColor),
            isDense: true,
            filled: true,
            fillColor: widget.enabled ? widget.fillColor : AppColors.soft,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(
                    widget.prefixIcon,
                    size: 17,
                    color: AppColors.muted,
                  ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 42,
              minHeight: 42,
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
                    splashRadius: 18,
                    icon: Icon(
                      _obscured
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: AppColors.muted,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : widget.suffix,
            border: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: widget.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: widget.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: const BorderSide(color: AppColors.ink, width: 1.3),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: const BorderSide(color: AppColors.error, width: 1.3),
            ),
          ),
        ),
      ],
    );
  }
}
