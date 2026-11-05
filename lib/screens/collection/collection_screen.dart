import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../utils/product_actions.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/product_grid.dart';
import '../../widgets/responsive.dart';
import '../../widgets/section_heading.dart';
import '../search/search_screen.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({
    super.key,
    this.categoryId,
    required this.title,
  });

  final String? categoryId;
  final String title;

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  late String? _categoryId = widget.categoryId;

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final isNew = widget.title.toUpperCase().contains('NEW');
    var products = catalog.products.where((product) {
      if (isNew && !product.isNew) return false;
      if (_categoryId != null && product.categoryId != _categoryId) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Column(
        children: [
          BrandHeader(
            onLeading: () => Navigator.of(context).pop(),
            leadingIcon: Icons.arrow_back,
            trailing: IconButton(
              splashRadius: 20,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SearchScreen(),
                ),
              ),
              icon: const Icon(
                Icons.search,
                color: AppColors.paper,
                size: 19,
              ),
            ),
          ),
          Expanded(
            child: catalog.loading
                ? const LoadingState(label: 'LOADING COLLECTION')
                : catalog.error != null && catalog.products.isEmpty
                ? ErrorState(
                    message: catalog.error!,
                    onRetry: catalog.reload,
                  )
                : SingleChildScrollView(
                    child: ContentFrame(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 34),
                          SectionHeading(
                            title: widget.title,
                            subtitle:
                                '${products.length} ${products.length == 1 ? 'piece' : 'pieces'}',
                          ),
                          const SizedBox(height: 20),
                          CategoryChips(
                            categories: catalog.categories
                                .map(
                                  (category) => (
                                    id: category.id,
                                    name: category.name,
                                  ),
                                )
                                .toList(),
                            selectedId: _categoryId,
                            onSelected: (id) =>
                                setState(() => _categoryId = id),
                          ),
                          const SizedBox(height: 22),
                          if (products.isEmpty)
                            const EmptyState(
                              icon: Icons.inventory_2_outlined,
                              title: 'Nothing here yet',
                              message:
                                  'This collection is being restocked. Browse the full catalogue in the meantime.',
                            )
                          else
                            ProductGrid(
                              products: products,
                              wishlistIds: wishlist.productIds,
                              onTapProduct: (product) =>
                                  ProductActions.open(context, product),
                              onToggleWishlist: (product) =>
                                  ProductActions.toggleWishlist(
                                    context,
                                    product,
                                  ),
                              onAddToCart: (product) =>
                                  ProductActions.addToCart(context, product),
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(bottom: 50),
                            ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
