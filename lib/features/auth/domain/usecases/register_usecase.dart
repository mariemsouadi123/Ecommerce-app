import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(
    String name,
    String email,
    String password,
    String address,
    String phone,
  ) async {
    return await repository.register(name, email, password, address, phone);
  }
}