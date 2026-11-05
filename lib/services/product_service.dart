import '../models/category.dart';
import '../models/product.dart';
import '../utils/parse.dart';
import 'database_service.dart';

class ProductService {
  ProductService({DatabaseService? database})
    : _database = database ?? DatabaseService();

  final DatabaseService _database;

  Stream<List<Product>> watchProducts() {
    return _database.productsRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return <Product>[];
      final products = <Product>[];
      for (final entry in value.entries) {
        final map = asStringMap(entry.value);
        final product = Product.fromMap(entry.key.toString(), map);
        if (product.active) products.add(product);
      }
      products.sort((a, b) {
        final order = a.sortOrder.compareTo(b.sortOrder);
        if (order != 0) return order;
        return (b.createdAt ?? DateTime(0)).compareTo(
          a.createdAt ?? DateTime(0),
        );
      });
      return products;
    });
  }

  Stream<List<Category>> watchCategories() {
    return _database.categoriesRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return <Category>[];
      final categories = value.entries
          .map(
            (entry) => Category.fromMap(
              entry.key.toString(),
              asStringMap(entry.value),
            ),
          )
          .toList();
      categories.sort((a, b) => a.order.compareTo(b.order));
      return categories;
    });
  }

  Future<List<Product>> fetchAllOnce() async {
    final snapshot = await _database.productsRef.get();
    final value = snapshot.value;
    if (value is! Map) return <Product>[];
    final products = value.entries
        .map(
          (entry) => Product.fromMap(
            entry.key.toString(),
            asStringMap(entry.value),
          ),
        )
        .where((product) => product.active)
        .toList();
    products.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return products;
  }

  Future<Product?> fetchProduct(String productId) async {
    final snapshot = await _database.productsRef.child(productId).get();
    final value = snapshot.value;
    if (value is! Map) return null;
    return Product.fromMap(productId, value);
  }

  Future<Map<String, Product>> fetchProductMap() async {
    final products = await fetchAllOnce();
    return {for (final product in products) product.id: product};
  }
}
