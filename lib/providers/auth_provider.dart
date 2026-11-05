import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../utils/firebase_error_mapper.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthService authService,
    required DatabaseService databaseService,
    required StorageService storageService,
  }) : _authService = authService,
       _databaseService = databaseService,
       _storageService = storageService;

  final AuthService _authService;
  final DatabaseService _databaseService;
  final StorageService _storageService;

  StreamSubscription<User?>? _subscription;
  User? _firebaseUser;
  AppUser? _profile;
  bool _isGuest = false;
  bool _initializing = true;
  bool _busy = false;
  String? _error;

  User? get firebaseUser => _firebaseUser;
  AppUser? get profile => _profile;
  bool get isGuest => _isGuest;
  bool get isInitializing => _initializing;
  bool get isBusy => _busy;
  bool get isAuthenticated => _firebaseUser != null;
  String? get uid => _firebaseUser?.uid;
  String? get email => _firebaseUser?.email ?? _profile?.email;
  String? get error => _error;
  String get displayName =>
      _profile?.displayName ??
      _firebaseUser?.displayName ??
      (isGuest ? 'GUEST' : 'TRAPPED MEMBER');

  void initialize() {
    _subscription ??= _authService.authStateChanges.listen((user) async {
      _firebaseUser = user;
      if (user == null) {
        if (!_isGuest) _profile = null;
        _initializing = false;
        notifyListeners();
        return;
      }
      _isGuest = false;
      await _loadProfile(user);
      _initializing = false;
      notifyListeners();
    });
  }

  Future<void> _loadProfile(User user) async {
    try {
      var profile = await _databaseService.fetchUser(user.uid);
      if (profile == null) {
        profile = AppUser(
          uid: user.uid,
          fullName: user.displayName ?? '',
          email: user.email ?? '',
          status: AppUser.statusActive,
          lastLoginAt: DateTime.now(),
        );
        await _databaseService.upsertUser(profile);
      } else if (!profile.isActive) {
        await _authService.signOut();
        _firebaseUser = null;
        _profile = null;
        _isGuest = false;
        _error =
            'This account is disabled. Contact support if you believe this is a mistake.';
        return;
      }
      _profile = profile;
    } catch (error) {
      _profile = AppUser(
        uid: user.uid,
        fullName: user.displayName ?? '',
        email: user.email ?? '',
        status: AppUser.statusActive,
      );
      _error = FirebaseErrorMapper.generic(error);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    return _run(() async {
      await _authService.signIn(email: email, password: password);
      _isGuest = false;
      final user = _authService.currentUser;
      if (user != null) {
        await _databaseService.updateUserFields(user.uid, {
          'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
        });
      }
    });
  }

  Future<bool> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    return _run(() async {
      await _authService.register(
        fullName: fullName,
        phone: phone,
        email: email,
        password: password,
      );
      _isGuest = false;
      // The auth stream can load the profile before the service has written
      // the full name to the database. Reload it now so prefilled forms are
      // correct.
      final user = _authService.currentUser;
      if (user != null) {
        await _loadProfile(user);
      }
    });
  }

  Future<bool> sendPasswordReset(String email) async {
    return _run(() async {
      await _authService.sendPasswordReset(email);
    });
  }

  Future<bool> updateProfile({
    required String fullName,
    required String phone,
    required String address,
  }) async {
    final user = _firebaseUser;
    if (user == null) {
      _error = 'Sign in to edit your profile.';
      notifyListeners();
      return false;
    }
    return _run(() async {
      await _databaseService.updateUserFields(user.uid, {
        'fullName': fullName.trim(),
        'phone': phone.trim(),
        'address': address.trim(),
      });
      await _authService.updateDisplayName(fullName);
      _profile = (_profile ??
              AppUser.empty(user.uid, email: user.email ?? ''))
          .copyWith(
            fullName: fullName.trim(),
            phone: phone.trim(),
            address: address.trim(),
            updatedAt: DateTime.now(),
          );
    });
  }

  Future<bool> updateProfilePicture(XFile file) async {
    final user = _firebaseUser;
    if (user == null) {
      _error = 'Sign in to update your profile picture.';
      notifyListeners();
      return false;
    }
    return _run(() async {
      final url = await _storageService.uploadProfileImage(
        uid: user.uid,
        file: file,
      );
      await _databaseService.updateUserFields(user.uid, {
        'profileImage': url,
      });
      _profile = (_profile ??
              AppUser.empty(user.uid, email: user.email ?? ''))
          .copyWith(profileImage: url, updatedAt: DateTime.now());
    });
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return _run(() async {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    });
  }

  Future<void> refreshProfile() async {
    final user = _firebaseUser;
    if (user == null) return;
    try {
      _profile = await _databaseService.fetchUser(user.uid);
      notifyListeners();
    } catch (_) {
      // Keep the cached profile; the next auth event will retry.
    }
  }

  void continueAsGuest() {
    _isGuest = true;
    _profile = null;
    _firebaseUser = null;
    _error = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    _isGuest = false;
    _profile = null;
    _firebaseUser = null;
    await _authService.signOut();
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    if (_busy) return false;
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (error) {
      _error = FirebaseErrorMapper.auth(error);
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
