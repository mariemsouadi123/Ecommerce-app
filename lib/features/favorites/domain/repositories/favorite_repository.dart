import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/favorites/domain/entities/favorite_product.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

abstract class FavoriteRepository {
  Future<Either<Failure, Unit>> addToFavorites(Product product);
  Future<Either<Failure, List<FavoriteProduct>>> getFavorites();
  Future<Either<Failure, Unit>> removeFromFavorites(Product product);
}