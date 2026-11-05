import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class TrappedBottomNav extends StatelessWidget {
  const TrappedBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.wishlistCount,
    required this.cartCount,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final int wishlistCount;
  final int cartCount;

  static const _items = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'HOME'),
    _NavItem(
      icon: Icons.favorite_border,
      activeIcon: Icons.favorite,
      label: 'WISHLIST',
    ),
    _NavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: 'ORDERS',
    ),
    _NavItem(
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag,
      label: 'CART',
    ),
    _NavItem(
      icon: Icons.payment_outlined,
      activeIcon: Icons.payment,
      label: 'PAYMENTS',
    ),
    _NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'PROFILE',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ink,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var index = 0; index < _items.length; index++)
                Expanded(
                  child: _NavButton(
                    item: _items[index],
                    active: selectedIndex == index,
                    badge: index == 1
                        ? wishlistCount
                        : index == 3
                        ? cartCount
                        : index == 4
                        ? null
                        : 0,
                    onTap: () => onSelect(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.active,
    required this.badge,
    required this.onTap,
  });

  final _NavItem item;
  final bool active;
  final int? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.paper : AppColors.faint;
    return InkResponse(
      onTap: onTap,
      radius: 32,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(active ? item.activeIcon : item.icon, size: 19, color: color),
              if (badge != null && badge! > 0)
                Positioned(
                  top: -5,
                  right: -8,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 13),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge! > 99 ? '99+' : '$badge',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.micro.copyWith(
                        fontSize: 6,
                        letterSpacing: 0,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            item.label,
            style: AppTextStyles.navLabel.copyWith(
              color: color,
              fontSize: 7,
              letterSpacing: 0.8,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}