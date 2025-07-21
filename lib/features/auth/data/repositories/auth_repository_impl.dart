import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/auth_exceptions.dart';
import 'package:ecommerce_app/core/errors/auth_failures.dart';
import 'package:ecommerce_app/core/errors/exception.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/core/network/network_info.dart';
import 'package:ecommerce_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user_entity.dart';
import 'package:ecommerce_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required GoogleSignIn googleSignIn,
  }) : _googleSignIn = googleSignIn;

 @override
Future<Either<Failure, UserEntity>> login(String email, String password) async {
  try {
    print('[DEBUG] Starting login process for email: $email');
    final userModel = await remoteDataSource.login(email, password);
    print('[DEBUG] Login successful for user: ${userModel.email}');
    return Right(userModel.toEntity());
  } on UnauthorizedException {
    print('[WARNING] Invalid credentials for email: $email');
    return Left(InvalidCredentialsFailure());
  } on BadRequestException catch (e) {
    print('[ERROR] Bad request: ${e.message}');
    return Left(ServerFailure(message: e.message));
  } on ServerException catch (e) {
    print('[ERROR] Server error: ${e.message}');
    return Left(ServerFailure(message: e.message));
  } on NetworkException {
    print('[ERROR] Network error');
    return Left(OfflineFailure());
  } catch (e) {
    print('[ERROR] Unexpected login error: $e');
    return Left(ServerFailure(message: 'Login failed: ${e.toString()}'));
  }
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

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    if (!await networkInfo.isConnected) {
      return Left(OfflineFailure());
    }

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return Left(CanceledByUserFailure());
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = 
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Convert Firebase User to your UserEntity
      final user = userCredential.user;
      if (user != null) {
        return Right(UserEntity(
          id: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          // Add other fields as needed
        ));
      } else {
        return Left(ServerFailure(message: 'No user returned from Google Sign-In'));
      }
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Google Sign-In failed'));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error during Google Sign-In: ${e.toString()}'));
    }
  }
  @override
  Future<Either<Failure, UserEntity>> updateProfile(UserEntity user) async {
    return await _handleAuthRequest(() async {
      final userModel = await remoteDataSource.updateProfile(user);
      return userModel.toEntity();
    });
  }
  Future<Either<Failure, T>> _handleAuthRequest<T>(Future<T> Function() request) async {
  try {
    if (!await networkInfo.isConnected) {
      return Left(OfflineFailure());
    }
    
    final response = await request();
    return Right(response);
  } on UserAlreadyExistsException {
    return Left(EmailAlreadyInUseFailure());
  } on InvalidCredentialsException {
    return Left(InvalidCredentialsFailure());
  } on UnauthorizedException {
    return Left(UnauthorizedFailure());
  } on NetworkException {
    return Left(OfflineFailure());
  } on ServerException catch (e) {
    return Left(ServerFailure(message: e.message));
  } on NotFoundException {
    return Left(NotFoundFailure());
  } on TokenExpiredException {
    return Left(UnauthorizedFailure());
  } on SessionExpiredException {
    return Left(UnauthorizedFailure());
  } catch (e) {
    return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
  }
}
}