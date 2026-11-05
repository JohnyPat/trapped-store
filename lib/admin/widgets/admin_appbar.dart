import 'package:flutter/material.dart';

import 'package:trapped_store/shared/constants/admin_constants.dart';

/// Admin app bar for desktop/web layout, with sidebar toggle and user menu.
class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdminAppBar({
    super.key,
    required this.onMenuToggle,
    required this.onLogout,
    this.title,
  });

  final VoidCallback? onMenuToggle;
  final VoidCallback? onLogout;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            )
          : const Text('Trapped Store'),
      actions: [
        // Menu toggle for mobile
        if (isMobile)
          IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Menu',
            onPressed: onMenuToggle,
            color: AdminColors.ink,
          ),
        // User profile/profile menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.person_outline, size: 28),
          tooltip: 'Admin',
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person, size: 18),
                  SizedBox(width: 8),
                  Text('Profile'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 18),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'logout') onLogout?.call();
          },
        ),
      ],
      toolbarHeight: kToolbarHeight,
    );
  }

  @override
  Size get preferredSize => Size(kToolbarHeight, kToolbarHeight);
}