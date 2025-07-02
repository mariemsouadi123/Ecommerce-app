import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

class CartRepositoryImpl implements CartRepository {
  @override
  Future<Either<Failure, Unit>> addProductToCart(Product product) async {
    return const Right(unit); 
  }

  @override
  Future<Either<Failure, List<CartItem>>> getCartItems() async {
    return const Right([]); 
  }

  @override
  Future<Either<Failure, void>> removeProductFromCart(Product product) async {
    return const Right(null); 
  }
}