import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_assets.dart';
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
import '../../widgets/product_grid.dart';
import '../../widgets/product_image.dart';
import '../../widgets/responsive.dart';
import '../../widgets/section_heading.dart';
import '../../widgets/size_chart_table.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/trapped_button.dart';
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

    final isMobile = Breakpoints.isMobile(context);
    final isDesktop = Breakpoints.isDesktop(context);
    final selectedSize = _selectedSize ??
        (product.sizes.isEmpty ? 'ONE SIZE' : product.sizes.first);
    final maxQuantity = product.stock.clamp(1, 10);
    if (_quantity > maxQuantity) _quantity = maxQuantity;
    final related = catalog.products
        .where(
          (item) =>
              item.categoryId == product.categoryId && item.id != product.id,
        )
        .take(4)
        .toList();

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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isDesktop)
                    ContentFrame(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 34),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 11,
                              child: _Gallery(product: product),
                            ),
                            const SizedBox(width: 48),
                            Expanded(
                              flex: 8,
                              child: _ProductInfo(
                                product: product,
                                selectedSize: selectedSize,
                                quantity: _quantity,
                                maxQuantity: maxQuantity,
                                wishlisted:
                                    wishlist.isWishlisted(product.id),
                                busy: _busy,
                                onSizeChanged: (size) =>
                                    setState(() => _selectedSize = size),
                                onQuantityChanged: (value) =>
                                    setState(() => _quantity = value),
                                onToggleWishlist: () =>
                                    _toggleWishlist(product),
                                onAddToCart: () => _addToCart(product,
                                    buyNow: false),
                                onBuyNow: () => _addToCart(product,
                                    buyNow: true),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Gallery(product: product),
                        ContentFrame(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 26),
                            child: _ProductInfo(
                              product: product,
                              selectedSize: selectedSize,
                              quantity: _quantity,
                              maxQuantity: maxQuantity,
                              wishlisted: wishlist.isWishlisted(product.id),
                              busy: _busy,
                              onSizeChanged: (size) =>
                                  setState(() => _selectedSize = size),
                              onQuantityChanged: (value) =>
                                  setState(() => _quantity = value),
                              onToggleWishlist: () =>
                                  _toggleWishlist(product),
                              onAddToCart: () =>
                                  _addToCart(product, buyNow: false),
                              onBuyNow: () =>
                                  _addToCart(product, buyNow: true),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ContentFrame(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 48),
                        SectionHeading(
                          title: 'Complete the fit',
                          subtitle: 'More pieces from this collection.',
                          align: SectionHeadingAlign.left,
                        ),
                        const SizedBox(height: 20),
                        if (related.isEmpty)
                          Text(
                            'No related pieces right now.',
                            style: AppTextStyles.bodyMuted,
                          )
                        else
                          ProductGrid(
                            products: related,
                            wishlistIds: wishlist.productIds,
                            onTapProduct: (item) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute<void>(
                                  builder: (_) => ProductDetailsScreen(
                                    productId: item.id,
                                  ),
                                ),
                              );
                            },
                            onToggleWishlist: _toggleWishlist,
                            onAddToCart: (item) =>
                                _addToCart(item, buyNow: false),
                            shrinkWrap: true,
                            columns: isMobile ? 2 : 4,
                          ),
                        const SizedBox(height: 52),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final gallery = product.gallery;
    return Column(
      children: [
        AspectRatio(
          aspectRatio: isMobile ? 0.92 : 1.08,
          child: ProductImage(
            imageUrl: gallery.isNotEmpty ? gallery.first : '',
            fallbackAsset: product.localFallback,
            padding: EdgeInsets.all(isMobile ? 18 : 34),
          ),
        ),
        if (!isMobile)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                for (var index = 0; index < 2; index++) ...[
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.1,
                      child: EditorialImage(
                        imageUrl: 'asset:${index == 0 ? AppAssets.editorialThree : AppAssets.editorialTwo}',
                        fallbackAsset:
                            index == 0 ? AppAssets.editorialThree : AppAssets.editorialTwo,
                        grayscale: true,
                        overlayOpacity: 0.1,
                      ),
                    ),
                  ),
                  if (index == 0) const SizedBox(width: 12),
                ],
              ],
            ),
          ),
        if (isMobile) ...[
          const SizedBox(height: 8),
          EditorialImage(
            imageUrl: 'asset:${AppAssets.editorialTwo}',
            fallbackAsset: AppAssets.editorialTwo,
            grayscale: true,
            height: 230,
          ),
          const SizedBox(height: 8),
          EditorialImage(
            imageUrl: 'asset:${AppAssets.editorialThree}',
            fallbackAsset: AppAssets.editorialThree,
            grayscale: true,
            height: 230,
          ),
        ],
        const SizedBox(height: 16),
        const SizeChartTable(compact: true),
      ],
    );
  }
}

class _ProductInfo extends StatelessWidget {
  const _ProductInfo({
    required this.product,
    required this.selectedSize,
    required this.quantity,
    required this.maxQuantity,
    required this.wishlisted,
    required this.busy,
    required this.onSizeChanged,
    required this.onQuantityChanged,
    required this.onToggleWishlist,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  final Product product;
  final String selectedSize;
  final int quantity;
  final int maxQuantity;
  final bool wishlisted;
  final bool busy;
  final ValueChanged<String> onSizeChanged;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onToggleWishlist;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name.toUpperCase(),
          style: AppTextStyles.displaySmall.copyWith(
            fontSize: isMobile ? 24 : 30,
            height: 1.2,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (product.reviewCount > 0) ...[
              StarRating(
                rating: product.rating,
                reviewCount: product.reviewCount,
                size: 12,
                showValue: true,
              ),
              const SizedBox(width: 10),
            ],
            Text(
              product.inStock
                  ? (product.isLowStock
                        ? 'ONLY ${product.stock} LEFT'
                        : 'IN STOCK')
                  : 'SOLD OUT',
              style: AppTextStyles.micro.copyWith(
                fontSize: 8,
                letterSpacing: 1.2,
                color: product.isLowStock ? AppColors.warning : AppColors.muted,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        PriceText(
          price: product.price,
          compareAtPrice: product.compareAtPrice,
          fontSize: 16,
        ),
        const SizedBox(height: 18),
        Text(
          product.description.isEmpty
              ? 'A [trapped] essential. Cut for everyday wear and finished with signature branding.'
              : product.description,
          style: AppTextStyles.bodyMuted.copyWith(height: 1.8, fontSize: 11.5),
        ),
        const SizedBox(height: 24),
        Divider(color: AppColors.line, height: 1),
        const SizedBox(height: 20),
        Text(
          'SIZE',
          style: AppTextStyles.micro.copyWith(
            fontSize: 8.5,
            letterSpacing: 2,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            Expanded(
              child: _DropdownShell(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedSize,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 17,
                      color: AppColors.ink,
                    ),
                    style: AppTextStyles.body.copyWith(
                      fontSize: 11,
                      letterSpacing: 0.4,
                    ),
                    items: (product.sizes.isEmpty
                            ? ['ONE SIZE']
                            : product.sizes)
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
              ),
            ),
            const SizedBox(width: 10),
            _DropdownShell(
              width: 92,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: quantity,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 17,
                    color: AppColors.ink,
                  ),
                  style: AppTextStyles.body.copyWith(fontSize: 11),
                  items: [
                    for (var value = 1; value <= maxQuantity; value++)
                      DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value'),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) onQuantityChanged(value);
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            _WishlistSquare(
              active: wishlisted,
              onTap: onToggleWishlist,
            ),
          ],
        ),
        const SizedBox(height: 18),
        TrappedButton(
          label: product.inStock ? 'ADD TO CART' : 'SOLD OUT',
          onPressed: product.inStock && !busy ? onAddToCart : null,
          variant: TrappedButtonVariant.outline,
          loading: busy,
          height: 48,
        ),
        const SizedBox(height: 10),
        TrappedButton(
          label: 'BUY IT NOW',
          onPressed: product.inStock && !busy ? onBuyNow : null,
          height: 48,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Icon(
              Icons.local_shipping_outlined,
              size: 14,
              color: AppColors.muted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'SHIPS NATIONWIDE · FREE OVER PHP 3,000',
                style: AppTextStyles.micro.copyWith(
                  fontSize: 7,
                  letterSpacing: 1.2,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _InfoAccordion(
          title: 'DETAILS & CARE',
          body:
              '100% heavyweight cotton. Cold wash inside out. Do not iron directly over the print. Air dry in the shade to preserve the graphic.',
        ),
        _InfoAccordion(
          title: 'SHIPPING & RETURNS',
          body:
              'Orders are dispatched within 1–3 business days. Metro Manila delivery takes 1–3 days; provincial delivery takes 3–7 days. Unworn pieces may be returned within 7 days of delivery.',
        ),
        _InfoAccordion(
          title: 'SIZE GUIDE',
          body:
              'Measurements are taken flat. If you are between sizes, size up for a relaxed fit. See the full size chart above.',
        ),
      ],
    );
  }
}

class _DropdownShell extends StatelessWidget {
  const _DropdownShell({required this.child, this.width});

  final Widget child;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: Border.all(color: AppColors.lineDark),
        borderRadius: BorderRadius.circular(3),
      ),
      child: child,
    );
  }
}

class _WishlistSquare extends StatelessWidget {
  const _WishlistSquare({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.paper,
          border: Border.all(color: AppColors.lineDark),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Icon(
          active ? Icons.favorite : Icons.favorite_border,
          size: 17,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

class _InfoAccordion extends StatelessWidget {
  const _InfoAccordion({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: AppColors.line),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 16),
        iconColor: AppColors.ink,
        collapsedIconColor: AppColors.muted,
        title: Text(
          title,
          style: AppTextStyles.micro.copyWith(
            fontSize: 8,
            letterSpacing: 1.6,
          ),
        ),
        children: [
          Text(
            body,
            style: AppTextStyles.bodyMuted.copyWith(
              fontSize: 10.5,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}
