import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/auth_exceptions.dart';
import 'package:ecommerce_app/core/errors/auth_failures.dart';
import 'package:ecommerce_app/core/errors/exception.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/core/network/network_info.dart';
import 'package:ecommerce_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ecommerce_app/features/auth/domain/entities/auth_token_provider.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user_entity.dart';
import 'package:ecommerce_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as secureStorage;
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final GoogleSignIn _googleSignIn;
  final SharedPreferences _sharedPreferences;
  final AuthTokenProvider tokenProvider;

  static const _tokenKey = 'auth_token';

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required GoogleSignIn googleSignIn,
    required SharedPreferences sharedPreferences,
    required this.tokenProvider,
  })  : _googleSignIn = googleSignIn,
        _sharedPreferences = sharedPreferences;

@override
Future<Either<Failure, UserEntity>> login(String email, String password) async {
  try {
    if (!await networkInfo.isConnected) return Left(OfflineFailure());
    
    final userModel = await remoteDataSource.login(email, password);
    print('Token received: ${userModel.token}'); 
    await _saveToken(userModel.token!);
    print('Token saved successfully');
    return Right(userModel.toEntity());
  } on UnauthorizedException {
    return Left(InvalidCredentialsFailure());
  } catch (e) {
    print('Login error: $e');
    return Left(ServerFailure(message: 'Login failed'));
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
    try {
      if (!await networkInfo.isConnected) {
        return Left(OfflineFailure());
      }

      final userModel = await remoteDataSource.register(
        name,
        email,
        password,
        address,
        phone,
      );
      await _saveToken(userModel.token);
      return Right(userModel.toEntity());
    } on UserAlreadyExistsException {
      return Left(EmailAlreadyInUseFailure());
    } on BadRequestException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure(message: 'Registration failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(OfflineFailure());
      }

      final token = await getToken();
      if (token == null) {
        return Left(UnauthorizedFailure());
      }

      final userModel = await remoteDataSource.getCurrentUser();
      return Right(userModel.toEntity());
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get current user: ${e.toString()}'));
    }
  }

  @override
Future<Either<Failure, Unit>> logout() async {
  try {
    await remoteDataSource.logout();
    await _googleSignIn.signOut();
    return const Right(unit);
  } catch (e) {
    return Left(ServerFailure(message: 'Logout failed'));
  }
}

  @override
Future<Either<Failure, UserEntity>> signInWithGoogle() async {
  try {
    if (!await networkInfo.isConnected) {
      return Left(OfflineFailure());
    }

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return Left(CanceledByUserFailure());
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = 
        await FirebaseAuth.instance.signInWithCredential(credential);

    if (userCredential.user != null) {
      final user = userCredential.user!;
      final userEntity = UserEntity(
        id: user.uid,
        name: user.displayName ?? 'Google User',
        email: user.email ?? '',
        imageUrl: user.photoURL, // Add this line
      );

      final token = await user.getIdToken();
      await _saveToken(token); 

      return Right(userEntity);
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
  try {
    if (!await networkInfo.isConnected) {
      return Left(OfflineFailure());
    }

    final token = await getToken();
    if (token == null) {
      return Left(UnauthorizedFailure());
    }

    final userModel = await remoteDataSource.updateProfile(user);
    return Right(userModel.toEntity());
  } on UnauthorizedException {
    return Left(UnauthorizedFailure());
  } on ServerException catch (e) {
    return Left(ServerFailure(message: e.message));
  } on NetworkException {
    return Left(OfflineFailure());
  } catch (e) {
    return Left(ServerFailure(
      message: 'Failed to update profile: ${e.toString()}'
    ));
  }
}
  Future<String> getToken() async {
    final token = _sharedPreferences.getString(_tokenKey);
    if (token == null) {
      throw Exception('No authentication token found');
    }
    return token;
  }

  Future<void> _saveToken(String? token) async {
    if (token != null) {
      await _sharedPreferences.setString(_tokenKey, token);
      tokenProvider.saveToken(token);
    }
  }

  Future<void> _clearToken() async {
    await _sharedPreferences.remove(_tokenKey);
    tokenProvider.clearToken();
  }

}