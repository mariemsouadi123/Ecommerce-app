import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/core/strings/failures.dart';
import 'package:ecommerce_app/features/favorites/domain/entities/favorite_product.dart';
import 'package:ecommerce_app/features/favorites/domain/usecases/add_to_favorites.dart';
import 'package:ecommerce_app/features/favorites/domain/usecases/get_favorites.dart';
import 'package:ecommerce_app/features/favorites/domain/usecases/remove_from_favorites.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'favorite_event.dart';
part 'favorite_state.dart';

// favorite_bloc.dart
class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final AddToFavorites addToFavorites;
  final GetFavorites getFavorites;
  final RemoveFromFavorites removeFromFavorites;
  
  FavoriteBloc({
    required this.addToFavorites,
    required this.getFavorites,
    required this.removeFromFavorites,
  }) : super(FavoriteInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<AddToFavoritesEvent>(_onAddToFavorites);
    on<RemoveFromFavoritesEvent>(_onRemoveFromFavorites);
  }

  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(FavoriteLoading());
    final failureOrFavorites = await getFavorites();
    emit(_handleFavoritesResult(failureOrFavorites));
  }

  Future<void> _onAddToFavorites(
    AddToFavoritesEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      final newFavorites = List<FavoriteProduct>.from(currentState.favorites)
        ..add(FavoriteProduct(product: event.product, addedAt: DateTime.now()));
      emit(FavoritesLoaded(newFavorites));
    }

    final failureOrSuccess = await addToFavorites(event.product);
    failureOrSuccess.fold(
      (failure) {
        if (currentState is FavoritesLoaded) {
          emit(FavoritesLoaded(List<FavoriteProduct>.from(currentState.favorites)));
        }
        emit(FavoriteError(message: _mapFailureToMessage(failure)));
      },
      (_) {
      },
    );
  }
  Future<void> _onRemoveFromFavorites(
    RemoveFromFavoritesEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      final newFavorites = currentState.favorites
          .where((fav) => fav.product.id != event.product.id)
          .toList();
      emit(FavoritesLoaded(newFavorites));
    }

    final failureOrSuccess = await removeFromFavorites(event.product);
    failureOrSuccess.fold(
      (failure) {
        if (currentState is FavoritesLoaded) {
          emit(FavoritesLoaded(List<FavoriteProduct>.from(currentState.favorites)));
        }
        emit(FavoriteError(message: _mapFailureToMessage(failure)));
      },
      (_) {
        add(LoadFavoritesEvent());
      },
    );
  }

  FavoriteState _handleFavoritesResult(Either<Failure, List<FavoriteProduct>> result) {
    return result.fold(
      (failure) => FavoriteError(message: _mapFailureToMessage(failure)),
      (favorites) => FavoritesLoaded(favorites),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case EmptyCacheFailure:
        return EMPTY_CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected error';
    }
  }
}