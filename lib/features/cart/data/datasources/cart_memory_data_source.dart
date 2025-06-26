import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

class CartMemoryDataSource {
  final List<CartItem> _cartItems = [];

  Future<void> cacheProduct(Product product) async {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.name == product.name, 
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex] = CartItem(
        product: _cartItems[existingIndex].product,
        quantity: _cartItems[existingIndex].quantity + 1,
      );
    } else {
      _cartItems.add(CartItem(product: product, quantity: 1));
    }
  }

  Future<List<CartItem>> getCachedProducts() async {
    return List.unmodifiable(_cartItems);
  }

  Future<void> removeProduct(Product product) async {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.name == product.name, 
    );

    if (existingIndex >= 0) {
      if (_cartItems[existingIndex].quantity > 1) {
        _cartItems[existingIndex] = CartItem(
          product: _cartItems[existingIndex].product,
          quantity: _cartItems[existingIndex].quantity - 1,
        );
      } else {
        _cartItems.removeAt(existingIndex);
      }
    }
  }

  Future<void> clearCart() async {
    _cartItems.clear();
  }
}