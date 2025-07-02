part of 'favorite_bloc.dart';

abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object> get props => [];
}

class LoadFavoritesEvent extends FavoriteEvent {}

class AddToFavoritesEvent extends FavoriteEvent {
  final Product product;

  const AddToFavoritesEvent(this.product);

  @override
  List<Object> get props => [product];
}

class RemoveFromFavoritesEvent extends FavoriteEvent {
  final Product product;

  const RemoveFromFavoritesEvent(this.product);

  @override
  List<Object> get props => [product];
}