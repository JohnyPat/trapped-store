import 'package:flutter/material.dart';

import '../constants/app_assets.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.logoMark,
      width: size,
      fit: BoxFit.contain,
    );
  }
}
