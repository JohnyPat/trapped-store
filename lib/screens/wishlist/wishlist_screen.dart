import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../utils/auth_guard.dart';
import '../../utils/product_actions.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/product_grid.dart';
import '../../widgets/responsive.dart';
import '../../widgets/section_heading.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final catalog = context.watch<CatalogProvider>();
    final wishlist = context.watch<WishlistProvider>();

    if (!auth.isAuthenticated) {
      return SingleChildScrollView(
        child: ContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 38),
              const SectionHeading(
                title: 'Wishlist',
                subtitle: 'Keep the pieces you are not ready to let go of.',
              ),
              const SizedBox(height: 20),
              EmptyState(
                icon: Icons.favorite_border,
                title: 'Sign in to save pieces',
                message:
                    'Your wishlist is tied to your account, so it follows you from web to mobile.',
                actionLabel: 'SIGN IN',
                onAction: () => openLogin(context),
              ),
            ],
          ),
        ),
      );
    }

    if (catalog.loading && catalog.products.isEmpty) {
      return const LoadingState(label: 'LOADING WISHLIST');
    }
    if (catalog.error != null && catalog.products.isEmpty) {
      return ErrorState(
        message: catalog.error!,
        onRetry: catalog.reload,
      );
    }

    final products = wishlist.productIds
        .map(catalog.productById)
        .whereType<Product>()
        .toList();

    return RefreshIndicator(
      color: AppColors.ink,
      onRefresh: () async => catalog.reload(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 38),
              SectionHeading(
                title: 'Wishlist',
                subtitle: products.isEmpty
                    ? 'Keep the pieces you are not ready to let go of.'
                    : '${products.length} ${products.length == 1 ? 'piece' : 'pieces'} saved for later.',
              ),
              const SizedBox(height: 24),
              if (products.isEmpty)
                EmptyState(
                  icon: Icons.favorite_border,
                  title: 'Nothing saved yet',
                  message:
                      'Tap the heart on any piece to keep it here while you decide.',
                  actionLabel: 'SHOP THE COLLECTION',
                  onAction: () => ProductActions.openCollection(context),
                )
              else
                ProductGrid(
                  products: products,
                  wishlistIds: wishlist.productIds,
                  onTapProduct: (product) =>
                      ProductActions.open(context, product),
                  onToggleWishlist: (product) =>
                      ProductActions.toggleWishlist(context, product),
                  onAddToCart: (product) =>
                      ProductActions.addToCart(context, product),
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 46),
                ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
