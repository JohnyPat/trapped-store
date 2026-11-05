import 'package:flutter/material.dart';

import 'package:trapped_store/shared/constants/admin_constants.dart';

import '../models/admin_product_model.dart';
import '../services/admin_product_service.dart';
import '../widgets/admin_product_card.dart';
import 'admin_product_form_page.dart';

/// Admin products management page: list, search, add, edit, delete.
class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  final _productService = AdminProductService();
  final _searchController = TextEditingController();
  String _query = '';

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
        title: const Text('Delete product?'),
        content: Text('Remove "${product.name}" from the store? This cannot be undone.'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${product.name}" deleted.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row: title + Add Product button
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
          // Search bar
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
              onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
            ),
          ),
          // Product grid
          Expanded(
            child: StreamBuilder<List<AdminProduct>>(
              stream: _productService.watchAllProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Failed to load products: ${snapshot.error}'),
                  );
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
              },
            ),
          ),
        ],
      ),
    );
  }
}