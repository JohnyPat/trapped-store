import 'package:flutter/material.dart';

import 'package:trapped_store/shared/constants/admin_constants.dart';
import 'package:trapped_store/utils/formatters.dart';
import 'package:trapped_store/utils/image_data.dart';

import '../models/admin_product_model.dart';
import '../services/admin_product_service.dart';
import '../widgets/admin_breakpoints.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_page_container.dart';
import '../widgets/admin_product_card.dart';
import 'admin_product_form_page.dart';

/// Admin products management: list, search, add, edit, delete.
class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  final _productService = AdminProductService();
  final _searchController = TextEditingController();
  String _query = '';
  String _stockFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddProduct() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AdminProductFormPage()),
    );
  }

  void _openEditProduct(AdminProduct product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdminProductFormPage(product: product),
      ),
    );
  }

  Future<void> _confirmDelete(AdminProduct product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        constraints: const BoxConstraints(maxWidth: 520),
        title: const Text('Delete product?'),
        content: Text(
          'Remove "${product.name}" from the store? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AdminColors.danger),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _productService.deleteProduct(product.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('"${product.name}" deleted.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final desktop = AdminBreakpoints.isDesktop(context);
    return StreamBuilder<List<AdminProduct>>(
      stream: _productService.watchAllProducts(),
      builder: (context, snapshot) {
        if (desktop) return _buildDesktop(snapshot);
        return _buildMobile(snapshot);
      },
    );
  }

  // ── Mobile (unchanged layout) ───────────────────────────────────────

  Widget _buildMobile(AsyncSnapshot<List<AdminProduct>> snapshot) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Text(
                  'Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.ink,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _openAddProduct,
                  icon: const Icon(Icons.add),
                  label: const Text('ADD PRODUCT'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AdminColors.ink,
                    foregroundColor: AdminColors.paper,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products or SKU...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
            ),
          ),
          Expanded(child: _buildMobileBody(snapshot)),
        ],
      ),
    );
  }

  Widget _buildMobileBody(AsyncSnapshot<List<AdminProduct>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(child: Text('Failed to load products: ${snapshot.error}'));
    }
    var products = snapshot.data ?? <AdminProduct>[];
    if (_query.isNotEmpty) {
      products = products.where((p) {
        return p.name.toLowerCase().contains(_query) ||
            p.sku.toLowerCase().contains(_query);
      }).toList();
    }
    if (products.isEmpty) {
      return const Center(
        child: Text('No products yet. Tap "ADD PRODUCT" to create one.'),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1100
            ? 4
            : width >= 760
            ? 3
            : 2;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.58,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return AdminProductCard(
              product: product,
              showActions: true,
              onEdit: () => _openEditProduct(product),
              onDelete: () => _confirmDelete(product),
            );
          },
        );
      },
    );
  }

  // ── Desktop data table ──────────────────────────────────────────────

  Widget _buildDesktop(AsyncSnapshot<List<AdminProduct>> snapshot) {
    var products = snapshot.data ?? <AdminProduct>[];
    switch (_stockFilter) {
      case 'low':
        products = products.where((p) => p.isLowStock).toList();
        break;
      case 'out':
        products = products
            .where((p) => !p.isAvailable || p.stock <= 0)
            .toList();
        break;
      case 'in':
        products = products.where((p) => p.isAvailable && p.stock > 5).toList();
        break;
    }

    return Scaffold(
      backgroundColor: AdminColors.canvas,
      body: AdminPageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminPageHeader(
              title: 'Products',
              subtitle:
                  'Manage the catalog, pricing and stock levels for the store.',
              actions: FilledButton.icon(
                onPressed: _openAddProduct,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add product'),
                style: FilledButton.styleFrom(
                  backgroundColor: AdminColors.ink,
                  foregroundColor: AdminColors.paper,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: AdminDataTable<AdminProduct>(
                rows: products,
                loading: snapshot.connectionState == ConnectionState.waiting,
                error: snapshot.hasError
                    ? 'Failed to load products: ${snapshot.error}'
                    : null,
                searchText: (p) => '${p.name} ${p.sku} ${p.categoryId}',
                searchHint: 'Search products or SKU…',
                emptyMessage: 'No products match this filter.',
                minWidth: 980,
                pageSize: 10,
                initialSortIndex: 0,
                initialSortAscending: true,
                filters: [
                  AdminTableFilter(
                    label: 'All',
                    selected: _stockFilter == 'all',
                    onTap: () => setState(() => _stockFilter = 'all'),
                  ),
                  AdminTableFilter(
                    label: 'In stock',
                    selected: _stockFilter == 'in',
                    onTap: () => setState(() => _stockFilter = 'in'),
                  ),
                  AdminTableFilter(
                    label: 'Low stock',
                    selected: _stockFilter == 'low',
                    onTap: () => setState(() => _stockFilter = 'low'),
                  ),
                  AdminTableFilter(
                    label: 'Out of stock',
                    selected: _stockFilter == 'out',
                    onTap: () => setState(() => _stockFilter = 'out'),
                  ),
                ],
                columns: [
                  AdminTableColumn<AdminProduct>(
                    label: 'Product',
                    flex: 3,
                    sortValue: (p) => p.name,
                    cell: (p) => Row(
                      children: [
                        _productThumb(p),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AdminColors.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                p.sku.isEmpty ? 'No SKU' : 'SKU: ${p.sku}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AdminColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AdminTableColumn<AdminProduct>(
                    label: 'Category',
                    flex: 2,
                    sortValue: (p) => p.categoryId,
                    cell: (p) => Text(
                      p.categoryId.isEmpty ? '—' : p.categoryId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AdminColors.ink,
                      ),
                    ),
                  ),
                  AdminTableColumn<AdminProduct>(
                    label: 'Price',
                    flex: 1,
                    align: Alignment.centerRight,
                    sortValue: (p) => p.price,
                    cell: (p) => Text(
                      Formatters.currency(p.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AdminColors.ink,
                      ),
                    ),
                  ),
                  AdminTableColumn<AdminProduct>(
                    label: 'Stock',
                    flex: 1,
                    align: Alignment.centerRight,
                    sortValue: (p) => p.stock,
                    cell: (p) => _stockBadge(p),
                  ),
                  AdminTableColumn<AdminProduct>(
                    label: 'Status',
                    flex: 2,
                    cell: (p) => Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        _tag(
                          p.isAvailable ? 'ACTIVE' : 'HIDDEN',
                          p.isAvailable
                              ? AdminColors.success
                              : AdminColors.muted,
                        ),
                        if (p.featured) _tag('FEATURED', AdminColors.accent),
                        if (p.isNew) _tag('NEW', AdminColors.warning),
                      ],
                    ),
                  ),
                  AdminTableColumn<AdminProduct>(
                    label: 'Actions',
                    width: 96,
                    align: Alignment.centerRight,
                    cell: (p) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: 'Edit product',
                          child: IconButton(
                            iconSize: 18,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _openEditProduct(p),
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: AdminColors.accent,
                            ),
                          ),
                        ),
                        Tooltip(
                          message: 'Delete product',
                          child: IconButton(
                            iconSize: 18,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _confirmDelete(p),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AdminColors.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productThumb(AdminProduct product) {
    final url = product.imageUrl;
    Widget child;
    if (url == null || url.isEmpty) {
      child = const Icon(
        Icons.inventory_2_outlined,
        size: 20,
        color: AdminColors.muted,
      );
    } else {
      final inline = decodeImageDataUrl(url);
      if (inline != null) {
        child = Image.memory(
          inline,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const Icon(
            Icons.image_not_supported_outlined,
            size: 18,
            color: AdminColors.muted,
          ),
        );
      } else if (url.startsWith('http')) {
        child = Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const Icon(
            Icons.image_not_supported_outlined,
            size: 18,
            color: AdminColors.muted,
          ),
        );
      } else {
        final assetPath = url.startsWith('asset:')
            ? url.substring('asset:'.length)
            : url;
        child = Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const Icon(
            Icons.image_not_supported_outlined,
            size: 18,
            color: AdminColors.muted,
          ),
        );
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 40,
        height: 50,
        color: AdminColors.canvas,
        child: child,
      ),
    );
  }

  Widget _stockBadge(AdminProduct product) {
    final color = !product.isAvailable || product.stock <= 0
        ? AdminColors.danger
        : product.isLowStock
        ? AdminColors.warning
        : AdminColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        product.stock.toString(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: color,
        ),
      ),
    );
  }
}
