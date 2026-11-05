import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class SizeChartTable extends StatelessWidget {
  const SizeChartTable({super.key, this.compact = false});

  final bool compact;

  static const _rows = [
    ['S', '18', '27', '19'],
    ['M', '19', '28', '20'],
    ['L', '20', '29', '21'],
    ['XL', '21', '30', '22'],
    ['2XL', '22', '31', '23'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ink,
      padding: EdgeInsets.all(compact ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'SIZE CHART — TOPS',
            style: AppTextStyles.micro.copyWith(
              color: AppColors.paper,
              fontSize: compact ? 7.5 : 8.5,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Table(
            border: TableBorder.all(
              color: AppColors.paper.withValues(alpha: .25),
              width: 0.6,
            ),
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: AppColors.paper.withValues(alpha: .08),
                ),
                children: [
                  _cell('SIZE', header: true),
                  _cell('CHEST', header: true),
                  _cell('LENGTH', header: true),
                  _cell('SHOULDER', header: true),
                ],
              ),
              for (final row in _rows)
                TableRow(
                  children: row.map((value) => _cell(value)).toList(),
                ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            'MEASUREMENTS IN INCHES. GARMENT MEASURED FLAT.',
            style: AppTextStyles.micro.copyWith(
              color: AppColors.faint,
              fontSize: 6.5,
              letterSpacing: 1,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(String value, {bool header = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: AppTextStyles.micro.copyWith(
          color: header ? AppColors.paper : AppColors.paper.withValues(alpha: .8),
          fontSize: header ? 6.5 : 7.5,
          letterSpacing: 0.8,
          fontWeight: header ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}
