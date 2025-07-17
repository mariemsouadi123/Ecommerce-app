import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register(
    String name,
    String email,
    String password,
    String address,
    String phone,
  );
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<Either<Failure, Unit>> logout();
}