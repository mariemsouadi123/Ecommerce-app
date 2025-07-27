// features/checkout/domain/repositories/checkout_repository.dart
import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/checkout/domain/entities/PurchaseOrder.dart';

abstract class CheckoutRepository {
  Future<Either<Failure, PurchaseOrder>> processPayment({
    required List<CartItem> items,
    required double total,
    required String paymentMethod,
    String? cardToken,
    String? verificationCode,
  });
  
  Future<Either<Failure, String>> initiatePayment({
    required double amount,
    required String paymentMethod,
    String? cardNumber,
    String? expiryDate,
    String? cvc, required String userEmail,
  });
  
  Future<Either<Failure, bool>> verifyPayment({
    required String paymentId,
    required String verificationCode,
  });
   Future<Either<Failure, bool>> resendVerificationCode({
    required String paymentId,
    required String userEmail,
  });
}