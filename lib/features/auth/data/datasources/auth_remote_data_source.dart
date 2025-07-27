import 'dart:convert';
import 'package:ecommerce_app/core/errors/auth_exceptions.dart';
import 'package:ecommerce_app/core/errors/exception.dart';
import 'package:ecommerce_app/features/auth/data/models/use_model.dart';
import 'package:ecommerce_app/features/auth/domain/entities/auth_token_provider.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user_entity.dart';
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
  Future<UserModel> updateProfile(UserEntity user);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final NetworkInfo networkInfo;
  final AuthTokenProvider tokenProvider;

  AuthRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.networkInfo,
    required this.tokenProvider,
  });

  @override
  Future<UserModel> login(String email, String password) async {
    if (!await networkInfo.isConnected) throw const NetworkException();
    
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email.trim().toLowerCase(),
          'password': password.trim(),
        }),
      );

      return _handleResponse(response, (data) async {
        if (data['token'] == null || data['user'] == null) {
          throw const ServerException('Invalid server response');
        }
        await tokenProvider.saveToken(data['token']);
        return UserModel.fromJson({
          ...data['user'],
          'token': data['token'],
        });
      });
    } catch (e) {
      print('[ERROR] Login failed: $e');
      rethrow;
    }
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
    
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'password': password.trim(),
          'address': address.trim(),
          'phone': phone.trim(),
        }),
      );

      return _handleResponse(response, (data) async {
        if (data['token'] == null || data['user'] == null) {
          throw const ServerException('Invalid server response');
        }
        await tokenProvider.saveToken(data['token']);
        return UserModel.fromJson({
          ...data['user'],
          'token': data['token'],
        });
      });
    } catch (e) {
      print('[ERROR] Registration failed: $e');
      rethrow;
    }
  }

@override
Future<UserModel> getCurrentUser() async {
  if (!await networkInfo.isConnected) throw const NetworkException();
  
  final token = await tokenProvider.getToken();
  print('Token for current user request: $token');
  if (token == null) throw const UnauthorizedException('Not authenticated');

  final response = await client.get(
    Uri.parse('$baseUrl/api/user'), // Ensure this matches your backend
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  return _handleResponse(response, (data) => UserModel.fromJson(data));
}
  @override
  Future<UserModel> updateProfile(UserEntity user) async {
    if (!await networkInfo.isConnected) throw const NetworkException();
    
    final token = await tokenProvider.getToken();
    if (token == null) throw const UnauthorizedException('Not authenticated');

    try {
      final response = await client.put(
        Uri.parse('$baseUrl/api/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'address': user.address,
        }),
      );

      return _handleResponse(response, (data) => UserModel.fromJson(data['user']));
    } catch (e) {
      print('[ERROR] Failed to update profile: $e');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    if (!await networkInfo.isConnected) throw const NetworkException();
    
    final token = await tokenProvider.getToken();
    if (token == null) throw const UnauthorizedException('Not authenticated');

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await tokenProvider.clearToken();
      } else {
        throw ServerException('Logout failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('[ERROR] Failed to logout: $e');
      rethrow;
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
    }

    final errorMsg = responseBody['message'] ?? 
                   responseBody['error'] ?? 
                   'Request failed with status $statusCode';

    switch (statusCode) {
      case 400:
        throw BadRequestException(errorMsg);
      case 401:
        throw UnauthorizedException(errorMsg);
      case 404:
        throw NotFoundException(errorMsg);
      default:
        throw ServerException(errorMsg);
    }
  }
}