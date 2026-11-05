import '../utils/parse.dart';

class CartItem {
  const CartItem({
    required this.key,
    required this.productId,
    required this.quantity,
    required this.size,
    this.addedAt,
  });

  final String key;
  final String productId;
  final int quantity;
  final String size;
  final DateTime? addedAt;

  factory CartItem.fromMap(String key, Map<dynamic, dynamic> map) {
    final data = asStringMap(map);
    return CartItem(
      key: key,
      productId: asString(data['productId']),
      quantity: asInt(data['quantity'], 1),
      size: asString(data['size'], 'M'),
      addedAt: asDate(data['addedAt']),
    );
  }

  factory CartItem.create({
    required String productId,
    required int quantity,
    required String size,
  }) {
    return CartItem(
      key: cartKey(productId, size),
      productId: productId,
      quantity: quantity,
      size: size,
      addedAt: DateTime.now(),
    );
  }

  static String cartKey(String productId, String size) =>
      '${productId}__${size.toUpperCase()}';

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'quantity': quantity,
    'size': size,
    'addedAt': addedAt?.millisecondsSinceEpoch ??
        DateTime.now().millisecondsSinceEpoch,
  };

  CartItem copyWith({int? quantity}) => CartItem(
    key: key,
    productId: productId,
    quantity: quantity ?? this.quantity,
    size: size,
    addedAt: addedAt,
  );
}
