// auth_failures.dart
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:equatable/equatable.dart';

abstract class AuthFailure extends Failure {
  const AuthFailure({String? message}) : super(message: message);
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure() 
      : super(message: 'Invalid email or password');
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure() 
      : super(message: 'Email already in use');
}

class UnauthorizedFailure extends AuthFailure {
  const UnauthorizedFailure() 
      : super(message: 'Session expired, please login again');
}

class RegistrationFailure extends AuthFailure {
  const RegistrationFailure() 
      : super(message: 'Registration failed');
}

class LogoutFailure extends AuthFailure {
  const LogoutFailure() 
      : super(message: 'Failed to logout');
}

class CanceledByUserFailure extends AuthFailure {
  const CanceledByUserFailure() 
      : super(message: 'Canceled by user');
}