import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    this.canDecrement = true,
    this.canIncrement = true,
    this.compact = false,
  });

  final int quantity;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final bool canDecrement;
  final bool canIncrement;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 30.0 : 38.0;
    final width = compact ? 92.0 : 112.0;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lineDark),
        borderRadius: BorderRadius.circular(3),
        color: AppColors.paper,
      ),
      child: Row(
        children: [
          _button(
            icon: Icons.remove,
            onTap: canDecrement ? onDecrement : null,
            size: compact ? 13 : 15,
          ),
          Expanded(
            child: Center(
              child: Text(
                '$quantity',
                style: AppTextStyles.price.copyWith(
                  fontSize: compact ? 10 : 11.5,
                ),
              ),
            ),
          ),
          _button(
            icon: Icons.add,
            onTap: canIncrement ? onIncrement : null,
            size: compact ? 13 : 15,
          ),
        ],
      ),
    );
  }

  Widget _button({
    required IconData icon,
    required VoidCallback? onTap,
    required double size,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: compact ? 28 : 34,
        height: compact ? 30 : 38,
        child: Icon(
          icon,
          size: size,
          color: onTap == null ? AppColors.faint : AppColors.ink,
        ),
      ),
    );
  }
}
