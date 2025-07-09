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
  LoadProductsByCategoryEvent(this.category);
}

class SearchProductsEvent extends ProductsEvent {
  final String query;
  SearchProductsEvent(this.query);
}
