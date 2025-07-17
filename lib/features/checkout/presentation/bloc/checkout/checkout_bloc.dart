// features/checkout/presentation/bloc/checkout/checkout_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/presentation/bloc/cart/cart_bloc.dart';
import 'package:ecommerce_app/features/checkout/domain/entities/PurchaseOrder.dart';
import 'package:ecommerce_app/features/checkout/domain/usecases/process_payment.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'checkout_event.dart';
part 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final ProcessPayment processPayment;
  final CartBloc cartBloc;

  CheckoutBloc({
    required this.processPayment,
    required this.cartBloc,
  }) : super(CheckoutInitial()) {
    on<ProcessPaymentEvent>(_processPayment);
  }

  Future<void> _processPayment(
    ProcessPaymentEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());
    
    final result = await processPayment(
      items: event.items,
      total: event.total,
    );

    result.fold(
      (failure) => emit(CheckoutError(message: failure.message ?? 'Payment failed')),
      (order) {
        cartBloc.add(ClearCartEvent());
        emit(CheckoutSuccess(order));
      },
    );
  }
}