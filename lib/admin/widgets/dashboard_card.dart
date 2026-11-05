import 'package:flutter/material.dart';

import 'package:trapped_store/shared/constants/admin_constants.dart';

/// Dashboard summary card displaying a single statistic.
class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.iconData,
    required this.color,
    this.showArrow = false,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData iconData;
  final Color color;
  final bool showArrow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final horizontalPadding = isMobile ? 16.0 : 20.0;
    final verticalPadding = isMobile ? 12.0 : 16.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: AdminColors.paper,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AdminColors.line.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(iconData, color: color, size: 24),
            ),
            const Spacer(),
            // Title and value
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AdminColors.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow indicator for mobile
            if (showArrow)
              const Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: AdminColors.muted,
              ),
          ],
        ),
      ),
    );
  }
}