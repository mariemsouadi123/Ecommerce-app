import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

class AddToFavorites {
  final FavoriteRepository repository;

  AddToFavorites(this.repository);

  Future<Either<Failure, Unit>> call(Product product) async {
    return await repository.addToFavorites(product);
  }
}