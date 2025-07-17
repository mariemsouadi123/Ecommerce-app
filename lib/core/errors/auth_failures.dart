import 'package:equatable/equatable.dart';

// Base class for all auth failures
abstract class AuthFailure extends Equatable {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure() : super('Invalid email or password');
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure() : super('Email already in use');
}

class UnauthorizedFailure extends AuthFailure {
  const UnauthorizedFailure() : super('Session expired, please login again');
}

class RegistrationFailure extends AuthFailure {
  const RegistrationFailure() : super('Registration failed');
}

class LogoutFailure extends AuthFailure {
  const LogoutFailure() : super('Failed to logout');
}