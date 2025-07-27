import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/checkout/domain/entities/PurchaseOrder.dart';
import 'package:ecommerce_app/features/checkout/domain/repositories/checkout_repository.dart';

// features/checkout/domain/usecases/process_payment.dart
class ProcessPayment {
  final CheckoutRepository repository;

  ProcessPayment(this.repository);

  Future<Either<Failure, PurchaseOrder>> call({
    required List<CartItem> items,
    required double total,
    required String paymentMethod,
    String? cardToken,
    String? verificationCode,
  }) async {
    return await repository.processPayment(
      items: items,
      total: total,
      paymentMethod: paymentMethod,
      cardToken: cardToken,
      verificationCode: verificationCode,
    );
  }
}