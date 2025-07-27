part of 'checkout_bloc.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object> get props => [];
}

class SelectPaymentMethod extends CheckoutEvent {
  final String paymentMethod;

  const SelectPaymentMethod(this.paymentMethod);

  @override
  List<Object> get props => [paymentMethod];
}

class SubmitPaymentDetails extends CheckoutEvent {
  final String cardNumber;
  final String expiryDate;
  final String cvc;
  final double total;
  final String userEmail; // Make this required
  final List<CartItem> items;

  const SubmitPaymentDetails({
    required this.cardNumber,
    required this.expiryDate,
    required this.cvc,
    required this.total,
    required this.userEmail, // Required parameter
    required this.items,
  });

  @override
  List<Object> get props => [cardNumber, expiryDate, cvc, total, userEmail, items];
}

class SubmitVerificationCode extends CheckoutEvent {
  final String code;
  final String paymentId;

  const SubmitVerificationCode({
    required this.code,
    required this.paymentId,
  });

  @override
  List<Object> get props => [code, paymentId];
}

class ResendVerificationCode extends CheckoutEvent {
  final String paymentId;
  final String userEmail;

  const ResendVerificationCode({
    required this.paymentId,
    required this.userEmail,
  });

  @override
  List<Object> get props => [paymentId, userEmail];
}

class CompleteOrder extends CheckoutEvent {
  final List<CartItem> items;
  final double total;
  final String paymentMethod;

  const CompleteOrder({
    required this.items,
    required this.total,
    this.paymentMethod = 'credit_card',
  });

  @override
  List<Object> get props => [items, total, paymentMethod];
}