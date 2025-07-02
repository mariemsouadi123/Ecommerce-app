import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/checkout/domain/entities/PurchaseOrder.dart';
import 'package:ecommerce_app/features/checkout/domain/usecases/process_payment.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'checkout_event.dart';
part 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final ProcessPayment processPayment;

  CheckoutBloc({required this.processPayment}) : super(CheckoutInitial()) {
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
      (order) => emit(CheckoutSuccess(order)),
    );
  }
}