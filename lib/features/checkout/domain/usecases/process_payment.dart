import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/checkout/domain/entities/PurchaseOrder.dart';
import 'package:ecommerce_app/features/checkout/domain/repositories/checkout_repository.dart';

class ProcessPayment {
  final CheckoutRepository repository;

  ProcessPayment(this.repository);

  Future<Either<Failure, PurchaseOrder>> call({
    required List<CartItem> items,
    required double total,
  }) async {
    return await repository.processPayment(
      items: items,
      total: total,
    );
  }
}