import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/presentation/bloc/cart/cart_bloc.dart';
import 'package:ecommerce_app/features/cart/presentation/pages/checkout_page.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CartBloc>().add(LoadCartEvent());
            },
          ),
        ],
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is CartLoaded) {
            if (state.items.isEmpty) {
              return const Center(child: Text('Your cart is empty'));
            }
            
            final total = state.items.fold<double>(
              0,
              (sum, item) => sum + (item.product.price * item.quantity),
            );

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return Slidable(
                        key: ValueKey(item.product.id),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                _removeItem(context, item.product);
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Remove',
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Image.network(
                            item.product.imageUrl,
                            width: 50,
                            height: 50,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error),
                          ),
                          title: Text(item.product.name),
                          subtitle: Text('Quantity: ${item.quantity}'),
                          trailing: Text(
                            '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _handleCheckout(context, state.items, total);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Checkout'),
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

  void _handleCheckout(BuildContext context, List<CartItem> items, double total) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to proceed with this order?'),
            const SizedBox(height: 16),
            Text('Total: \$${total.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); 
              _proceedToCheckout(context, items, total);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout(BuildContext context, List<CartItem> items, double total) {
    context.read<CartBloc>().add(CheckoutCartEvent(items: items, total: total));
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(items: items, total: total),
      ),
    );
  }
}