import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/presentation/bloc/cart/cart_bloc.dart';
import 'package:ecommerce_app/features/checkout/domain/entities/PurchaseOrder.dart';
import 'package:ecommerce_app/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:ecommerce_app/features/checkout/domain/usecases/process_payment.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'checkout_event.dart';
part 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final ProcessPayment processPayment;
  final CartBloc cartBloc;
  final CheckoutRepository repository;
  final GetCurrentUserUseCase getCurrentUser;

  CheckoutBloc({
    required this.processPayment,
    required this.cartBloc,
    required this.repository,
required this.getCurrentUser,
  }) : super(CheckoutInitial()) {
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
    on<SubmitPaymentDetails>(_onSubmitPaymentDetails);
    on<SubmitVerificationCode>(_onSubmitVerificationCode);
    on<ResendVerificationCode>(_onResendVerificationCode);
    on<CompleteOrder>(_onCompleteOrder);
  }

  Future<void> _onSelectPaymentMethod(
    SelectPaymentMethod event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(PaymentMethodSelected(event.paymentMethod));
  }

Future<void> _onSubmitPaymentDetails(
  SubmitPaymentDetails event,
  Emitter<CheckoutState> emit,
) async {
  emit(CheckoutLoading());
  
  try {
    final result = await repository.initiatePayment(
      amount: event.total,
      paymentMethod: 'credit_card',
      cardNumber: event.cardNumber,
      expiryDate: event.expiryDate,
      cvc: event.cvc,
      userEmail: event.userEmail, // Use the passed email
    );

    result.fold(
      (failure) => emit(CheckoutError(failure.message ?? 'Payment failed')),
      (paymentId) => emit(VerificationCodeSent(
        paymentId: paymentId,
        userEmail: event.userEmail, // Use the same email
        items: event.items,
        total: event.total,
      )),
    );
  } catch (e) {
    emit(CheckoutError('Failed to process payment: ${e.toString()}'));
  }
}
  Future<void> _onSubmitVerificationCode(
    SubmitVerificationCode event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());
    
    final result = await repository.verifyPayment(
      paymentId: event.paymentId,
      verificationCode: event.code,
    );

    result.fold(
      (failure) => emit(CheckoutError(failure.message ?? 'Verification failed')),
      (success) {
        if (success) {
          emit(VerificationCompleted(
            paymentId: event.paymentId,
            items: (state as VerificationCodeSent).items,
            total: (state as VerificationCodeSent).total,
          ));
        } else {
          emit(CheckoutError('Invalid verification code'));
        }
      },
    );
  }

  Future<void> _onResendVerificationCode(
    ResendVerificationCode event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());
    
    final result = await repository.resendVerificationCode(
      paymentId: event.paymentId,
      userEmail: event.userEmail,
    );

    result.fold(
      (failure) => emit(CheckoutError(failure.message ?? 'Failed to resend code')),
      (success) => emit(VerificationCodeSent(
        paymentId: event.paymentId,
        userEmail: event.userEmail,
        items: (state as VerificationCodeSent).items,
        total: (state as VerificationCodeSent).total,
      )),
    );
  }

  Future<void> _onCompleteOrder(
    CompleteOrder event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());
    
    final paymentMethod = state is PaymentMethodSelected 
        ? (state as PaymentMethodSelected).paymentMethod 
        : 'credit_card';

    final result = await processPayment(
      items: event.items,
      total: event.total,
      paymentMethod: paymentMethod,
    );

    result.fold(
      (failure) => emit(CheckoutError(failure.message ?? 'Order failed')),
      (order) {
        cartBloc.add(ClearCartEvent());
        emit(CheckoutSuccess(order));
      },
    );
  }
}