import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/exception.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/core/network/network_info.dart';
import 'package:ecommerce_app/features/products/data/datasources/product_local_data_source.dart';
import 'package:ecommerce_app/features/products/data/datasources/product_remote_data_source.dart';
import 'package:ecommerce_app/features/products/data/models/product_model.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Product>>> getAllProducts() async {
    if (await networkInfo.isConnected) {
      try {
        final List<ProductModel> remoteModels = await remoteDataSource.getAllProducts();
        await localDataSource.cacheProducts(remoteModels);
        return Right(remoteModels); 
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final List<ProductModel> localModels = await localDataSource.getCachedProducts();
        return Right(localModels);
      } on EmptyCacheException {
        return Left(EmptyCacheFailure());
      }
    }
  }
}