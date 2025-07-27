import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/core/strings/failures.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/domain/usecases/add_product_to_crt.dart';
import 'package:ecommerce_app/features/cart/domain/usecases/get_cart_items.dart';
import 'package:ecommerce_app/features/cart/domain/usecases/remove_product_from_cart.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  List<CartItem> _cartItems = []; 

  CartBloc() : super(CartInitial()) {
    on<AddProductToCartEvent>(_onAddProductToCart);
    on<LoadCartEvent>(_onLoadCart);
    on<RemoveProductFromCartEvent>(_onRemoveProductFromCart);
    on<ClearCartEvent>(_onClearCart); // Add this line

  }

  Future<void> _onAddProductToCart(
    AddProductToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    try {
      final existingIndex = _cartItems.indexWhere(
        (item) => item.product.name == event.product.name,
      );

      if (existingIndex >= 0) {
        _cartItems[existingIndex] = CartItem(
          product: _cartItems[existingIndex].product,
          quantity: _cartItems[existingIndex].quantity + 1,
        );
      } else {
        _cartItems.add(CartItem(product: event.product, quantity: 1));
      }
      
      emit(CartLoaded(items: List.unmodifiable(_cartItems)));
    } catch (e) {
      emit(CartError(message: _mapFailureToMessage(EmptyCacheFailure())));
    }
  }

  Future<void> _onLoadCart(
    LoadCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    try {
      if (_cartItems.isEmpty) {
        emit(CartError(message: 'Cart is empty'));
      } else {
        emit(CartLoaded(items: List.unmodifiable(_cartItems)));
      }
    } catch (e) {
      emit(CartError(message: _mapFailureToMessage(EmptyCacheFailure())));
    }
  }

  Future<void> _onRemoveProductFromCart(
    RemoveProductFromCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    try {
      final existingIndex = _cartItems.indexWhere(
        (item) => item.product.name == event.product.name,
      );

      if (existingIndex >= 0) {
        if (_cartItems[existingIndex].quantity > 1) {
          _cartItems[existingIndex] = CartItem(
            product: _cartItems[existingIndex].product,
            quantity: _cartItems[existingIndex].quantity - 1,
          );
        } else {
          _cartItems.removeAt(existingIndex);
        }
      }
      
      emit(CartLoaded(items: List.unmodifiable(_cartItems)));
    } catch (e) {
      emit(CartError(message: _mapFailureToMessage(EmptyCacheFailure())));
    }
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is EmptyCacheFailure) {
      return failure.message ?? EMPTY_CACHE_FAILURE_MESSAGE;
    }
    return 'Unexpected error';
  }
  // In your CartBloc class
Future<void> _onClearCart(
  ClearCartEvent event,
  Emitter<CartState> emit,
) async {
  emit(CartLoading());
  _cartItems.clear();
  emit(CartLoaded(items: List.from(_cartItems))); // Emit empty cart
}
}