import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/presentation/bloc/cart/cart_bloc.dart';
import 'package:ecommerce_app/features/checkout/domain/entities/PurchaseOrder.dart';
import 'package:ecommerce_app/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:ecommerce_app/features/checkout/domain/usecases/process_payment.dart';
import 'package:ecommerce_app/features/checkout/presentation/bloc/checkout/checkout_bloc.dart';
import 'package:ecommerce_app/features/checkout/presentation/pages/payment_success_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// features/checkout/presentation/pages/checkout_page.dart
class CheckoutPage extends StatelessWidget {
  final List<CartItem> items;
  final double total;

  const CheckoutPage({
    Key? key,
    required this.items,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CheckoutBloc(
        processPayment: ProcessPayment(
          context.read<CheckoutRepository>(),
        ),
        cartBloc: context.read<CartBloc>(),
      ),
      child: _CheckoutView(items: items, total: total),
    );
  }
}

class _CheckoutView extends StatefulWidget {
  final List<CartItem> items;
  final double total;

  const _CheckoutView({
    Key? key,
    required this.items,
    required this.total,
  }) : super(key: key);

  @override
  State<_CheckoutView> createState() => __CheckoutViewState();
}

class __CheckoutViewState extends State<_CheckoutView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: BlocConsumer<CheckoutBloc, CheckoutState>(
        listener: (context, state) {
          if (state is CheckoutSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentSuccessPage(order: state.order),
              ),
            );
          } else if (state is CheckoutError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is CheckoutLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(child: _buildOrderSummary()),
                _buildPaymentButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary() {
    return ListView(
      children: [
        const Text('Order Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...widget.items.map((item) => ListTile(
          leading: Image.network(item.product.imageUrl, width: 50, height: 50),
          title: Text(item.product.name),
          subtitle: Text('Qty: ${item.quantity}'),
          trailing: Text('\$${(item.product.price * item.quantity).toStringAsFixed(2)}'),
        )),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('\$${widget.total.toStringAsFixed(2)}', 
                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _confirmPayment(context),
        child: const Text('CONFIRM PAYMENT'),
      ),
    );
  }

  void _confirmPayment(BuildContext context) {
    context.read<CheckoutBloc>().add(
      ProcessPaymentEvent(
        items: widget.items,
        total: widget.total,
      ),
    );
  }
}