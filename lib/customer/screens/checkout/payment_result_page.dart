import 'package:flutter/material.dart';

import 'package:trapped_store/constants/app_colors.dart';
import 'package:trapped_store/constants/app_text_styles.dart';
import 'package:trapped_store/models/payment.dart';
import 'package:trapped_store/utils/formatters.dart';
import 'package:trapped_store/widgets/trapped_button.dart';

class PaymentResultPage extends StatefulWidget {
  final Payment? payment;
  final bool isSuccessful;

  const PaymentResultPage({
    super.key,
    required this.payment,
    required this.isSuccessful,
  });

  @override
  State<PaymentResultPage> createState() => _PaymentResultPageState();
}

class _PaymentResultPageState extends State<PaymentResultPage> {
  late Payment _payment;
  late bool _isSuccessful;

  @override
  void initState() {
    super.initState();
    _payment = widget.payment!;
    _isSuccessful = widget.isSuccessful;
  }

  @override
  Widget build(BuildContext context) {
    // Checkout result doesn't need auth/providers in build
    return Scaffold(
      appBar: AppBar(
        title: _isSuccessful
            ? const Text('Payment Successful')
            : const Text('Payment Failed'),
        backgroundColor: _isSuccessful ? AppColors.success : AppColors.danger,
        foregroundColor: AppColors.paper,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Status icon
            Icon(
              _isSuccessful ? Icons.check_circle : Icons.cancel,
              size: 100,
              color: _isSuccessful ? AppColors.success : AppColors.danger,
            ),
            const SizedBox(height: 32),

            // Status text
            Text(
              _isSuccessful
                  ? 'Payment Successful'
                  : 'Payment Failed',
              style: AppTextStyles.label.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isSuccessful ? AppColors.success : AppColors.danger,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isSuccessful
                  ? 'Your simulated payment has been processed.'
                  : 'Your simulated payment could not be processed.',
              style: AppTextStyles.bodyMuted.copyWith(
                fontSize: 14,
                color: AppColors.muted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Payment details card
            Card(
              color: AppColors.paper,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Details',
                      style: AppTextStyles.micro.copyWith(
                        fontSize: 10,
                        letterSpacing: 2,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(
                      label: 'Order ID',
                      value: _payment.orderId.isNotEmpty
                          ? _payment.orderId
                          : 'N/A',
                    ),
                    const _Divider(),
                    _DetailRow(
                      label: 'Payment Method',
                      value: _payment.paymentMethod.label,
                    ),
                    const _Divider(),
                    _DetailRow(
                      label: 'Amount',
                      value: Formatters.currency(_payment.amount),
                    ),
                    const _Divider(),
                    _DetailRow(
                      label: 'Reference Number',
                      value: _payment.referenceNumber,
                    ),
                    const _Divider(),
                    _DetailRow(
                      label: 'Status',
                      value: _payment.paymentStatus.label,
                      isStatus: true,
                    ),
                    const _Divider(),
                    _DetailRow(
                      label: 'Created At',
                      value: Formatters.dateTime(_payment.createdAt),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Action buttons
            if (_isSuccessful) ...[
              TrappedButton(
                label: 'View Order Details',
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/order_details',
                    arguments: {'orderId': _payment.orderId},
                  );
                },
                variant: TrappedButtonVariant.outline,
              ),
              const SizedBox(height: 16),
              TrappedButton(
                label: 'Continue Shopping',
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                variant: TrappedButtonVariant.outline,
              ),
            ] else ...[
              TrappedButton(
                label: 'Try Again',
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              ),
              const SizedBox(height: 16),
              TrappedButton(
                label: 'Continue Shopping',
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                variant: TrappedButtonVariant.outline,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isStatus;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: AppTextStyles.small.copyWith(
                fontSize: 9,
                color: AppColors.muted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.price.copyWith(
                fontSize: 11,
                color: isStatus ? AppColors.success : AppColors.ink,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        height: 1,
        color: AppColors.line,
      ),
    );
  }
}