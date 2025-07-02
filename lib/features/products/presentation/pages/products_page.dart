import 'package:ecommerce_app/features/favorites/domain/entities/favorite_product.dart';
import 'package:ecommerce_app/features/favorites/presentation/bloc/favorite/favorite_bloc.dart';
import 'package:ecommerce_app/features/favorites/presentation/pages/favorites_page.dart';
import 'package:ecommerce_app/features/products/presentation/blocs/products/products_bloc.dart';
import 'package:ecommerce_app/features/products/presentation/widgets/product_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Products'),
        actions: [
          BlocBuilder<FavoriteBloc, FavoriteState>(
            builder: (context, state) {
              final favoritesCount = state is FavoritesLoaded 
                  ? state.favorites.length 
                  : 0;
              
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FavoritesPage(),
                        ),
                      );
                    },
                  ),
                  if (favoritesCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
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
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          if (state is LoadingProductsState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LoadedProductsState) {
            return BlocBuilder<FavoriteBloc, FavoriteState>(
              builder: (context, favoriteState) {
                final favorites = favoriteState is FavoritesLoaded 
                    ? favoriteState.favorites 
                    : <FavoriteProduct>[];
                
                return ProductListWidget(
                  products: state.products,
                  isFavorite: (product) {
                    return favorites.any((fav) => fav.product.name == product.name);
                  },
                  onFavoritePressed: (product) {
                    final isFav = favorites.any((fav) => fav.product.name == product.name);
                    
                    if (isFav) {
                      context.read<FavoriteBloc>().add(
                        RemoveFromFavoritesEvent(product),
                      );
                    } else {
                      context.read<FavoriteBloc>().add(
                        AddToFavoritesEvent(product),
                      );
                    }
                  },
                );
              },
            );
          } else if (state is ErrorProductsState) {
            return Center(child: Text(state.message));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}