// products_event.dart
part of 'products_bloc.dart';

sealed class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object> get props => [];
}

class GetAllProductsEvent extends ProductsEvent {}

class RefreshProductsEvent extends ProductsEvent {}

class LoadProductsByCategoryEvent extends ProductsEvent {
  final String category;
  const LoadProductsByCategoryEvent(this.category);

  @override
  List<Object> get props => [category];
}



class FilterProductsByCategory extends ProductsEvent {
  final String category;
  const FilterProductsByCategory(this.category);
  @override List<Object> get props => [category];
}

class SearchProducts extends ProductsEvent {
  final String query;
  const SearchProducts(this.query);
  @override List<Object> get props => [query];
}