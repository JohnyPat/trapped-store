import 'package:firebase_database/firebase_database.dart';

import '../models/app_user.dart';
import '../utils/parse.dart';

class DatabaseService {
  DatabaseService({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  FirebaseDatabase get database => _database;
  DatabaseReference get root => _database.ref();
  DatabaseReference get productsRef => root.child('products');
  DatabaseReference get categoriesRef => root.child('categories');
  DatabaseReference get settingsRef => root.child('settings');
  DatabaseReference get usersRef => root.child('users');
  DatabaseReference get paymentsRef => root.child('payments');
  DatabaseReference get orderRefs => root.child('orders');
  DatabaseReference get orderLocksRef => root.child('orderLocks');

  DatabaseReference userRef(String uid) => usersRef.child(uid);
  DatabaseReference wishlistRef(String uid) => root.child('wishlist').child(uid);
  DatabaseReference cartRef(String uid) => root.child('cart').child(uid);
  DatabaseReference ordersRef(String uid) => root.child('orders').child(uid);
  DatabaseReference orderRef(String uid, String orderId) =>
      ordersRef(uid).child(orderId);

  Stream<AppUser?> watchUser(String uid) {
    return userRef(uid).onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return null;
      return AppUser.fromMap(uid, value);
    });
  }

  Future<AppUser?> fetchUser(String uid) async {
    final snapshot = await userRef(uid).get();
    final value = snapshot.value;
    if (value is! Map) return null;
    return AppUser.fromMap(uid, value);
  }

  Future<void> upsertUser(AppUser user) async {
    final existing = await userRef(user.uid).get();
    final payload = user.toMap();
    if (!existing.exists) {
      payload['createdAt'] = DateTime.now().millisecondsSinceEpoch;
    }
    await userRef(user.uid).update(payload);
  }

  Future<void> updateUserFields(
    String uid,
    Map<String, dynamic> fields,
  ) async {
    await userRef(uid).update({
      ...fields,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<Map<String, dynamic>> fetchSettings() async {
    final snapshot = await settingsRef.get();
    return asStringMap(snapshot.value);
  }
}
