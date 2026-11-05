import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.color = AppColors.paper,
    this.fontSize = 20,
    this.letterSpacing = -0.6,
  });

  final Color color;
  final double fontSize;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.logoWordmark,
      height: fontSize * 1.35,
      color: color,
      colorBlendMode: BlendMode.srcIn,
      fit: BoxFit.contain,
    );
  }
}
