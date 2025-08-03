import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ecommerce_app/features/auth/presentation/pages/login_page.dart';
import 'package:ecommerce_app/features/auth/presentation/pages/profile_page.dart';
import 'package:ecommerce_app/features/cart/presentation/bloc/cart/cart_bloc.dart';
import 'package:ecommerce_app/features/cart/presentation/pages/cart_page.dart';
import 'package:ecommerce_app/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:ecommerce_app/features/checkout/presentation/bloc/checkout/checkout_bloc.dart';
import 'package:ecommerce_app/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:ecommerce_app/features/favorites/domain/usecases/add_to_favorites.dart';
import 'package:ecommerce_app/features/favorites/domain/usecases/get_favorites.dart';
import 'package:ecommerce_app/features/favorites/domain/usecases/remove_from_favorites.dart';
import 'package:ecommerce_app/features/favorites/presentation/bloc/favorite/favorite_bloc.dart';
import 'package:ecommerce_app/features/favorites/presentation/pages/favorites_page.dart';
import 'package:ecommerce_app/features/products/presentation/blocs/products/products_bloc.dart';
import 'package:ecommerce_app/features/products/presentation/pages/products_page.dart';
import 'package:ecommerce_app/firebase_options.dart';
import 'package:ecommerce_app/injection_container.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        RepositoryProvider<AuthRepository>(
          create: (context) => sl<AuthRepository>(),
        ),
        RepositoryProvider<CheckoutRepository>(
          create: (context) => sl<CheckoutRepository>(),
        ),
        RepositoryProvider<FavoriteRepository>(
          create: (context) => sl<FavoriteRepository>(),
        ),
      ],
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          });
          return  LoginPage();
        }
        return  LoginPage();
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
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFEE3BC),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: 'https://maison-kayser.com/wp-content/themes/kayser/images/international_logo.png',
              height: 40,
              width: 40,
              fit: BoxFit.contain,
              placeholder: (context, url) => const SizedBox(
                height: 40,
                width: 40,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF5E3023),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Icon(
                Icons.bakery_dining,
                color: const Color(0xFF5E3023),
                size: 40,
              ),
            )
            .animate()
            .scale(delay: 200.ms),
            
            const SizedBox(width: 12),
            Text(
              _getAppBarTitle(),
              style: const TextStyle(
                color: Color(0xFF5E3023),
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.1,
              ),
            )
            .animate()
            .fadeIn(delay: 300.ms)
            .slideX(begin: 0.2),
          ],
        ),
        centerTitle: true,
        actions: [
          if (_currentIndex == 0) _buildFavoriteButton(context),
                    IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFF5E3023),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
          )
          .animate()
          .fadeIn(delay: 400.ms),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          final itemCount = state is CartLoaded ? state.items.length : 0;
          
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  if (index == 2) {
                    context.read<AuthBloc>().add(LogoutEvent());
                    return;
                  }
                  if (index == 1) {
                    context.read<CartBloc>().add(LoadCartEvent());
                  }
                  setState(() => _currentIndex = index);
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: const Color(0xFFFEE3BC), 
                selectedItemColor: const Color(0xFFFF6B35), 
                unselectedItemColor: const Color(0xFF5E3023).withOpacity(0.6),
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                items: [
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _currentIndex == 0 
                            ? const Color(0xFFFF6B35).withOpacity(0.2) 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.home,
                        size: 26,
                      ),
                    ),
                    label: 'Products',
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _currentIndex == 1 
                            ? const Color(0xFFFF6B35).withOpacity(0.2) 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(
                            Icons.shopping_cart,
                            size: 26,
                          ),
                          if (itemCount > 0)
                            Positioned(
                              right: -8,
                              top: -8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC8553D),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFEE3BC),
                                    width: 1.5,
                                  ),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '$itemCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    label: 'Cart',
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _currentIndex == 2 
                            ? const Color(0xFFFF6B35).withOpacity(0.2) 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.logout,
                        size: 26,
                      ),
                    ),
                    label: 'Logout',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

 Widget _buildFavoriteButton(BuildContext context) {
  return BlocBuilder<FavoriteBloc, FavoriteState>(
    builder: (context, state) {
      final favoritesCount = state is FavoritesLoaded ? state.favorites.length : 0;
      
      return IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FavoritesPage(),
            ),
          );
        },
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite,
                color: const Color(0xFF5E3023),
                size: 26,
              ),
            ),
            if (favoritesCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8553D),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFEE3BC),
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    favoritesCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}
  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 1:
        return 'Your Cart';
      default:
        return 'Our Bakery';
    }
  }
}