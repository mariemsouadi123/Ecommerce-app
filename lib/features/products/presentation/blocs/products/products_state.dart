import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:equatable/equatable.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();
}

class ProductsLoading extends ProductsState {
  @override List<Object> get props => [];
}

class ProductsLoaded extends ProductsState {
  final List<Product> allProducts;
  final List<Product> filteredProducts;
  final String currentCategory;
  final String currentSearchQuery;

  const ProductsLoaded({
    required this.allProducts,
    required this.filteredProducts,
    this.currentCategory = 'All',
    this.currentSearchQuery = '',
  });

  @override
  List<Object> get props => [
        allProducts,
        filteredProducts,
        currentCategory,
        currentSearchQuery,
      ];

  ProductsLoaded copyWith({
    List<Product>? allProducts,
    List<Product>? filteredProducts,
    String? currentCategory,
    String? currentSearchQuery,
  }) {
    return ProductsLoaded(
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      currentCategory: currentCategory ?? this.currentCategory,
      currentSearchQuery: currentSearchQuery ?? this.currentSearchQuery,
    );
  }
}
