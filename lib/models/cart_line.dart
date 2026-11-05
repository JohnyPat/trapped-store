import 'cart_item.dart';
import 'product.dart';

class CartLine {
  const CartLine({required this.item, required this.product});

  final CartItem item;
  final Product product;

  double get lineTotal => product.price * item.quantity;
  int get quantity => item.quantity;
}
