import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/brand_mark.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandMark(size: 78),
            const SizedBox(height: 26),
            const BrandLogo(fontSize: 24),
            const SizedBox(height: 12),
            Text(
              'WEAR YOUR CONVICTION.',
              style: AppTextStyles.micro.copyWith(
                color: AppColors.faint,
                fontSize: 7,
                letterSpacing: 3,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 34),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 1.4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.paper.withValues(alpha: .8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
