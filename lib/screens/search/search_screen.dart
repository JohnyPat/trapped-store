import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../utils/product_actions.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/product_grid.dart';
import '../../widgets/responsive.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialCategoryId});

  final String? initialCategoryId;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.initialCategoryId;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final query = _query.trim().toLowerCase();
    final results = catalog.products.where((product) {
      final matchesCategory =
          _categoryId == null || product.categoryId == _categoryId;
      if (!matchesCategory) return false;
      if (query.isEmpty) return true;
      return product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          catalog.categoryName(product.categoryId).toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Column(
        children: [
          BrandHeader(
            onLeading: () => Navigator.of(context).pop(),
            leadingIcon: Icons.arrow_back,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 28),
                    Text(
                      'SEARCH',
                      style: AppTextStyles.label.copyWith(
                        fontSize: 11,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      onChanged: (value) => setState(() => _query = value),
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14,
                        letterSpacing: 0.4,
                      ),
                      decoration: InputDecoration(
                        hintText: 'SEARCH PRODUCTS, CATEGORIES...',
                        hintStyle: AppTextStyles.micro.copyWith(
                          fontSize: 9,
                          letterSpacing: 1.4,
                          color: AppColors.faint,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 19,
                          color: AppColors.muted,
                        ),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _controller.clear();
                                  setState(() => _query = '');
                                },
                                icon: const Icon(
                                  Icons.close,
                                  size: 17,
                                  color: AppColors.muted,
                                ),
                              ),
                        filled: true,
                        fillColor: AppColors.canvas,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 17,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2),
                          borderSide: const BorderSide(color: AppColors.line),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2),
                          borderSide: const BorderSide(color: AppColors.line),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2),
                          borderSide: const BorderSide(color: AppColors.ink),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
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
                      onSelected: (id) => setState(() => _categoryId = id),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      query.isEmpty && _categoryId == null
                          ? 'ALL PIECES'
                          : '${results.length} ${results.length == 1 ? 'RESULT' : 'RESULTS'}',
                      style: AppTextStyles.micro.copyWith(
                        fontSize: 8,
                        letterSpacing: 1.8,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (results.isEmpty)
                      const EmptyState(
                        icon: Icons.search_off,
                        title: 'No matches',
                        message:
                            'Try a different search term or browse another category.',
                      )
                    else
                      ProductGrid(
                        products: results,
                        wishlistIds: wishlist.productIds,
                        onTapProduct: (product) =>
                            ProductActions.open(context, product),
                        onToggleWishlist: (product) =>
                            ProductActions.toggleWishlist(context, product),
                        onAddToCart: (product) =>
                            ProductActions.addToCart(context, product),
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: 40),
                      ),
                    const SizedBox(height: 20),
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
