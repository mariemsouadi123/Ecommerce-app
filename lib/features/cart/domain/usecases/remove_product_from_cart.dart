import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

class RemoveProductFromCartUseCase {
  final CartRepository repository;

  RemoveProductFromCartUseCase(this.repository);

  Future<Either<Failure, void>> call(Product product) async {
    return await repository.removeProductFromCart(product);
  }
}