import 'package:firebase_database/firebase_database.dart';

import '../models/cart_item.dart';
import '../utils/parse.dart';
import 'database_service.dart';

class CartService {
  CartService({DatabaseService? database})
    : _database = database ?? DatabaseService();

  final DatabaseService _database;

  Stream<List<CartItem>> watchCart(String uid) {
    return _database.cartRef(uid).onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return <CartItem>[];
      final items = value.entries
          .map(
            (entry) => CartItem.fromMap(
              entry.key.toString(),
              asStringMap(entry.value),
            ),
          )
          .where((item) => item.productId.isNotEmpty && item.quantity > 0)
          .toList();
      items.sort((a, b) {
        final left = a.addedAt ?? DateTime(0);
        final right = b.addedAt ?? DateTime(0);
        return left.compareTo(right);
      });
      return items;
    });
  }

  Future<void> addItem({
    required String uid,
    required String productId,
    required String size,
    int quantity = 1,
  }) async {
    final key = CartItem.cartKey(productId, size);
    final ref = _database.cartRef(uid).child(key);
    await ref.runTransaction((current) {
      final data = asStringMap(current);
      final existing = asInt(data['quantity']);
      final next = existing + quantity;
      return Transaction.success({
        'productId': productId,
        'size': size.toUpperCase(),
        'quantity': next,
        'addedAt': data['addedAt'] ??
            DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    });
  }

  Future<void> setQuantity({
    required String uid,
    required String key,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      await removeItem(uid: uid, key: key);
      return;
    }
    await _database.cartRef(uid).child(key).update({
      'quantity': quantity,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> removeItem({
    required String uid,
    required String key,
  }) async {
    await _database.cartRef(uid).child(key).remove();
  }

  Future<void> clear(String uid) async {
    await _database.cartRef(uid).remove();
  }
}
