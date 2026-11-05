import '../utils/parse.dart';
import 'order.dart';

export 'order.dart';

class Payment {
  const Payment({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    this.orderNumber = '',
    this.referenceNumber = '',
    this.currency = 'PHP',
    this.itemsSummary = '',
  });

  final String id;
  final String userId;
  final String orderId;
  final String orderNumber;
  final double amount;
  final String currency;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String referenceNumber;
  final String itemsSummary;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Payment.fromMap(String id, Map<dynamic, dynamic> map) {
    final data = asStringMap(map);
    return Payment(
      id: id,
      userId: asString(data['userId']),
      orderId: asString(data['orderId']),
      orderNumber: asString(data['orderNumber']),
      amount: asDouble(data['amount']),
      currency: asString(data['currency'], 'PHP'),
      paymentMethod: PaymentMethod.fromValue(asString(data['paymentMethod'])),
      paymentStatus: PaymentStatus.fromValue(asString(data['paymentStatus'])),
      referenceNumber: asString(data['referenceNumber']),
      itemsSummary: asString(data['itemsSummary']),
      createdAt: asDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: asDate(data['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'orderId': orderId,
    'orderNumber': orderNumber,
    'amount': amount,
    'currency': currency,
    'paymentMethod': paymentMethod.value,
    'paymentStatus': paymentStatus.value,
    'referenceNumber': referenceNumber,
    'itemsSummary': itemsSummary,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
  };
}