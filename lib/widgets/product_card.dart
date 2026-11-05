import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/product.dart';
import '../utils/formatters.dart';
import 'price_text.dart';
import 'product_image.dart';
import 'star_rating.dart';
import 'trapped_button.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.isWishlisted,
    required this.onTap,
    required this.onToggleWishlist,
    required this.onAddToCart,
    this.compact = false,
  });

  final Product product;
  final bool isWishlisted;
  final VoidCallback onTap;
  final VoidCallback onToggleWishlist;
  final VoidCallback onAddToCart;
  final bool compact;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _hovered ? AppColors.ink : AppColors.line,
            width: 1,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: widget.compact ? 0.96 : 0.92,
                      child: ProductImage(
                        imageUrl: product.imageUrl,
                        fallbackAsset: product.localFallback,
                        padding: EdgeInsets.all(widget.compact ? 8 : 12),
                      ),
                    ),
                    if (!product.inStock)
                      Positioned.fill(
                        child: Container(
                          color: AppColors.paper.withValues(alpha: 0.72),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.ink,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              'SOLD OUT',
                              style: AppTextStyles.micro.copyWith(
                                color: AppColors.paper,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _WishlistButton(
                        active: widget.isWishlisted,
                        onTap: widget.onToggleWishlist,
                      ),
                    ),
                    if (product.isNew && product.inStock)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.paper.withValues(alpha: 0.92),
                            border: Border.all(color: AppColors.ink),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            'NEW',
                            style: AppTextStyles.micro.copyWith(
                              fontSize: 7,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    widget.compact ? 10 : 14,
                    12,
                    widget.compact ? 10 : 14,
                    12,
                  ),
                  child: Column(
                    children: [
                      Text(
                        product.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title.copyWith(
                          fontSize: widget.compact ? 9.5 : 10.5,
                          letterSpacing: 1.2,
                          height: 1.45,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      PriceText(
                        price: product.price,
                        compareAtPrice: product.compareAtPrice,
                        fontSize: widget.compact ? 10 : 11,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 7),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (product.reviewCount > 0) ...[
                            StarRating(
                              rating: product.rating,
                              size: widget.compact ? 8 : 9,
                            ),
                            const SizedBox(width: 5),
                          ],
                          Text(
                            product.inStock
                                ? (product.isLowStock
                                      ? 'ONLY ${product.stock} LEFT'
                                      : 'IN STOCK')
                                : 'SOLD OUT',
                            style: AppTextStyles.micro.copyWith(
                              fontSize: 7,
                              letterSpacing: 0.9,
                              color: product.isLowStock
                                  ? AppColors.warning
                                  : AppColors.muted,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 11),
                      TrappedButton(
                        label: product.inStock ? 'ADD TO BAG' : 'SOLD OUT',
                        onPressed: product.inStock ? widget.onAddToCart : null,
                        variant: TrappedButtonVariant.outline,
                        height: 31,
                        fontSize: 8,
                      ),
                      if (widget.compact) const SizedBox(height: 2),
                      if (!widget.compact && product.reviewCount > 0) ...[
                        const SizedBox(height: 7),
                        Text(
                          Formatters.plural(product.reviewCount, 'REVIEW'),
                          style: AppTextStyles.micro.copyWith(
                            fontSize: 7,
                            letterSpacing: 0.8,
                            color: AppColors.faint,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WishlistButton extends StatelessWidget {
  const _WishlistButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.paper,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.line, width: 1),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(
            active ? Icons.favorite : Icons.favorite_border,
            size: 15,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}
