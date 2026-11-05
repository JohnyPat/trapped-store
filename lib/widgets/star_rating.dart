import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    this.reviewCount,
    this.size = 11,
    this.showValue = false,
    this.color = AppColors.ink,
  });

  final double rating;
  final int? reviewCount;
  final double size;
  final bool showValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fullStars = rating.floor();
    final hasHalf = rating - fullStars >= 0.35;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < 5; index++)
          Icon(
            index < fullStars
                ? Icons.star_rounded
                : (index == fullStars && hasHalf
                      ? Icons.star_half_rounded
                      : Icons.star_outline_rounded),
            size: size,
            color: color,
          ),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.micro.copyWith(
              fontSize: 8,
              letterSpacing: 0.6,
              color: color,
            ),
          ),
        ],
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: AppTextStyles.micro.copyWith(
              fontSize: 8,
              letterSpacing: 0.2,
              color: AppColors.muted,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}
