import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/product.dart';
import '../utils/formatters.dart';
import 'trapped_button.dart';

Future<String?> showSizePicker(BuildContext context, Product product) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.paper,
    builder: (sheetContext) => _SizePickerSheet(product: product),
  );
}

class _SizePickerSheet extends StatefulWidget {
  const _SizePickerSheet({required this.product});

  final Product product;

  @override
  State<_SizePickerSheet> createState() => _SizePickerSheetState();
}

class _SizePickerSheetState extends State<_SizePickerSheet> {
  late String _selected =
      widget.product.sizes.isEmpty ? 'M' : widget.product.sizes.first;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          22,
          18,
          22,
          18 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 34,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.lineDark,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name.toUpperCase(),
                        style: AppTextStyles.title.copyWith(
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.currency(product.price),
                        style: AppTextStyles.price.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${product.stock} IN STOCK',
                  style: AppTextStyles.micro.copyWith(
                    fontSize: 7.5,
                    letterSpacing: 1.2,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              'SELECT SIZE',
              style: AppTextStyles.micro.copyWith(
                fontSize: 8.5,
                letterSpacing: 2,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final size in product.sizes)
                  _SizeChip(
                    label: size,
                    selected: _selected == size,
                    onTap: () => setState(() => _selected = size),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            TrappedButton(
              label: 'ADD TO BAG',
              onPressed: () => Navigator.of(context).pop(_selected),
              height: 46,
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeChip extends StatelessWidget {
  const _SizeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: 52,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.paper,
          border: Border.all(
            color: selected ? AppColors.ink : AppColors.lineDark,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          label,
          style: AppTextStyles.micro.copyWith(
            fontSize: 9,
            letterSpacing: 1,
            color: selected ? AppColors.paper : AppColors.ink,
          ),
        ),
      ),
    );
  }
}
