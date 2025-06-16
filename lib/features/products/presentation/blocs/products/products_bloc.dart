import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/features/products/domain/usecases/get_all_products.dart';
import 'package:equatable/equatable.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GetAllProductsUseCase getAllProducts;

  ProductsBloc({required this.getAllProducts}) : super(ProductsInitial()) {
    on<ProductsEvent>((event, emit) async {
      if (event is GetAllProductsEvent || event is RefreshProductsEvent) {
        await _handleGetProductsEvent(event, emit);
      }
    });
  }

  Future<void> _handleGetProductsEvent(
      ProductsEvent event, Emitter<ProductsState> emit) async {
    emit(LoadingProductsState());

    final failureOrProducts = await getAllProducts();
    emit(_mapFailureOrProductsToState(failureOrProducts));
  }

  ProductsState _mapFailureOrProductsToState(
      Either<Failure, List<Product>> failureOrProducts) {
    return failureOrProducts.fold(
      (failure) => ErrorProductsState(message: _mapFailureToMessage(failure)),
      (products) => LoadedProductsState(products: products),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return "Server failure, please try again later";
      case EmptyCacheFailure:
        return "No cached data available";
      case OfflineFailure:
        return "No internet connection";
      case NotFoundFailure:
        return "Product not found";
      default:
        return "Unexpected error, please try again later";
    }
  }
}