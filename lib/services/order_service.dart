import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
import '../models/cart_item.dart';
import '../models/payment.dart';
import '../models/product.dart';
import '../utils/parse.dart';
import 'database_service.dart';

class OrderException implements Exception {
  const OrderException(this.message);
  final String message;

  @override
  String toString() => message;
}

class OrderService {
  OrderService({DatabaseService? database})
    : _database = database ?? DatabaseService();

  final DatabaseService _database;

  Stream<List<Order>> watchOrders(String uid) {
    return _database.ordersRef(uid).onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return <Order>[];
      final orders = value.entries
          .map(
            (entry) => Order.fromMap(
              entry.key.toString(),
              asStringMap(entry.value),
            ),
          )
          .toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  Stream<Order?> watchOrder(String uid, String orderId) {
    return _database.orderRef(uid, orderId).onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return null;
      return Order.fromMap(orderId, value);
    });
  }

  Future<Order?> fetchOrder(String uid, String orderId) async {
    final snapshot = await _database.orderRef(uid, orderId).get();
    final value = snapshot.value;
    if (value is! Map) return null;
    return Order.fromMap(orderId, value);
  }

  Future<Order> placeOrder({
    required String uid,
    required List<CartItem> cartItems,
    required ShippingAddress deliveryAddress,
    required PaymentMethod paymentMethod,
    String notes = '',
  }) async {
    if (cartItems.isEmpty) {
      throw const OrderException('Your cart is empty.');
    }
    // Payment method validation - all methods (cod, gcash, maya, card) are valid for simulated payments
    // No need to block any method since all payments are simulated
    if (deliveryAddress.fullName.trim().isEmpty ||
        deliveryAddress.phone.trim().isEmpty ||
        deliveryAddress.email.trim().isEmpty ||
        deliveryAddress.street.trim().isEmpty ||
        deliveryAddress.city.trim().isEmpty ||
        deliveryAddress.province.trim().isEmpty ||
        deliveryAddress.postalCode.trim().isEmpty) {
      throw const OrderException(
        'Complete all required delivery information before placing the order.',
      );
    }

    final products = await _database.productsRef.get();
    final productValues = products.value;
    if (productValues is! Map) {
      throw const OrderException('The catalogue is unavailable.');
    }

    final settings = await _database.fetchSettings();
    final configuredShipping = asDouble(
      settings['shippingFee'],
      AppConstants.defaultShippingFee,
    );
    final freeShippingThreshold = asDouble(
      settings['freeShippingThreshold'],
      AppConstants.freeShippingThreshold,
    );

    final orderItems = <OrderItem>[];
    final stockUsage = <String, int>{};
    final productNames = <String>[];
    double subtotal = 0;

    for (final item in cartItems) {
      if (item.quantity < 1) {
        throw const OrderException('Invalid quantity in cart.');
      }
      final raw = productValues[item.productId];
      if (raw is! Map) {
        throw OrderException(
          'A product in your cart is no longer available. Remove it and retry.',
        );
      }
      final product = Product.fromMap(item.productId, raw);
      final nextUsage = (stockUsage[product.id] ?? 0) + item.quantity;
      if (!product.active || product.stock < nextUsage) {
        throw OrderException(
          '${product.name} does not have enough stock for this order.',
        );
      }
      stockUsage[product.id] = nextUsage;
      final lineTotal = product.price * item.quantity;
      subtotal += lineTotal;
      productNames.add('${product.name} × ${item.quantity}');
      orderItems.add(
        OrderItem(
          productId: product.id,
          name: product.name,
          imageUrl: product.imageUrl,
          price: product.price,
          quantity: item.quantity,
          size: item.size,
        ),
      );
    }

    final shippingFee = subtotal >= freeShippingThreshold
        ? 0.0
        : configuredShipping;
    final total = subtotal + shippingFee;
    final now = DateTime.now();
    final orderId = const Uuid().v4();
    final orderNumber =
        'TRP-${DateFormat('yyMMdd').format(now)}-${orderId.substring(0, 4).toUpperCase()}';
    final order = Order(
      id: orderId,
      orderNumber: orderNumber,
      userId: uid,
      items: orderItems,
      subtotal: subtotal,
      shippingFee: shippingFee,
      totalAmount: total,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      paymentStatus: PaymentStatus.pending,
      orderStatus: OrderStatus.pending,
      createdAt: now,
      updatedAt: now,
      statusHistory: [
        OrderStatusEvent(
          status: OrderStatus.pending,
          at: now,
          note: 'Order placed. Awaiting confirmation.',
        ),
      ],
      idempotencyKey: orderId,
      notes: notes.trim(),
    );
    final payment = Payment(
      id: orderId,
      userId: uid,
      orderId: orderId,
      orderNumber: orderNumber,
      amount: total,
      paymentMethod: paymentMethod,
      paymentStatus: PaymentStatus.pending,
      referenceNumber: 'COD-$orderNumber',
      itemsSummary: productNames.join(', '),
      createdAt: now,
      updatedAt: now,
    );

    final updates = <String, dynamic>{
      'orders/$uid/$orderId': order.toMap(),
      'payments/${payment.id}': payment.toMap(),
      'orderLocks/$uid/$orderId': {
        'orderId': orderId,
        'createdAt': now.millisecondsSinceEpoch,
      },
      'cart/$uid': null,
      'users/$uid/lastOrderId': orderId,
    };
    for (final entry in stockUsage.entries) {
      final raw = productValues[entry.key];
      final currentStock = asInt(asStringMap(raw)['stock']);
      updates['products/${entry.key}/stock'] = currentStock - entry.value;
    }

    try {
      await _database.root.update(updates);
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        throw const OrderException(
          'The order could not be placed because the database rejected it. '
          'Please refresh and try again.',
        );
      }
      throw OrderException(error.message ?? 'Unable to place the order.');
    }
    return order;
  }

  Future<Order> cancelOrder({
    required String uid,
    required Order order,
  }) async {
    if (!order.canCancel) {
      throw const OrderException(
        'This order can no longer be cancelled. Contact support for help.',
      );
    }
    final now = DateTime.now();
    final nextHistory = [
      ...order.statusHistory,
      OrderStatusEvent(
        status: OrderStatus.cancelled,
        at: now,
        note: 'Cancelled by customer.',
      ),
    ];
    final updates = <String, dynamic>{
      'orders/$uid/${order.id}/orderStatus': OrderStatus.cancelled.value,
      'orders/$uid/${order.id}/paymentStatus': PaymentStatus.cancelled.value,
      'orders/$uid/${order.id}/updatedAt': now.millisecondsSinceEpoch,
      'orders/$uid/${order.id}/statusHistory':
          nextHistory.map((event) => event.toMap()).toList(),
      'payments/${order.id}/paymentStatus': PaymentStatus.cancelled.value,
      'payments/${order.id}/updatedAt': now.millisecondsSinceEpoch,
    };

    // Restore inventory for each product. Items with the same product but
    // different sizes are grouped so the stock update is correct.
    final usage = <String, int>{};
    for (final item in order.items) {
      usage[item.productId] = (usage[item.productId] ?? 0) + item.quantity;
    }
    final productSnapshots = await _database.productsRef.get();
    final productValues = productSnapshots.value;
    if (productValues is Map) {
      for (final entry in usage.entries) {
        final raw = productValues[entry.key];
        if (raw is! Map) continue;
        final currentStock = asInt(asStringMap(raw)['stock']);
        updates['products/${entry.key}/stock'] = currentStock + entry.value;
      }
    }

    try {
      await _database.root.update(updates);
    } on FirebaseException catch (error) {
      throw OrderException(error.message ?? 'Unable to cancel the order.');
    }
    return order.copyWith(
      orderStatus: OrderStatus.cancelled,
      paymentStatus: PaymentStatus.cancelled,
      updatedAt: now,
      statusHistory: nextHistory,
    );
  }
}
