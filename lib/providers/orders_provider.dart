import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../utils/app_exception.dart';
import '../utils/firebase_error_mapper.dart';

class OrdersProvider extends ChangeNotifier {
  OrdersProvider({required OrderService orderService})
    : _orderService = orderService;

  final OrderService _orderService;
  StreamSubscription<List<Order>>? _subscription;
  List<Order> _orders = const [];
  String? _uid;
  bool _loading = true;
  bool _placing = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get loading => _loading;
  bool get placing => _placing;
  String? get error => _error;
  int get count => _orders.length;

  void bindUser(String? uid) {
    if (_uid == uid) return;
    _uid = uid;
    _subscription?.cancel();
    _subscription = null;
    _orders = const [];
    _loading = uid != null;
    _error = null;
    if (uid != null) {
      _subscription = _orderService.watchOrders(uid).listen(
        (orders) {
          _orders = orders;
          _loading = false;
          _error = null;
          notifyListeners();
        },
        onError: (Object error) {
          _loading = false;
          _error = FirebaseErrorMapper.generic(error);
          notifyListeners();
        },
      );
    }
    notifyListeners();
  }

  Future<Order> placeOrder({
    required List<CartItem> cartItems,
    required ShippingAddress address,
    required PaymentMethod paymentMethod,
    String notes = '',
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw const AuthRequiredException('Sign in to place an order.');
    }
    if (_placing) {
      throw const AppException('Your order is already being placed.');
    }
    _placing = true;
    _error = null;
    notifyListeners();
    try {
      return await _orderService.placeOrder(
        uid: uid,
        cartItems: cartItems,
        deliveryAddress: address,
        paymentMethod: paymentMethod,
        notes: notes,
      );
    } catch (error) {
      _error = error is OrderException
          ? error.message
          : FirebaseErrorMapper.generic(error);
      notifyListeners();
      rethrow;
    } finally {
      _placing = false;
      notifyListeners();
    }
  }

  Future<Order> cancelOrder(Order order) async {
    final uid = _uid;
    if (uid == null) {
      throw const AuthRequiredException('Sign in to manage your orders.');
    }
    try {
      return await _orderService.cancelOrder(uid: uid, order: order);
    } catch (error) {
      _error = error is OrderException
          ? error.message
          : FirebaseErrorMapper.generic(error);
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  void reload() {
    final uid = _uid;
    _uid = null;
    bindUser(uid);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
