import 'package:ecommerce_app/features/products/domain/entities/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});
}
