import 'package:ecommerce_app/features/cart/presentation/bloc/cart/cart_bloc.dart';
import 'package:ecommerce_app/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductListWidget extends StatelessWidget {
  final List<Product> products;

  const ProductListWidget({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CartBloc>()..add(LoadCartEvent()),
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final itemCount = cartState is CartLoaded
                  ? cartState.items
                      .where((cartItem) => cartItem.product.id == product.id)
                      .fold<int>(0, (sum, cartItem) => sum + cartItem.quantity)
                  : 0;

              return ListTile(
                leading: Image.network(
                  product.imageUrl,
                  width: 50,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) => 
                     const Icon(Icons.error),
                ),
                title: Text(product.name),
                subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$itemCount'),
                    const SizedBox(width: 8),
                    Text('${product.stock} in stock'),
                    IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () {
                        context.read<CartBloc>().add(
                          AddProductToCartEvent(product)
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} added to cart'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}