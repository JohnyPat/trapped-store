import 'package:firebase_auth/firebase_auth.dart';

import 'package:trapped_store/services/database_service.dart';

/// Admin authentication service.
/// Uses the existing Firebase project and checks admin permission
/// via the `settings/adminUid` path in Realtime Database.
class AdminAuthService {
  AdminAuthService({FirebaseAuth? auth, DatabaseService? database})
      : _auth = auth ?? FirebaseAuth.instance,
        _database = database ?? DatabaseService();

  final FirebaseAuth _auth;
  final DatabaseService _database;

  /// Stream of admin auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;
  String? get uid => _auth.currentUser?.uid;

  /// Check if the current user is authorized as admin.
  /// Reads the `settings/adminUid` from the database and compares
  /// it with the signed-in user's UID.
  ///
  /// Throws an [AdminAuthException] with the real reason when the
  /// check cannot be completed (e.g. permission denied reading settings).
  Future<bool> get isAdmin async {
    final snapshot = await _database.settingsRef.get();
    final value = snapshot.value;
    final rawAdminUid = value is Map ? value['adminUid'] as String? : null;
    final adminUid = _sanitizeUid(rawAdminUid);
    if (adminUid == null) {
      throw AdminAuthException(
        'settings/adminUid is not set in the Realtime Database. '
        'Raw value: ${rawAdminUid ?? "(missing)"}',
      );
    }
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const AdminAuthException('No authenticated user.');
    }
    if (uid != adminUid) {
      throw AdminAuthException(
        'Your UID ($uid) does not match settings/adminUid (raw: "$rawAdminUid", parsed: "$adminUid").',
      );
    }
    return true;
  }

  /// Strip whitespace and accidental quote characters that sometimes get
  /// pasted into the console value (e.g. `"1eIC6..."` instead of
  /// `1eIC6...`). UIDs never contain quotes or spaces, so this is safe.
  static String? _sanitizeUid(String? raw) {
    if (raw == null) return null;
    final clean = raw.trim().replaceAll('"', '').replaceAll("'", '').trim();
    return clean.isEmpty ? null : clean;
  }

  /// Sign in with email and password.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email.
  Future<void> sendPasswordReset({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Returns the display name from the user profile.
  String? getDisplayName() {
    final user = _auth.currentUser;
    return user?.displayName;
  }

  /// Returns the user's email.
  String? getUserEmail() {
    final user = _auth.currentUser;
    return user?.email;
  }
}

/// Raised when the admin privilege check cannot be completed.
class AdminAuthException implements Exception {
  const AdminAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}