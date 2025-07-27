import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/checkout/data/datasources/checkout_remote_data_source.dart';
import 'package:http/http.dart' as http;

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final AuthRepository authRepository;


  CheckoutRemoteDataSourceImpl( {required this.client, required this.baseUrl ,     required this.authRepository, required Object remoteDataSource,
});

  @override
  Future<Either<Failure, Map<String, dynamic>>> processOrder({
    required List<CartItem> items,
    required double total,
    required String paymentMethod,

    String? cardToken,
    String? verificationCode,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'items': items.map((item) => {
                'productId': item.product.id,
                'quantity': item.quantity,
              }).toList(),
          'total': total,
          'paymentMethod': paymentMethod,
          'cardToken': cardToken,
          'verificationCode': verificationCode,
        }),
      );

      final responseBody = json.decode(response.body);
      
      if (response.statusCode == 201) {
        return Right(responseBody);
      } else {
        return Left(ServerFailure(
          message: responseBody['error'] ?? 'Payment failed with status ${response.statusCode}'
        ));
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Network error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> initiatePayment({
    required double amount,
    required String paymentMethod,
    String? cardNumber,
    String? expiryDate,
    String? cvc,
  }) async {
    try {
      // Get the current user's token
      final token = await authRepository.getToken();
      
      final response = await client.post(
        Uri.parse('$baseUrl/api/orders/initiate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include the token
        },
        body: json.encode({
          'amount': amount,
          'paymentMethod': paymentMethod,
          'cardNumber': cardNumber,
          'expiryDate': expiryDate,
          'cvc': cvc,
          'userEmail': (await authRepository.getCurrentUser()).fold(
            (failure) => throw Exception('Failed to get user email'),
            (user) => user.email,
          ),
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return Right(responseBody['paymentId']);
      } else {
        final error = json.decode(response.body)['error'] ?? 'Failed to initiate payment';
        return Left(ServerFailure(message: error));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> resendVerificationCode({
    required String paymentId,
    required String userEmail,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/orders/resend-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'paymentId': paymentId,
          'userEmail': userEmail,
        }),
      );

      final responseBody = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return responseBody['success'] ?? false;
      } else {
        throw ServerFailure(
          message: responseBody['error'] ?? 'Failed to resend verification code'
        );
      }
    } catch (e) {
      throw ServerFailure(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<Either<Failure, bool>> verifyPayment({
    required String paymentId,
    required String verificationCode,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/orders/verify'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'paymentId': paymentId,
          'verificationCode': verificationCode,
        }),
      );

      final responseBody = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return Right(responseBody['success'] ?? false);
      } else {
        return Left(ServerFailure(
          message: responseBody['error'] ?? 'Verification failed'
        ));
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Network error: ${e.toString()}'));
    }
  }
}