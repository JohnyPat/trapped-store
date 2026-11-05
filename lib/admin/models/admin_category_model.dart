import 'package:flutter/material.dart';

/// Model for an admin-managed category.
@immutable
class AdminCategory {
  final String id;
  final String name;
  final String? description;
  final int productCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AdminCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.productCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminCategory.empty(String id) => AdminCategory(
        id: id,
        name: '',
        description: '',
        productCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  AdminCategory copyWith({
    String? id,
    String? name,
    String? description,
    int? productCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      productCount: productCount ?? this.productCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'productCount': productCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory AdminCategory.fromMap(String id, Map<String, dynamic> data) {
    final now = DateTime.now();
    return AdminCategory(
      id: id,
      name: data['name'] ?? '',
      description: data['description'],
      productCount: data['productCount'] ?? 0,
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : now,
      updatedAt: data['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'])
          : now,
    );
  }

  String get displayName => name.isNotEmpty ? name : 'Uncategorized';
}