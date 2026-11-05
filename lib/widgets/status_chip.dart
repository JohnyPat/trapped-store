import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/order.dart';

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status, this.compact = false});

  final OrderStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isCancelled = status == OrderStatus.cancelled;
    final isDelivered = status == OrderStatus.delivered;
    final background = isCancelled
        ? AppColors.errorSoft
        : isDelivered
        ? AppColors.ink
        : AppColors.paper;
    final foreground = isCancelled
        ? AppColors.error
        : isDelivered
        ? AppColors.paper
        : AppColors.ink;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: isCancelled
              ? AppColors.error.withValues(alpha: .35)
              : isDelivered
              ? AppColors.ink
              : AppColors.lineDark,
        ),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.micro.copyWith(
          fontSize: compact ? 7 : 7.5,
          letterSpacing: 1.3,
          color: foreground,
        ),
      ),
    );
  }
}

class PaymentStatusChip extends StatelessWidget {
  const PaymentStatusChip({super.key, required this.status, this.compact = false});

  final PaymentStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isPaid = status == PaymentStatus.paidSimulated;
    final isFailed = status == PaymentStatus.failedSimulated;
    final isRefunded = status == PaymentStatus.refundedSimulated;
    final isCancelled = status == PaymentStatus.cancelled;
    final danger = isFailed || isCancelled;
    final background = isPaid
        ? AppColors.ink
        : isRefunded
        ? AppColors.warningSoft
        : danger
        ? AppColors.errorSoft
        : AppColors.paper;
    final foreground = isPaid
        ? AppColors.paper
        : isRefunded
        ? AppColors.warning
        : danger
        ? AppColors.error
        : AppColors.muted;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: isPaid
              ? AppColors.ink
              : danger
              ? AppColors.error.withValues(alpha: .35)
              : AppColors.lineDark,
        ),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.micro.copyWith(
          fontSize: compact ? 7 : 7.5,
          letterSpacing: 1.3,
          color: foreground,
        ),
      ),
    );
  }
}
