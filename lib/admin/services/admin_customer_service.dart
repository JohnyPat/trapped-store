import 'package:trapped_store/services/database_service.dart';

import '../../utils/parse.dart';
import '../models/admin_customer_model.dart';

/// Service for managing customers in the admin panel.
/// Reads user profiles from the `users` path in Realtime Database.
class AdminCustomerService {
  AdminCustomerService({DatabaseService? database})
      : _database = database ?? DatabaseService();

  final DatabaseService _database;

  /// Listen to all customers.
  Stream<List<AdminCustomer>> watchAllCustomers() {
    return _database.usersRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data is! Map) return <AdminCustomer>[];
      return data.entries.map((entry) {
        final value = asStringMap(entry.value);
        return AdminCustomer.fromMap(entry.key.toString(), value);
      }).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  /// Listen to a specific customer.
  Stream<AdminCustomer> watchCustomer(String uid) {
    return _database.usersRef.child(uid).onValue.map((event) {
      final data = event.snapshot.value;
      if (data is! Map) return AdminCustomer.empty(uid);
      return AdminCustomer.fromMap(uid, asStringMap(data));
    });
  }

  /// Fetch a single customer by UID.
  Future<AdminCustomer> fetchCustomer(String uid) async {
    final snapshot = await _database.usersRef.child(uid).get();
    final data = asStringMap(snapshot.value);
    if (data.isEmpty) return AdminCustomer.empty(uid);
    return AdminCustomer.fromMap(uid, data);
  }

  /// Search customers by name or email.
  Stream<List<AdminCustomer>> searchCustomers(String query) {
    return watchAllCustomers().map((customers) {
      if (query.isEmpty) return customers;
      final lower = query.toLowerCase();
      return customers.where((c) =>
          c.fullName.toLowerCase().contains(lower) ||
              c.email.toLowerCase().contains(lower) ||
              c.phone.contains(lower))
          .toList();
    });
  }

  /// Update customer status (active/disabled).
  Future<void> updateCustomerStatus({
    required String uid,
    required String status,
  }) async {
    await _database.usersRef.child(uid).update({
      'status': status,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Count total customers.
  Stream<int> getCustomerCount() {
    return watchAllCustomers().map((customers) => customers.length);
  }

  /// Get active customers count.
  Stream<int> getActiveCustomersCount() {
    return watchAllCustomers().map((customers) =>
        customers.where((c) => c.status == 'active').length);
  }

  /// Get disabled customers count.
  Stream<int> getDisabledCustomersCount() {
    return watchAllCustomers().map((customers) =>
        customers.where((c) => c.status == 'disabled').length);
  }
}