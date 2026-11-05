import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import 'database_service.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, DatabaseService? database})
    : _auth = auth ?? FirebaseAuth.instance,
      _database = database ?? DatabaseService();

  final FirebaseAuth _auth;
  final DatabaseService _database;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'The account could not be created.',
      );
    }
    final now = DateTime.now();
    await user.updateDisplayName(fullName.trim());
    final profile = AppUser(
      uid: user.uid,
      fullName: fullName.trim(),
      email: user.email ?? email.trim(),
      phone: phone.trim(),
      status: AppUser.statusActive,
      createdAt: now,
      updatedAt: now,
      lastLoginAt: now,
    );
    await _database.upsertUser(profile);
    return credential;
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Not signed in.');
    await user.updateDisplayName(name.trim());
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Not signed in.');
    final email = user.email;
    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message: 'This account has no email address.',
      );
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }
}
