part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String address;
  final String phone;

  const RegisterEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.address,
    required this.phone,
  });

  @override
  List<Object> get props => [name, email, password, address, phone];
}

class GetCurrentUserEvent extends AuthEvent {}
class CheckAuthEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}