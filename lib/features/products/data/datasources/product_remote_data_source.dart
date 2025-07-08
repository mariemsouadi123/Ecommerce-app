import 'dart:convert';

import 'package:ecommerce_app/core/errors/exception.dart';
import 'package:ecommerce_app/features/products/data/models/product_model.dart';
import 'package:http/http.dart' as http;

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getAllProducts();
  Future<ProductModel> getProductById(String id);
}
const BASE_URL = "http://10.0.2.2:5000";

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client client;

  ProductRemoteDataSourceImpl({required this.client});

 @override
Future<List<ProductModel>> getAllProducts() async {
  final response = await client.get(
    Uri.parse("$BASE_URL/api/products"),
    headers: {
      "Content-Type": "application/json",
    },
  );

  if (response.statusCode == 200) {
    final List decodedJson = json.decode(response.body) as List;
    final List<ProductModel> productModels = decodedJson
        .map<ProductModel>((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
    return productModels;
  } else {
    throw ServerException();
  }
}

  @override
  Future<ProductModel> getProductById(String id) async {
    final response = await client.get(
      Uri.parse("$BASE_URL/api/products/$id"),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return ProductModel.fromJson(json.decode(response.body) as Map<String, dynamic>);
    } else if (response.statusCode == 404) {
      throw NotFoundException();
    } else {
      throw ServerException();
    }
  }
}