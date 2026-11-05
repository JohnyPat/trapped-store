import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';
import '../../utils/auth_guard.dart';
import '../../utils/formatters.dart';
import '../../utils/product_actions.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/product_image.dart';
import '../../widgets/responsive.dart';
import '../../widgets/section_heading.dart';
import '../../widgets/status_chip.dart';
import '../orders/order_details_screen.dart';

enum _OrderFilter { all, active, completed, cancelled }

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  _OrderFilter _filter = _OrderFilter.all;

  List<Order> _applyFilter(List<Order> orders) {
    switch (_filter) {
      case _OrderFilter.all:
        return orders;
      case _OrderFilter.active:
        return orders
            .where((order) => !order.orderStatus.isTerminal)
            .toList();
      case _OrderFilter.completed:
        return orders
            .where((order) => order.orderStatus == OrderStatus.delivered)
            .toList();
      case _OrderFilter.cancelled:
        return orders
            .where((order) => order.orderStatus == OrderStatus.cancelled)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final ordersProvider = context.watch<OrdersProvider>();

    if (!auth.isAuthenticated) {
      return SingleChildScrollView(
        child: ContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 38),
              const SectionHeading(
                title: 'Orders',
                subtitle: 'Track every piece from confirmation to delivery.',
              ),
              const SizedBox(height: 20),
              EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Sign in to view orders',
                message:
                    'Your order history and delivery updates are tied to your account.',
                actionLabel: 'SIGN IN',
                onAction: () => openLogin(context),
              ),
            ],
          ),
        ),
      );
    }

    if (ordersProvider.loading && ordersProvider.orders.isEmpty) {
      return const LoadingState(label: 'LOADING ORDERS');
    }
    if (ordersProvider.error != null && ordersProvider.orders.isEmpty) {
      return ErrorState(
        message: ordersProvider.error!,
        onRetry: ordersProvider.reload,
      );
    }

    final filtered = _applyFilter(ordersProvider.orders);

    return RefreshIndicator(
      color: AppColors.ink,
      onRefresh: () async => ordersProvider.reload(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 38),
              SectionHeading(
                title: 'Orders',
                subtitle: ordersProvider.orders.isEmpty
                    ? 'Track every piece from confirmation to delivery.'
                    : '${ordersProvider.orders.length} ${ordersProvider.orders.length == 1 ? 'order' : 'orders'} placed with [trapped].',
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'ALL',
                      selected: _filter == _OrderFilter.all,
                      onTap: () => setState(() => _filter = _OrderFilter.all),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'ACTIVE',
                      selected: _filter == _OrderFilter.active,
                      onTap: () => setState(() => _filter = _OrderFilter.active),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'COMPLETED',
                      selected: _filter == _OrderFilter.completed,
                      onTap: () =>
                          setState(() => _filter = _OrderFilter.completed),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'CANCELLED',
                      selected: _filter == _OrderFilter.cancelled,
                      onTap: () =>
                          setState(() => _filter = _OrderFilter.cancelled),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (ordersProvider.orders.isEmpty)
                EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No orders yet',
                  message:
                      'When you place an order it will appear here with live status updates.',
                  actionLabel: 'SHOP THE COLLECTION',
                  onAction: () => ProductActions.openCollection(context),
                )
              else if (filtered.isEmpty)
                EmptyState(
                  icon: Icons.filter_alt_off_outlined,
                  title: 'Nothing in this view',
                  message: 'Try another filter to see your orders.',
                  actionLabel: 'SHOW ALL',
                  onAction: () => setState(() => _filter = _OrderFilter.all),
                )
              else
                for (final order in filtered)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _OrderCard(order: order),
                  ),
              const SizedBox(height: 34),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.paper,
          border: Border.all(
            color: selected ? AppColors.ink : AppColors.lineDark,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          label,
          style: AppTextStyles.micro.copyWith(
            fontSize: 7.5,
            letterSpacing: 1.3,
            color: selected ? AppColors.paper : AppColors.ink,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final preview = order.items.take(isMobile ? 3 : 4).toList();
    final remaining = order.items.length - preview.length;
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OrderDetailsScreen(orderId: order.id),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.paper,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.orderNumber,
                    style: AppTextStyles.title.copyWith(
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                OrderStatusChip(status: order.orderStatus, compact: true),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${Formatters.dateTime(order.createdAt)} · ${order.itemCount} ${order.itemCount == 1 ? 'PIECE' : 'PIECES'}',
              style: AppTextStyles.micro.copyWith(
                fontSize: 7,
                letterSpacing: 0.7,
                color: AppColors.muted,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (final item in preview)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 52,
                      height: 62,
                      child: ProductImage(
                        imageUrl: item.imageUrl,
                        fallbackAsset: AppAssets.fallbackForProduct(
                          item.productId,
                        ),
                        padding: const EdgeInsets.all(4),
                      ),
                    ),
                  ),
                if (remaining > 0)
                  Container(
                    width: 52,
                    height: 62,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Text(
                      '+$remaining',
                      style: AppTextStyles.price.copyWith(fontSize: 10),
                    ),
                  ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TOTAL',
                      style: AppTextStyles.micro.copyWith(
                        fontSize: 6.5,
                        letterSpacing: 1.2,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.currency(order.totalAmount),
                      style: AppTextStyles.price.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 13),
            Divider(color: AppColors.line, height: 1),
            const SizedBox(height: 11),
            Row(
              children: [
                PaymentStatusChip(
                  status: order.paymentStatus,
                  compact: true,
                ),
                const SizedBox(width: 8),
                Text(
                  order.paymentMethod.label,
                  style: AppTextStyles.micro.copyWith(
                    fontSize: 6.8,
                    letterSpacing: 0.8,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Text(
                  'VIEW ORDER',
                  style: AppTextStyles.micro.copyWith(
                    fontSize: 7,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward,
                  size: 11,
                  color: AppColors.ink,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
