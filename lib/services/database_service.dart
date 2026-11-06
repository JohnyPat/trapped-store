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
    final snapshot = await userRef(user.uid).get();
    final existing = asStringMap(snapshot.value);
    await _writeMutableProfile(
      uid: user.uid,
      existing: existing,
      update: {
        'fullName': user.fullName.trim(),
        'email': user.email.trim(),
        'phone': user.phone.trim(),
        'address': user.address.trim(),
        'barangay': user.barangay.trim(),
        'city': user.city.trim(),
        'province': user.province.trim(),
        'postalCode': user.postalCode.trim(),
        'profileImage': user.profileImage,
      },
    );
  }

  /// Merge supplied fields with the stored record and write a valid object.
  ///
  /// Realtime Database validation is applied at `/users/{uid}`, so a partial
  /// update fails if the record is missing `createdAt` or another required
  /// field. We preserve existing values, write only fields the client is
  /// allowed to write, and add missing immutable fields if absent.
  Future<void> updateUserFields(
    String uid,
    Map<String, dynamic> fields,
  ) async {
    final snapshot = await userRef(uid).get();
    final existing = asStringMap(snapshot.value);
    await _writeMutableProfile(
      uid: uid,
      existing: existing,
      update: fields,
    );
  }

  Future<void> _writeMutableProfile({
    required String uid,
    required Map<String, dynamic> existing,
    required Map<String, dynamic> update,
  }) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    String pick(String key, {required String fallback}) {
      final incoming = asString(update[key]).trim();
      if (incoming.isNotEmpty) return incoming;
      final stored = asString(existing[key]).trim();
      return stored.isNotEmpty ? stored : fallback;
    }

    final fullName = pick('fullName', fallback: 'TRAPPED MEMBER');
    // Never overwrite an existing email; it's only writable when missing.
    final existingEmail = asString(existing['email']).trim();
    final requestedEmail = asString(update['email']).trim();
    final email = existingEmail.isNotEmpty
        ? existingEmail
        : (requestedEmail.isNotEmpty ? requestedEmail : '');
    final phone = pick('phone', fallback: '0000000');
    final address = pick('address', fallback: '');
    final barangay = pick('barangay', fallback: '');
    final city = pick('city', fallback: '');
    final province = pick('province', fallback: '');
    final postalCode = pick('postalCode', fallback: '');
    final profileImage = asString(update['profileImage'] ?? existing['profileImage']);

    if (email.isEmpty) {
      throw StateError(
        'Profile is missing the account email. Please sign in again.',
      );
    }

    final payload = <String, dynamic>{
      'fullName': fullName,
      'address': address,
      'barangay': barangay,
      'city': city,
      'province': province,
      'postalCode': postalCode,
      'updatedAt': nowMs,
    };

    if (phone.length >= 7) payload['phone'] = phone;
    if (profileImage.isNotEmpty) payload['profileImage'] = profileImage;

    // Only write the immutable-ish fields when they are absent. Firebase
    // denies rewriting them once they exist, even to the same value.
    if (existingEmail.isEmpty) payload['email'] = email;
    if (asString(existing['uid']).trim().isEmpty) payload['uid'] = uid;

    final storedCreatedAt = asDate(existing['createdAt']);
    if (storedCreatedAt == null) payload['createdAt'] = nowMs;

    final storedStatus = asString(existing['status']).trim().toLowerCase();
    if (storedStatus.isEmpty) payload['status'] = 'active';

    // Reject clearly invalid phone before attempting the write.
    if (phone.length < 7) {
      throw StateError('Phone number must be at least 7 digits.');
    }

    await userRef(uid).update(payload);
  }

  Future<Map<String, dynamic>> fetchSettings() async {
    final snapshot = await settingsRef.get();
    return asStringMap(snapshot.value);
  }
}
