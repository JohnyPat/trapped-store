import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/wishlist_service.dart';
import '../utils/app_exception.dart';
import '../utils/firebase_error_mapper.dart';

class WishlistProvider extends ChangeNotifier {
  WishlistProvider({required WishlistService wishlistService})
    : _wishlistService = wishlistService;

  final WishlistService _wishlistService;
  StreamSubscription<Set<String>>? _subscription;
  Set<String> _productIds = <String>{};
  String? _uid;
  bool _busy = false;
  String? _error;

  Set<String> get productIds => _productIds;
  int get count => _productIds.length;
  bool get busy => _busy;
  String? get error => _error;

  bool isWishlisted(String productId) => _productIds.contains(productId);

  void bindUser(String? uid) {
    if (_uid == uid) return;
    _uid = uid;
    _subscription?.cancel();
    _subscription = null;
    _productIds = <String>{};
    _error = null;
    if (uid != null) {
      _subscription = _wishlistService.watchWishlist(uid).listen(
        (ids) {
          _productIds = ids;
          _error = null;
          notifyListeners();
        },
        onError: (Object error) {
          _error = FirebaseErrorMapper.generic(error);
          notifyListeners();
        },
      );
    }
    notifyListeners();
  }

  Future<void> toggle(String productId) async {
    final uid = _uid;
    if (uid == null) {
      throw const AuthRequiredException(
        'Sign in to save pieces to your wishlist.',
      );
    }
    if (_busy) return;
    _busy = true;
    _error = null;
    final wasWishlisted = _productIds.contains(productId);
    if (wasWishlisted) {
      _productIds = {..._productIds}..remove(productId);
    } else {
      _productIds = {..._productIds, productId};
    }
    notifyListeners();
    try {
      await _wishlistService.setWishlisted(
        uid,
        productId,
        wishlisted: !wasWishlisted,
      );
    } catch (error) {
      // Roll back the optimistic change.
      if (wasWishlisted) {
        _productIds = {..._productIds, productId};
      } else {
        _productIds = {..._productIds}..remove(productId);
      }
      _error = FirebaseErrorMapper.generic(error);
      notifyListeners();
      rethrow;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> remove(String productId) async {
    final uid = _uid;
    if (uid == null) {
      throw const AuthRequiredException('Sign in to edit your wishlist.');
    }
    try {
      await _wishlistService.remove(uid, productId);
    } catch (error) {
      _error = FirebaseErrorMapper.generic(error);
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
