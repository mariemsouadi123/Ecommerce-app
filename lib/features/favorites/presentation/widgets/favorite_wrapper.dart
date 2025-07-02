import 'package:ecommerce_app/features/favorites/presentation/bloc/favorite/favorite_bloc.dart';
import 'package:ecommerce_app/features/favorites/domain/usecases/add_to_favorites.dart';
import 'package:ecommerce_app/features/favorites/domain/usecases/get_favorites.dart';
import 'package:ecommerce_app/features/favorites/domain/usecases/remove_from_favorites.dart';
import 'package:ecommerce_app/features/favorites/data/repositories/favorite_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteWrapper extends StatelessWidget {
  final Widget child;
  
  const FavoriteWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final repository = FavoriteRepositoryImpl();
        return FavoriteBloc(
          addToFavorites: AddToFavorites(repository),
          getFavorites: GetFavorites(repository),
          removeFromFavorites: RemoveFromFavorites(repository),
        )..add(LoadFavoritesEvent());
      },
      child: child,
    );
  }
}