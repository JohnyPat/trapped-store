import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/product.dart';
import 'product_card.dart';
import 'responsive.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.products,
    required this.wishlistIds,
    required this.onTapProduct,
    required this.onToggleWishlist,
    required this.onAddToCart,
    this.columns,
    this.shrinkWrap = false,
    this.physics,
    this.padding = EdgeInsets.zero,
    this.compact = false,
  });

  final List<Product> products;
  final Set<String> wishlistIds;
  final ValueChanged<Product> onTapProduct;
  final ValueChanged<Product> onToggleWishlist;
  final ValueChanged<Product> onAddToCart;
  final int? columns;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsets padding;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final count = columns ?? Breakpoints.productColumns(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = Breakpoints.isMobile(context) ? 12.0 : 18.0;
        final available = constraints.maxWidth - padding.horizontal;
        final cardWidth = (available - spacing * (count - 1)) / count;
        final imageHeight = cardWidth / (compact ? 0.96 : 0.92);
        final footerHeight = compact ? 132.0 : (Breakpoints.isMobile(context) ? 138.0 : 148.0);
        final extent = imageHeight + footerHeight;
        return GridView.builder(
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: physics ?? (shrinkWrap ? const NeverScrollableScrollPhysics() : null),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: extent,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              compact: compact,
              isWishlisted: wishlistIds.contains(product.id),
              onTap: () => onTapProduct(product),
              onToggleWishlist: () => onToggleWishlist(product),
              onAddToCart: () => onAddToCart(product),
            );
          },
        );
      },
    );
  }
}

class HorizontalProductRail extends StatelessWidget {
  const HorizontalProductRail({
    super.key,
    required this.products,
    required this.wishlistIds,
    required this.onTapProduct,
    required this.onToggleWishlist,
    required this.onAddToCart,
  });

  final List<Product> products;
  final Set<String> wishlistIds;
  final ValueChanged<Product> onTapProduct;
  final ValueChanged<Product> onToggleWishlist;
  final ValueChanged<Product> onAddToCart;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final cardWidth = isMobile ? 178.0 : 228.0;
    final cardHeight = cardWidth / 0.92 + 148;
    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: Breakpoints.pagePadding(context),
        ),
        itemCount: products.length,
        separatorBuilder: (_, _) => SizedBox(width: isMobile ? 12 : 18),
        itemBuilder: (context, index) {
          final product = products[index];
          return SizedBox(
            width: cardWidth,
            child: ProductCard(
              product: product,
              compact: false,
              isWishlisted: wishlistIds.contains(product.id),
              onTap: () => onTapProduct(product),
              onToggleWishlist: () => onToggleWishlist(product),
              onAddToCart: () => onAddToCart(product),
            ),
          );
        },
      ),
    );
  }
}

class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    this.includeAll = true,
  });

  final List<({String id, String name})> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;
  final bool includeAll;

  @override
  Widget build(BuildContext context) {
    final items = <({String id, String name})>[
      if (includeAll) (id: 'all', name: 'ALL'),
      ...categories,
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in items) ...[
            _CategoryChip(
              label: item.name,
              selected:
                  (item.id == 'all' && selectedId == null) ||
                  selectedId == item.id,
              onTap: () => onSelected(item.id == 'all' ? null : item.id),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
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
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.paper,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: selected ? AppColors.ink : AppColors.lineDark,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTextStyles.micro.copyWith(
            fontSize: 7.5,
            letterSpacing: 1.4,
            color: selected ? AppColors.paper : AppColors.ink,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
