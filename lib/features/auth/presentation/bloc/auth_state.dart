part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  final bool isGoogleSignIn;
  
  const AuthLoading({this.isGoogleSignIn = false});
  
  @override
  List<Object> get props => [isGoogleSignIn];
}

class Authenticated extends AuthState {
  final UserEntity user;
  
  const Authenticated({required this.user});
  
  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  final bool isGoogleSignIn;
  
  const AuthError(this.message, {this.isGoogleSignIn = false});
  
  @override
  List<Object> get props => [message, isGoogleSignIn];
}