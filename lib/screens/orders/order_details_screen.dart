import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_text_styles.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';
import '../../services/order_service.dart';
import '../../utils/app_snack.dart';
import '../../utils/auth_guard.dart';
import '../../utils/formatters.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/order_timeline.dart';
import '../../widgets/product_image.dart';
import '../../widgets/responsive.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/trapped_button.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final OrderService _orderService = OrderService();
  bool _cancelling = false;

  Future<void> _cancel(Order order) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Cancel order',
      message:
          'Cancel ${order.orderNumber}? Reserved stock will be released back to the store.',
      confirmLabel: 'CANCEL ORDER',
      cancelLabel: 'KEEP ORDER',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _cancelling = true);
    try {
      await context.read<OrdersProvider>().cancelOrder(order);
      if (!mounted) return;
      AppSnack.show(context, 'Order cancelled.');
    } catch (error) {
      if (!mounted) return;
      AppSnack.error(context, error.toString());
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final uid = auth.uid;
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Column(
        children: [
          BrandHeader(
            onLeading: () => Navigator.of(context).maybePop(),
            leadingIcon: Icons.arrow_back,
          ),
          Expanded(
            child: uid == null
                ? EmptyState(
                    icon: Icons.lock_outline,
                    title: 'Sign in required',
                    message:
                        'Sign in to view this order and its delivery updates.',
                    actionLabel: 'SIGN IN',
                    onAction: () => openLogin(context),
                  )
                : StreamBuilder<Order?>(
                    stream: _orderService.watchOrder(uid, widget.orderId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return ErrorState(
                          message: 'This order could not be loaded.',
                          onRetry: () => setState(() {}),
                        );
                      }
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const LoadingState(label: 'LOADING ORDER');
                      }
                      final order = snapshot.data;
                      if (order == null) {
                        return const EmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: 'Order not found',
                          message:
                              'This order does not exist or is not linked to your account.',
                        );
                      }
                      return _buildOrder(context, order);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrder(BuildContext context, Order order) {
    final isDesktop = Breakpoints.isDesktop(context);
    return SingleChildScrollView(
      child: ContentFrame(
        maxWidth: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 34),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ORDER',
                        style: AppTextStyles.label.copyWith(
                          fontSize: 10,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        order.orderNumber,
                        style: AppTextStyles.displaySmall.copyWith(
                          fontSize: isDesktop ? 28 : 22,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PLACED ${Formatters.dateTime(order.createdAt).toUpperCase()}',
                        style: AppTextStyles.micro.copyWith(
                          fontSize: 7,
                          letterSpacing: 1.2,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    OrderStatusChip(status: order.orderStatus),
                    const SizedBox(height: 8),
                    PaymentStatusChip(status: order.paymentStatus, compact: true),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(3),
              ),
              child: OrderTimeline(
                status: order.orderStatus,
                history: order.statusHistory,
              ),
            ),
            if (order.notes.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              _InfoBlock(
                title: 'DELIVERY NOTES',
                children: [
                  Text(
                    order.notes,
                    style: AppTextStyles.bodyMuted.copyWith(
                      fontSize: 10,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 26),
            Text(
              'ITEMS',
              style: AppTextStyles.micro.copyWith(
                fontSize: 8,
                letterSpacing: 2,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 12),
            for (final item in order.items)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  border: Border.all(color: AppColors.line),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 62,
                      height: 74,
                      child: ProductImage(
                        imageUrl: item.imageUrl,
                        fallbackAsset: AppAssets.fallbackForProduct(
                          item.productId,
                        ),
                        padding: const EdgeInsets.all(5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name.toUpperCase(),
                            style: AppTextStyles.title.copyWith(
                              fontSize: 10.5,
                              letterSpacing: 0.7,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'SIZE ${item.size} · QTY ${item.quantity}',
                            style: AppTextStyles.micro.copyWith(
                              fontSize: 7,
                              letterSpacing: 1,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            '${Formatters.currency(item.price)} EACH',
                            style: AppTextStyles.micro.copyWith(
                              fontSize: 6.8,
                              letterSpacing: 0.7,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      Formatters.currency(item.lineTotal),
                      style: AppTextStyles.price.copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    label: 'Subtotal',
                    value: Formatters.currency(order.subtotal),
                  ),
                  const SizedBox(height: 10),
                  _SummaryRow(
                    label: 'Shipping',
                    value: order.shippingFee == 0
                        ? 'FREE'
                        : Formatters.currency(order.shippingFee),
                  ),
                  const SizedBox(height: 14),
                  Divider(color: AppColors.lineDark, height: 1),
                  const SizedBox(height: 14),
                  _SummaryRow(
                    label: 'Total',
                    value: Formatters.currency(order.totalAmount),
                    emphasize: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _InfoBlock(
                      title: 'DELIVERY ADDRESS',
                      children: [
                        Text(
                          order.deliveryAddress.fullName,
                          style: AppTextStyles.body.copyWith(fontSize: 11.5),
                        ),
                        const SizedBox(height: 6),
                        for (final line in order.deliveryAddress.lines)
                          Text(
                            line,
                            style: AppTextStyles.bodyMuted.copyWith(
                              fontSize: 10,
                              height: 1.6,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          order.deliveryAddress.phone,
                          style: AppTextStyles.bodyMuted.copyWith(
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          order.deliveryAddress.email,
                          style: AppTextStyles.bodyMuted.copyWith(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _InfoBlock(
                      title: 'PAYMENT',
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                order.paymentMethod.label,
                                style: AppTextStyles.micro.copyWith(
                                  fontSize: 8,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            PaymentStatusChip(
                              status: order.paymentStatus,
                              compact: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          order.paymentMethod == PaymentMethod.cod
                              ? 'Pay the courier in cash when your order arrives. Online payment is not enabled.'
                              : 'Online payment is not enabled for this store.',
                          style: AppTextStyles.bodyMuted.copyWith(
                            fontSize: 9.5,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else ...[
              _InfoBlock(
                title: 'DELIVERY ADDRESS',
                children: [
                  Text(
                    order.deliveryAddress.fullName,
                    style: AppTextStyles.body.copyWith(fontSize: 11.5),
                  ),
                  const SizedBox(height: 6),
                  for (final line in order.deliveryAddress.lines)
                    Text(
                      line,
                      style: AppTextStyles.bodyMuted.copyWith(
                        fontSize: 10,
                        height: 1.6,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    order.deliveryAddress.phone,
                    style: AppTextStyles.bodyMuted.copyWith(fontSize: 10),
                  ),
                  Text(
                    order.deliveryAddress.email,
                    style: AppTextStyles.bodyMuted.copyWith(fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _InfoBlock(
                title: 'PAYMENT',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.paymentMethod.label,
                          style: AppTextStyles.micro.copyWith(
                            fontSize: 8,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      PaymentStatusChip(
                        status: order.paymentStatus,
                        compact: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    order.paymentMethod == PaymentMethod.cod
                        ? 'Pay the courier in cash when your order arrives. Online payment is not enabled.'
                        : 'Online payment is not enabled for this store.',
                    style: AppTextStyles.bodyMuted.copyWith(
                      fontSize: 9.5,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 26),
            if (order.canCancel) ...[
              TrappedButton(
                label: 'CANCEL ORDER',
                onPressed: _cancelling ? null : () => _cancel(order),
                variant: TrappedButtonVariant.outline,
                loading: _cancelling,
                height: 46,
                fontSize: 9,
              ),
              const SizedBox(height: 10),
            ],
            TrappedButton(
              label: 'CONTACT SUPPORT',
              onPressed: () => showInfoDialog(
                context,
                title: 'Order support',
                message:
                    'Questions about ${order.orderNumber}? Email ${AppConstants.supportEmail} and include your order number. Our team replies within one business day.',
              ),
              variant: TrappedButtonVariant.text,
              height: 42,
              fontSize: 8.5,
            ),
            const SizedBox(height: 46),
          ],
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTextStyles.micro.copyWith(
              fontSize: 7.5,
              letterSpacing: 1.8,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label.toUpperCase(),
            style: AppTextStyles.micro.copyWith(
              fontSize: emphasize ? 9 : 8,
              letterSpacing: emphasize ? 1.8 : 1.2,
              color: emphasize ? AppColors.ink : AppColors.muted,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.price.copyWith(
            fontSize: emphasize ? 14 : 11,
          ),
        ),
      ],
    );
  }
}
