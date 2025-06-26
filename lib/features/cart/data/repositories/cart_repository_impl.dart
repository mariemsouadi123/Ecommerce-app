import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/cart/data/datasources/cart_memory_data_source.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

class CartRepositoryImpl implements CartRepository {
  final CartMemoryDataSource memoryDataSource;

  CartRepositoryImpl({required this.memoryDataSource});

  @override
  Future<Either<Failure, Unit>> addProductToCart(Product product) async {
    try {
      await memoryDataSource.cacheProduct(product);
      return const Right(unit);
    } catch (e) {
      return Left(EmptyCacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<CartItem>>> getCartItems() async {
    try {
      final cartItems = await memoryDataSource.getCachedProducts();
      if (cartItems.isEmpty) {
        return Left(EmptyCacheFailure(message: 'Cart is empty'));
      }
      return Right(cartItems);
    } catch (e) {
      return Left(EmptyCacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> removeProductFromCart(Product product) async {
    try {
      await memoryDataSource.removeProduct(product);
      return const Right(null);
    } catch (e) {
      return Left(EmptyCacheFailure());
    }
  }
}