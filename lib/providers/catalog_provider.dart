import 'dart:async';

import 'package:flutter/foundation.dart' hide Category;

import '../models/category.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../utils/firebase_error_mapper.dart';

class CatalogProvider extends ChangeNotifier {
  CatalogProvider({required ProductService productService})
    : _productService = productService;

  final ProductService _productService;
  StreamSubscription<List<Product>>? _productSubscription;
  StreamSubscription<List<Category>>? _categorySubscription;

  List<Product> _products = const [];
  List<Category> _categories = const [];
  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategoryId;

  List<Product> get products => _products;
  List<Category> get categories => _categories;
  bool get loading => _loading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;

  void initialize() {
    if (_productSubscription != null) return;
    _productSubscription = _productService.watchProducts().listen(
      (products) {
        _products = products;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object error) {
        _loading = false;
        _error = FirebaseErrorMapper.generic(error);
        notifyListeners();
      },
    );
    _categorySubscription = _productService.watchCategories().listen(
      (categories) {
        _categories = categories;
        notifyListeners();
      },
      onError: (Object error) {
        _error = FirebaseErrorMapper.generic(error);
        notifyListeners();
      },
    );
  }

  List<Product> get filteredProducts {
    final query = _searchQuery.trim().toLowerCase();
    return _products.where((product) {
      final matchesCategory = _selectedCategoryId == null ||
          product.categoryId == _selectedCategoryId;
      if (!matchesCategory) return false;
      if (query.isEmpty) return true;
      final category = categoryName(product.categoryId).toLowerCase();
      return product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          category.contains(query);
    }).toList();
  }

  List<Product> get featuredProducts =>
      _products.where((product) => product.featured).toList();

  List<Product> get newArrivals =>
      _products.where((product) => product.isNew).toList();

  List<Product> get popularProducts {
    final sorted = [..._products]
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(8).toList();
  }

  Product? productById(String id) {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  Map<String, Product> get productMap => {
    for (final product in _products) product.id: product,
  };

  String categoryName(String categoryId) {
    for (final category in _categories) {
      if (category.id == categoryId) return category.name;
    }
    return 'COLLECTION';
  }

  void setSearch(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String? categoryId) {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    notifyListeners();
  }

  void reload() {
    _productSubscription?.cancel();
    _categorySubscription?.cancel();
    _productSubscription = null;
    _categorySubscription = null;
    _loading = true;
    _error = null;
    notifyListeners();
    initialize();
  }

  @override
  void dispose() {
    _productSubscription?.cancel();
    _categorySubscription?.cancel();
    super.dispose();
  }
}
