import 'package:ecommerce_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ecommerce_app/features/auth/presentation/pages/login_page.dart';
import 'package:ecommerce_app/features/cart/presentation/bloc/cart/cart_bloc.dart';
import 'package:ecommerce_app/features/cart/presentation/pages/cart_page.dart';
import 'package:ecommerce_app/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:ecommerce_app/features/checkout/presentation/bloc/checkout/checkout_bloc.dart';
import 'package:ecommerce_app/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:ecommerce_app/features/favorites/domain/usecases/add_to_favorites.dart';
import 'package:ecommerce_app/features/favorites/domain/usecases/get_favorites.dart';
import 'package:ecommerce_app/features/favorites/domain/usecases/remove_from_favorites.dart';
import 'package:ecommerce_app/features/favorites/presentation/bloc/favorite/favorite_bloc.dart';
import 'package:ecommerce_app/features/products/presentation/blocs/products/products_bloc.dart';
import 'package:ecommerce_app/features/products/presentation/pages/products_page.dart';
import 'package:ecommerce_app/firebase_options.dart';
import 'package:ecommerce_app/injection_container.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CheckoutRepository>(
          create: (context) => sl<CheckoutRepository>(),
    )],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => sl<AuthBloc>()..add(CheckAuthEvent()),
            lazy: false, 
          ),
          BlocProvider(
            create: (_) => sl<ProductsBloc>()..add(GetAllProductsEvent()),
            lazy: false,
          ),
          BlocProvider(create: (_) => sl<CartBloc>()),
          BlocProvider(create: (_) => sl<CheckoutBloc>()),
          BlocProvider(
            create: (context) => FavoriteBloc(
              addToFavorites: AddToFavorites(sl<FavoriteRepository>()),
              getFavorites: GetFavorites(sl<FavoriteRepository>()),
              removeFromFavorites: RemoveFromFavorites(sl<FavoriteRepository>()),
            )..add(LoadFavoritesEvent()),
          ),
        ],
        child: MaterialApp(
          home: const AuthWrapper(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is Authenticated) {
          return const MainPage();
        } else if (state is Unauthenticated) {
          return  LoginPage();
        } else if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is AuthError) {
          // Show login page but also show error
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          });
          return  LoginPage();
        }
        return  LoginPage(); // fallback
      },
    );
  }
}
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ProductsPage(),
    const CartPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().add(LogoutEvent()),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          final itemCount = state is CartLoaded ? state.items.length : 0;
          
          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index == 1) {
                context.read<CartBloc>().add(LoadCartEvent());
              }
              setState(() => _currentIndex = index);
            },
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Products',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.shopping_cart),
                    if (itemCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$itemCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Cart',
              ),
            ],
          );
        },
      ),
    );
  }
}