import 'package:flutter/material.dart';

import 'package:trapped_store/shared/constants/admin_constants.dart';

/// Centres admin page content and caps it at a comfortable reading width so
/// cards and tables never stretch across an ultrawide monitor.
class AdminPageContainer extends StatelessWidget {
  const AdminPageContainer({
    super.key,
    required this.child,
    this.maxWidth = 1360,
    this.padding = const EdgeInsets.all(32),
    this.scrollable = false,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  /// Wrap the page body in a vertical scroll view. Use `false` for pages that
  /// manage their own scroll area (for example a table that fills the height).
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
    return scrollable ? SingleChildScrollView(child: content) : content;
  }
}

/// Consistent desktop page heading with an optional action area.
class AdminPageHeader extends StatelessWidget {
  const AdminPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AdminColors.ink,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: AdminColors.muted,
            ),
          ),
        ],
      ],
    );

    final actionArea = actions;
    if (actionArea == null) return heading;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [heading, const SizedBox(height: 16), actionArea],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: heading),
            const SizedBox(width: 24),
            actionArea,
          ],
        );
      },
    );
  }
}
