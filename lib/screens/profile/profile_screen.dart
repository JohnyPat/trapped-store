import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../utils/auth_guard.dart';
import '../../utils/formatters.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive.dart';
import '../../widgets/section_heading.dart';
import '../../widgets/trapped_button.dart';
import '../../admin/services/admin_auth_service.dart';
import '../about/about_screen.dart';
import '../profile/change_password_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/payment_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

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
    if (!confirmed) return;
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orders = context.watch<OrdersProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final cart = context.watch<CartProvider>();

    if (!auth.isAuthenticated) {
      return SingleChildScrollView(
        child: ContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 38),
              const SectionHeading(
                title: 'Profile',
                subtitle: 'Your account, orders and saved pieces in one place.',
              ),
              const SizedBox(height: 20),
              EmptyState(
                icon: Icons.person_outline,
                title: 'Sign in to your account',
                message:
                    'Access your profile, order history, saved pieces and delivery details.',
                actionLabel: 'SIGN IN',
                onAction: () => openLogin(context),
              ),
            ],
          ),
        ),
      );
    }

    final profile = auth.profile;
    final name = profile?.displayName ?? auth.displayName;
    final email = profile?.email.isNotEmpty == true
        ? profile!.email
        : (auth.email ?? '');
    final image = profile?.profileImage ?? '';
    final isDesktop = Breakpoints.isDesktop(context);

    return SingleChildScrollView(
      child: ContentFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 38),
            const SectionHeading(
              title: 'Profile',
              subtitle: 'Your account, orders and saved pieces in one place.',
            ),
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                children: [
                  _Avatar(imageUrl: image, name: name, size: isDesktop ? 86 : 72),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.toUpperCase(),
                          style: AppTextStyles.title.copyWith(
                            color: AppColors.paper,
                            fontSize: isDesktop ? 18 : 15,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          email,
                          style: AppTextStyles.bodyMuted.copyWith(
                            color: AppColors.paper.withValues(alpha: .65),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profile?.createdAt == null
                              ? 'TRAPPED MEMBER'
                              : 'MEMBER SINCE ${Formatters.date(profile!.createdAt).toUpperCase()}',
                          style: AppTextStyles.micro.copyWith(
                            color: AppColors.faint,
                            fontSize: 6.8,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (profile != null && !profile.hasCompleteDeliveryInfo)
              _CompleteProfileBanner(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const EditProfileScreen(),
                  ),
                ),
              ),
            if (profile != null && !profile.hasCompleteDeliveryInfo)
              const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.canvas,
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _Stat(
                      label: 'ORDERS',
                      value: '${orders.count}',
                      onTap: () => onNavigate(2),
                    ),
                  ),
                  Container(width: 1, height: 50, color: AppColors.line),
                  Expanded(
                    child: _Stat(
                      label: 'WISHLIST',
                      value: '${wishlist.count}',
                      onTap: () => onNavigate(1),
                    ),
                  ),
                  Container(width: 1, height: 50, color: AppColors.line),
                  Expanded(
                    child: _Stat(
                      label: 'BAG',
                      value: '${cart.count}',
                      onTap: () => onNavigate(3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _ProfileSection(
              title: 'ACCOUNT',
              children: [
                _ProfileTile(
                  icon: Icons.person_outline,
                  label: 'Edit profile',
                  subtitle: 'Name, phone, delivery address and photo',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  ),
                ),
                _ProfileTile(
                  icon: Icons.lock_outline,
                  label: 'Change password',
                  subtitle: 'Update your account password',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _ProfileSection(
              title: 'SHOPPING',
              children: [
                _ProfileTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'Orders',
                  subtitle: 'Track and manage your orders',
                  onTap: () => onNavigate(2),
                ),
                _ProfileTile(
                  icon: Icons.favorite_border,
                  label: 'Wishlist',
                  subtitle: '${wishlist.count} saved ${wishlist.count == 1 ? 'piece' : 'pieces'}',
                  onTap: () => onNavigate(1),
                ),
                _ProfileTile(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Bag',
                  subtitle: '${cart.count} ${cart.count == 1 ? 'piece' : 'pieces'} ready for checkout',
                  onTap: () => onNavigate(3),
                ),
                _ProfileTile(
                  icon: Icons.payments_outlined,
                  label: 'Payment history',
                  subtitle: 'Cash on delivery payment records',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PaymentHistoryScreen(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _ProfileSection(
              title: 'SUPPORT',
              children: [
                _ProfileTile(
                  icon: Icons.local_shipping_outlined,
                  label: 'Shipping & returns',
                  subtitle: 'Delivery times and our returns policy',
                  onTap: () => showInfoDialog(
                    context,
                    title: 'Shipping & returns',
                    message:
                        'Orders are dispatched within 1–3 business days. Metro Manila delivery takes 1–3 days; provincial delivery takes 3–7 days. Unworn pieces may be returned within 7 days of delivery. Contact ${AppConstants.supportEmail} to start a return.',
                  ),
                ),
                _ProfileTile(
                  icon: Icons.mail_outline,
                  label: 'Contact support',
                  subtitle: AppConstants.supportEmail,
                  onTap: () => showInfoDialog(
                    context,
                    title: 'Contact support',
                    message:
                        'Email ${AppConstants.supportEmail} with your order number and a short description of the issue. Our team replies Monday to Friday, 9AM–6PM PHT.',
                  ),
                ),
                _ProfileTile(
                  icon: Icons.info_outline,
                  label: 'About [trapped]',
                  subtitle: 'Independent streetwear from Manila',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AboutScreen(),
                    ),
                  ),
                ),
              ],
            ),
            const _AdminPanelSection(),
            const SizedBox(height: 30),
            TrappedButton(
              label: 'SIGN OUT',
              onPressed: () => _signOut(context),
              variant: TrappedButtonVariant.outline,
              height: 46,
              fontSize: 9,
            ),
            const SizedBox(height: 44),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.imageUrl,
    required this.name,
    required this.size,
  });

  final String imageUrl;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = Formatters.initials(name);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.paper,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.paper, width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.startsWith('http')
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _initials(initials),
            )
          : _initials(initials),
    );
  }

  Widget _initials(String initials) {
    return Center(
      child: Text(
        initials,
        style: AppTextStyles.displaySmall.copyWith(
          fontSize: size * 0.34,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.displaySmall.copyWith(fontSize: 19),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.micro.copyWith(
                fontSize: 6.5,
                letterSpacing: 1.4,
                color: AppColors.muted,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompleteProfileBanner extends StatelessWidget {
  const _CompleteProfileBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.warningSoft,
          border: Border.all(color: AppColors.warning.withValues(alpha: .3)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.warning,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Complete your phone and delivery address for a faster checkout.',
                style: AppTextStyles.small.copyWith(
                  fontSize: 9.5,
                  color: AppColors.warning,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward,
              size: 14,
              color: AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.children});

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
            fontSize: 8,
            letterSpacing: 2,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.paper,
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.ink),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: AppTextStyles.micro.copyWith(
                      fontSize: 8,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.small.copyWith(
                      fontSize: 9.5,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: AppColors.faint,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the "Admin panel" entry point **only** for accounts whose UID
/// matches `settings/adminUid` in the Realtime Database.
///
/// Regular users and guests see nothing — the admin area is completely
/// hidden instead of just disabled.
class _AdminPanelSection extends StatefulWidget {
  const _AdminPanelSection();

  @override
  State<_AdminPanelSection> createState() => _AdminPanelSectionState();
}

class _AdminPanelSectionState extends State<_AdminPanelSection> {
  /// null = still checking, true = admin, false = not admin
  bool? _isAdmin;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    try {
      final isAdmin = await AdminAuthService().isAdmin;
      if (!mounted) return;
      setState(() => _isAdmin = isAdmin);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isAdmin = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Secure by default: stay hidden until the admin check passes
    if (_isAdmin != true) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: _ProfileSection(
        title: 'ADMIN',
        children: [
          _ProfileTile(
            icon: Icons.admin_panel_settings_outlined,
            label: 'Admin panel',
            subtitle: 'Manage products, orders and customers',
            onTap: () => Navigator.of(context).pushNamed('/admin/login'),
          ),
        ],
      ),
    );
  }
}