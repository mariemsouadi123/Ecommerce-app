// features/checkout/presentation/pages/payment_method_page.dart
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/checkout/presentation/bloc/checkout/checkout_bloc.dart';
import 'package:ecommerce_app/features/checkout/presentation/pages/credit_cart_payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentMethodPage extends StatelessWidget {
  final List<CartItem> items;
  final double total;
    final String userEmail; // Add this parameter


  const PaymentMethodPage({
    Key? key,
    required this.items,
    required this.total,
    required this.userEmail
  }) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Payment Method')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Choose your payment method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildPaymentOption(
              context,
              icon: Icons.credit_card,
              title: 'Credit Card',
              description: 'Pay with Visa, Mastercard, etc.',
              onTap: () => _selectPaymentMethod(context, 'credit_card'),
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              context,
              icon: Icons.phone_android,
              title: 'Espace',
              description: 'Pay with your mobile wallet',
              onTap: () => _selectPaymentMethod(context, 'espace'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.brown),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _selectPaymentMethod(BuildContext context, String method) {
    context.read<CheckoutBloc>().add(SelectPaymentMethod(method));
    
    if (method == 'credit_card') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreditCardPaymentPage(items: items, total: total,userEmail: userEmail,),
        ),
      );
    } else {
      context.read<CheckoutBloc>().add(CompleteOrder(items: items, total: total));
    }
  }
}