import '../utils/parse.dart';

class WishlistItem {
  const WishlistItem({
    required this.productId,
    this.addedAt,
  });

  final String productId;
  final DateTime? addedAt;

  factory WishlistItem.fromMap(String productId, Map<dynamic, dynamic> map) {
    final data = asStringMap(map);
    return WishlistItem(
      productId: productId,
      addedAt: asDate(data['addedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'addedAt': DateTime.now().millisecondsSinceEpoch,
  };
}
