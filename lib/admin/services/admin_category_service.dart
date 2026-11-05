import 'package:firebase_database/firebase_database.dart';
import 'package:trapped_store/services/database_service.dart';

import '../../utils/parse.dart';
import '../models/admin_category_model.dart';

/// Service for managing categories in the admin panel.
/// CRUD operations against the Firebase Realtime Database `categories` path.
class AdminCategoryService {
  AdminCategoryService({DatabaseService? database})
      : _database = database ?? DatabaseService();

  final DatabaseService _database;

  /// Reference to a specific category.
  DatabaseReference _categoryRef(String id) => _database.categoriesRef.child(id);

  /// Listen to a single category.
  Stream<AdminCategory> watchCategory(String id) {
    return _categoryRef(id).onValue.map((event) {
      final data = event.snapshot.value;
      if (data is! Map) return AdminCategory.empty(id);
      return AdminCategory.fromMap(id, asStringMap(data));
    });
  }

  /// Listen to all categories.
  Stream<List<AdminCategory>> watchAllCategories() {
    return _database.categoriesRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data is! Map) return <AdminCategory>[];
      return data.entries.map((entry) {
        return AdminCategory.fromMap(
          entry.key.toString(),
          asStringMap(entry.value),
        );
      }).toList();
    });
  }

  /// Fetch a single category by ID.
  Future<AdminCategory> fetchCategory(String id) async {
    final snapshot = await _categoryRef(id).get();
    final data = asStringMap(snapshot.value);
    if (data.isEmpty) return AdminCategory.empty(id);
    return AdminCategory.fromMap(id, data);
  }

  /// Create a new category.
  Future<String> createCategory({
    required String name,
    String? description,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();
    final category = AdminCategory(
      id: id,
      name: name,
      description: description,
      productCount: 0,
      createdAt: now,
      updatedAt: now,
    );

    await _categoryRef(id).set(category.toMap());
    return id;
  }

  /// Update an existing category.
  Future<void> updateCategory({
    required String id,
    String? name,
    String? description,
    int? productCount,
  }) async {
    final ref = _categoryRef(id);
    final existing = await ref.get();
    final data = asStringMap(existing.value);

    if (data.isNotEmpty) {
      final category = AdminCategory.fromMap(id, data).copyWith(
        name: name ?? data['name']?.toString(),
        description: description ?? data['description']?.toString(),
        productCount: productCount ?? asInt(data['productCount']),
        updatedAt: DateTime.now(),
      );

      await ref.set(category.toMap());
    }
  }

  /// Delete a category.
  Future<void> deleteCategory(String id) async {
    await _categoryRef(id).remove();
  }
}