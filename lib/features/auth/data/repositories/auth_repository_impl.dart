import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/auth_exceptions.dart';
import 'package:ecommerce_app/core/errors/auth_failures.dart';
import 'package:ecommerce_app/core/errors/exception.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/core/network/network_info.dart';
import 'package:ecommerce_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user_entity.dart';
import 'package:ecommerce_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    return await _handleAuthRequest(() async {
      final userModel = await remoteDataSource.login(email, password);
      return userModel.toEntity();
    });
  }

  @override
  Future<Either<Failure, UserEntity>> register(
    String name,
    String email,
    String password,
    String address,
    String phone,
  ) async {
    return await _handleAuthRequest(() async {
      final userModel = await remoteDataSource.register(
        name,
        email,
        password,
        address,
        phone,
      );
      return userModel.toEntity();
    });
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    return await _handleAuthRequest(() async {
      final userModel = await remoteDataSource.getCurrentUser();
      return userModel.toEntity();
    });
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    return await _handleAuthRequest(() async {
      await remoteDataSource.logout();
      return unit;
    });
  }

 Future<Either<Failure, T>> _handleAuthRequest<T>(Future<T> Function() request) async {
  try {
    final response = await request();
    return Right(response);
  } on UserAlreadyExistsException {
    return  Left(EmailAlreadyInUseFailure() as Failure);
  } on InvalidCredentialsException {
    return  Left(InvalidCredentialsFailure() as Failure);
  } on UnauthorizedException {
    return  Left(UnauthorizedFailure() as Failure);
  } on NetworkException {
    return  Left(OfflineFailure());
  } on ServerException catch (e) {
    return Left(ServerFailure(message: e.message));
  } on NotFoundException {
    return  Left(NotFoundFailure());
  } on TokenExpiredException {
    return  Left(UnauthorizedFailure() as Failure);
  } on SessionExpiredException {
    return  Left(UnauthorizedFailure() as Failure);
  } 
}
}

