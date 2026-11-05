import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/order.dart';
import '../../utils/app_snack.dart';
import '../../utils/formatters.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/product_image.dart';
import '../../widgets/responsive.dart';
import '../../widgets/trapped_button.dart';
import '../orders/order_details_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Column(
        children: [
          BrandHeader(
            onLeading: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            leadingIcon: Icons.close,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ContentFrame(
                maxWidth: 640,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 46),
                    Center(
                      child: Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.ink, width: 1.2),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: AppColors.paper,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'ORDER CONFIRMED',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.label.copyWith(
                        fontSize: 12,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Thank you. We have received your order and will confirm it before dispatch.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMuted.copyWith(
                        fontSize: 10.5,
                        height: 1.75,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: InkWell(
                        onTap: () async {
                          await Clipboard.setData(
                            ClipboardData(text: order.orderNumber),
                          );
                          if (!context.mounted) return;
                          AppSnack.show(context, 'Order number copied.');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.canvas,
                            border: Border.all(color: AppColors.line),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                order.orderNumber,
                                style: AppTextStyles.price.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.copy,
                                size: 12,
                                color: AppColors.muted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        border: Border.all(color: AppColors.line),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'ORDER DETAILS',
                            style: AppTextStyles.micro.copyWith(
                              fontSize: 8,
                              letterSpacing: 2,
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 14),
                          for (final item in order.items)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 46,
                                    height: 56,
                                    child: ProductImage(
                                      imageUrl: item.imageUrl,
                                      fallbackAsset:
                                          AppAssets.fallbackForProduct(
                                            item.productId,
                                          ),
                                      padding: const EdgeInsets.all(4),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name.toUpperCase(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.micro.copyWith(
                                            fontSize: 7.5,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'SIZE ${item.size} · QTY ${item.quantity}',
                                          style: AppTextStyles.micro.copyWith(
                                            fontSize: 6.5,
                                            letterSpacing: 0.6,
                                            color: AppColors.muted,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    Formatters.currency(item.lineTotal),
                                    style: AppTextStyles.price.copyWith(
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Divider(color: AppColors.lineDark, height: 1),
                          const SizedBox(height: 14),
                          _Row(
                            label: 'Subtotal',
                            value: Formatters.currency(order.subtotal),
                          ),
                          const SizedBox(height: 9),
                          _Row(
                            label: 'Shipping',
                            value: order.shippingFee == 0
                                ? 'FREE'
                                : Formatters.currency(order.shippingFee),
                          ),
                          const SizedBox(height: 13),
                          _Row(
                            label: 'Total',
                            value: Formatters.currency(order.totalAmount),
                            emphasize: true,
                          ),
                          const SizedBox(height: 16),
                          Divider(color: AppColors.lineDark, height: 1),
                          const SizedBox(height: 14),
                          _Row(
                            label: 'Payment',
                            value: order.paymentMethod.label,
                          ),
                          const SizedBox(height: 9),
                          _Row(
                            label: 'Deliver to',
                            value: order.deliveryAddress.fullName,
                          ),
                          const SizedBox(height: 9),
                          _Row(
                            label: 'Address',
                            value: order.deliveryAddress.oneLine,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    TrappedButton(
                      label: 'VIEW ORDER',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              OrderDetailsScreen(orderId: order.id),
                        ),
                      ),
                      height: 48,
                    ),
                    const SizedBox(height: 10),
                    TrappedButton(
                      label: 'CONTINUE SHOPPING',
                      onPressed: () =>
                          Navigator.of(context).popUntil((route) => route.isFirst),
                      variant: TrappedButtonVariant.outline,
                      height: 46,
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label.toUpperCase(),
            style: AppTextStyles.micro.copyWith(
              fontSize: emphasize ? 8.5 : 7.5,
              letterSpacing: emphasize ? 1.4 : 1,
              color: emphasize ? AppColors.ink : AppColors.muted,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.price.copyWith(
              fontSize: emphasize ? 13 : 10,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
