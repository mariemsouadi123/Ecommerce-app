import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

abstract class CartRepository {
  Future<Either<Failure, Unit>> addProductToCart(Product product);
  Future<Either<Failure, List<CartItem>>> getCartItems();
  Future<Either<Failure, void>> removeProductFromCart(Product product);
}