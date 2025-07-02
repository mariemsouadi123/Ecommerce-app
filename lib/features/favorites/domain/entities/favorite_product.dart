import 'package:equatable/equatable.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

class FavoriteProduct extends Equatable {
  final Product product;
  final DateTime addedAt;

  const FavoriteProduct({
    required this.product,
    required this.addedAt,
  });

  @override
  List<Object> get props => [product.name, addedAt]; 
}