import 'package:flutter/widgets.dart';

/// Shared responsive breakpoints for the admin console.
///
/// Desktop styles only apply at 1024 logical pixels and above, matching the
/// requested CSS `@media (min-width: 1024px)` behaviour. Anything below this
/// width keeps the existing mobile/tablet layout.
class AdminBreakpoints {
  const AdminBreakpoints._();

  static const double desktop = 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;

  static bool isMobile(BuildContext context) => !isDesktop(context);
}
