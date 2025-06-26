import 'package:ecommerce_app/core/network/network_info.dart';
import 'package:ecommerce_app/features/cart/data/datasources/cart_memory_data_source.dart';
import 'package:ecommerce_app/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:ecommerce_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecommerce_app/features/cart/domain/usecases/add_product_to_crt.dart';
import 'package:ecommerce_app/features/cart/domain/usecases/get_cart_items.dart';
import 'package:ecommerce_app/features/cart/domain/usecases/remove_product_from_cart.dart';
import 'package:ecommerce_app/features/cart/presentation/bloc/cart/cart_bloc.dart';
import 'package:ecommerce_app/features/checkout/data/datasources/checkout_remote_data_source.dart';
import 'package:ecommerce_app/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:ecommerce_app/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:ecommerce_app/features/checkout/domain/usecases/process_payment.dart';
import 'package:ecommerce_app/features/checkout/presentation/bloc/checkout/checkout_bloc.dart';
import 'package:ecommerce_app/features/products/data/datasources/product_local_data_source.dart';
import 'package:ecommerce_app/features/products/data/datasources/product_remote_data_source.dart';
import 'package:ecommerce_app/features/products/data/repositories/product_repositories_impl.dart';
import 'package:ecommerce_app/features/products/domain/repositories/product_repository.dart';
import 'package:ecommerce_app/features/products/domain/usecases/get_all_products.dart';
import 'package:ecommerce_app/features/products/presentation/blocs/products/products_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory(() => ProductsBloc(getAllProducts: sl()));
  sl.registerFactory(() => CartBloc(
        addProductToCart: sl(),
        getCartItems: sl(),
  removeProductFromCart: sl(),
      ));

        sl.registerFactory(() => CheckoutBloc(processPayment: sl()));

  sl.registerLazySingleton(() => GetAllProductsUseCase(sl()));
  sl.registerLazySingleton(() => AddProductToCartUseCase(sl()));
  sl.registerLazySingleton(() => GetCartItemsUseCase(sl()));
  sl.registerLazySingleton(() => RemoveProductFromCartUseCase(sl()));
  sl.registerLazySingleton(() => ProcessPayment(sl()));


  sl.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
      ));
      
  sl.registerLazySingleton<CartRepository>(() => CartRepositoryImpl(
        memoryDataSource: sl(),
      ));
    
    sl.registerLazySingleton<CheckoutRepository>(() => CheckoutRepositoryImpl(
        remoteDataSource: sl(),
      ));

  sl.registerLazySingleton<CartMemoryDataSource>(() => CartMemoryDataSource());
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(sharedPreferences: sl()),
  );
sl.registerLazySingleton<CheckoutRemoteDataSource>(
    () => CheckoutRemoteDataSourceImpl(client: sl(), baseUrl: 'http://10.0.2.2:5000'),
  );
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());
}