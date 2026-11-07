import '../utils/parse.dart';

enum OrderStatus {
  pending('pending', 'PENDING', 0),
  confirmed('confirmed', 'CONFIRMED', 1),
  processing('processing', 'PROCESSING', 2),
  shipped('shipped', 'SHIPPED', 3),
  delivered('delivered', 'DELIVERED', 4),
  cancelled('cancelled', 'CANCELLED', -1);

  const OrderStatus(this.value, this.label, this.step);

  final String value;
  final String label;
  final int step;

  bool get canCancel => this == pending || this == confirmed;
  bool get isTerminal => this == delivered || this == cancelled;

  static OrderStatus fromValue(String? value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

enum PaymentStatus {
  pending('pending', 'PENDING'),
  paidSimulated('paid_simulated', 'PAID (SIM)'),
  failedSimulated('failed_simulated', 'FAILED (SIM)'),
  cancelled('cancelled', 'CANCELLED'),
  refundedSimulated('refunded_simulated', 'REFUNDED (SIM)');

  const PaymentStatus(this.value, this.label);

  final String value;
  final String label;

  static PaymentStatus fromValue(String? value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}

enum PaymentMethod {
  cod('cod', 'CASH ON DELIVERY'),
  gcash('gcash', 'GCash'),
  maya('maya', 'Maya'),
  card('card', 'CREDIT/DEBIT CARD');

  const PaymentMethod(this.value, this.label);

  final String value;
  final String label;

  static PaymentMethod fromValue(String? value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.value == value,
      orElse: () => PaymentMethod.cod,
    );
  }
}

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.size,
  });

  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;
  final String size;

  double get lineTotal => price * quantity;

  factory OrderItem.fromMap(Map<dynamic, dynamic> map) {
    final data = asStringMap(map);
    return OrderItem(
      productId: asString(data['productId']),
      name: asString(data['name'], 'PRODUCT'),
      imageUrl: asString(data['imageUrl']),
      price: asDouble(data['price']),
      quantity: asInt(data['quantity'], 1),
      size: asString(data['size'], 'M'),
    );
  }

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'name': name,
    'imageUrl': imageUrl,
    'price': price,
    'quantity': quantity,
    'size': size,
  };
}

class ShippingAddress {
  const ShippingAddress({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.street,
    required this.barangay,
    required this.city,
    required this.province,
    required this.postalCode,
    this.notes = '',
  });

  final String fullName;
  final String phone;
  final String email;
  final String street;
  final String barangay;
  final String city;
  final String province;
  final String postalCode;
  final String notes;

  String get oneLine => [
    street,
    barangay,
    city,
    province,
    postalCode,
  ].where((part) => part.trim().isNotEmpty).join(', ');

  List<String> get lines => [
    street,
    barangay,
    '$city, $province',
    postalCode,
  ].where((part) => part.trim().isNotEmpty).toList();

  factory ShippingAddress.fromMap(Map<dynamic, dynamic> map) {
    final data = asStringMap(map);
    return ShippingAddress(
      fullName: asString(data['fullName']),
      phone: asString(data['phone']),
      email: asString(data['email']),
      street: asString(data['street']),
      barangay: asString(data['barangay']),
      city: asString(data['city']),
      province: asString(data['province']),
      postalCode: asString(data['postalCode']),
      notes: asString(data['notes']),
    );
  }

  Map<String, dynamic> toMap() => {
    'fullName': fullName.trim(),
    'phone': phone.trim(),
    'email': email.trim(),
    'street': street.trim(),
    'barangay': barangay.trim(),
    'city': city.trim(),
    'province': province.trim(),
    'postalCode': postalCode.trim(),
    'notes': notes.trim(),
  };
}

class OrderStatusEvent {
  const OrderStatusEvent({
    required this.status,
    required this.at,
    this.note = '',
  });

  final OrderStatus status;
  final DateTime at;
  final String note;

  factory OrderStatusEvent.fromMap(Map<dynamic, dynamic> map) {
    final data = asStringMap(map);
    return OrderStatusEvent(
      status: OrderStatus.fromValue(asString(data['status'])),
      at: asDate(data['at'] ?? data['changedAt']) ?? DateTime.now(),
      note: asString(data['note']),
    );
  }

  Map<String, dynamic> toMap() => {
    'status': status.value,
    'at': at.millisecondsSinceEpoch,
    'note': note,
  };
}

class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.createdAt,
    required this.updatedAt,
    this.statusHistory = const [],
    this.idempotencyKey = '',
    this.notes = '',
  });

  final String id;
  final String orderNumber;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double shippingFee;
  final double totalAmount;
  final ShippingAddress deliveryAddress;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final OrderStatus orderStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderStatusEvent> statusHistory;
  final String idempotencyKey;
  final String notes;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get canCancel => orderStatus.canCancel;
  String get contactEmail => deliveryAddress.email;
  String get contactPhone => deliveryAddress.phone;

  factory Order.fromMap(String id, Map<dynamic, dynamic> map) {
    final data = asStringMap(map);
    final rawItems = asList(data['items'] ?? data['products']);
    return Order(
      id: id,
      orderNumber: asString(data['orderNumber'], id),
      userId: asString(data['userId']),
      items: rawItems
          .map((item) => OrderItem.fromMap(asStringMap(item)))
          .toList(),
      subtotal: asDouble(data['subtotal']),
      shippingFee: asDouble(data['shippingFee']),
      totalAmount: asDouble(data['totalAmount']),
      deliveryAddress: ShippingAddress.fromMap(
        asStringMap(data['deliveryAddress']),
      ),
      paymentMethod: PaymentMethod.fromValue(asString(data['paymentMethod'])),
      paymentStatus: PaymentStatus.fromValue(asString(data['paymentStatus'])),
      orderStatus: OrderStatus.fromValue(asString(data['orderStatus'])),
      createdAt: asDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: asDate(data['updatedAt']) ?? DateTime.now(),
      statusHistory: asList(data['statusHistory'])
          .map((event) => OrderStatusEvent.fromMap(asStringMap(event)))
          .toList(),
      idempotencyKey: asString(data['idempotencyKey']),
      notes: asString(data['notes']),
    );
  }

  Map<String, dynamic> toMap() => {
    'orderNumber': orderNumber,
    'userId': userId,
    'items': items.map((item) => item.toMap()).toList(),
    'subtotal': subtotal,
    'shippingFee': shippingFee,
    'totalAmount': totalAmount,
    'deliveryAddress': deliveryAddress.toMap(),
    'paymentMethod': paymentMethod.value,
    'paymentStatus': paymentStatus.value,
    'orderStatus': orderStatus.value,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
    'statusHistory': statusHistory.map((event) => event.toMap()).toList(),
    'idempotencyKey': idempotencyKey,
    'notes': notes,
  };

  Order copyWith({
    PaymentStatus? paymentStatus,
    OrderStatus? orderStatus,
    DateTime? updatedAt,
    List<OrderStatusEvent>? statusHistory,
  }) {
    return Order(
      id: id,
      orderNumber: orderNumber,
      userId: userId,
      items: items,
      subtotal: subtotal,
      shippingFee: shippingFee,
      totalAmount: totalAmount,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      statusHistory: statusHistory ?? this.statusHistory,
      idempotencyKey: idempotencyKey,
      notes: notes,
    );
  }
}
