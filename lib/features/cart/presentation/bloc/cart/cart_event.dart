part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class AddProductToCartEvent extends CartEvent {
  final Product product;

  const AddProductToCartEvent(this.product);

  @override
  List<Object> get props => [product];
}
class CheckoutCartEvent extends CartEvent {
  final List<CartItem> items;
  final double total;

  const CheckoutCartEvent({required this.items, required this.total});

  @override
  List<Object> get props => [items, total];
}

// Add to cart_event.dart
class RemoveProductFromCartEvent extends CartEvent {
  final Product product;

  const RemoveProductFromCartEvent(this.product);

  @override
  List<Object> get props => [product];
}
class LoadCartEvent extends CartEvent {}