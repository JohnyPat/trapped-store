import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../screens/collection/collection_screen.dart';
import '../screens/product/product_details_screen.dart';
import '../widgets/size_picker_sheet.dart';
import 'app_snack.dart';
import 'auth_guard.dart';

abstract final class ProductActions {
  static Future<void> open(BuildContext context, Product product) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsScreen(productId: product.id),
      ),
    );
  }

  static Future<void> openCollection(
    BuildContext context, {
    String? categoryId,
    String title = 'ALL PRODUCTS',
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CollectionScreen(
          categoryId: categoryId,
          title: title,
        ),
      ),
    );
  }

  static Future<void> toggleWishlist(
    BuildContext context,
    Product product,
  ) async {
    if (!await ensureSignedIn(context)) return;
    if (!context.mounted) return;
    try {
      await context.read<WishlistProvider>().toggle(product.id);
      if (!context.mounted) return;
      final saved = context.read<WishlistProvider>().isWishlisted(product.id);
      AppSnack.show(
        context,
        saved ? 'Added to your wishlist.' : 'Removed from your wishlist.',
      );
    } catch (error) {
      if (!context.mounted) return;
      AppSnack.error(context, error.toString());
    }
  }

  static Future<void> addToCart(
    BuildContext context,
    Product product,
  ) async {
    if (!await ensureSignedIn(context)) return;
    if (!context.mounted) return;
    final size = await showSizePicker(context, product);
    if (size == null || !context.mounted) return;
    try {
      await context.read<CartProvider>().add(
        product: product,
        size: size,
        quantity: 1,
      );
      if (!context.mounted) return;
      AppSnack.success(context, '${product.name} added to your bag.');
    } catch (error) {
      if (!context.mounted) return;
      AppSnack.error(context, error.toString());
    }
  }
}
