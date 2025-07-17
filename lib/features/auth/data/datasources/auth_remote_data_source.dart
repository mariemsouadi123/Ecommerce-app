import 'dart:convert';
import 'package:ecommerce_app/core/errors/auth_exceptions.dart';
import 'package:ecommerce_app/core/errors/exception.dart';
import 'package:ecommerce_app/features/auth/data/models/use_model.dart';
import 'package:http/http.dart' as http;
import '../../../../core/network/network_info.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(
    String name,
    String email,
    String password,
    String address,
    String phone,
  );
  Future<UserModel> getCurrentUser();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final NetworkInfo networkInfo;

  AuthRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.networkInfo,
  });

  @override
  Future<UserModel> login(String email, String password) async {
    if (!await networkInfo.isConnected) throw const NetworkException();
    
    final response = await client.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email.trim(),
        'password': password.trim(),
      }),
    );

    return _handleResponse(response, (data) => UserModel.fromJson(data['user']));
  }

  @override
  Future<UserModel> register(
    String name,
    String email,
    String password,
    String address,
    String phone,
  ) async {
    if (!await networkInfo.isConnected) throw const NetworkException();
    
    final response = await client.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name.trim(),
        'email': email.trim(),
        'password': password.trim(),
        'address': address.trim(),
        'phone': phone.trim(),
      }),
    );

    return _handleResponse(response, (data) => UserModel.fromJson(data['user']));
  }

  @override
  Future<UserModel> getCurrentUser() async {
    if (!await networkInfo.isConnected) throw const NetworkException();
    
    final response = await client.get(
      Uri.parse('$baseUrl/api/me'),
      headers: {'Content-Type': 'application/json'},
    );

    return _handleResponse(response, (data) => UserModel.fromJson(data['user']));
  }

  @override
  Future<void> logout() async {
    if (!await networkInfo.isConnected) throw const NetworkException();
    
    final response = await client.post(
      Uri.parse('$baseUrl/api/logout'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw const ServerException();
    }
  }

  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) onSuccess,
  ) {
    final statusCode = response.statusCode;
    final responseBody = json.decode(response.body);

    if (statusCode == 200 || statusCode == 201) {
      return onSuccess(responseBody);
    } else if (statusCode == 400) {
      throw BadRequestException(responseBody['message']);
    } else if (statusCode == 401) {
      throw UnauthorizedException(responseBody['message']);
    } else if (statusCode == 404) {
      throw NotFoundException(responseBody['message']);
    } else {
      throw ServerException(responseBody['message']);
    }
  }
}