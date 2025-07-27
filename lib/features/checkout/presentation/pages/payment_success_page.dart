import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce_app/features/cart/presentation/bloc/cart/cart_bloc.dart';
import 'package:ecommerce_app/features/checkout/domain/entities/PurchaseOrder.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PaymentSuccessPage extends StatelessWidget {
  final PurchaseOrder order;

  const PaymentSuccessPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Payment Successful'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF5E3023),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFEE3BC), Color(0xFFFFF0E5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 80,
                    ).animate().scale(delay: 200.ms),
                    const SizedBox(height: 24),
                    const Text(
                      'Payment Successful!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5E3023),
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 16),
                    Text(
                      'Order #${order.id}',
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFF5E3023).withOpacity(0.8),
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 8),
                    Text(
                      '\$${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5E3023),
                      ),
                    ).animate().fadeIn(delay: 500.ms),
                    const SizedBox(height: 24),
                    Text(
                      'Thank you for your purchase!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFF5E3023).withOpacity(0.8),
                      ),
                    ).animate().fadeIn(delay: 600.ms),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF5E3023),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                        child: const Text(
                          'Continue Shopping',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 700.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
