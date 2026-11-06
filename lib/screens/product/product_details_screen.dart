import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../utils/app_snack.dart';
import '../../utils/auth_guard.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/error_state.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/price_text.dart';
import '../../widgets/product_image.dart';
import '../../widgets/size_chart_table.dart';
import '../checkout/checkout_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? _selectedSize;
  int _quantity = 1;
  bool _busy = false;

  Future<void> _toggleWishlist(Product product) async {
    if (!await ensureSignedIn(context)) return;
    if (!mounted) return;
    try {
      await context.read<WishlistProvider>().toggle(product.id);
    } catch (error) {
      if (!mounted) return;
      AppSnack.error(context, error.toString());
    }
  }

  Future<void> _addToCart(Product product, {required bool buyNow}) async {
    if (!await ensureSignedIn(context)) return;
    if (!mounted) return;
    if (!product.inStock) {
      AppSnack.error(context, 'This piece is sold out.');
      return;
    }
    final size = _selectedSize ??
        (product.sizes.isEmpty ? 'ONE SIZE' : product.sizes.first);
    setState(() => _busy = true);
    try {
      await context.read<CartProvider>().add(
            product: product,
            size: size,
            quantity: _quantity,
          );
      if (!mounted) return;
      if (buyNow) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const CheckoutScreen()),
        );
      } else {
        AppSnack.success(
          context,
          '${product.name} × $_quantity added to your bag.',
        );
      }
    } catch (error) {
      if (!mounted) return;
      AppSnack.error(context, error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final product = catalog.productById(widget.productId);

    if (catalog.loading) {
      return const Scaffold(body: LoadingState(label: 'LOADING PIECE'));
    }

    if (product == null) {
      return Scaffold(
        body: Column(
          children: [
            BrandHeader(
              onLeading: () => Navigator.of(context).pop(),
              leadingIcon: Icons.arrow_back,
            ),
            const Expanded(
              child: ErrorState(
                title: 'PIECE NOT FOUND',
                message:
                    'This product is no longer available. Browse the latest collection instead.',
              ),
            ),
          ],
        ),
      );
    }

    final selectedSize = _selectedSize ??
        (product.sizes.isEmpty ? 'ONE SIZE' : product.sizes.first);
    final maxQuantity = product.stock.clamp(1, 10);
    if (_quantity > maxQuantity) _quantity = maxQuantity;

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Column(
        children: [
          BrandHeader(
            onLeading: () => Navigator.of(context).pop(),
            leadingIcon: Icons.arrow_back,
            trailing: IconButton(
              splashRadius: 20,
              onPressed: () => _toggleWishlist(product),
              icon: Icon(
                wishlist.isWishlisted(product.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: AppColors.paper,
                size: 19,
              ),
            ),
          ),
          Expanded(
            child: _MobileProductDetails(
              product: product,
              selectedSize: selectedSize,
              quantity: _quantity,
              maxQuantity: maxQuantity,
              busy: _busy,
              onSizeChanged: (size) => setState(() => _selectedSize = size),
              onQuantityChanged: (value) => setState(() => _quantity = value),
              onAddToCart: () => _addToCart(product, buyNow: false),
              onBuyNow: () => _addToCart(product, buyNow: true),
              onToggleWishlist: () => _toggleWishlist(product),
              wishlisted: wishlist.isWishlisted(product.id),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileProductDetails extends StatelessWidget {
  const _MobileProductDetails({
    required this.product,
    required this.selectedSize,
    required this.quantity,
    required this.maxQuantity,
    required this.busy,
    required this.wishlisted,
    required this.onSizeChanged,
    required this.onQuantityChanged,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.onToggleWishlist,
  });

  final Product product;
  final String selectedSize;
  final int quantity;
  final int maxQuantity;
  final bool busy;
  final bool wishlisted;
  final ValueChanged<String> onSizeChanged;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final VoidCallback onToggleWishlist;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1.05,
                child: ProductImage(
                  imageUrl: product.gallery.isNotEmpty ? product.gallery.first : '',
                  fallbackAsset: product.localFallback,
                  backgroundColor: AppColors.paper,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                ),
              ),
              const SizedBox(height: 10),
              const SizeChartTable(compact: true),
              const SizedBox(height: 22),
              Text(
                product.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 7),
              // Product records do not yet have colour fields. The seeded
              // catalogue is all black; add a `color` field later per product.
              const Text(
                'BLACK',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 12,
                  letterSpacing: 2,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 12),
              PriceText(
                price: product.price,
                compareAtPrice: product.compareAtPrice,
                fontSize: 16,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 370;
                  return Row(
                    mainAxisAlignment: compact
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: compact ? 112 : 148,
                        height: 40,
                        child: _GhostDropdown(
                          value: selectedSize,
                          isExpanded: true,
                          style: const TextStyle(
                            fontFamily: 'SpaceMono',
                            fontSize: 11,
                            color: AppColors.ink,
                          ),
                          items: (product.sizes.isEmpty ? ['ONE SIZE'] : product.sizes)
                              .map(
                                (size) => DropdownMenuItem<String>(
                                  value: size,
                                  child: Text(size),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) onSizeChanged(value);
                          },
                        ),
                      ),
                      SizedBox(width: compact ? 6 : 12),
                      SizedBox(
                        width: compact ? 100 : 112,
                        height: 40,
                        child: _QuantityStepper(
                          value: quantity,
                          min: 1,
                          max: maxQuantity,
                          onChanged: onQuantityChanged,
                        ),
                      ),
                      SizedBox(width: compact ? 6 : 12),
                      IconButton(
                        splashRadius: 20,
                        onPressed: onToggleWishlist,
                        icon: Icon(
                          wishlisted ? Icons.favorite : Icons.favorite_border,
                          color: AppColors.ink,
                          size: 27,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              _DetailCtaButton(
                label: product.inStock ? 'Add to Cart' : 'Sold Out',
                filled: false,
                enabled: product.inStock && !busy,
                onPressed: onAddToCart,
                busy: busy,
              ),
              const SizedBox(height: 10),
              _DetailCtaButton(
                label: 'Buy it Now',
                filled: true,
                enabled: product.inStock && !busy,
                onPressed: onBuyNow,
                busy: busy,
              ),
              const SizedBox(height: 20),
              Text(
                'SHIPS NATIONWIDE · FREE OVER PHP 3,000',
                textAlign: TextAlign.center,
                style: AppTextStyles.micro.copyWith(
                  fontSize: 7,
                  letterSpacing: 1.4,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bordered white/ghost dropdown used for the SIZE field.
class _GhostDropdown extends StatelessWidget {
  const _GhostDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.isExpanded = true,
    this.style,
  });

  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final bool isExpanded;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: Border.all(color: AppColors.ink, width: 1.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: isExpanded,
            underline: const SizedBox.shrink(),
            itemHeight: 48,
            style: style,
            icon: const Text('⌄'),
            items: items,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

/// − / value / + quantity stepper used in the mock design.
class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: Border.all(color: AppColors.ink, width: 1.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: value <= min ? null : () => onChanged(value - 1),
              child: Icon(
                Icons.remove,
                size: 15,
                color: value <= min ? AppColors.faint : AppColors.ink,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '$value',
                style: const TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: value >= max ? null : () => onChanged(value + 1),
              child: Icon(
                Icons.add,
                size: 15,
                color: value >= max ? AppColors.faint : AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Large rounded CTA button used by the mock: white / black.
class _DetailCtaButton extends StatelessWidget {
  const _DetailCtaButton({
    required this.label,
    required this.filled,
    required this.enabled,
    required this.onPressed,
    this.busy = false,
  });

  final String label;
  final bool filled;
  final bool enabled;
  final VoidCallback onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: filled
          ? FilledButton(
              onPressed: enabled ? onPressed : null,
              style: FilledButton.styleFrom(
                backgroundColor: enabled ? AppColors.ink : AppColors.faint,
                foregroundColor: AppColors.paper,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.7,
                      ),
                    ),
            )
          : OutlinedButton(
              onPressed: enabled ? onPressed : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ink,
                side: const BorderSide(color: AppColors.ink, width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
    );
  }
}
