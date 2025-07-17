import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/checkout/data/datasources/checkout_remote_data_source.dart';
import 'package:http/http.dart' as http;

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  CheckoutRemoteDataSourceImpl({required this.client, required this.baseUrl});

  @override
  Future<Either<Failure, Map<String, dynamic>>> processOrder({
    required List<CartItem> items,
    required double total,
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
}