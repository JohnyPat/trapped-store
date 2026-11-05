import '../models/wishlist_item.dart';
import 'database_service.dart';

class WishlistService {
  WishlistService({DatabaseService? database})
    : _database = database ?? DatabaseService();

  final DatabaseService _database;

  Stream<Set<String>> watchWishlist(String uid) {
    return _database.wishlistRef(uid).onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return <String>{};
      return value.keys.map((key) => key.toString()).toSet();
    });
  }

  Future<void> add(String uid, String productId) async {
    final item = WishlistItem(productId: productId);
    await _database
        .wishlistRef(uid)
        .child(productId)
        .set(item.toMap());
  }

  Future<void> remove(String uid, String productId) async {
    await _database.wishlistRef(uid).child(productId).remove();
  }

  Future<void> setWishlisted(
    String uid,
    String productId, {
    required bool wishlisted,
  }) {
    return wishlisted ? add(uid, productId) : remove(uid, productId);
  }

  Future<void> clear(String uid) async {
    await _database.wishlistRef(uid).remove();
  }
}
