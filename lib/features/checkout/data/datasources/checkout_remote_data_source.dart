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

