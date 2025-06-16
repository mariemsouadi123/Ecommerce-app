import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

class AddProductToCartUseCase {
  final CartRepository repository;

  AddProductToCartUseCase(this.repository);

  Future<Either<Failure, Unit>> call(Product product) async {
    return await repository.addProductToCart(product);
  }
}