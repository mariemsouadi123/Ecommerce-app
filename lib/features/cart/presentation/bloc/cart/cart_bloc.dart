import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/core/strings/failures.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/domain/usecases/add_product_to_crt.dart';
import 'package:ecommerce_app/features/cart/domain/usecases/get_cart_items.dart';

import 'package:ecommerce_app/features/cart/domain/usecases/checkout_cart.dart';
import 'package:ecommerce_app/features/cart/domain/usecases/remove_product_from_cart.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:equatable/equatable.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final AddProductToCartUseCase addProductToCart;
  final GetCartItemsUseCase getCartItems;
  final CheckoutCartUseCase checkoutCart;
  final RemoveProductFromCartUseCase removeProductFromCart; // Add this


  CartBloc({
    required this.addProductToCart,
    required this.getCartItems,
    required this.removeProductFromCart,
    required this.checkoutCart,
  }) : super(CartInitial()) {
    on<AddProductToCartEvent>(_onAddProductToCart);
    on<LoadCartEvent>(_onLoadCart);
  
    on<CheckoutCartEvent>(_onCheckoutCart);
    on<RemoveProductFromCartEvent>(_onRemoveProductFromCart);
  }

  Future<void> _onAddProductToCart(
    AddProductToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    final failureOrSuccess = await addProductToCart(event.product);
    failureOrSuccess.fold(
      (failure) => emit(CartError(message: _mapFailureToMessage(failure))),
      (_) => add(LoadCartEvent()),
    );
  }

  Future<void> _onLoadCart(
    LoadCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    final failureOrCartItems = await getCartItems();
    failureOrCartItems.fold(
      (failure) => emit(CartError(message: _mapFailureToMessage(failure))),
      (items) => emit(CartLoaded(items: items)),
    );
  }

  
  Future<void> _onCheckoutCart(
    CheckoutCartEvent event,
    Emitter<CartState> emit,
  ) async {
    if (state is! CartLoaded) return;
    
    final currentItems = (state as CartLoaded).items;
    if (currentItems.isEmpty) {
      emit(CartError(message: 'Cart is empty'));
      return;
    }

    emit(CartLoading());
    final failureOrSuccess = await checkoutCart(currentItems);
    failureOrSuccess.fold(
      (failure) => emit(CartError(message: _mapFailureToMessage(failure))),
      (_) {
        emit(CartCheckoutSuccess());
        emit(CartLoaded(items: [])); 
      },
    );
  }
  Future<void> _onRemoveProductFromCart(
    RemoveProductFromCartEvent event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartLoaded) {
      emit(CartLoading());
      final failureOrSuccess = await removeProductFromCart(event.product);
      failureOrSuccess.fold(
        (failure) => emit(CartError(message: _mapFailureToMessage(failure))),
        (_) => add(LoadCartEvent()),
      );
    }
  }
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case EmptyCacheFailure:
        return EMPTY_CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected error';
    }
  }
}