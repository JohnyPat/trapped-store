import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.align = SectionHeadingAlign.center,
    this.padding = EdgeInsets.zero,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final SectionHeadingAlign align;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final isCenter = align == SectionHeadingAlign.center;
    final content = Column(
      crossAxisAlignment: isCenter
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (isCenter)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Diamond(),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 11,
                    letterSpacing: 3,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _Diamond(),
            ],
          )
        else
          Row(
            children: [
              _Diamond(),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: AppTextStyles.label.copyWith(
                    fontSize: 11,
                    letterSpacing: 3,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        if (subtitle != null) ...[
          const SizedBox(height: 9),
          Text(
            subtitle!,
            textAlign: isCenter ? TextAlign.center : TextAlign.left,
            style: AppTextStyles.bodyMuted.copyWith(
              fontSize: 11,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );
    return Padding(
      padding: padding,
      child: SizedBox(width: double.infinity, child: content),
    );
  }
}

enum SectionHeadingAlign { center, left }

class _Diamond extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.785398,
      child: Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
