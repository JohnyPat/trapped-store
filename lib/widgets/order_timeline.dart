import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/order.dart';
import '../utils/formatters.dart';

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({
    super.key,
    required this.status,
    this.history = const [],
    this.compact = false,
  });

  final OrderStatus status;
  final List<OrderStatusEvent> history;
  final bool compact;

  static const _steps = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.processing,
    OrderStatus.shipped,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.errorSoft,
          border: Border.all(color: AppColors.error.withValues(alpha: .25)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          children: [
            const Icon(Icons.close, size: 18, color: AppColors.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'THIS ORDER WAS CANCELLED',
                style: AppTextStyles.micro.copyWith(
                  fontSize: 9,
                  letterSpacing: 1.5,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < _steps.length; index++)
          _TimelineRow(
            step: _steps[index],
            isComplete: status.step >= _steps[index].step,
            isCurrent: status == _steps[index],
            isLast: index == _steps.length - 1,
            event: _eventFor(_steps[index]),
            compact: compact,
          ),
      ],
    );
  }

  OrderStatusEvent? _eventFor(OrderStatus step) {
    for (final event in history) {
      if (event.status == step) return event;
    }
    return null;
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.step,
    required this.isComplete,
    required this.isCurrent,
    required this.isLast,
    required this.event,
    required this.compact,
  });

  final OrderStatus step;
  final bool isComplete;
  final bool isCurrent;
  final bool isLast;
  final OrderStatusEvent? event;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isComplete ? AppColors.ink : AppColors.paper,
                    border: Border.all(
                      color: isComplete ? AppColors.ink : AppColors.lineDark,
                      width: 1.2,
                    ),
                  ),
                  child: isComplete
                      ? const Icon(
                          Icons.check,
                          size: 9,
                          color: AppColors.paper,
                        )
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      color: isComplete ? AppColors.ink : AppColors.line,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : (compact ? 16 : 22)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: AppTextStyles.micro.copyWith(
                      fontSize: compact ? 8 : 9,
                      letterSpacing: 1.6,
                      color: isComplete ? AppColors.ink : AppColors.faint,
                    ),
                  ),
                  if (event != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      Formatters.dateTime(event!.at),
                      style: AppTextStyles.micro.copyWith(
                        fontSize: 7.5,
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.w400,
                        color: AppColors.muted,
                      ),
                    ),
                  ] else if (isCurrent) ...[
                    const SizedBox(height: 4),
                    Text(
                      'IN PROGRESS',
                      style: AppTextStyles.micro.copyWith(
                        fontSize: 7.5,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w400,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                  if (event?.note.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      event!.note,
                      style: AppTextStyles.small.copyWith(
                        fontSize: 9.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
