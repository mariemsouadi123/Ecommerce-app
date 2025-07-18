import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/features/favorites/domain/entities/favorite_product.dart';
import 'package:ecommerce_app/features/favorites/presentation/bloc/favorite/favorite_bloc.dart';
import 'package:ecommerce_app/features/favorites/presentation/pages/favorites_page.dart';
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
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.brown.shade50,
              Colors.brown.shade100,
              Colors.brown.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Logo at the top
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: CachedNetworkImage(
                  imageUrl: 'https://maison-kayser.com/wp-content/themes/kayser/images/international_logo.png?x48382',
                  height: 30,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const SizedBox(
                    height: 30,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ).animate().fadeIn(duration: 300.ms),
              ),
              
              // App Bar with bakery styling
              _buildAppBar(context),
              
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

  Widget _buildContentSection(BuildContext context, ProductsState state) {
    if (state is ProductsLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.brown.shade700,
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
              color: Colors.brown.shade800,
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
              // Search and filter section
              _buildSearchFilterSection(context, state),
              
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
        color: Colors.brown.shade700,
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

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Our Bakery Treats',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.brown.shade800,
          fontFamily: 'Pacifico',
        ),
      ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.2),
      centerTitle: true,
      actions: [
        _buildFavoriteButton(context),
      ],
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, state) {
        final favoritesCount = state is FavoritesLoaded ? state.favorites.length : 0;
        
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.brown.shade100,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.shade300,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: Colors.brown.shade700,
                ),
                onPressed: () => _navigateToFavorites(context),
              ),
            ).animate().fadeIn(delay: 400.ms).scale(),
            
            if (favoritesCount > 0)
              Positioned(
                right: 12,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    favoritesCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ).animate().scale(),
              ),
          ],
        );
      },
    );
  }

  void _navigateToFavorites(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const FavoritesPage(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    );
  }

  Widget _buildSearchFilterSection(BuildContext context, ProductsLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          _buildSearchBar(context),
          _buildCategoryChips(context, state),
          if (state.currentSearchQuery.isNotEmpty) _buildResultsCount(state),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.brown.shade100,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Find your favorite treat...',
          hintStyle: TextStyle(color: Colors.brown.shade500),
          prefixIcon: Icon(Icons.search, color: Colors.brown.shade700),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear, color: Colors.brown.shade700),
            onPressed: () => context.read<ProductsBloc>().add(SearchProducts('')),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (query) => context.read<ProductsBloc>().add(SearchProducts(query)),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5);
  }

  Widget _buildCategoryChips(BuildContext context, ProductsLoaded state) {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildResultsCount(ProductsLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Found ${state.filteredProducts.length} delicious items',
        style: TextStyle(
          fontSize: 14,
          color: Colors.brown.shade700,
          fontStyle: FontStyle.italic,
        ),
      ).animate().fadeIn(),
    );
  }

  Widget _buildBakeryCategoryChip(BuildContext context, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.brown.shade800,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            context.read<ProductsBloc>().add(FilterProductsByCategory(label));
          }
        },
        selectedColor: Colors.brown.shade700,
        backgroundColor: Colors.brown.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 2,
        shadowColor: Colors.brown.shade300,
      ),
    );
  }
}