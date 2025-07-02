import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/favorites/domain/entities/favorite_product.dart';
import 'package:ecommerce_app/features/favorites/domain/repositories/favorite_repository.dart';

class GetFavorites {
  final FavoriteRepository repository;

  GetFavorites(this.repository);

  Future<Either<Failure, List<FavoriteProduct>>> call() async {
    return await repository.getFavorites();
  }
}