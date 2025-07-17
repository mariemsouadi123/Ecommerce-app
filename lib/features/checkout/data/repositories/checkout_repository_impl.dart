import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/checkout/data/datasources/checkout_remote_data_source.dart';
import 'package:ecommerce_app/features/checkout/domain/entities/PurchaseOrder.dart';
import 'package:ecommerce_app/features/checkout/domain/repositories/checkout_repository.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remoteDataSource;

  CheckoutRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PurchaseOrder>> processPayment({
    required List<CartItem> items,
    required double total,
  }) async {
    try {
      final result = await remoteDataSource.processOrder(
        items: items,
        total: total,
      );

      return result.fold(
        (failure) => Left(failure),
        (response) {
          if (response['success'] == true) {
            final order = PurchaseOrder.fromJson(response['order']);
            return Right(order);
          } else {
            return Left(ServerFailure(
              message: response['error'] ?? 'Payment failed'
            ));
          }
        },
      );
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to process payment: ${e.toString()}'
      ));
    }
  }
}