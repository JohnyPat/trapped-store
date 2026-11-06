import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:trapped_store/shared/constants/admin_constants.dart';
import 'package:trapped_store/services/storage_service.dart';
import 'package:trapped_store/utils/app_snack.dart';

import '../models/admin_category_model.dart';
import '../models/admin_product_model.dart';
import '../services/admin_category_service.dart';
import '../services/admin_product_service.dart';

/// Bundled product images that can be assigned as a product image.
const _bundledImages = <String>[
  'assets/images/products/praise-the-lord.png',
  'assets/images/products/we-are-fucked.png',
  'assets/images/products/pistol-tee.png',
  'assets/images/products/cruzifix-tee.png',
  'assets/images/products/leopard-shorts.png',
  'assets/images/products/fleece-shorts.png',
  'assets/images/products/check-shorts.png',
  'assets/images/products/real-tree-shorts.png',
  'assets/images/products/leo-jorts-brown.png',
  'assets/images/products/leo-jorts-white.png',
  'assets/images/products/666-cap.png',
  'assets/images/products/mauve-cap.png',
];

/// Add / Edit form for an admin-managed product.
class AdminProductFormPage extends StatefulWidget {
  const AdminProductFormPage({super.key, this.product});

  /// The product to edit, or null to create a new one.
  final AdminProduct? product;

  @override
  State<AdminProductFormPage> createState() => _AdminProductFormPageState();
}

class _AdminProductFormPageState extends State<AdminProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _compareAtPrice = TextEditingController();
  final _stock = TextEditingController();
  final _sizes = TextEditingController();
  final _imageUrl = TextEditingController();
  final _sku = TextEditingController();
  final _newCategory = TextEditingController();

  final _productService = AdminProductService();
  final _categoryService = AdminCategoryService();
  final _storageService = StorageService();
  final _imagePicker = ImagePicker();

  String? _categoryId;
  String? _selectedPreset;
  bool _featured = false;
  bool _isNew = false;
  bool _submitting = false;
  bool _uploading = false;
  bool _loadingCategories = true;
  List<AdminCategory> _categories = [];

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    if (product != null) {
      _name.text = product.name;
      _description.text = product.description;
      _price.text = product.price.toStringAsFixed(2);
      if (product.compareAtPrice != null) {
        _compareAtPrice.text = product.compareAtPrice!.toStringAsFixed(2);
      }
      _stock.text = product.stock.toString();
      _sizes.text = product.sizes.join(', ');
      _imageUrl.text = product.imageUrl ?? '';
      _sku.text = product.sku;
      _categoryId = product.categoryId.isEmpty ? null : product.categoryId;
      _featured = product.featured;
      _isNew = product.isNew;
      final existing = product.imageUrl ?? '';
      if (existing.isNotEmpty && !existing.startsWith('http')) {
        // Bundled asset path — mark it as the selected preset
        _selectedPreset =
            existing.startsWith('asset:') ? existing.substring(6) : existing;
      }
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.watchAllCategories().first;
      if (mounted) setState(() => _categories = categories);
    } catch (_) {
      if (mounted) setState(() => _categories = []);
    } finally {
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _compareAtPrice.dispose();
    _stock.dispose();
    _sizes.dispose();
    _imageUrl.dispose();
    _sku.dispose();
    _newCategory.dispose();
    super.dispose();
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) return 'Price is required';
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Enter a valid number';
    if (parsed < 0) return 'Price cannot be negative';
    return null;
  }

  String? _validateStock(String? value) {
    if (value == null || value.trim().isEmpty) return 'Stock is required';
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return 'Enter a whole number';
    if (parsed < 0) return 'Stock cannot be negative';
    return null;
  }

  List<String> _parseSizes(String raw) {
    return raw
        .split(',')
        .map((s) => s.trim().toUpperCase())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
  }

  /// Returns the category id to use for this product.
  /// - If the admin typed a new category name, create it on the fly.
  /// - Otherwise use the dropdown selection.
  Future<String?> _resolveCategoryId() async {
    final newName = _newCategory.text.trim();
    if (newName.isNotEmpty) {
      return _categoryService.createCategory(name: newName);
    }
    return _categoryId;
  }

  /// Effective image for the preview/save: preset first, then the text field.
  String? get _effectiveImage {
    if (_selectedPreset != null && _imageUrl.text.trim().isEmpty) {
      return _selectedPreset;
    }
    final url = _imageUrl.text.trim();
    return url.isEmpty ? null : url;
  }

  /// Let the admin pick a photo (camera or gallery) and upload it to
  /// Firebase Storage. The returned download URL is written into the
  /// image field so it syncs like any other product image.
  Future<void> _pickAndUploadImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take a photo'),
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
    if (source == null) return;

    setState(() => _uploading = true);
    try {
      final file =
          await _imagePicker.pickImage(source: source, imageQuality: 85);
      if (file == null) {
        if (mounted) setState(() => _uploading = false);
        return;
      }
      // New products have no id yet — use a timestamp-based folder.
      final productKey = widget.product?.id ??
          'new_${DateTime.now().millisecondsSinceEpoch}';
      final url = await _storageService.uploadProductImage(
        productId: productKey,
        file: file,
      );
      if (!mounted) return;
      setState(() {
        _imageUrl.text = url;
        _selectedPreset = null;
        _uploading = false;
      });
      AppSnack.success(context, 'Photo uploaded — remember to SAVE.');
    } on StorageServiceException catch (error) {
      if (!mounted) return;
      AppSnack.error(context, error.message);
      setState(() => _uploading = false);
    } catch (error) {
      if (!mounted) return;
      AppSnack.error(context, 'Upload failed: $error');
      setState(() => _uploading = false);
    }
  }

  /// Resolves either the bundled asset path or a network URL into a widget.
  Widget _imageFor(String path, {BoxFit fit = BoxFit.cover}) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (_, _, _) => _brokenImage(),
      );
    }
    final assetPath =
        path.startsWith('asset:') ? path.substring('asset:'.length) : path;
    return Image.asset(assetPath, fit: fit, errorBuilder: (_, _, _) => _brokenImage());
  }

  Widget _brokenImage() => const Icon(
        Icons.image_not_supported,
        size: 48,
        color: AdminColors.muted,
      );

  /// Large live preview of the chosen image.
  Widget _buildImagePreview() {
    final effective = _effectiveImage;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 180,
        width: double.infinity,
        color: AdminColors.canvas,
        child: effective == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_photo_alternate_outlined,
                        size: 48, color: AdminColors.muted),
                    const SizedBox(height: 8),
                    Text('Choose an image below',
                        style: TextStyle(
                            color: AdminColors.muted, fontSize: 12)),
                  ],
                ),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  _imageFor(effective, fit: BoxFit.cover),
                  if (_selectedPreset != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        color: AdminColors.ink,
                        child: const Text(
                          'BUNDLED',
                          style: TextStyle(
                            color: AdminColors.paper,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  /// Grid of bundled streetwear shots to choose from.
  Widget _buildPresetGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _bundledImages.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final path = _bundledImages[index];
        final selected = _selectedPreset == path;
        return GestureDetector(
          onTap: () => setState(() {
            if (selected) {
              _selectedPreset = null;
            } else {
              _selectedPreset = path;
              _imageUrl.clear();
            }
          }),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(path, fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _brokenImage()),
                if (selected)
                  Container(
                    color: AdminColors.ink.withValues(alpha: 0.55),
                    child: const Icon(Icons.check_circle,
                        color: AdminColors.paper, size: 32),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final newCategoryName = _newCategory.text.trim();
    if (_categoryId == null && newCategoryName.isEmpty) {
      AppSnack.error(context, 'Select a category, or type a new one.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final categoryId = await _resolveCategoryId();
      if (categoryId == null) {
        if (!mounted) return;
        AppSnack.error(context, 'Unable to resolve the category. Try again.');
        setState(() => _submitting = false);
        return;
      }

      final sizes = _parseSizes(_sizes.text);
      if (sizes.isEmpty) {
        if (!mounted) return;
        AppSnack.error(context, 'Enter at least one size (e.g. S, M, L).');
        setState(() => _submitting = false);
        return;
      }

      final compareAtPriceText = _compareAtPrice.text.trim();
      final compareAtPrice =
          compareAtPriceText.isEmpty ? null : double.parse(compareAtPriceText);
      final imageUrl = _effectiveImage;

      if (_isEditing) {
        await _productService.updateProduct(
          id: widget.product!.id,
          name: _name.text.trim(),
          description: _description.text.trim(),
          price: double.parse(_price.text.trim()),
          compareAtPrice: compareAtPrice,
          imageUrl: imageUrl,
          categoryId: categoryId,
          stock: int.parse(_stock.text.trim()),
          isAvailable: int.parse(_stock.text.trim()) > 0,
          sizes: sizes,
          featured: _featured,
          isNew: _isNew,
          sku: _sku.text.trim().isEmpty ? null : _sku.text.trim(),
        );
        if (!mounted) return;
        AppSnack.success(context, 'Product updated.');
      } else {
        await _productService.createProduct(
          name: _name.text.trim(),
          description: _description.text.trim(),
          price: double.parse(_price.text.trim()),
          compareAtPrice: compareAtPrice,
          imageUrl: imageUrl,
          categoryId: categoryId,
          stock: int.parse(_stock.text.trim()),
          sizes: sizes,
          featured: _featured,
          isNew: _isNew,
          sku: _sku.text.trim().isEmpty ? null : _sku.text.trim(),
        );
        if (!mounted) return;
        AppSnack.success(context, 'Product created.');
      }
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      AppSnack.error(context, 'Failed to save product: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Product name *',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _price,
                    decoration: const InputDecoration(
                      labelText: 'Price *',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: _validatePrice,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _compareAtPrice,
                    decoration: const InputDecoration(
                      labelText: 'Compare-at price (optional)',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return null;
                      final price = double.tryParse(value.trim());
                      if (price == null) return 'Enter a valid number';
                      if (price < 0) return 'Cannot be negative';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stock,
                    decoration: const InputDecoration(
                      labelText: 'Stock *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validateStock,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _sizes,
                    decoration: const InputDecoration(
                      labelText: 'Sizes * (comma separated)',
                      border: OutlineInputBorder(),
                      hintText: 'S, M, L, XL',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loadingCategories)
              const Center(child: CircularProgressIndicator())
            else ...[
              DropdownButtonFormField<String>(
                initialValue: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (value) => setState(() => _categoryId = value),
                hint: const Text('Select a category'),
              ),
              const SizedBox(height: 10),
              const Text(
                'Or create a new category:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AdminColors.muted,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _newCategory,
                decoration: const InputDecoration(
                  hintText: 'New category name',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            // ── PRODUCT IMAGE ─────────────────────────────
            Text(
              'PRODUCT IMAGE',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: AdminColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Upload a photo, pick a bundled streetwear shot, or paste a link.',
              style: TextStyle(fontSize: 11, color: AdminColors.muted),
            ),
            const SizedBox(height: 12),
            _buildImagePreview(),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _uploading ? null : _pickAndUploadImage,
              icon: _uploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload_outlined, size: 18),
              label: Text(_uploading ? 'UPLOADING…' : 'UPLOAD PHOTO'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AdminColors.ink,
                side: const BorderSide(color: AdminColors.line),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _imageUrl,
              decoration: const InputDecoration(
                labelText: 'Or paste image URL / asset path',
                border: OutlineInputBorder(),
                hintText: 'https://… or assets/images/products/…',
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() => _selectedPreset = null),
            ),
            const SizedBox(height: 12),
            const Text(
              'Bundled images (tap to select):',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AdminColors.muted,
              ),
            ),
            const SizedBox(height: 8),
            _buildPresetGrid(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sku,
              decoration: const InputDecoration(
                labelText: 'SKU (optional — auto generated if empty)',
                border: OutlineInputBorder(),
                hintText: 'TRP-XXX-123',
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Featured'),
              value: _featured,
              onChanged: (v) => setState(() => _featured = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mark as New'),
              value: _isNew,
              onChanged: (v) => setState(() => _isNew = v),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AdminColors.ink,
                foregroundColor: AdminColors.paper,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isEditing ? 'SAVE CHANGES' : 'ADD PRODUCT',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}