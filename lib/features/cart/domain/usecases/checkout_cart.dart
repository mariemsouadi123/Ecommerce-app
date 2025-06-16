import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/domain/repositories/cart_repository.dart';

abstract class CheckoutCartUseCase {
  Future<Either<Failure, void>> call(List<CartItem> items);
}
class CheckoutCartUseCaseImpl implements CheckoutCartUseCase {
  final CartRepository repository;

  CheckoutCartUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, void>> call(List<CartItem> items) async {
    return await repository.checkoutCart(items);
  }
}