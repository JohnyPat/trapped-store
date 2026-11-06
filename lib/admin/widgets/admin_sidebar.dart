import 'package:flutter/material.dart';

import 'package:trapped_store/shared/constants/admin_constants.dart';
import 'package:trapped_store/admin/services/admin_auth_service.dart';

/// Admin sidebar navigation for desktop/web layout.
class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    this.onItemSelected,
  });

  final int selectedIndex;
  final void Function(int)? onItemSelected;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final items = [
      {'icon': Icons.dashboard, 'label': 'Dashboard'},
      {'icon': Icons.inventory, 'label': 'Products'},
      {'icon': Icons.category, 'label': 'Categories'},
      {'icon': Icons.shopping_bag, 'label': 'Orders'},
      {'icon': Icons.people, 'label': 'Customers'},
      {'icon': Icons.payments, 'label': 'Payments'},
      {'icon': Icons.bar_chart, 'label': 'Reports'},
      {'icon': Icons.web_asset, 'label': 'Site'},
    ];

    return Container(
      width: isMobile ? double.infinity : 240,
      color: AdminColors.ink,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ADMIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Trapped Store',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Navigation items
          ...List.generate(items.length, (index) => _NavItem(
            icon: items[index]['icon'] as IconData,
            label: items[index]['label'] as String,
            isSelected: selectedIndex == index,
            onTap: () => onItemSelected?.call(index),
          )),
          const Spacer(),
          // Logout button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                await AdminAuthService().signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/admin/login', (route) => false);
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.danger,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AdminColors.accent.withValues(alpha: 0.15)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AdminColors.accent : AdminColors.muted,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AdminColors.accent : AdminColors.muted,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}