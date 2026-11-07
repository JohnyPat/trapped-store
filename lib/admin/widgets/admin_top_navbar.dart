import 'package:flutter/material.dart';

import 'package:trapped_store/shared/constants/admin_constants.dart';
import 'package:trapped_store/admin/services/admin_auth_service.dart';

/// Desktop top navigation bar. The page heading lives in the page body, so
/// this bar only carries context, account details and the sign-out action.
class AdminTopNavbar extends StatelessWidget {
  const AdminTopNavbar({
    super.key,
    required this.title,
    required this.onLogout,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final auth = AdminAuthService();
    final email = auth.getUserEmail() ?? 'Administrator';
    final displayName = auth.getDisplayName()?.trim();
    final name = (displayName == null || displayName.isEmpty)
        ? 'Administrator'
        : displayName;
    final initial = name.substring(0, 1).toUpperCase();

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: AdminColors.paper,
        border: Border(bottom: BorderSide(color: AdminColors.line)),
      ),
      child: Row(
        children: [
          Text(
            'Admin',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AdminColors.muted.withValues(alpha: 0.9),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.chevron_right,
              size: 16,
              color: AdminColors.muted,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AdminColors.ink,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(width: 12),
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 12, color: AdminColors.muted),
            ),
          ],
          const Spacer(),
          Tooltip(
            message: 'Live Firebase data',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AdminColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AdminColors.success.withValues(alpha: 0.35),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LiveDot(),
                  SizedBox(width: 6),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: AdminColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 18),
          Container(width: 1, height: 26, color: AdminColors.line),
          const SizedBox(width: 18),
          PopupMenuButton<String>(
            tooltip: 'Account menu',
            offset: const Offset(0, 46),
            onSelected: (value) {
              if (value == 'logout') onLogout();
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AdminColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AdminColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: AdminColors.danger),
                    SizedBox(width: 10),
                    Text('Sign out'),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AdminColors.ink,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AdminColors.paper,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 170),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AdminColors.ink,
                          ),
                        ),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AdminColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.expand_more,
                    size: 18,
                    color: AdminColors.muted,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: AdminColors.success,
        shape: BoxShape.circle,
      ),
    );
  }
}
