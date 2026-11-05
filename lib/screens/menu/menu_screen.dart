import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/responsive.dart';
import '../auth/login_screen.dart';
import '../about/about_screen.dart';
import '../collection/collection_screen.dart';
import '../search/search_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  void _goToTab(BuildContext context, int index) {
    Navigator.of(context).pop();
    onNavigate(index);
  }

  void _openCollection(
    BuildContext context, {
    String? categoryId,
    required String title,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => CollectionScreen(categoryId: categoryId, title: title),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Sign out',
      message:
          'Your bag and wishlist stay saved to your account. You can sign back in anytime.',
      confirmLabel: 'SIGN OUT',
      cancelLabel: 'STAY',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 62,
              child: ContentFrame(
                child: Row(
                  children: [
                    IconButton(
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.paper,
                        size: 22,
                      ),
                    ),
                    const Expanded(
                      child: Center(child: BrandLogo(fontSize: 19)),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
            ),
            Divider(color: AppColors.paper.withValues(alpha: .16), height: 1),
            Expanded(
              child: SingleChildScrollView(
                child: ContentFrame(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 34),
                        if (auth.isAuthenticated)
                          Text(
                            'HELLO, ${auth.displayName.toUpperCase()}',
                            style: AppTextStyles.micro.copyWith(
                              color: AppColors.faint,
                              fontSize: 8,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        else
                          Text(
                            'BROWSE AS GUEST',
                            style: AppTextStyles.micro.copyWith(
                              color: AppColors.faint,
                              fontSize: 8,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        const SizedBox(height: 26),
                        _MenuSection(
                          title: 'SHOP',
                          children: [
                            _MenuLink(
                              label: 'Home',
                              onTap: () => _goToTab(context, 0),
                            ),
                            _MenuLink(
                              label: 'About us',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const AboutScreen(),
                                ),
                              ),
                            ),
                            _MenuLink(
                              label: 'Shop all',
                              onTap: () => _openCollection(
                                context,
                                title: 'ALL PRODUCTS',
                              ),
                            ),
                            _MenuLink(
                              label: 'New arrivals',
                              onTap: () => _openCollection(
                                context,
                                title: 'NEW ARRIVALS',
                              ),
                            ),
                            _MenuLink(
                              label: 'Shirts',
                              onTap: () => _openCollection(
                                context,
                                categoryId: 'cat-shirts',
                                title: 'SHIRTS',
                              ),
                            ),
                            _MenuLink(
                              label: 'Shorts',
                              onTap: () => _openCollection(
                                context,
                                categoryId: 'cat-pants',
                                title: 'SHORTS',
                              ),
                            ),
                            _MenuLink(
                              label: 'Headwear',
                              onTap: () => _openCollection(
                                context,
                                categoryId: 'cat-headwear',
                                title: 'HEADWEAR',
                              ),
                            ),
                            _MenuLink(
                              label: 'Search',
                              onTap: () => Navigator.of(context).pushReplacement(
                                MaterialPageRoute<void>(
                                  builder: (_) => const SearchScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        _MenuSection(
                          title: 'ACCOUNT',
                          children: auth.isAuthenticated
                              ? [
                                  _MenuLink(
                                    label: 'Wishlist',
                                    onTap: () => _goToTab(context, 1),
                                  ),
                                  _MenuLink(
                                    label: 'Orders',
                                    onTap: () => _goToTab(context, 2),
                                  ),
                                  _MenuLink(
                                    label: 'Bag',
                                    onTap: () => _goToTab(context, 3),
                                  ),
                                  _MenuLink(
                                    label: 'Profile',
                                    onTap: () => _goToTab(context, 4),
                                  ),
                                  _MenuLink(
                                    label: 'Sign out',
                                    danger: true,
                                    onTap: () => _signOut(context),
                                  ),
                                ]
                              : [
                                  _MenuLink(
                                    label: 'Sign in / Create account',
                                    onTap: () =>
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute<void>(
                                            builder: (_) => const LoginScreen(),
                                          ),
                                        ),
                                  ),
                                  _MenuLink(
                                    label: 'Wishlist',
                                    onTap: () => _goToTab(context, 1),
                                  ),
                                  _MenuLink(
                                    label: 'Orders',
                                    onTap: () => _goToTab(context, 2),
                                  ),
                                  _MenuLink(
                                    label: 'Bag',
                                    onTap: () => _goToTab(context, 3),
                                  ),
                                  _MenuLink(
                                    label: 'Profile',
                                    onTap: () => _goToTab(context, 4),
                                  ),
                                ],
                        ),
                        const SizedBox(height: 36),
                        Divider(
                          color: AppColors.paper.withValues(alpha: .16),
                          height: 1,
                        ),
                        const SizedBox(height: 22),
                        Text(
                          AppConstants.supportEmail.toUpperCase(),
                          style: AppTextStyles.micro.copyWith(
                            color: AppColors.faint,
                            fontSize: 7.5,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'MANILA, PHILIPPINES · SHIPS NATIONWIDE',
                          style: AppTextStyles.micro.copyWith(
                            color: AppColors.faint,
                            fontSize: 7,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          AppConstants.tagline,
                          style: AppTextStyles.micro.copyWith(
                            color: AppColors.paper.withValues(alpha: .5),
                            fontSize: 7,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 34),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: AppTextStyles.micro.copyWith(
            color: AppColors.faint,
            fontSize: 7.5,
            letterSpacing: 2.4,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}

class _MenuLink extends StatelessWidget {
  const _MenuLink({
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.paper.withValues(alpha: .12)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: AppTextStyles.micro.copyWith(
                  color: danger ? AppColors.errorSoft : AppColors.paper,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(
              Icons.arrow_outward,
              size: 15,
              color: danger
                  ? AppColors.errorSoft.withValues(alpha: .7)
                  : AppColors.faint,
            ),
          ],
        ),
      ),
    );
  }
}
