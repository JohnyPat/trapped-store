import 'package:flutter/material.dart';

import 'package:trapped_store/shared/constants/admin_constants.dart';

/// A bordered panel used across desktop admin pages.
class AdminSectionCard extends StatelessWidget {
  const AdminSectionCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.all(20),
    this.fill = false,
    this.height,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  /// When true the body expands to fill the available height. Use this for
  /// cards that contain their own scrollable list.
  final bool fill;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final body = Padding(padding: padding, child: child);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AdminColors.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.line),
        boxShadow: [
          BoxShadow(
            color: AdminColors.ink.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AdminColors.ink,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AdminColors.muted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 12),
                    trailing!,
                  ],
                ],
              ),
            ),
            const Divider(height: 1, color: AdminColors.line),
          ],
          if (fill) Expanded(child: body) else body,
        ],
      ),
    );
  }
}
