import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_text_styles.dart';
import '../../models/cart_line.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../utils/app_snack.dart';
import '../../utils/auth_guard.dart';
import '../../utils/formatters.dart';
import '../../utils/product_actions.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/product_image.dart';
import '../../widgets/quantity_selector.dart';
import '../../widgets/responsive.dart';
import '../../widgets/section_heading.dart';
import '../../widgets/trapped_button.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _busy = false;

  Future<void> _changeQuantity(
    CartProvider cart,
    CartLine line,
    int next,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (next <= 0) {
        await cart.remove(line.item);
      } else if (next > line.item.quantity) {
        await cart.increment(line.item, line.product);
      } else {
        await cart.decrement(line.item);
      }
    } catch (error) {
      if (!mounted) return;
      AppSnack.error(context, error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove(CartProvider cart, CartLine line) async {
    try {
      await cart.remove(line.item);
      if (!mounted) return;
      AppSnack.show(context, '${line.product.name} removed from your bag.');
    } catch (error) {
      if (!mounted) return;
      AppSnack.error(context, error.toString());
    }
  }

  Future<void> _removeUnavailable(CartProvider cart, CatalogProvider catalog) async {
    try {
      for (final item in [...cart.items]) {
        final product = catalog.productById(item.productId);
        if (product == null || !product.active) {
          await cart.remove(item);
        }
      }
      if (!mounted) return;
      AppSnack.show(context, 'Unavailable pieces removed from your bag.');
    } catch (error) {
      if (!mounted) return;
      AppSnack.error(context, error.toString());
    }
  }

  Future<void> _clear(CartProvider cart) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Clear your bag',
      message: 'Remove every piece from your bag? This cannot be undone.',
      confirmLabel: 'CLEAR BAG',
      destructive: true,
    );
    if (!confirmed) return;
    try {
      await cart.clear();
      if (!mounted) return;
      AppSnack.show(context, 'Your bag is now empty.');
    } catch (error) {
      if (!mounted) return;
      AppSnack.error(context, error.toString());
    }
  }

  Future<void> _checkout(
    CartProvider cart,
    CatalogProvider catalog,
  ) async {
    if (!await ensureSignedIn(context)) return;
    if (!mounted) return;
    final validation = cart.validateForCheckout(catalog.productMap);
    if (validation != null) {
      AppSnack.error(context, validation);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CheckoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final catalog = context.watch<CatalogProvider>();
    final cart = context.watch<CartProvider>();
    final isDesktop = Breakpoints.isDesktop(context);

    if (!auth.isAuthenticated) {
      return SingleChildScrollView(
        child: ContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 38),
              const SectionHeading(
                title: 'Your bag',
                subtitle: 'Sign in to build a bag that syncs everywhere.',
              ),
              const SizedBox(height: 20),
              EmptyState(
                icon: Icons.shopping_bag_outlined,
                title: 'Sign in to start a bag',
                message:
                    'Your bag is saved to your account, so you can finish checkout on any device.',
                actionLabel: 'SIGN IN',
                onAction: () => openLogin(context),
              ),
            ],
          ),
        ),
      );
    }

    if (catalog.loading && catalog.products.isEmpty) {
      return const LoadingState(label: 'LOADING YOUR BAG');
    }

    final lines = cart.lines(catalog.productMap);
    final unavailable = cart.items.length - lines.length;
    final subtotal = cart.subtotal(catalog.productMap);
    final shipping = cart.shippingFee(catalog.productMap);
    final total = cart.total(catalog.productMap);

    return SingleChildScrollView(
      child: ContentFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 38),
            SectionHeading(
              title: 'Your bag',
              subtitle: cart.isEmpty
                  ? 'Nothing in here yet. The next drop is waiting.'
                  : '${cart.count} ${cart.count == 1 ? 'piece' : 'pieces'} ready for checkout.',
            ),
            const SizedBox(height: 24),
            if (cart.isEmpty)
              EmptyState(
                icon: Icons.shopping_bag_outlined,
                title: 'Your bag is empty',
                message:
                    'Browse the collection and add the pieces that speak to you.',
                actionLabel: 'SHOP THE COLLECTION',
                onAction: () => ProductActions.openCollection(context),
              )
            else if (lines.isEmpty)
              EmptyState(
                icon: Icons.remove_shopping_cart_outlined,
                title: 'Pieces no longer available',
                message:
                    'The pieces in your bag have been removed from the store. Clear them to start again.',
                actionLabel: 'CLEAR UNAVAILABLE',
                onAction: () => _removeUnavailable(cart, catalog),
              )
            else ...[
              if (unavailable > 0)
                _UnavailableBanner(
                  count: unavailable,
                  onRemove: () => _removeUnavailable(cart, catalog),
                ),
              if (unavailable > 0) const SizedBox(height: 14),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          for (final line in lines)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _CartLineTile(
                                line: line,
                                busy: _busy,
                                onChangeQuantity: (value) =>
                                    _changeQuantity(cart, line, value),
                                onRemove: () => _remove(cart, line),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () => _clear(cart),
                              child: Text(
                                'CLEAR BAG',
                                style: AppTextStyles.micro.copyWith(
                                  fontSize: 8,
                                  letterSpacing: 1.8,
                                  color: AppColors.muted,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.muted,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 34),
                    Expanded(
                      flex: 2,
                      child: _OrderSummary(
                        subtotal: subtotal,
                        shipping: shipping,
                        total: total,
                        onCheckout: () => _checkout(cart, catalog),
                        onContinue: () => ProductActions.openCollection(context),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final line in lines)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CartLineTile(
                          line: line,
                          busy: _busy,
                          onChangeQuantity: (value) =>
                              _changeQuantity(cart, line, value),
                          onRemove: () => _remove(cart, line),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => _clear(cart),
                        child: Text(
                          'CLEAR BAG',
                          style: AppTextStyles.micro.copyWith(
                            fontSize: 8,
                            letterSpacing: 1.8,
                            color: AppColors.muted,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.muted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _OrderSummary(
                      subtotal: subtotal,
                      shipping: shipping,
                      total: total,
                      onCheckout: () => _checkout(cart, catalog),
                      onContinue: () => ProductActions.openCollection(context),
                    ),
                  ],
                ),
            ],
            const SizedBox(height: 44),
          ],
        ),
      ),
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({
    required this.line,
    required this.busy,
    required this.onChangeQuantity,
    required this.onRemove,
  });

  final CartLine line;
  final bool busy;
  final ValueChanged<int> onChangeQuantity;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final product = line.product;
    final isMobile = Breakpoints.isMobile(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isMobile ? 82 : 96,
            height: isMobile ? 100 : 118,
            child: ProductImage(
              imageUrl: product.imageUrl,
              fallbackAsset: product.localFallback,
              padding: const EdgeInsets.all(7),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => ProductActions.open(context, product),
                        child: Text(
                          product.name.toUpperCase(),
                          style: AppTextStyles.title.copyWith(
                            fontSize: isMobile ? 10.5 : 11.5,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onRemove,
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(
                          Icons.close,
                          size: 15,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'SIZE ${line.item.size}',
                  style: AppTextStyles.micro.copyWith(
                    fontSize: 7.5,
                    letterSpacing: 1.2,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Formatters.currency(product.price),
                  style: AppTextStyles.price.copyWith(fontSize: 11.5),
                ),
                if (product.isLowStock) ...[
                  const SizedBox(height: 4),
                  Text(
                    'ONLY ${product.stock} LEFT',
                    style: AppTextStyles.micro.copyWith(
                      fontSize: 6.5,
                      letterSpacing: 0.8,
                      color: AppColors.warning,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    QuantitySelector(
                      quantity: line.item.quantity,
                      compact: true,
                      canDecrement: !busy,
                      canIncrement: !busy && line.item.quantity < product.stock,
                      onDecrement: () =>
                          onChangeQuantity(line.item.quantity - 1),
                      onIncrement: () =>
                          onChangeQuantity(line.item.quantity + 1),
                    ),
                    const Spacer(),
                    Text(
                      Formatters.currency(line.lineTotal),
                      style: AppTextStyles.price.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.onCheckout,
    required this.onContinue,
  });

  final double subtotal;
  final double shipping;
  final double total;
  final VoidCallback onCheckout;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final remaining =
        AppConstants.freeShippingThreshold - subtotal;
    final progress = (subtotal / AppConstants.freeShippingThreshold).clamp(
      0.0,
      1.0,
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ORDER SUMMARY',
            style: AppTextStyles.micro.copyWith(
              fontSize: 8,
              letterSpacing: 2,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 18),
          _SummaryRow(label: 'Subtotal', value: Formatters.currency(subtotal)),
          const SizedBox(height: 11),
          _SummaryRow(
            label: 'Shipping',
            value: shipping == 0 ? 'FREE' : Formatters.currency(shipping),
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.lineDark, height: 1),
          const SizedBox(height: 16),
          _SummaryRow(
            label: 'Total',
            value: Formatters.currency(total),
            emphasize: true,
          ),
          const SizedBox(height: 18),
          if (remaining > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                backgroundColor: AppColors.line,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ADD ${Formatters.currency(remaining)} MORE FOR FREE SHIPPING',
              style: AppTextStyles.micro.copyWith(
                fontSize: 6.8,
                letterSpacing: 0.9,
                color: AppColors.muted,
                fontWeight: FontWeight.w400,
              ),
            ),
          ] else
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 13,
                  color: AppColors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  'YOU QUALIFY FOR FREE SHIPPING',
                  style: AppTextStyles.micro.copyWith(
                    fontSize: 6.8,
                    letterSpacing: 0.9,
                    color: AppColors.success,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          TrappedButton(
            label: 'PROCEED TO CHECKOUT',
            onPressed: onCheckout,
            height: 48,
            fontSize: 9.5,
          ),
          const SizedBox(height: 10),
          TrappedButton(
            label: 'CONTINUE SHOPPING',
            onPressed: onContinue,
            variant: TrappedButtonVariant.outline,
            height: 44,
            fontSize: 9,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 12,
                color: AppColors.muted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'CASH ON DELIVERY ONLY · ONLINE PAYMENT COMING SOON',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.micro.copyWith(
                    fontSize: 6.2,
                    letterSpacing: 0.7,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
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

class _UnavailableBanner extends StatelessWidget {
  const _UnavailableBanner({required this.count, required this.onRemove});

  final int count;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              '$count ${count == 1 ? 'piece is' : 'pieces are'} no longer available and will be excluded from checkout.',
              style: AppTextStyles.small.copyWith(
                fontSize: 9.5,
                color: AppColors.warning,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onRemove,
            child: Text(
              'REMOVE',
              style: AppTextStyles.micro.copyWith(
                fontSize: 7,
                letterSpacing: 1,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
