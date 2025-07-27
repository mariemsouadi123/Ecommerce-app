import 'package:ecommerce_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ecommerce_app/features/checkout/presentation/bloc/checkout/checkout_bloc.dart';
import 'package:ecommerce_app/features/checkout/presentation/pages/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/presentation/bloc/cart/cart_bloc.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: const Color(0xFFFEE3BC),
        elevation: 0,
        foregroundColor: const Color(0xFF5E3023),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh),
            ),
            onPressed: () {
              context.read<CartBloc>().add(LoadCartEvent());
            },
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
      backgroundColor: const Color(0xFFFEE3BC),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFC8553D),
              ),
            );
          }
          if (state is CheckoutSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment successful!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF5E3023),
              ),
            );
          }

          if (state is CartLoaded) {
            if (state.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 60,
                      color: const Color(0xFF5E3023).withOpacity(0.3),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 18,
                        color: const Color(0xFF5E3023).withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              );
            }

            final total = state.items.fold<double>(
              0,
              (sum, item) => sum + (item.product.price * item.quantity),
            );

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Slidable(
                          key: ValueKey(item.product.id),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  _removeItem(context, item.product);
                                },
                                backgroundColor: const Color(0xFFC8553D),
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Remove',
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ],
                          ),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.product.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  item.product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5E3023),
                                  ),
                                ),
                                subtitle: Text(
                                  'Qty: ${item.quantity}',
                                  style: TextStyle(
                                    color: const Color(0xFF5E3023).withOpacity(0.6),
                                  ),
                                ),
                                trailing: Text(
                                  '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5E3023),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: (100 * index).ms),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
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
                      const SizedBox(height: 16),
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
                          onPressed: () => _handlePayment(context, state.items, total),
                          child: const Text(
                            'Proceed to Payment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Your cart is empty'));
        },
      ),
    );
  }

  void _removeItem(BuildContext context, Product product) {
    context.read<CartBloc>().add(RemoveProductFromCartEvent(product));
  }

  void _handlePayment(BuildContext context, List<CartItem> items, double total) {
    final authState = context.read<AuthBloc>().state;
    final userEmail = authState is Authenticated ? authState.user.email : '';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Confirm Payment',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5E3023),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Total Amount: \$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5E3023),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Items: ${items.length}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5E3023),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xFF5E3023)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E3023),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutPage(
                            items: items,
                            total: total,
                            userEmail: userEmail,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Confirm',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
