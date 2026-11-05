import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/payment.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payments_provider.dart';
import '../../services/payment_service.dart';
import '../../utils/auth_guard.dart';
import '../../utils/formatters.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/responsive.dart';
import '../../widgets/status_chip.dart';
import '../orders/order_details_screen.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key, this.embedded = false});

  /// True when shown as the PAYMENTS tab inside the app shell
  /// (the shell already renders its own header).
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final paymentsProvider = context.watch<PaymentsProvider>();
    final isDesktop = Breakpoints.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Column(
        children: [
          if (!embedded)
            BrandHeader(
              onLeading: () => Navigator.of(context).pop(),
              leadingIcon: Icons.arrow_back,
            ),
          Expanded(
            child: !auth.isAuthenticated
                ? EmptyState(
                    icon: Icons.lock_outline,
                    title: 'Sign in required',
                    message:
                        'Sign in to see the payment record for every order.',
                    actionLabel: 'SIGN IN',
                    onAction: () => openLogin(context),
                  )
                : SingleChildScrollView(
                    child: ContentFrame(
                      maxWidth: 820,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 32),
                          Text(
                            'PAYMENT HISTORY',
                            style: AppTextStyles.label.copyWith(
                              fontSize: 11,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Every order records its payment method and status here.',
                            style: AppTextStyles.bodyMuted.copyWith(
                              fontSize: 10.5,
                              height: 1.7,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.canvas,
                              border: Border.all(color: AppColors.line),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: AppColors.muted,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    PaymentService.onlinePaymentsConfigured
                                        ? 'Online payments are verified by the payment provider before an order is marked paid.'
                                        : 'Cash on delivery only. Online payment is disabled until a verified payment provider and backend are configured, so no payment is ever simulated.',
                                    style: AppTextStyles.small.copyWith(
                                      fontSize: 9.5,
                                      height: 1.65,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          if (paymentsProvider.loading &&
                              paymentsProvider.payments.isEmpty)
                            const LoadingState(label: 'LOADING PAYMENTS')
                          else if (paymentsProvider.error != null &&
                              paymentsProvider.payments.isEmpty)
                            ErrorState(
                              message: paymentsProvider.error!,
                              onRetry: paymentsProvider.reload,
                            )
                          else if (paymentsProvider.payments.isEmpty)
                            const EmptyState(
                              icon: Icons.payments_outlined,
                              title: 'No payments yet',
                              message:
                                  'Your payment records will appear here after your first order.',
                            )
                          else ...[
                            _Totals(payments: paymentsProvider.payments),
                            const SizedBox(height: 18),
                            if (isDesktop)
                              Wrap(
                                spacing: 14,
                                runSpacing: 14,
                                children: [
                                  for (final payment
                                      in paymentsProvider.payments)
                                    SizedBox(
                                      width: 390,
                                      child: _PaymentCard(payment: payment),
                                    ),
                                ],
                              )
                            else
                              for (final payment in paymentsProvider.payments)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _PaymentCard(payment: payment),
                                ),
                          ],
                          const SizedBox(height: 42),
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

class _Totals extends StatelessWidget {
  const _Totals({required this.payments});

  final List<Payment> payments;

  @override
  Widget build(BuildContext context) {
    final paid = payments
        .where((payment) => payment.paymentStatus == PaymentStatus.paidSimulated)
        .fold<double>(0, (sum, payment) => sum + payment.amount);
    final pending = payments
        .where((payment) => payment.paymentStatus == PaymentStatus.pending)
        .fold<double>(0, (sum, payment) => sum + payment.amount);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PAID',
                  style: AppTextStyles.micro.copyWith(
                    fontSize: 7,
                    letterSpacing: 1.6,
                    color: AppColors.faint,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  Formatters.currency(paid),
                  style: AppTextStyles.price.copyWith(
                    fontSize: 16,
                    color: AppColors.paper,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: AppColors.paper.withValues(alpha: .16),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PENDING',
                  style: AppTextStyles.micro.copyWith(
                    fontSize: 7,
                    letterSpacing: 1.6,
                    color: AppColors.faint,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  Formatters.currency(pending),
                  style: AppTextStyles.price.copyWith(
                    fontSize: 16,
                    color: AppColors.paper,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: payment.orderId.isEmpty
          ? null
          : () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => OrderDetailsScreen(orderId: payment.orderId),
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
                    payment.orderNumber.isEmpty
                        ? payment.orderId.toUpperCase()
                        : payment.orderNumber,
                    style: AppTextStyles.title.copyWith(
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                PaymentStatusChip(
                  status: payment.paymentStatus,
                  compact: true,
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              Formatters.dateTime(payment.createdAt),
              style: AppTextStyles.micro.copyWith(
                fontSize: 7,
                letterSpacing: 0.7,
                color: AppColors.muted,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.paymentMethod.label,
                        style: AppTextStyles.micro.copyWith(
                          fontSize: 7.5,
                          letterSpacing: 1,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (payment.referenceNumber.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          payment.referenceNumber,
                          style: AppTextStyles.micro.copyWith(
                            fontSize: 6.5,
                            letterSpacing: 0.5,
                            color: AppColors.faint,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  Formatters.currency(payment.amount),
                  style: AppTextStyles.price.copyWith(fontSize: 14),
                ),
              ],
            ),
            if (payment.itemsSummary.isNotEmpty) ...[
              const SizedBox(height: 12),
              Divider(color: AppColors.line, height: 1),
              const SizedBox(height: 10),
              Text(
                payment.itemsSummary.toUpperCase(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.micro.copyWith(
                  fontSize: 6.5,
                  letterSpacing: 0.6,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
