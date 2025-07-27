// features/checkout/domain/repositories/checkout_repository_impl.dart
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/checkout/data/datasources/checkout_remote_data_source.dart';
import 'package:ecommerce_app/features/checkout/domain/entities/PurchaseOrder.dart';
import 'package:ecommerce_app/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:http/http.dart' as client;

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;
  final String baseUrl;

CheckoutRepositoryImpl({
    required this.remoteDataSource,
    required this.authRepository,
    required this.baseUrl,
  });
  @override
  Future<Either<Failure, PurchaseOrder>> processPayment({
    required List<CartItem> items,
    required double total,
    required String paymentMethod,
    String? cardToken,
    String? verificationCode,
  }) async {
    try {
      final result = await remoteDataSource.processOrder(
        items: items,
        total: total,
        paymentMethod: paymentMethod,
        cardToken: cardToken,
        verificationCode: verificationCode,
      );

      return result.fold(
        (failure) => Left(failure),
        (response) {
          if (response['success'] == true) {
            final order = PurchaseOrder.fromJson(response['order']);
            return Right(order);
          } else {
            return Left(
                ServerFailure(message: response['error'] ?? 'Payment failed'));
          }
        },
      );
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to process payment: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> initiatePayment({
    required double amount,
    required String paymentMethod,
    String? cardNumber,
    String? expiryDate,
    String? cvc,
    required String userEmail, // Add required email parameter
  }) async {
    try {
      final token = await authRepository.getToken();

      final response = await client.post(
        Uri.parse('$baseUrl/api/orders/initiate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'amount': amount,
          'paymentMethod': paymentMethod,
          'cardNumber': cardNumber,
          'expiryDate': expiryDate,
          'cvc': cvc,
          'userEmail': userEmail, // Use passed email
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return Right(responseBody['paymentId']);
      } else {
        final error =
            json.decode(response.body)['error'] ?? 'Failed to initiate payment';
        return Left(ServerFailure(message: error));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyPayment({
    required String paymentId,
    required String verificationCode,
  }) async {
    try {
      return await remoteDataSource.verifyPayment(
        paymentId: paymentId,
        verificationCode: verificationCode,
      );
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to verify payment: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> resendVerificationCode({
    required String paymentId,
    required String userEmail,
  }) async {
    try {
      final response = await remoteDataSource.resendVerificationCode(
        paymentId: paymentId,
        userEmail: userEmail,
      );
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
