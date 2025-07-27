import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/features/favorites/domain/entities/favorite_product.dart';
import 'package:ecommerce_app/features/favorites/presentation/bloc/favorite/favorite_bloc.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/features/products/presentation/blocs/products/products_bloc.dart';
import 'package:ecommerce_app/features/products/presentation/blocs/products/products_state.dart';
import 'package:ecommerce_app/features/products/presentation/widgets/product_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFEE3BC), // Light beige
              Color(0xFFFFF9F0), // Off-white
              Color(0xFFFEE3BC), // Light beige
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: _buildSearchBar(context),
              ),
              
              // Main content area
              Expanded(
                child: BlocBuilder<ProductsBloc, ProductsState>(
                  builder: (context, state) {
                    return _buildContentSection(context, state);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E3023).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Find your favorite treat...',
          hintStyle: TextStyle(color: const Color(0xFF5E3023).withOpacity(0.5)),
          prefixIcon: Icon(
            Icons.search,
            color: const Color(0xFF5E3023),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.clear,
              color: const Color(0xFF5E3023),
            ),
            onPressed: () => context.read<ProductsBloc>().add(SearchProducts('')),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
        onChanged: (query) => context.read<ProductsBloc>().add(SearchProducts(query)),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5);
  }

  Widget _buildContentSection(BuildContext context, ProductsState state) {
    if (state is ProductsLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: const Color(0xFF5E3023),
        ).animate(
          onPlay: (controller) => controller.repeat(),
        ).rotate(),
      );
    }

    if (state is ProductsLoaded) {
      if (state.allProducts.isEmpty) {
        return Center(
          child: Text(
            'No delicious treats available yet!',
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF5E3023).withOpacity(0.7),
            ),
          ).animate().shake(),
        );
      }

      return BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, favoriteState) {
          final favorites = favoriteState is FavoritesLoaded 
              ? favoriteState.favorites 
              : <FavoriteProduct>[];
              
          return Column(
            children: [
              // Categories
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 12),
                child: _buildCategoryChips(context, state),
              ),
              
              // Results count
              if (state.filteredProducts.isNotEmpty)
                _buildResultsCount(state),
              
              // Product grid
              Expanded(
                child: ProductListWidget(
                  products: state.filteredProducts,
                  isFavorite: (product) => favorites.any((fav) => fav.product.id == product.id),
                  onFavoritePressed: (product) => _handleFavoriteAction(context, product, favorites),
                ),
              ),
            ],
          );
        },
      );
    }

    return Center(
      child: CircularProgressIndicator(
        color: const Color(0xFF5E3023),
      ),
    );
  }

  void _handleFavoriteAction(BuildContext context, Product product, List<FavoriteProduct> favorites) {
    final isFav = favorites.any((fav) => fav.product.id == product.id);
    if (isFav) {
      context.read<FavoriteBloc>().add(RemoveFromFavoritesEvent(product));
    } else {
      context.read<FavoriteBloc>().add(AddToFavoritesEvent(product));
    }
  }

  Widget _buildCategoryChips(BuildContext context, ProductsLoaded state) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          'All',
          'Reception',
          'Boulangerie',
          'Patisserie',
          'Viennoiserie',
        ].map((category) => _buildBakeryCategoryChip(
          context,
          category,
          state.currentCategory == category,
        )).toList()
        .animate(interval: 100.ms)
        .slideX(begin: 0.5, end: 0, curve: Curves.easeOut)
        .fadeIn(),
      ),
    );
  }

  Widget _buildBakeryCategoryChip(BuildContext context, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF5E3023),
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            context.read<ProductsBloc>().add(FilterProductsByCategory(label));
          }
        },
        selectedColor: const Color(0xFFFF6B35), // Red-orange
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: const Color(0xFF5E3023).withOpacity(0.2),
            width: 1,
          ),
        ),
        elevation: 2,
        shadowColor: const Color(0xFF5E3023).withOpacity(0.1),
      ),
    );
  }

  Widget _buildResultsCount(ProductsLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        'Found ${state.filteredProducts.length} delicious items',
        style: TextStyle(
          fontSize: 14,
          color: const Color(0xFF5E3023).withOpacity(0.7),
          fontStyle: FontStyle.italic,
        ),
      ).animate().fadeIn(),
    );
  }
}