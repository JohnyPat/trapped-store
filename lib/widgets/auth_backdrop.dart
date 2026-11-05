import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import 'product_image.dart';

class AuthBackdrop extends StatelessWidget {
  const AuthBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const EditorialImage(
          imageUrl: '',
          fallbackAsset: AppAssets.forest,
          grayscale: true,
          fit: BoxFit.cover,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x99000000),
                Color(0xCC000000),
                Color(0xF2000000),
              ],
              stops: [0, 0.55, 1],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.2),
              radius: 0.85,
              colors: [
                Colors.white.withValues(alpha: 0.08),
                Colors.transparent,
              ],
            ),
          ),
        ),
        SafeArea(child: child),
      ],
    );
  }
}

class AuthPageShell extends StatelessWidget {
  const AuthPageShell({
    super.key,
    required this.children,
    this.maxWidth = 380,
    this.showBack = false,
  });

  final List<Widget> children;
  final double maxWidth;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return AuthBackdrop(
      child: Stack(
        children: [
          if (showBack)
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.paper,
                  size: 20,
                ),
              ),
            ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
