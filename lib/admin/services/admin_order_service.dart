import 'package:trapped_store/services/database_service.dart';

import '../../utils/parse.dart';
import '../models/admin_order_model.dart';

/// Service for managing orders in the admin panel.
/// Reads all customer orders and provides admin operations.
class AdminOrderService {
  AdminOrderService({DatabaseService? database})
    : _database = database ?? DatabaseService();

  final DatabaseService _database;

  /// Listen to all orders across all users.
  Stream<List<AdminOrder>> watchAllOrders() {
    return _database.orderRefs.onValue.map((event) {
      final data = event.snapshot.value;
      if (data is! Map) return <AdminOrder>[];
      final List<AdminOrder> allOrders = [];
      data.forEach((userId, userData) {
        if (userData is! Map) return;
        userData.forEach((orderId, orderData) {
          if (orderData is! Map) return;
          allOrders.add(
            AdminOrder.fromMap(
              orderId.toString(),
              asStringMap(orderData),
              userId: userId.toString(),
            ),
          );
        });
      });
      return allOrders..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  /// Listen to orders for a specific user.
  Stream<List<AdminOrder>> watchUserOrders(String uid) {
    return _database.ordersRef(uid).onValue.map((event) {
      final data = event.snapshot.value;
      if (data is! Map) return <AdminOrder>[];
      return data.entries.map((entry) {
        final value = entry.value;
        if (value is! Map) return AdminOrder.empty(entry.key.toString());
        return AdminOrder.fromMap(entry.key.toString(), asStringMap(value));
      }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  /// Fetch a single order by user ID and order ID.
  Future<AdminOrder> fetchOrder(String uid, String orderId) async {
    final snapshot = await _database.orderRef(uid, orderId).get();
    final data = asStringMap(snapshot.value);
    if (data.isEmpty) return AdminOrder.empty(orderId);
    return AdminOrder.fromMap(orderId, data, userId: uid);
  }

  /// Listen to a single order so the admin detail view stays in sync.
  Stream<AdminOrder?> watchOrder(String uid, String orderId) {
    return _database.orderRef(uid, orderId).onValue.map((event) {
      final data = asStringMap(event.snapshot.value);
      if (data.isEmpty) return null;
      return AdminOrder.fromMap(orderId, data, userId: uid);
    });
  }

  /// Search orders by status.
  Stream<List<AdminOrder>> searchByStatus(String status) {
    return _database.orderRefs.onValue.map((event) {
      final data = event.snapshot.value;
      if (data is! Map) return <AdminOrder>[];
      final List<AdminOrder> results = [];
      data.forEach((userId, userData) {
        if (userData is! Map) return;
        userData.forEach((orderId, orderData) {
          if (orderData is! Map) return;
          final order = AdminOrder.fromMap(
            orderId.toString(),
            asStringMap(orderData),
            userId: userId.toString(),
          );
          if (order.orderStatus.toLowerCase() == status.toLowerCase()) {
            results.add(order);
          }
        });
      });
      return results..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  /// Update order status and optionally payment status.
  Future<void> updateOrderStatus({
    required String uid,
    required String orderId,
    required String newStatus,
    String? paymentStatus,
  }) async {
    if (uid.trim().isEmpty || orderId.trim().isEmpty) {
      throw StateError(
        'Order is missing its customer reference. Refresh the list and try again.',
      );
    }
    final ref = _database.orderRef(uid, orderId);
    final now = DateTime.now();

    final updateMap = <String, dynamic>{
      'orderStatus': newStatus,
      'updatedAt': now.millisecondsSinceEpoch,
    };
    if (paymentStatus != null) {
      updateMap['paymentStatus'] = paymentStatus;
    }

    // Add to status history using push
    await ref.child('statusHistory').push().set({
      'status': newStatus,
      'changedAt': now.millisecondsSinceEpoch,
    });

    await ref.update(updateMap);
  }

  /// Get recent orders (last N).
  Stream<List<AdminOrder>> getRecentOrders({int limit = 10}) {
    return watchAllOrders().map((orders) => orders.take(limit).toList());
  }

  /// Get pending orders count.
  Stream<int> getPendingOrdersCount() {
    return searchByStatus('pending').map((orders) => orders.length);
  }

  /// Get processing orders count.
  Stream<int> getProcessingOrdersCount() {
    return searchByStatus('processing').map((orders) => orders.length);
  }

  /// Get shipped orders count.
  Stream<int> getShippedOrdersCount() {
    return searchByStatus('shipped').map((orders) => orders.length);
  }

  /// Get delivered orders count.
  Stream<int> getDeliveredOrdersCount() {
    return searchByStatus('delivered').map((orders) => orders.length);
  }

  /// Get cancelled orders count.
  Stream<int> getCancelledOrdersCount() {
    return searchByStatus('cancelled').map((orders) => orders.length);
  }
}
