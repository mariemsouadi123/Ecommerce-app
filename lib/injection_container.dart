import 'package:ecommerce_app/core/network/network_info.dart';
import 'package:ecommerce_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ecommerce_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ecommerce_app/features/auth/domain/entities/auth_token_provider.dart';
import 'package:ecommerce_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/SignInWithGoogleUseCase.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/update_profile.dart';
import 'package:ecommerce_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ecommerce_app/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:ecommerce_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecommerce_app/features/cart/domain/usecases/add_product_to_crt.dart';
import 'package:ecommerce_app/features/cart/domain/usecases/get_cart_items.dart';
import 'package:ecommerce_app/features/cart/domain/usecases/remove_product_from_cart.dart';
import 'package:ecommerce_app/features/cart/presentation/bloc/cart/cart_bloc.dart';
import 'package:ecommerce_app/features/checkout/data/datasources/checkoutRemoteDataSourceImpl.dart';
import 'package:ecommerce_app/features/checkout/data/datasources/checkout_remote_data_source.dart';
import 'package:ecommerce_app/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:ecommerce_app/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:ecommerce_app/features/checkout/domain/usecases/process_payment.dart';
import 'package:ecommerce_app/features/checkout/presentation/bloc/checkout/checkout_bloc.dart';
import 'package:ecommerce_app/features/favorites/data/repositories/favorite_repository_impl.dart';
import 'package:ecommerce_app/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:ecommerce_app/features/favorites/domain/usecases/add_to_favorites.dart';
import 'package:ecommerce_app/features/favorites/domain/usecases/get_favorites.dart';
import 'package:ecommerce_app/features/favorites/domain/usecases/remove_from_favorites.dart';
import 'package:ecommerce_app/features/favorites/presentation/bloc/favorite/favorite_bloc.dart';
import 'package:ecommerce_app/features/products/data/datasources/product_local_data_source.dart';
import 'package:ecommerce_app/features/products/data/datasources/product_remote_data_source.dart';
import 'package:ecommerce_app/features/products/data/repositories/product_repositories_impl.dart';
import 'package:ecommerce_app/features/products/domain/repositories/product_repository.dart';
import 'package:ecommerce_app/features/products/domain/usecases/get_all_products.dart';
import 'package:ecommerce_app/features/products/presentation/blocs/products/products_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;
Future<void> init() async {
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  
 final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Register AuthTokenProvider
 sl.registerLazySingleton<AuthTokenProvider>(() => AuthTokenProviderImpl(sl()));
  // Auth Feature
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      client: sl(), 
      baseUrl: 'http://10.0.2.2:5000', 
      networkInfo: sl(),
      tokenProvider: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
    googleSignIn: GoogleSignIn(
      scopes: ['email', 'profile'],
      signInOption: SignInOption.standard,
    ),
    sharedPreferences: sl(),
    tokenProvider: sl(),
  ));

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));

  // Bloc
  sl.registerFactory(() => AuthBloc(
    loginUseCase: sl(),
    registerUseCase: sl(),
    getCurrentUserUseCase: sl(),
    logoutUseCase: sl(),
    signInWithGoogleUseCase: sl(),
    updateProfileUseCase: sl(),
  ));

  // Products Feature
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(
    remoteDataSource: sl(),
    localDataSource: sl(),
    networkInfo: sl(),
  ));

  sl.registerLazySingleton(() => GetAllProductsUseCase(sl()));
  sl.registerFactory(() => ProductsBloc(getAllProducts: sl()));

  // Cart Feature
  sl.registerLazySingleton<CartRepository>(() => CartRepositoryImpl());
  sl.registerLazySingleton(() => AddProductToCartUseCase(sl()));
  sl.registerLazySingleton(() => GetCartItemsUseCase(sl()));
  sl.registerLazySingleton(() => RemoveProductFromCartUseCase(sl()));
  sl.registerFactory(() => CartBloc());

  // Favorites Feature
  sl.registerSingleton<FavoriteRepository>(FavoriteRepositoryImpl());
  sl.registerSingleton<AddToFavorites>(AddToFavorites(sl()));
  sl.registerSingleton<GetFavorites>(GetFavorites(sl()));
  sl.registerSingleton<RemoveFromFavorites>(RemoveFromFavorites(sl()));
  sl.registerFactory(() => FavoriteBloc(
    addToFavorites: sl(),
    getFavorites: sl(),
    removeFromFavorites: sl(),
  ));
// 1. Register remote data source with explicit types
sl.registerLazySingleton<CheckoutRemoteDataSource>(
  () => CheckoutRemoteDataSourceImpl(
    client: sl<http.Client>(),
    baseUrl: 'http://10.0.2.2:5000',
    authRepository: sl<AuthRepository>(), remoteDataSource: sl<AuthRemoteDataSource>(),
  ),
);

// 2. Register repository with explicit types
sl.registerLazySingleton<CheckoutRepository>(
  () => CheckoutRepositoryImpl(
    remoteDataSource: sl<CheckoutRemoteDataSource>(),
    authRepository: sl<AuthRepository>(),
    baseUrl: 'http://10.0.2.2:5000',
  ),
);

// 3. Register use case
sl.registerLazySingleton<ProcessPayment>(() => ProcessPayment(sl<CheckoutRepository>()));

// 4. Register bloc
sl.registerFactory<CheckoutBloc>(() => CheckoutBloc(
  processPayment: sl<ProcessPayment>(),
  cartBloc: sl<CartBloc>(),
  repository: sl<CheckoutRepository>(),
  getCurrentUser: sl<GetCurrentUserUseCase>(),
));
}