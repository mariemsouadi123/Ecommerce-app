import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/features/products/domain/usecases/get_all_products.dart';
import 'package:ecommerce_app/features/products/presentation/blocs/products/products_state.dart';
import 'package:equatable/equatable.dart';

part 'products_event.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GetAllProductsUseCase getAllProducts;

  ProductsBloc({required this.getAllProducts}) : super(ProductsLoading()) {
    on<GetAllProductsEvent>(_onGetAllProducts);
    on<FilterProductsByCategory>(_onFilterByCategory);
    on<SearchProducts>(_onSearchProducts);
  }

  Future<void> _onGetAllProducts(
    GetAllProductsEvent event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsLoading());
    final failureOrProducts = await getAllProducts();
    
    failureOrProducts.fold(
      (failure) => emit(ProductsLoaded(  // Fallback to empty lists on error
        allProducts: [],
        filteredProducts: [],
        currentCategory: 'All',
        currentSearchQuery: '',
      )),
      (products) => emit(ProductsLoaded(
        allProducts: products,
        filteredProducts: products,
        currentCategory: 'All',
        currentSearchQuery: '',
      )),
    );
  }

  void _onFilterByCategory(
    FilterProductsByCategory event,
    Emitter<ProductsState> emit,
  ) {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      final filtered = _applyFilters(
        currentState.allProducts,
        category: event.category,
        query: currentState.currentSearchQuery,
      );
      
      emit(currentState.copyWith(
        filteredProducts: filtered,
        currentCategory: event.category,
      ));
    }
  }

  void _onSearchProducts(
    SearchProducts event,
    Emitter<ProductsState> emit,
  ) {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      final filtered = _applyFilters(
        currentState.allProducts,
        category: currentState.currentCategory,
        query: event.query,
      );
      
      emit(currentState.copyWith(
        filteredProducts: filtered,
        currentSearchQuery: event.query,
      ));
    }
  }

  List<Product> _applyFilters(
    List<Product> products, {
    required String category,
    required String query,
  }) {
    var filtered = List<Product>.from(products);
    
    if (category != 'All') {
      filtered = filtered.where((p) => p.category == category).toList();
    }
    
    if (query.isNotEmpty) {
      filtered = filtered.where((p) => 
        p.name.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }
}