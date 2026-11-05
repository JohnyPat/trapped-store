import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/brand_header.dart';
import '../widgets/responsive.dart';
import 'cart/cart_screen.dart';
import 'home/home_screen.dart';
import 'menu/menu_screen.dart';
import 'orders/orders_screen.dart';
import 'profile/payment_history_screen.dart';
import 'profile/profile_screen.dart';
import 'search/search_screen.dart';
import 'wishlist/wishlist_screen.dart';

/// The signed-in (or guest) application shell. Tab indexes match the bottom
/// navigation: 0 home, 1 wishlist, 2 orders, 3 cart, 4 payments, 5 profile.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onNavigate: _select),
      const WishlistScreen(),
      const OrdersScreen(),
      const CartScreen(),
      const PaymentHistoryScreen(embedded: true),
      ProfileScreen(onNavigate: _select),
    ];
  }

  void _select(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  void _openMenu() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MenuScreen(onNavigate: _select),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(context);
    final auth = context.watch<AuthProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Column(
        children: [
          if (isDesktop)
            DesktopHeader(
              selectedIndex: _index,
              onSelect: _select,
              onSearch: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
              ),
              onProfile: () => _select(5),
              onCart: () => _select(3),
              onWishlist: () => _select(1),
              isSignedIn: auth.isAuthenticated,
              wishlistCount: wishlist.count,
              cartCount: cart.count,
            )
          else
            BrandHeader(
              onLeading: _openMenu,
              trailing: _HeaderBag(
                count: cart.count,
                onTap: () => _select(3),
              ),
            ),
          Expanded(
            child: IndexedStack(index: _index, children: _screens),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : TrappedBottomNav(
              selectedIndex: _index,
              onSelect: _select,
              wishlistCount: wishlist.count,
              cartCount: cart.count,
            ),
    );
  }
}

class _HeaderBag extends StatelessWidget {
  const _HeaderBag({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: 20,
      onPressed: onTap,
      padding: EdgeInsets.zero,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            color: AppColors.paper,
            size: 20,
          ),
          if (count > 0)
            Positioned(
              top: -5,
              right: -7,
              child: Container(
                constraints: const BoxConstraints(minWidth: 13),
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
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
    );
  }
}
