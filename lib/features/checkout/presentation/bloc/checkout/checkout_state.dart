part of 'checkout_bloc.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class PaymentMethodSelected extends CheckoutState {
  final String paymentMethod;

  const PaymentMethodSelected(this.paymentMethod);

  @override
  List<Object> get props => [paymentMethod];
}

class VerificationCodeSent extends CheckoutState {
  final String paymentId;
  final String userEmail;
  final List<CartItem> items;
  final double total;

  const VerificationCodeSent({
    required this.paymentId,
    required this.userEmail,
    required this.items,
    required this.total,
  });

  @override
  List<Object> get props => [paymentId, userEmail, items, total];
}

class VerificationCompleted extends CheckoutState {
  final String paymentId;
  final List<CartItem> items;
  final double total;

  const VerificationCompleted({
    required this.paymentId,
    required this.items,
    required this.total,
  });

  @override
  List<Object> get props => [paymentId, items, total];
}

class CheckoutLoading extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {
  final PurchaseOrder order;

  const CheckoutSuccess(this.order);

  @override
  List<Object> get props => [order];
}

class CheckoutError extends CheckoutState {
  final String message;

  const CheckoutError(this.message);

  @override
  List<Object> get props => [message];
}