import 'package:flutter/material.dart';

import 'package:trapped_store/shared/constants/admin_constants.dart';

import '../models/admin_category_model.dart';
import '../services/admin_category_service.dart';
import '../services/admin_product_service.dart';
import '../widgets/admin_breakpoints.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_page_container.dart';

/// Admin categories management: list, add, rename, delete.
class AdminCategoriesPage extends StatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  State<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  final _categoryService = AdminCategoryService();
  final _productService = AdminProductService();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<Map<String, int>> _loadProductCounts() async {
    try {
      final products = await _productService.watchAllProducts().first;
      final counts = <String, int>{};
      for (final p in products) {
        counts[p.categoryId] = (counts[p.categoryId] ?? 0) + 1;
      }
      return counts;
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveCategory({AdminCategory? existing}) async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _showMessage('Give the category a name.');
      return;
    }
    try {
      if (existing == null) {
        await _categoryService.createCategory(
          name: name,
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
        );
        _showMessage('Category created.');
      } else {
        await _categoryService.updateCategory(
          id: existing.id,
          name: name,
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
        );
        _showMessage('Category updated.');
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      _showMessage('Failed to save category: $e');
    }
  }

  Future<void> _deleteCategory(AdminCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        constraints: const BoxConstraints(maxWidth: 520),
        title: const Text('Delete category?'),
        content: Text(
          'Remove "${category.name}"? Products in this category are kept, '
          'but their category will become unknown.',
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
      await _categoryService.deleteCategory(category.id);
      _showMessage('Category deleted.');
    } catch (e) {
      _showMessage('Failed to delete category: $e');
    }
  }

  Future<void> _showCategoryDialog({AdminCategory? existing}) async {
    if (existing != null) {
      _nameCtrl.text = existing.name;
      _descCtrl.text = existing.description ?? '';
    } else {
      _nameCtrl.clear();
      _descCtrl.clear();
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        constraints: const BoxConstraints(maxWidth: 560),
        title: Text(existing == null ? 'Add category' : 'Edit category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Category name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => _saveCategory(existing: existing),
            style: FilledButton.styleFrom(
              backgroundColor: AdminColors.ink,
              foregroundColor: AdminColors.paper,
            ),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _loadProductCounts(),
      builder: (context, countsSnap) {
        return StreamBuilder<List<AdminCategory>>(
          stream: _categoryService.watchAllCategories(),
          builder: (context, snapshot) {
            if (AdminBreakpoints.isDesktop(context)) {
              return _buildDesktop(countsSnap, snapshot);
            }
            return _buildMobile(countsSnap, snapshot);
          },
        );
      },
    );
  }

  // ── Mobile (unchanged layout) ───────────────────────────────────────

  Widget _buildMobile(
    AsyncSnapshot<Map<String, int>> countsSnap,
    AsyncSnapshot<List<AdminCategory>> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (snapshot.hasError) {
      return Scaffold(
        body: Center(
          child: Text('Failed to load categories: ${snapshot.error}'),
        ),
      );
    }
    var categories = snapshot.data ?? <AdminCategory>[];
    categories = categories.toList()..sort((a, b) => a.name.compareTo(b.name));
    final counts = countsSnap.data ?? {};

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.ink,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => _showCategoryDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('ADD CATEGORY'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AdminColors.ink,
                    foregroundColor: AdminColors.paper,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: categories.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No categories yet.\nTap "ADD CATEGORY" to create one.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AdminColors.muted),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final count = counts[category.id] ?? 0;
                      return Card(
                        color: AdminColors.paper,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AdminColors.canvas,
                            child: Text(
                              category.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: AdminColors.ink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(category.name),
                          subtitle: Text(
                            category.description?.isNotEmpty == true
                                ? category.description!
                                : '$count product${count == 1 ? '' : 's'}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AdminColors.canvas,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '$count products',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AdminColors.muted,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                color: AdminColors.accent,
                                onPressed: () =>
                                    _showCategoryDialog(existing: category),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 18),
                                color: AdminColors.danger,
                                onPressed: () => _deleteCategory(category),
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── Desktop data table ──────────────────────────────────────────────

  Widget _buildDesktop(
    AsyncSnapshot<Map<String, int>> countsSnap,
    AsyncSnapshot<List<AdminCategory>> snapshot,
  ) {
    var categories = snapshot.data ?? <AdminCategory>[];
    categories = categories.toList()..sort((a, b) => a.name.compareTo(b.name));
    final counts = countsSnap.data ?? {};

    return Scaffold(
      backgroundColor: AdminColors.canvas,
      body: AdminPageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminPageHeader(
              title: 'Categories',
              subtitle:
                  'Organise the catalog into groups customers can browse.',
              actions: FilledButton.icon(
                onPressed: () => _showCategoryDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add category'),
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
              child: AdminDataTable<AdminCategory>(
                rows: categories,
                loading: snapshot.connectionState == ConnectionState.waiting,
                error: snapshot.hasError
                    ? 'Failed to load categories: ${snapshot.error}'
                    : null,
                searchText: (c) => '${c.name} ${c.description ?? ''}',
                searchHint: 'Search categories…',
                emptyMessage: 'No categories yet. Add one to get started.',
                minWidth: 720,
                pageSize: 10,
                initialSortIndex: 0,
                initialSortAscending: true,
                columns: [
                  AdminTableColumn<AdminCategory>(
                    label: 'Category',
                    flex: 2,
                    sortValue: (c) => c.name,
                    cell: (c) => Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AdminColors.canvas,
                          child: Text(
                            c.name.isEmpty
                                ? '?'
                                : c.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AdminColors.ink,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            c.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AdminColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AdminTableColumn<AdminCategory>(
                    label: 'Description',
                    flex: 3,
                    cell: (c) => Text(
                      (c.description ?? '').isEmpty ? '—' : c.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AdminColors.muted,
                      ),
                    ),
                  ),
                  AdminTableColumn<AdminCategory>(
                    label: 'Products',
                    flex: 1,
                    align: Alignment.centerRight,
                    sortValue: (c) => counts[c.id] ?? 0,
                    cell: (c) {
                      final count = counts[c.id] ?? 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AdminColors.canvas,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AdminColors.ink,
                          ),
                        ),
                      );
                    },
                  ),
                  AdminTableColumn<AdminCategory>(
                    label: 'Actions',
                    width: 96,
                    align: Alignment.centerRight,
                    cell: (c) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: 'Edit category',
                          child: IconButton(
                            iconSize: 18,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _showCategoryDialog(existing: c),
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: AdminColors.accent,
                            ),
                          ),
                        ),
                        Tooltip(
                          message: 'Delete category',
                          child: IconButton(
                            iconSize: 18,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _deleteCategory(c),
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
}
