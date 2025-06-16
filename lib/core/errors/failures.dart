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
  @override
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
