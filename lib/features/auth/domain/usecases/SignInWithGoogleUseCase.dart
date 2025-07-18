import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user_entity.dart';
import 'package:ecommerce_app/features/auth/domain/repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    return await repository.signInWithGoogle();
  }
}