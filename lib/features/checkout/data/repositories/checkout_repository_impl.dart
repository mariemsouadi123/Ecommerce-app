import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/checkout/data/datasources/checkout_remote_data_source.dart';
import 'package:ecommerce_app/features/checkout/domain/entities/PurchaseOrder.dart';
import 'package:ecommerce_app/features/checkout/domain/repositories/checkout_repository.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remoteDataSource;

  CheckoutRepositoryImpl({required this.remoteDataSource});

  Future<Either<Failure, PurchaseOrder>> processPayment({
    required List<CartItem> items,
    required double total,
  }) async {
    final failureOrResponse = await remoteDataSource.processOrder(
      items: items,
      total: total,
    );

    return failureOrResponse.fold(
      (failure) => Left(failure),
      (response) {
        try {
          final orderData = response['order'];
          final order = PurchaseOrder(
            id: orderData['id'],
            items: items,
            total: orderData['total'],
            date: DateTime.parse(orderData['createdAt']),
            status: orderData['status'],
          );
          return Right(order);
        } catch (e) {
          return Left(ServerFailure(message: 'Failed to parse order data'));
        }
      },
    );
  }
}