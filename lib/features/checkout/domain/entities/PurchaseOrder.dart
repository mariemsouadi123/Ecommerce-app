import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:equatable/equatable.dart';

class PurchaseOrder extends Equatable {
  final String id;
  final List<CartItem> items;
  final double total;
  final DateTime date;
  final String status;

  const PurchaseOrder({
    required this.id,
    required this.items,
    required this.total,
    required this.date,
    this.status = 'completed',
  });

  @override
  List<Object> get props => [id, items, total, date, status];

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'] ?? json['_id'],
      items: (json['items'] as List).map((item) => CartItem(
        product: Product(
          id: item['product'] is String ? item['product'] : item['product']['_id'],
          name: item['name'],
          price: (item['price'] as num).toDouble(),
          description: '',
          category: '',
          stock: 0,
          imageUrl: '',
        ),
        quantity: item['quantity'],
      )).toList(),
      total: (json['total'] as num).toDouble(),
      date: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'completed',
    );
  }
}