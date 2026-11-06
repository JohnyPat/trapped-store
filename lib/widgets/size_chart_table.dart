import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class SizeChartTable extends StatelessWidget {
  const SizeChartTable({super.key, this.compact = false});

  final bool compact;

  static const _rows = [
    ['X-SMALL', '22"', '27"'],
    ['SMALL', '23"', '28"'],
    ['MEDIUM', '24"', '29"'],
    ['LARGE', '25"', '30"'],
    ['X-LARGE', '26"', '31"'],
    ['2X-LARGE', '27"', '32"'],
    ['3X-LARGE', '28"', '33"'],
    ['4X-LARGE', '29"', '34"'],
   ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ink,
      padding: EdgeInsets.all(compact ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'SIZE CHART (INCHES)',
            textAlign: TextAlign.center,
            style: AppTextStyles.micro.copyWith(
              color: AppColors.paper.withValues(alpha: .65),
              fontSize: compact ? 8 : 9,
              letterSpacing: 2.4,
            ),
          ),
          const SizedBox(height: 10),
          Table(
            border: TableBorder(
              horizontalInside: BorderSide(
                color: AppColors.paper.withValues(alpha: .18),
              ),
            ),
            columnWidths: const {
              0: FlexColumnWidth(1.7),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                children: [
                  _cell('', header: true),
                  _cell('WIDTH', header: true),
                  _cell('LENGTH', header: true),
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
