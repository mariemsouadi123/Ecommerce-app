import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/auth_failures.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/SignInWithGoogleUseCase.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/update_profile.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
    required this.signInWithGoogleUseCase,
    required this.updateProfileUseCase, // Add this

  }) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<GetCurrentUserEvent>(_onGetCurrentUser);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuth);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
  // Add this to your AuthBloc event handlers
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUseCase(event.email, event.password);
    emit(_mapFailureOrUserToState(result));
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await registerUseCase(
      event.name,
      event.email,
      event.password,
      event.address,
      event.phone,
    );
    emit(_mapFailureOrUserToState(result));
  }

  Future<void> _onGetCurrentUser(GetCurrentUserEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await getCurrentUserUseCase();
    emit(_mapFailureOrUserToState(result));
  }
Future<void> _onUpdateProfile(
  UpdateProfileEvent event, 
  Emitter<AuthState> emit
) async {
  emit(AuthLoading());
  try {
    final result = await updateProfileUseCase(event.user);
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (updatedUser) => emit(Authenticated(user: updatedUser)),
    );
  } catch (e) {
    emit(AuthError('Failed to update profile'));
  }
}
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await logoutUseCase();
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (_) => emit(Unauthenticated()),
    );
  }

  Future<void> _onCheckAuth(CheckAuthEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await getCurrentUserUseCase();
    emit(_mapFailureOrUserToState(result));
  }
Future<void> _onSignInWithGoogle(SignInWithGoogleEvent event, Emitter<AuthState> emit) async {
  emit(AuthLoading(isGoogleSignIn: true));
  final result = await signInWithGoogleUseCase();
  result.fold(
    (failure) => emit(AuthError(_mapFailureToMessage(failure), isGoogleSignIn: true)),
    (user) => emit(Authenticated(user: user)),
  );
}

  AuthState _mapFailureOrUserToState(Either<Failure, UserEntity> result) {
    return result.fold(
      (failure) => AuthError(_mapFailureToMessage(failure)),
      (user) => Authenticated(user: user),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred';
      case OfflineFailure():
        return 'No internet connection';
      case InvalidCredentialsFailure:
        return 'Invalid email or password';
      case UnauthorizedFailure:
        return 'Session expired, please login again';
      default:
        return 'An unexpected error occurred';
    }
  }
}