import 'dart:convert';
import 'package:ecommerce_app/features/cart/presentation/bloc/cart/cart_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/checkout/domain/entities/PurchaseOrder.dart';
import 'package:ecommerce_app/features/checkout/presentation/pages/payment_success_page.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CheckoutPage extends StatelessWidget {
  final List<CartItem> items;
  final double total;
  final String userEmail;

  const CheckoutPage({
    Key? key,
    required this.items,
    required this.total,
    required this.userEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xFFFEE3BC),
        elevation: 0,
        foregroundColor: const Color(0xFF5E3023),
      ),
      backgroundColor: const Color(0xFFFEE3BC),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(child: _buildOrderSummary()),
            _buildPaymentButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5E3023),
              ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.product.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: const Icon(Icons.error),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5E3023),
                              ),
                            ),
                            Text(
                              'Qty: ${item.quantity}',
                              style: TextStyle(
                                color: const Color(0xFF5E3023).withOpacity(0.6),
                            ),
                        )],
                        ),
                      ),
                      Text(
                        '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5E3023),
                        ),
                      ),
                    ],
                  ),
                )),
            const Divider(
              color: Color(0xFF5E3023),
              thickness: 0.2,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5E3023),
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5E3023),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xFF5E3023),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => _processPayment(context),
        child: const Text(
          'COMPLETE PAYMENT',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Future<void> _processPayment(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'items': items
              .map((item) => {
                    'productId': item.product.id,
                    'name': item.product.name,
                    'price': item.product.price,
                    'quantity': item.quantity,
                  })
              .toList(),
          'total': total,
          'userEmail': userEmail,
          'paymentMethod': 'credit_card',
        }),
      );

      if (response.statusCode == 201) {
        final orderData = jsonDecode(response.body);

        // Clear the cart before navigation
        context.read<CartBloc>().add(ClearCartEvent());

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSuccessPage(
              order: PurchaseOrder.fromJson(orderData['order']),
            ),
          ),
        );
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Payment failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: const Color(0xFFC8553D),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: const Color(0xFFC8553D),
        ),
      );
    }
  }
}