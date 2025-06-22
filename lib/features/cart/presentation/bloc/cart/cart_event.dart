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


class RemoveProductFromCartEvent extends CartEvent {
  final Product product;

  const RemoveProductFromCartEvent(this.product);

  @override
  List<Object> get props => [product];
}
class LoadCartEvent extends CartEvent {}