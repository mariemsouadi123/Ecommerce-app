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
      final products = await memoryDataSource.getCachedProducts();
      final cartItems = _groupProducts(products);
      return Right(cartItems);
    } catch (e) {
      return Left(EmptyCacheFailure());
    }
  }

  List<CartItem> _groupProducts(List<Product> products) {
    final productCounts = <Product, int>{};
    for (final product in products) {
      productCounts.update(
        product,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    return productCounts.entries
        .map((entry) => CartItem(product: entry.key, quantity: entry.value))
        .toList();
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
