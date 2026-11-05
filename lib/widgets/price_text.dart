import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../utils/formatters.dart';

class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.price,
    this.compareAtPrice,
    this.fontSize = 12,
    this.color = AppColors.ink,
    this.textAlign = TextAlign.left,
  });

  final double price;
  final double? compareAtPrice;
  final double fontSize;
  final Color color;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final hasCompare = compareAtPrice != null && compareAtPrice! > price;
    return Wrap(
      alignment: textAlign == TextAlign.center
          ? WrapAlignment.center
          : WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        Text(
          Formatters.currency(price),
          style: AppTextStyles.price.copyWith(fontSize: fontSize, color: color),
        ),
        if (hasCompare)
          Text(
            Formatters.currency(compareAtPrice!),
            style: AppTextStyles.price.copyWith(
              fontSize: fontSize - 1,
              color: AppColors.faint,
              decoration: TextDecoration.lineThrough,
              fontWeight: FontWeight.w400,
            ),
          ),
      ],
    );
  }
}
