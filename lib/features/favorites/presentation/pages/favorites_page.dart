import 'package:ecommerce_app/features/favorites/presentation/bloc/favorite/favorite_bloc.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Favorites'),
        backgroundColor: const Color(0xFFFEE3BC),
        elevation: 0,
        foregroundColor: const Color(0xFF5E3023),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh),
            ),
            onPressed: () {
              context.read<FavoriteBloc>().add(LoadFavoritesEvent());
            },
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
      body: Stack(
        children: [
          // Background with decorative circles
          Container(
            color: const Color(0xFFFEE3BC),
            child: Stack(
              children: [
                Positioned(
                  top: -50,
                  left: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD88C9A).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ).animate().scale(delay: 200.ms, duration: 1000.ms),
                ),
                Positioned(
                  bottom: -100,
                  right: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ).animate().scale(delay: 300.ms, duration: 1000.ms),
                ),
              ],
            ),
          ),
          
          // Content
          BlocConsumer<FavoriteBloc, FavoriteState>(
            listener: (context, state) {
              if (state is FavoriteError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: const Color(0xFFC8553D),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is FavoriteLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF5E3023),
                  ),
                );
              }

              if (state is FavoritesLoaded) {
                if (state.favorites.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 60,
                          color: const Color(0xFF5E3023).withOpacity(0.3),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No favorites yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: const Color(0xFF5E3023).withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.favorites.length,
                  itemBuilder: (context, index) {
                    final favorite = state.favorites[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Slidable(
                        key: ValueKey(favorite.product.id),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                context.read<FavoriteBloc>().add(
                                  RemoveFromFavoritesEvent(favorite.product),
                                );
                              },
                              backgroundColor: const Color(0xFFC8553D),
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Remove',
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ],
                        ),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                favorite.product.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.error),
                                ),
                              ),
                            ),
                            title: Text(
                              favorite.product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5E3023),
                              ),
                            ),
                            subtitle: Text(
                              '\$${favorite.product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF6B35),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.favorite, color: Colors.red),
                              onPressed: () {
                                context.read<FavoriteBloc>().add(
                                  RemoveFromFavoritesEvent(favorite.product),
                                );
                              },
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: (100 * index).ms),
                    );
                  },
                );
              }

              return const Center(child: Text('No favorites yet'));
            },
          ),
        ],
      ),
    );
  }
}