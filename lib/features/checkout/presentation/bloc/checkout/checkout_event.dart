part of 'checkout_bloc.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object> get props => [];
}

class ProcessPaymentEvent extends CheckoutEvent {
  final List<CartItem> items;
  final double total;

  const ProcessPaymentEvent({
    required this.items,
    required this.total,
  });

  @override
  List<Object> get props => [items, total];
}