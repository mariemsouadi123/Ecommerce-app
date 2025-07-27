import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:equatable/equatable.dart';

class PurchaseOrder extends Equatable {
  final String id;
  final double total;
  final DateTime date;
  final String status;
  final String paymentMethod;

  const PurchaseOrder({
    required this.id,
    required this.total,
    required this.date,
    this.status = 'completed',
    this.paymentMethod = 'credit_card',
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['_id'] ?? json['id'] ?? '', // Handle both _id and id fields
      total: (json['total'] as num?)?.toDouble() ?? 0.0, // Null-safe conversion
      date: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(), // Fallback to current time
      status: json['status'] ?? 'completed',
      paymentMethod: json['paymentMethod'] ?? 'credit_card',
    );
  }

  @override
  List<Object> get props => [id, total, date, status, paymentMethod];
}