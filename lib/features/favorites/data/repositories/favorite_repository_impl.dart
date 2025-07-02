import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/favorites/domain/entities/favorite_product.dart';
import 'package:ecommerce_app/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final List<FavoriteProduct> _favorites = [];

  @override
  Future<Either<Failure, Unit>> addToFavorites(Product product) async {
    try {
      if (!_favorites.any((fav) => fav.product.name == product.name)) {
        _favorites.add(FavoriteProduct(
          product: product,
          addedAt: DateTime.now(),
        ));
      }
      return const Right(unit);
    } catch (e) {
      return Left(EmptyCacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<FavoriteProduct>>> getFavorites() async {
    try {
      return Right(_favorites);
    } catch (e) {
      return Left(EmptyCacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> removeFromFavorites(Product product) async {
    try {
      _favorites.removeWhere((fav) => fav.product.name == product.name);
      return const Right(unit);
    } catch (e) {
      return Left(EmptyCacheFailure());
    }
  }
}