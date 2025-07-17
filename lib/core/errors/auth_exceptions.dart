// auth_exceptions.dart
import 'package:equatable/equatable.dart';

// Base class for all exceptions
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException() : super('No internet connection');
}
class BadRequestException extends AppException {
  const BadRequestException([String? message])
      : super(message ?? 'Bad request', statusCode: 400);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([String? message])
      : super(message ?? 'Unauthorized', statusCode: 401);
}


// Auth-specific exceptions
class AuthException extends AppException {
  const AuthException(String message, {int? statusCode})
      : super(message, statusCode: statusCode);
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException()
      : super('Invalid credentials', statusCode: 401);
}

class UserAlreadyExistsException extends AuthException {
  const UserAlreadyExistsException()
      : super('User already exists', statusCode: 400);
}

class TokenExpiredException extends AuthException {
  const TokenExpiredException()
      : super('Authentication token expired', statusCode: 401);
}

class SessionExpiredException extends AuthException {
  const SessionExpiredException()
      : super('Session expired', statusCode: 401);
}