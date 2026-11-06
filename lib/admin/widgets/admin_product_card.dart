import 'package:flutter/material.dart';

import 'package:trapped_store/shared/constants/admin_constants.dart';
import 'package:trapped_store/utils/formatters.dart';

import '../../utils/image_data.dart';
import '../models/admin_product_model.dart';

/// Admin product card for listing products in tables or grids.
class AdminProductCard extends StatelessWidget {
  const AdminProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
    this.showActions = false,
  });

  final AdminProduct product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showActions;

  /// Resolves the product image (asset path, "asset:" prefix, or network).
  Widget _buildImage(AdminProduct product) {
    final url = product.imageUrl;
    if (url == null || url.isEmpty) {
      return const Icon(Icons.inventory, size: 40,
          color: AdminColors.muted);
    }
    final errorIcon = Icons.image_not_supported;
    final inline = decodeImageDataUrl(url);
    if (inline != null) {
      return Image.memory(
        inline,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(errorIcon, color: AdminColors.muted),
      );
    }
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, _, _) =>
            Icon(errorIcon, color: AdminColors.muted),
      );
    }
    final assetPath =
        url.startsWith('asset:') ? url.substring('asset:'.length) : url;
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) =>
          Icon(errorIcon, color: AdminColors.muted),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.isLowStock;
    final statusColor = isLowStock ? AdminColors.warning : AdminColors.success;

    return Card(
      color: AdminColors.paper,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image thumbnail
            AspectRatio(
              aspectRatio: 16 / 21,
              child: Container(
                decoration: BoxDecoration(
                  color: AdminColors.canvas,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _buildImage(product),
              ),
            ),
            const SizedBox(height: 8),
            // Product name and SKU
            Text(
              product.name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: AdminColors.ink,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'SKU: ${product.sku}',
              style: TextStyle(
                fontSize: 10,
                color: AdminColors.muted,
              ),
            ),
            const SizedBox(height: 4),
            // Price and stock
            Row(
              children: [
                Text(
                  Formatters.currency(product.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AdminColors.ink,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    product.stockStatus,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Category and featured tags
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (product.categoryId.isNotEmpty)
                  Chip(
                    label: Text(
                      'Cat: ${product.categoryId.split('-').first}',
                      style: const TextStyle(fontSize: 9, color: AdminColors.muted),
                    ),
                    backgroundColor: AdminColors.canvas,
                  ),
                if (product.featured)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.star, size: 12, color: AdminColors.accent),
                  ),
                if (product.isNew)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.new_releases, size: 12, color: AdminColors.success),
                  ),
              ],
            ),
            if (showActions) ...[
              const Spacer(),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18,
                        color: AdminColors.accent),
                    onPressed: onEdit,
                    tooltip: 'Edit product',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18,
                        color: AdminColors.danger),
                    onPressed: onDelete,
                    tooltip: 'Delete product',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}