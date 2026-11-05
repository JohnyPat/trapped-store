import 'dart:async';

import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../models/cart_item.dart';
import '../models/cart_line.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../utils/app_exception.dart';
import '../utils/firebase_error_mapper.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({required CartService cartService})
    : _cartService = cartService;

  final CartService _cartService;
  StreamSubscription<List<CartItem>>? _subscription;
  List<CartItem> _items = const [];
  String? _uid;
  bool _busy = false;
  String? _error;

  List<CartItem> get items => _items;
  int get count => _items.fold(0, (sum, item) => sum + item.quantity);
  bool get busy => _busy;
  String? get error => _error;
  bool get isEmpty => _items.isEmpty;

  void bindUser(String? uid) {
    if (_uid == uid) return;
    _uid = uid;
    _subscription?.cancel();
    _subscription = null;
    _items = const [];
    _error = null;
    if (uid != null) {
      _subscription = _cartService.watchCart(uid).listen(
        (items) {
          _items = items;
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

  int quantityFor(String productId, String size) {
    for (final item in _items) {
      if (item.productId == productId &&
          item.size.toUpperCase() == size.toUpperCase()) {
        return item.quantity;
      }
    }
    return 0;
  }

  bool contains(String productId, String size) =>
      quantityFor(productId, size) > 0;

  Future<void> add({
    required Product product,
    required String size,
    int quantity = 1,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw const AuthRequiredException('Sign in to add pieces to your bag.');
    }
    if (quantity < 1) {
      throw const AppException('Choose a valid quantity.');
    }
    if (!product.inStock) {
      throw const AppException('This piece is sold out.');
    }
    final existing = quantityFor(product.id, size);
    if (existing + quantity > product.stock) {
      throw AppException(
        'Only ${product.stock} ${product.stock == 1 ? 'piece is' : 'pieces are'} available in this size.',
      );
    }
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await _cartService.addItem(
        uid: uid,
        productId: product.id,
        size: size,
        quantity: quantity,
      );
    } catch (error) {
      _error = FirebaseErrorMapper.generic(error);
      notifyListeners();
      rethrow;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> increment(CartItem item, Product product) async {
    if (item.quantity >= product.stock) {
      throw AppException(
        'Only ${product.stock} ${product.stock == 1 ? 'piece is' : 'pieces are'} available.',
      );
    }
    await setQuantity(item, item.quantity + 1);
  }

  Future<void> decrement(CartItem item) async {
    if (item.quantity <= 1) {
      await remove(item);
      return;
    }
    await setQuantity(item, item.quantity - 1);
  }

  Future<void> setQuantity(CartItem item, int quantity) async {
    final uid = _uid;
    if (uid == null) {
      throw const AuthRequiredException('Sign in to update your bag.');
    }
    try {
      await _cartService.setQuantity(
        uid: uid,
        key: item.key,
        quantity: quantity,
      );
    } catch (error) {
      _error = FirebaseErrorMapper.generic(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> remove(CartItem item) async {
    final uid = _uid;
    if (uid == null) {
      throw const AuthRequiredException('Sign in to update your bag.');
    }
    try {
      await _cartService.removeItem(uid: uid, key: item.key);
    } catch (error) {
      _error = FirebaseErrorMapper.generic(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> clear() async {
    final uid = _uid;
    if (uid == null) return;
    await _cartService.clear(uid);
  }

  List<CartLine> lines(Map<String, Product> products) {
    final result = <CartLine>[];
    for (final item in _items) {
      final product = products[item.productId];
      if (product != null) {
        result.add(CartLine(item: item, product: product));
      }
    }
    return result;
  }

  double subtotal(Map<String, Product> products) =>
      lines(products).fold(0, (sum, line) => sum + line.lineTotal);

  double shippingFee(Map<String, Product> products) {
    final subtotalValue = subtotal(products);
    if (subtotalValue <= 0) return 0;
    return subtotalValue >= AppConstants.freeShippingThreshold
        ? 0
        : AppConstants.defaultShippingFee;
  }

  double total(Map<String, Product> products) =>
      subtotal(products) + shippingFee(products);

  String? validateForCheckout(Map<String, Product> products) {
    if (_items.isEmpty) return 'Your bag is empty.';
    for (final item in _items) {
      final product = products[item.productId];
      if (product == null) {
        return 'A product in your bag is no longer available.';
      }
      if (!product.active) {
        return '${product.name} is no longer available.';
      }
      if (product.stock < item.quantity) {
        return '${product.name} has only ${product.stock} left. Update your quantity.';
      }
    }
    return null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
