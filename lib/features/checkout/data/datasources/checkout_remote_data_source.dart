import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:http/http.dart' as http;

abstract class CheckoutRemoteDataSource {
  Future<Either<Failure, Map<String, dynamic>>> processOrder({
    required List<CartItem> items,
    required double total,
  });
}

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
        body: json.encode({
          'items': items.map((item) => {
            'productId': item.product.id,
            'quantity': item.quantity,
            'price': item.product.price,
          }).toList(),
          'total': total,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        return Right(json.decode(response.body));
      } else {
        return Left(ServerFailure());
      }
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}