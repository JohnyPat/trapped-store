import 'package:flutter/material.dart';

/// Model for an admin-managed product.
@immutable
class AdminProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? compareAtPrice;
  final String categoryId;
  final String? imageUrl;
  final int stock;
  final bool isAvailable;
  final List<String> sizes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String sku;
  final bool featured;
  final bool isNew;

  const AdminProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.compareAtPrice,
    required this.categoryId,
    this.imageUrl,
    required this.stock,
    required this.isAvailable,
    required this.sizes,
    required this.createdAt,
    required this.updatedAt,
    required this.sku,
    required this.featured,
    required this.isNew,
  });

  factory AdminProduct.empty(String id) => AdminProduct(
        id: id,
        name: '',
        description: '',
        price: 0,
        categoryId: '',
        stock: 0,
        isAvailable: false,
        sizes: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        sku: '',
        featured: false,
        isNew: false,
      );

  AdminProduct copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? compareAtPrice,
    String? categoryId,
    String? imageUrl,
    int? stock,
    bool? isAvailable,
    List<String>? sizes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sku,
    bool? featured,
    bool? isNew,
  }) {
    return AdminProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
      isAvailable: isAvailable ?? this.isAvailable,
      sizes: sizes ?? this.sizes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sku: sku ?? this.sku,
      featured: featured ?? this.featured,
      isNew: isNew ?? this.isNew,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'compareAtPrice': compareAtPrice,
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'images': const <String>[],
      'stock': stock,
      'isAvailable': isAvailable,
      'rating': 0.0,
      'reviewCount': 0,
      'sizes': sizes,
      'active': true,
      'sortOrder': 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'sku': sku,
      'featured': featured,
      'isNew': isNew,
    };
  }

  factory AdminProduct.fromMap(String id, Map<String, dynamic> data) {
    final now = DateTime.now();
    return AdminProduct(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      compareAtPrice: data['compareAtPrice']?.toDouble(),
      categoryId: data['categoryId'] ?? '',
      imageUrl: data['imageUrl'],
      stock: data['stock'] ?? 0,
      isAvailable: data['isAvailable'] ?? true,
      sizes: List<String>.from(data['sizes'] ?? []),
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : now,
      updatedAt: data['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'])
          : now,
      sku: data['sku'] ?? '',
      featured: data['featured'] ?? false,
      isNew: data['isNew'] ?? false,
    );
  }

  String get stockStatus => isAvailable ? (stock <= 5 ? 'Low stock: $stock' : 'In stock: $stock') : 'Out of stock';
  bool get isLowStock => isAvailable && stock <= 5;
}