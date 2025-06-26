import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {}

class OfflineFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class ServerFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class EmptyCacheFailure extends Failure {
  final String? message;

  EmptyCacheFailure({this.message});

  @override
  List<Object?> get props => [message];
}
class NotFoundFailure extends Failure {
  @override
  List<Object?> get props => [];
}
class EmptyCartFailure extends Failure {
  @override
  List<Object?> get props => [];
}
