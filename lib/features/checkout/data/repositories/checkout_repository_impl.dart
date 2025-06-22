import 'package:dartz/dartz.dart' as dartz;
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/checkout/data/datasources/checkout_remote_data_source.dart';
import 'package:ecommerce_app/features/checkout/domain/entities/PurchaseOrder.dart';
import 'package:ecommerce_app/features/checkout/domain/repositories/checkout_repository.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remoteDataSource;

  CheckoutRepositoryImpl({required this.remoteDataSource});

  @override
  Future<dartz.Either<Failure, PurchaseOrder>> processPayment({
    required List<CartItem> items,
    required double total,
  }) async {
    final failureOrResponse = await remoteDataSource.processOrder(
      items: items,
      total: total,
    );

    return failureOrResponse.fold(
      (failure) => dartz.Left(failure),
      (response) {
        try {
          final order = PurchaseOrder(
            id: response['_id'],
            items: items,
            total: total,
            date: DateTime.parse(response['createdAt']),
            status: 'completed',
          );
          return dartz.Right(order);
        } catch (e) {
          return dartz.Left(ServerFailure());
        }
      },
    );
  }
}