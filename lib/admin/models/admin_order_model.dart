import 'package:flutter/material.dart';

import '../../utils/parse.dart';
import '../../shared/constants/admin_constants.dart';

/// Model for an admin-managed order.
@immutable
class AdminOrder {
  final String id;
  final String orderNumber;
  final String userId;
  final String customerName;
  final String customerEmail;
  final double subtotal;
  final double shippingFee;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<OrderItem> items;
  final String? notes;

  const AdminOrder({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.subtotal,
    required this.shippingFee,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.createdAt,
    this.updatedAt,
    required this.items,
    this.notes,
  });

  AdminOrder copyWith({
    String? id,
    String? orderNumber,
    String? userId,
    String? customerName,
    String? customerEmail,
    double? subtotal,
    double? shippingFee,
    double? totalAmount,
    String? paymentMethod,
    String? paymentStatus,
    String? orderStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItem>? items,
    String? notes,
  }) {
    return AdminOrder(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      notes: notes ?? this.notes,
    );
  }

  factory AdminOrder.empty(String id) {
    return AdminOrder(
      id: id,
      orderNumber: '',
      userId: '',
      customerName: '',
      customerEmail: '',
      subtotal: 0,
      shippingFee: 0,
      totalAmount: 0,
      paymentMethod: 'cod',
      paymentStatus: 'pending',
      orderStatus: 'pending',
      createdAt: DateTime.now(),
      items: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'userId': userId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'createdAt': createdAt.millisecondsSinceEpoch,
      if (updatedAt != null) 'updatedAt': updatedAt!.millisecondsSinceEpoch,
      'items': items.map((e) => e.toMap()).toList(),
      'notes': notes,
    };
  }

  factory AdminOrder.fromMap(
    String id,
    Map<String, dynamic> data, {
    String? userId,
  }) {
    final now = DateTime.now();
    final List<OrderItem> parsedItems = [];
    for (final rawItem in asList(data['items'])) {
      final item = asStringMap(rawItem);
      if (item.isEmpty) continue;
      parsedItems.add(OrderItem.fromMap(item));
    }

    final delivery = asStringMap(data['deliveryAddress']);
    final storedUserId = asString(data['userId']).trim();
    final storedName = asString(data['customerName']).trim();
    final storedEmail = asString(data['customerEmail']).trim();

    return AdminOrder(
      id: id,
      orderNumber: data['orderNumber'] ?? '',
      userId: storedUserId.isNotEmpty ? storedUserId : (userId ?? ''),
      customerName: storedName.isNotEmpty
          ? storedName
          : asString(delivery['fullName']),
      customerEmail: storedEmail.isNotEmpty
          ? storedEmail
          : asString(delivery['email']),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      shippingFee: (data['shippingFee'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? 'cod',
      paymentStatus: data['paymentStatus'] ?? 'pending',
      orderStatus: data['orderStatus'] ?? 'pending',
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : now,
      updatedAt: data['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'])
          : now,
      items: parsedItems,
      notes: data['notes'],
    );
  }

  String get statusLabel {
    switch (orderStatus.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return _capitalizeFirst(orderStatus);
    }
  }

  Color get statusColor {
    switch (orderStatus.toLowerCase()) {
      case 'pending':
        return AdminColors.warning;
      case 'processing':
        return AdminColors.accent;
      case 'shipped':
        return Colors.blue;
      case 'delivered':
        return AdminColors.success;
      case 'cancelled':
        return AdminColors.danger;
      default:
        return AdminColors.muted;
    }
  }

  String get paymentMethodLabel => paymentMethod.toLowerCase() == 'cod'
      ? 'Cash on Delivery'
      : _capitalizeFirst(paymentMethod);

  String _capitalizeFirst(String s) =>
      s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}' : s;
}

@immutable
class OrderItem {
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;
  final String? size;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    this.size,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      if (size != null) 'size': size,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      quantity: (data['quantity'] ?? 1).toInt(),
      size: data['size'],
    );
  }
}
