import 'package:ecommerce_app/features/products/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required String id,
    required String name,
    required double price,
    required String description,
    required String category,
    required int stock,
    required String imageUrl,
  }) : super(
          id: id,
          name: name,
          price: price,
          description: description,
          category: category,
          stock: stock,
          imageUrl: imageUrl,
        );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '', 
      name: json['name']?.toString() ?? 'No Name',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Other',
      stock: (json['stock'] as int?) ?? 0,
      imageUrl: json['imageUrl']?.toString() ?? 'https://via.placeholder.com/150',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'stock': stock,
      'imageUrl': imageUrl,
    };
  }
  factory ProductModel.empty() => const ProductModel(
        id: '',
        name: '',
        price: 0.0,
        description: '',
        category: '',
        stock: 0,
        imageUrl: '',
      );
  static ProductModel? fromJsonNullable(Map<String, dynamic>? json) {
    return json != null ? ProductModel.fromJson(json) : null;
  }
}