import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String? message;
  const Failure({this.message});

  @override
  List<Object?> get props => [message];
}

class OfflineFailure extends Failure {
  const OfflineFailure({String? message}) : super(message: message);
  
  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({String? message}) : super(message: message);
  
  @override
  List<Object?> get props => [message];
}

class EmptyCacheFailure extends Failure {
  const EmptyCacheFailure({String? message}) : super(message: message);
  
  @override
  List<Object?> get props => [message];
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({String? message}) : super(message: message);
  
  @override
  List<Object?> get props => [message];
}

class EmptyCartFailure extends Failure {
  const EmptyCartFailure({String? message}) : super(message: message);
  
  @override
  List<Object?> get props => [message];
}
