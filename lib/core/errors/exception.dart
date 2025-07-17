import 'package:ecommerce_app/core/errors/auth_exceptions.dart';

class ServerException extends AppException {
  const ServerException([String? message])
      : super(message ?? 'Server error', statusCode: 500);
}
class EmptyCacheException implements Exception{}

class OfflineException implements Exception{}
class NotFoundException extends AppException {
  const NotFoundException([String? message])
      : super(message ?? 'Not found', statusCode: 404);
}class EmptyCartException implements Exception{}
