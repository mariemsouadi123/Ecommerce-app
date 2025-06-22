import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/checkout/domain/entities/PurchaseOrder.dart' as domain;

abstract class CheckoutRepository {
  Future<Either<Failure, domain.PurchaseOrder>> processPayment({
    required List<CartItem> items,
    required double total,
  });
}