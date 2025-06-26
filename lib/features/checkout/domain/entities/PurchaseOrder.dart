import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';

class PurchaseOrder {
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
    required this.status,
  });
}