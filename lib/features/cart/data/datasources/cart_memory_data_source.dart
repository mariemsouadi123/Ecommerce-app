import 'package:ecommerce_app/features/products/domain/entities/product.dart';

class CartMemoryDataSource {
  final List<Product> _cartItems = [];

  Future<void> cacheProduct(Product product) async {
    _cartItems.add(product);
  } 
  Future<List<Product>> getCachedProducts() async {
    return _cartItems;
  }
  Future<void> removeProduct(Product product) async {
    _cartItems.removeWhere((p) => p.id == product.id);
  }
  Future<void> clearCart() async {
    _cartItems.clear();
  }
}