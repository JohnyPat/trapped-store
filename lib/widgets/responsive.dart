import 'package:flutter/material.dart';

enum ScreenSize { mobile, tablet, desktop }

class Breakpoints {
  static const double mobile = 700;
  static const double desktop = 1080;
  static const double maxContentWidth = 1240;

  static ScreenSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobile) return ScreenSize.mobile;
    if (width < desktop) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  static bool isMobile(BuildContext context) =>
      of(context) == ScreenSize.mobile;

  static bool isDesktop(BuildContext context) =>
      of(context) == ScreenSize.desktop;

  static int productColumns(BuildContext context) {
    switch (of(context)) {
      case ScreenSize.mobile:
        return 2;
      case ScreenSize.tablet:
        return 3;
      case ScreenSize.desktop:
        return 4;
    }
  }

  static double pagePadding(BuildContext context) {
    switch (of(context)) {
      case ScreenSize.mobile:
        return 18;
      case ScreenSize.tablet:
        return 30;
      case ScreenSize.desktop:
        return 40;
    }
  }
}

class ContentFrame extends StatelessWidget {
  const ContentFrame({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding:
              padding ??
              EdgeInsets.symmetric(horizontal: Breakpoints.pagePadding(context)),
          child: child,
        ),
      ),
    );
  }
}

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    switch (Breakpoints.of(context)) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet ?? desktop;
      case ScreenSize.desktop:
        return desktop;
    }
  }
}
