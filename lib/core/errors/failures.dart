import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
   final String? message;
  const Failure({this.message});
}

class OfflineFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class ServerFailure extends Failure {
  const ServerFailure({String? message}) : super(message: message);
  
  @override
  List<Object?> get props => [];
}

class EmptyCacheFailure extends Failure {
  const EmptyCacheFailure({String? message}) : super(message: message);
  
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
class NotFoundFailure extends Failure {
  @override
  List<Object?> get props => [];
}
class EmptyCartFailure extends Failure {
  @override
  List<Object?> get props => [];
}
