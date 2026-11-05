import 'package:trapped_store/models/payment.dart';
import '../utils/parse.dart';
import 'database_service.dart';

class PaymentService {
  PaymentService({DatabaseService? database})
    : _database = database ?? DatabaseService();

  final DatabaseService _database;

  Stream<List<Payment>> watchPayments(String uid) {
    return _database.paymentsRef
        .orderByChild('userId')
        .equalTo(uid)
        .onValue
        .map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return <Payment>[];
      final payments = value.entries
          .map(
            (entry) => Payment.fromMap(
              entry.key.toString(),
              asStringMap(entry.value),
            ),
          )
          .toList();
      payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return payments;
    });
  }

  Stream<Payment?> watchPayment(String paymentId) {
    return _database.paymentsRef.child(paymentId).onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return null;
      return Payment.fromMap(paymentId, value);
    });
  }

  Future<List<Payment>> fetchPaymentsOnce(String uid) async {
    final snapshot = await _database.paymentsRef
        .orderByChild('userId')
        .equalTo(uid)
        .get();
    final value = snapshot.value;
    if (value is! Map) return <Payment>[];
    return value.entries
        .map(
          (entry) => Payment.fromMap(
            entry.key.toString(),
            asStringMap(entry.value),
          ),
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Simulated online payment methods
  static List<PaymentMethod> get simulatedPaymentMethods =>[
    PaymentMethod.gcash,
    PaymentMethod.maya,
    PaymentMethod.card,
  ];

  /// Checks if online payments are configured (always false for demo)
  static bool get onlinePaymentsConfigured => false;

  /// Simulate a payment for the given order
  /// Returns a Payment record if successful, or throws an error
  Future<Payment> processSimulation({
    required String orderId,
    required String userId,
    required PaymentMethod paymentMethod,
    required double amount,
  }) async {
    // Check for duplicate payment
    final existingPayments = await fetchPaymentsOnce(userId);
    for (final payment in existingPayments) {
      if (payment.orderId == orderId &&
          payment.paymentStatus.value.startsWith('paid')) {
        throw Exception(
          'A payment has already been recorded for this order.',
        );
      }
    }

    // Generate a simulated reference number
    final referenceNumber = 'DEMO-${DateTime.now().millisecond}';

    // Create the payment record with simulated status
    final payment = Payment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      orderId: orderId,
      amount: amount,
      paymentMethod: paymentMethod,
      paymentStatus: PaymentStatus.paidSimulated,
      referenceNumber: referenceNumber,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save the payment record
    await _database.paymentsRef.child(payment.id).set(payment.toMap());

    // Update the order's payment status and method
    await _database.orderRefs.child(userId).child(orderId).update({
      'paymentMethod': paymentMethod.value,
      'paymentStatus': PaymentStatus.paidSimulated.value,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });

    return payment;
  }

  /// Simulate a failed payment
  Future<Payment> simulateFailedPayment({
    required String orderId,
    required String userId,
    required PaymentMethod paymentMethod,
    required double amount,
  }) async {
    // Check for duplicate payment
    final existingPayments = await fetchPaymentsOnce(userId);
    for (final payment in existingPayments) {
      if (payment.orderId == orderId &&
          payment.paymentStatus.value.startsWith('paid')) {
        throw Exception(
          'A payment has already been recorded for this order.',
        );
      }
    }

    // Generate a simulated reference number
    final referenceNumber = 'FAIL-DEMO-${DateTime.now().millisecond}';

    // Create the payment record with failed status
    final payment = Payment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      orderId: orderId,
      amount: amount,
      paymentMethod: paymentMethod,
      paymentStatus: PaymentStatus.failedSimulated,
      referenceNumber: referenceNumber,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save the payment record
    await _database.paymentsRef.child(payment.id).set(payment.toMap());

    // Update the order's payment status
    await _database.orderRefs.child(userId).child(orderId).update({
      'paymentMethod': paymentMethod.value,
      'paymentStatus': PaymentStatus.failedSimulated.value,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });

    return payment;
  }

  /// Simulate a cancelled payment
  Future<Payment> simulateCancelledPayment({
    required String orderId,
    required String userId,
    required PaymentMethod paymentMethod,
    required double amount,
  }) async {
    // Check for duplicate payment
    final existingPayments = await fetchPaymentsOnce(userId);
    for (final payment in existingPayments) {
      if (payment.orderId == orderId &&
          payment.paymentStatus.value.startsWith('paid')) {
        throw Exception(
          'A payment has already been recorded for this order.',
        );
      }
    }

    // Generate a simulated reference number
    final referenceNumber = 'CANCEL-DEMO-${DateTime.now().millisecond}';

    // Create the payment record with cancelled status
    final payment = Payment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      orderId: orderId,
      amount: amount,
      paymentMethod: paymentMethod,
      paymentStatus: PaymentStatus.cancelled,
      referenceNumber: referenceNumber,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save the payment record
    await _database.paymentsRef.child(payment.id).set(payment.toMap());

    // Update the order's payment status
    await _database.orderRefs.child(userId).child(orderId).update({
      'paymentMethod': paymentMethod.value,
      'paymentStatus': PaymentStatus.cancelled.value,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });

    return payment;
  }
}