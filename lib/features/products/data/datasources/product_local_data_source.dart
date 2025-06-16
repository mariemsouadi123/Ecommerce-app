import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/exception.dart';
import 'package:ecommerce_app/features/products/data/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const CACHED_PRODUCTS = "Cached_Products";

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final SharedPreferences sharedPreferences;

  ProductLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<Unit> cacheProducts(List<ProductModel> products) {
    final productModelsToJson = products
        .map((product) => product.toJson())
        .toList();
    sharedPreferences.setString(
        CACHED_PRODUCTS, json.encode(productModelsToJson));
    return Future.value(unit);
  }

  @override
  Future<List<ProductModel>> getCachedProducts() {
    final jsonString = sharedPreferences.getString(CACHED_PRODUCTS);
    if (jsonString != null) {
      final decodedJson = json.decode(jsonString) as List;
      return Future.value(
        decodedJson
            .map((jsonProduct) => ProductModel.fromJson(jsonProduct as Map<String, dynamic>))
            .toList(),
      );
    } else {
      throw EmptyCacheException();
    }
  }
}

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getCachedProducts();
  Future<Unit> cacheProducts(List<ProductModel> products);
}