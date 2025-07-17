import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final double price;
  final String description;
  final String category;
  final int stock;
  
  final String imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.stock,
    required this.imageUrl,
  });

  @override
  List<Object> get props => [id, name]; 
}