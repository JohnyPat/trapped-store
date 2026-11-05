import 'package:firebase_database/firebase_database.dart';
import 'package:trapped_store/services/database_service.dart';
import 'package:uuid/uuid.dart';

import '../../utils/parse.dart';
import '../models/admin_product_model.dart';

/// Service for managing products in the admin panel.
/// CRUD operations against the Firebase Realtime Database `products` path.
class AdminProductService {
  AdminProductService({DatabaseService? database})
      : _database = database ?? DatabaseService();

  final DatabaseService _database;
  final Uuid _uuid = Uuid();

  /// Reference to a specific product.
  DatabaseReference _productRef(String id) =>
      _database.productsRef.child(id);

  /// Listen to a single product.
  Stream<AdminProduct> watchProduct(String id) {
    return _productRef(id).onValue.map((event) {
      final data = event.snapshot.value;
      if (data is! Map) return AdminProduct.empty(id);
      return AdminProduct.fromMap(id, asStringMap(data));
    });
  }

  /// Listen to all products.
  Stream<List<AdminProduct>> watchAllProducts() {
    return _database.productsRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data is! Map) return <AdminProduct>[];
      return data.entries.map((entry) {
        return AdminProduct.fromMap(
          entry.key.toString(),
          asStringMap(entry.value),
        );
      }).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  /// Fetch a single product by ID.
  Future<AdminProduct> fetchProduct(String id) async {
    final snapshot = await _productRef(id).get();
    final data = asStringMap(snapshot.value);
    if (data.isEmpty) return AdminProduct.empty(id);
    return AdminProduct.fromMap(id, data);
  }

  /// Create a new product.
  Future<String> createProduct({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required int stock,
    required List<String> sizes,
    bool featured = false,
    bool isNew = false,
    double? compareAtPrice,
    String? imageUrl,
    String? sku,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final product = AdminProduct(
      id: id,
      name: name,
      description: description,
      price: price,
      compareAtPrice: compareAtPrice,
      imageUrl: imageUrl,
      categoryId: categoryId,
      stock: stock,
      isAvailable: stock > 0,
      sizes: sizes,
      createdAt: now,
      updatedAt: now,
      sku: sku?.trim().isNotEmpty == true
          ? sku!.trim()
          : 'TRP-${name.substring(0, 3).toUpperCase()}-${DateTime.now().millisecond}',
      featured: featured,
      isNew: isNew,
    );

    await _productRef(id).set(product.toMap());
    return id;
  }

  /// Update an existing product.
  Future<void> updateProduct({
    required String id,
    String? name,
    String? description,
    double? price,
    double? compareAtPrice,
    String? imageUrl,
    String? categoryId,
    int? stock,
    bool? isAvailable,
    List<String>? sizes,
    bool? featured,
    bool? isNew,
    String? sku,
  }) async {
    final ref = _productRef(id);
    final existing = await ref.get();
    final data = asStringMap(existing.value);

    if (data.isNotEmpty) {
      final product = AdminProduct.fromMap(id, data).copyWith(
        name: name ?? data['name']?.toString(),
        description: description ?? data['description']?.toString(),
        price: price ?? asDouble(data['price']),
        compareAtPrice: compareAtPrice ?? asDouble(data['compareAtPrice']),
        imageUrl: imageUrl ?? data['imageUrl']?.toString(),
        categoryId: categoryId ?? data['categoryId']?.toString(),
        stock: stock ?? asInt(data['stock']),
        isAvailable: isAvailable ?? asBool(data['isAvailable'], true),
        sizes: sizes ?? asStringList(data['sizes']),
        featured: featured ?? asBool(data['featured']),
        isNew: isNew ?? asBool(data['isNew']),
        sku: sku ?? data['sku']?.toString(),
        updatedAt: DateTime.now(),
      );

      await ref.set(product.toMap());
    }
  }

  /// Delete a product.
  Future<void> deleteProduct(String id) async {
    await _productRef(id).remove();
  }
}