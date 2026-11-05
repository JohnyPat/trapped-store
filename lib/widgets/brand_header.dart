import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'brand_logo.dart';
import 'responsive.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({
    super.key,
    this.onLeading,
    this.leadingIcon = Icons.menu,
    this.trailing,
    this.showLogo = true,
    this.height = 62,
  });

  final VoidCallback? onLeading;
  final IconData leadingIcon;
  final Widget? trailing;
  final bool showLogo;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ink,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: height,
          child: ContentFrame(
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  child: onLeading == null
                      ? null
                      : IconButton(
                          onPressed: onLeading,
                          splashRadius: 22,
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          icon: Icon(
                            leadingIcon,
                            size: 20,
                            color: AppColors.paper,
                          ),
                        ),
                ),
                Expanded(
                  child: Center(
                    child: showLogo
                        ? const BrandLogo(fontSize: 19)
                        : const SizedBox.shrink(),
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: trailing == null
                      ? null
                      : Align(alignment: Alignment.centerRight, child: trailing),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DesktopHeader extends StatelessWidget {
  const DesktopHeader({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.onSearch,
    required this.onProfile,
    required this.onCart,
    required this.onWishlist,
    required this.isSignedIn,
    required this.wishlistCount,
    required this.cartCount,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onSearch;
  final VoidCallback onProfile;
  final VoidCallback onCart;
  final VoidCallback onWishlist;
  final bool isSignedIn;
  final int wishlistCount;
  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ink,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 76,
          child: ContentFrame(
            child: Row(
              children: [
                InkWell(
                  onTap: () => onSelect(0),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: BrandLogo(fontSize: 21),
                  ),
                ),
                const SizedBox(width: 42),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _NavLink(
                        label: 'HOME',
                        active: selectedIndex == 0,
                        onTap: () => onSelect(0),
                      ),
                      _NavLink(
                        label: 'WISHLIST',
                        active: selectedIndex == 1,
                        onTap: onWishlist,
                        badge: wishlistCount,
                      ),
                      _NavLink(
                        label: 'ORDERS',
                        active: selectedIndex == 2,
                        onTap: () => onSelect(2),
                      ),
                      _NavLink(
                        label: 'PAYMENTS',
                        active: selectedIndex == 4,
                        onTap: () => onSelect(4),
                      ),
                      _NavLink(
                        label: 'PROFILE',
                        active: selectedIndex == 5,
                        onTap: onProfile,
                      ),
                    ],
                  ),
                ),
                _HeaderIcon(
                  icon: Icons.search,
                  onTap: onSearch,
                  tooltip: 'Search',
                ),
                _HeaderIcon(
                  icon: Icons.shopping_bag_outlined,
                  onTap: onCart,
                  tooltip: 'Bag',
                  badge: cartCount,
                ),
                if (!isSignedIn)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: TextButton(
                      onPressed: onProfile,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.paper,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: AppColors.paper),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      child: Text(
                        'SIGN IN',
                        style: AppTextStyles.micro.copyWith(
                          color: AppColors.paper,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.active,
    required this.onTap,
    this.badge = 0,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.micro.copyWith(
                    fontSize: 8,
                    letterSpacing: 1.8,
                    color: active ? AppColors.paper : AppColors.faint,
                  ),
                ),
                if (badge > 0) ...[
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badge',
                      style: AppTextStyles.micro.copyWith(
                        fontSize: 6.5,
                        letterSpacing: 0,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: active ? 18 : 0,
              height: 1,
              color: AppColors.paper,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.badge = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 18, color: AppColors.paper),
              if (badge > 0)
                Positioned(
                  top: -5,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge > 99 ? '99+' : '$badge',
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
        ),
      ),
    );
  }
}
