import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/payment.dart';
import '../services/payment_service.dart';
import '../utils/firebase_error_mapper.dart';

class PaymentsProvider extends ChangeNotifier {
  PaymentsProvider({required PaymentService paymentService})
    : _paymentService = paymentService;

  final PaymentService _paymentService;
  StreamSubscription<List<Payment>>? _subscription;
  List<Payment> _payments = const [];
  String? _uid;
  bool _loading = true;
  String? _error;

  List<Payment> get payments => _payments;
  bool get loading => _loading;
  String? get error => _error;

  void bindUser(String? uid) {
    if (_uid == uid) return;
    _uid = uid;
    _subscription?.cancel();
    _subscription = null;
    _payments = const [];
    _loading = uid != null;
    _error = null;
    if (uid != null) {
      _subscription = _paymentService.watchPayments(uid).listen(
        (payments) {
          _payments = payments;
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