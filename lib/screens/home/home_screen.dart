import 'dart:async';

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
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/home_footer.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/product_grid.dart';
import '../../widgets/product_image.dart';
import '../../widgets/responsive.dart';
import '../../widgets/section_heading.dart';
import '../../widgets/size_picker_sheet.dart';
import '../../widgets/trapped_button.dart';
import '../collection/collection_screen.dart';
import '../product/product_details_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _visibleCount = 8;

  Future<void> _openProduct(Product product) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsScreen(productId: product.id),
      ),
    );
  }

  Future<void> _toggleWishlist(Product product) async {
    if (!await ensureSignedIn(context)) return;
    if (!mounted) return;
    try {
      await context.read<WishlistProvider>().toggle(product.id);
      if (!mounted) return;
      final saved = context.read<WishlistProvider>().isWishlisted(product.id);
      AppSnack.show(
        context,
        saved ? 'Added to your wishlist.' : 'Removed from your wishlist.',
      );
    } catch (error) {
      if (!mounted) return;
      AppSnack.error(context, error.toString());
    }
  }

  Future<void> _addToCart(Product product) async {
    if (!await ensureSignedIn(context)) return;
    if (!mounted) return;
    final size = await showSizePicker(context, product);
    if (size == null || !mounted) return;
    try {
      await context.read<CartProvider>().add(
        product: product,
        size: size,
        quantity: 1,
      );
      if (!mounted) return;
      AppSnack.success(context, '${product.name} added to your bag.');
    } catch (error) {
      if (!mounted) return;
      AppSnack.error(context, error.toString());
    }
  }

  void _openCollection({String? categoryId, String? title}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CollectionScreen(
          categoryId: categoryId,
          title: title ?? 'ALL PRODUCTS',
        ),
      ),
    );
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final isMobile = Breakpoints.isMobile(context);

    if (catalog.loading) {
      return const Center(child: LoadingState(label: 'LOADING THE DROP'));
    }
    if (catalog.error != null && catalog.products.isEmpty) {
      return ErrorState(
        message: catalog.error!,
        onRetry: catalog.reload,
      );
    }
    if (catalog.products.isEmpty) {
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'The drop is coming',
        message:
            'The catalogue is empty right now. Check back soon for the next release.',
        actionLabel: 'REFRESH',
        onAction: catalog.reload,
      );
    }

    final featured = catalog.featuredProducts.isNotEmpty
        ? catalog.featuredProducts
        : catalog.products.take(4).toList();
    final newArrivals = catalog.newArrivals.isNotEmpty
        ? catalog.newArrivals
        : catalog.products.take(4).toList();
    final popular = catalog.popularProducts.take(4).toList();
    final filtered = catalog.selectedCategoryId == null
        ? catalog.products
        : catalog.products
              .where((product) => product.categoryId == catalog.selectedCategoryId)
              .toList();
    final visible = filtered.take(_visibleCount).toList();

    return RefreshIndicator(
      color: AppColors.ink,
      onRefresh: () async => catalog.reload(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroCarousel(
              onShop: () => _openCollection(),
              onShopShirts: () =>
                  _openCollection(categoryId: 'cat-shirts', title: 'SHIRTS'),
            ),
            ContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 22),
                  _SearchTrigger(onTap: _openSearch),
                  const SizedBox(height: 42),
                  SectionHeading(
                    title: 'Shop by category',
                    subtitle: 'Find your next uniform.',
                  ),
                  const SizedBox(height: 20),
                  _CategoryStrip(
                    onSelect: (id, name) =>
                        _openCollection(categoryId: id, title: name),
                  ),
                  const SizedBox(height: 56),
                  SectionHeading(
                    title: 'Featured',
                    subtitle: 'The pieces everyone is talking about.',
                    align: SectionHeadingAlign.left,
                    trailing: _ViewAll(
                      onTap: () => _openCollection(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            HorizontalProductRail(
              products: featured,
              wishlistIds: wishlist.productIds,
              onTapProduct: _openProduct,
              onToggleWishlist: _toggleWishlist,
              onAddToCart: _addToCart,
            ),
            ContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 54),
                  SectionHeading(
                    title: 'New arrivals',
                    subtitle: 'Fresh off the press.',
                    align: SectionHeadingAlign.left,
                    trailing: _ViewAll(
                      onTap: () => _openCollection(title: 'NEW ARRIVALS'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ProductGrid(
                    products: newArrivals.take(isMobile ? 4 : 4).toList(),
                    wishlistIds: wishlist.productIds,
                    onTapProduct: _openProduct,
                    onToggleWishlist: _toggleWishlist,
                    onAddToCart: _addToCart,
                    shrinkWrap: true,
                    columns: isMobile ? 2 : 4,
                  ),
                  const SizedBox(height: 56),
                  _EditorialBanner(
                    onShop: () => _openCollection(title: 'THE SUNDAY EDIT'),
                  ),
                  const SizedBox(height: 56),
                  SectionHeading(
                    title: 'Most wanted',
                    subtitle: 'Highest rated by the community.',
                    align: SectionHeadingAlign.left,
                  ),
                  const SizedBox(height: 20),
                  ProductGrid(
                    products: popular,
                    wishlistIds: wishlist.productIds,
                    onTapProduct: _openProduct,
                    onToggleWishlist: _toggleWishlist,
                    onAddToCart: _addToCart,
                    shrinkWrap: true,
                    columns: isMobile ? 2 : 4,
                  ),
                  const SizedBox(height: 58),
                  SectionHeading(
                    title: 'All products',
                    subtitle: 'The full [trapped] catalogue.',
                  ),
                  const SizedBox(height: 16),
                  CategoryChips(
                    categories: catalog.categories
                        .map((category) => (id: category.id, name: category.name))
                        .toList(),
                    selectedId: catalog.selectedCategoryId,
                    onSelected: (id) {
                      catalog.setCategory(id);
                      setState(() => _visibleCount = 8);
                    },
                  ),
                  const SizedBox(height: 20),
                  if (visible.isEmpty)
                    EmptyState(
                      icon: Icons.filter_alt_off_outlined,
                      title: 'Nothing in this collection yet',
                      message:
                          'Try another category or browse the full catalogue.',
                      actionLabel: 'CLEAR FILTER',
                      onAction: () {
                        catalog.setCategory(null);
                        setState(() => _visibleCount = 8);
                      },
                    )
                  else
                    ProductGrid(
                      products: visible,
                      wishlistIds: wishlist.productIds,
                      onTapProduct: _openProduct,
                      onToggleWishlist: _toggleWishlist,
                      onAddToCart: _addToCart,
                      shrinkWrap: true,
                    ),
                  if (visible.isNotEmpty && _visibleCount < filtered.length) ...[
                    const SizedBox(height: 26),
                    Center(
                      child: SizedBox(
                        width: 210,
                        child: TrappedButton(
                          label: 'LOAD MORE',
                          onPressed: () =>
                              setState(() => _visibleCount += 8),
                          variant: TrappedButtonVariant.outline,
                          height: 46,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 60),
                ],
              ),
            ),
            HomeFooter(
              onShop: () => _openCollection(),
              onOrders: () => widget.onNavigate(2),
              onWishlist: () => widget.onNavigate(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewAll extends StatelessWidget {
  const _ViewAll({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'VIEW ALL',
            style: AppTextStyles.micro.copyWith(
              fontSize: 7.5,
              letterSpacing: 1.4,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward, size: 11, color: AppColors.muted),
        ],
      ),
    );
  }
}

class _SearchTrigger extends StatelessWidget {
  const _SearchTrigger({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.paper,
          border: Border.all(color: AppColors.lineDark),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, size: 18, color: AppColors.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'SEARCH THE COLLECTION',
                style: AppTextStyles.micro.copyWith(
                  fontSize: 8.5,
                  letterSpacing: 1.8,
                  color: AppColors.faint,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward, size: 15, color: AppColors.ink),
          ],
        ),
      ),
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({required this.onSelect});

  final void Function(String? id, String name) onSelect;

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final isMobile = Breakpoints.isMobile(context);
    final entries = <({String? id, String name, String image})>[
      (
        id: null,
        name: 'ALL PRODUCTS',
        image: AppAssets.categoryImages['all']!,
      ),
      for (final category in catalog.categories)
        (
          id: category.id,
          name: category.name,
          image:
              AppAssets.categoryImages[category.id] ??
              AppAssets.categoryImages['all']!,
        ),
    ];
    if (isMobile) {
      return SizedBox(
        height: 128,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: entries.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final entry = entries[index];
            return SizedBox(
              width: 152,
              child: _CategoryTile(
                label: entry.name,
                asset: entry.image,
                onTap: () => onSelect(entry.id, entry.name),
              ),
            );
          },
        ),
      );
    }
    return Row(
      children: [
        for (var index = 0; index < entries.length; index++) ...[
          Expanded(
            child: SizedBox(
              height: 190,
              child: _CategoryTile(
                label: entries[index].name,
                asset: entries[index].image,
                onTap: () =>
                    onSelect(entries[index].id, entries[index].name),
              ),
            ),
          ),
          if (index != entries.length - 1) const SizedBox(width: 14),
        ],
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.asset,
    required this.onTap,
  });

  final String label;
  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          EditorialImage(
            imageUrl: 'asset:$asset',
            fallbackAsset: asset,
            grayscale: true,
            overlayOpacity: 0.32,
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 13,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.micro.copyWith(
                      color: AppColors.paper,
                      fontSize: 8.5,
                      letterSpacing: 1.8,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_outward,
                  color: AppColors.paper,
                  size: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorialBanner extends StatelessWidget {
  const _EditorialBanner({required this.onShop});

  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    return SizedBox(
      height: isMobile ? 300 : 340,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const EditorialImage(
            imageUrl: '',
            fallbackAsset: AppAssets.editorialFour,
            grayscale: true,
            overlayOpacity: 0.55,
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 22 : 34),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THE SUNDAY EDIT',
                  style: AppTextStyles.micro.copyWith(
                    color: AppColors.paper,
                    fontSize: 8,
                    letterSpacing: 2.8,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'SET APART.\nNOT FOR EVERYONE.',
                  style: AppTextStyles.displaySmall.copyWith(
                    color: AppColors.paper,
                    fontSize: isMobile ? 25 : 38,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: 190,
                  child: TrappedButton(
                    label: 'SHOP THE EDIT',
                    onPressed: onShop,
                    variant: TrappedButtonVariant.outline,
                    height: 42,
                    fontSize: 8.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel({required this.onShop, required this.onShopShirts});

  final VoidCallback onShop;
  final VoidCallback onShopShirts;

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _index = 0;

  static const _slides = [
    (
      asset: AppAssets.hero,
      kicker: 'SS26 — DROP 01',
      title: 'WEAR YOUR\nCONVICTION.',
      body: 'Heavyweight graphics for the set-apart.',
      cta: 'SHOP THE DROP',
    ),
    (
      asset: AppAssets.editorialTwo,
      kicker: 'PRAISE THE LORD',
      title: 'THESE ARE\nTHE DAYS.',
      body: 'I praise the Lord, then break the law.',
      cta: 'SHOP SHIRTS',
    ),
    (
      asset: AppAssets.editorialFour,
      kicker: 'EST. MANILA',
      title: 'SET APART.\nSTAY ROOTED.',
      body: 'Limited pieces, made to be worn out.',
      cta: 'SHOP THE COLLECTION',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_index + 1) % _slides.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final height = isMobile ? 450.0 : 500.0;
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _slides.length,
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  EditorialImage(
                    imageUrl: 'asset:${slide.asset}',
                    fallbackAsset: slide.asset,
                    grayscale: true,
                    overlayOpacity: 0.42,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x33000000), Color(0xB3000000)],
                        stops: [0.2, 1],
                      ),
                    ),
                  ),
                  ContentFrame(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slide.kicker,
                          style: AppTextStyles.micro.copyWith(
                            color: AppColors.paper.withValues(alpha: .8),
                            fontSize: 8,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.title,
                          style: AppTextStyles.display.copyWith(
                            color: AppColors.paper,
                            fontSize: isMobile ? 34 : 52,
                            height: 1.06,
                            letterSpacing: -1.8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.body,
                          style: AppTextStyles.bodyMuted.copyWith(
                            color: AppColors.paper.withValues(alpha: .72),
                            fontSize: 10.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: isMobile ? 190 : 210,
                          child: TrappedButton(
                            label: slide.cta,
                            onPressed: index == 1
                                ? widget.onShopShirts
                                : widget.onShop,
                            variant: TrappedButtonVariant.outline,
                            height: 44,
                            fontSize: 8.5,
                          ),
                        ),
                        const SizedBox(height: 34),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          if (!isMobile) ...[
            Positioned(
              left: 18,
              top: 0,
              bottom: 0,
              child: Center(
                child: _HeroArrow(
                  icon: Icons.arrow_back,
                  onTap: () => _controller.previousPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 18,
              top: 0,
              bottom: 0,
              child: Center(
                child: _HeroArrow(
                  icon: Icons.arrow_forward,
                  onTap: () => _controller.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                  ),
                ),
              ),
            ),
          ],
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < _slides.length; index++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: index == _index ? 18 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: index == _index
                          ? AppColors.paper
                          : AppColors.paper.withValues(alpha: .4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            right: isMobile ? 16 : 76,
            bottom: 30,
            child: IgnorePointer(
              child: Text(
                '[trapped]',
                style: AppTextStyles.display.copyWith(
                  color: AppColors.paper.withValues(alpha: .16),
                  fontSize: isMobile ? 40 : 74,
                  letterSpacing: -2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroArrow extends StatelessWidget {
  const _HeroArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.paper.withValues(alpha: .85),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 16, color: AppColors.ink),
        ),
      ),
    );
  }
}
