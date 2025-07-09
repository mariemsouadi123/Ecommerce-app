import 'package:ecommerce_app/features/cart/presentation/bloc/cart/cart_bloc.dart';
import 'package:ecommerce_app/features/favorites/presentation/bloc/favorite/favorite_bloc.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/features/products/presentation/blocs/products/products_bloc.dart';
import 'package:ecommerce_app/features/products/presentation/blocs/products/products_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductListWidget extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onFavoritePressed;
  final bool Function(Product) isFavorite;

  const ProductListWidget({
    super.key,
    required this.products,
    required this.onFavoritePressed,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCategoryFilter(context),
        _buildProductGrid(context),
      ],
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        if (state is! ProductsLoaded) return const SizedBox.shrink();
        
        return SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryChip(context, 'All', state.currentCategory == 'All'),
              _buildCategoryChip(context, 'Clothes', state.currentCategory == 'Clothes'),
              _buildCategoryChip(context, 'Make_Up', state.currentCategory == 'Make_Up'),
              _buildCategoryChip(context, 'SkinCare', state.currentCategory == 'SkinCare'),
              _buildCategoryChip(context, 'Accessories', state.currentCategory == 'Accessories'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(BuildContext context, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            context.read<ProductsBloc>().add(FilterProductsByCategory(label));
          }
        },
        selectedColor: Colors.blue,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    return Expanded(
      child: BlocListener<FavoriteBloc, FavoriteState>(
        listener: (context, state) {
          if (state is FavoriteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: products.isEmpty
            ? const Center(
                child: Text(
                  'No products in this category',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _ProductCard(
                    key: ValueKey('${product.id}-${product.name}'),
                    product: product,
                    isFavorite: isFavorite(product),
                    onFavoritePressed: () => onFavoritePressed(product),
                  );
                },
              ),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;

  const _ProductCard({
    required Key key,
    required this.product,
    required this.isFavorite,
    required this.onFavoritePressed,
  }) : super(key: key);

  @override
  State<_ProductCard> createState() => _ProductCardState();
}


class _ProductCardState extends State<_ProductCard> {
  late bool _isFavorite;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  void didUpdateWidget(covariant _ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _isFavorite = widget.isFavorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: constraints.maxWidth * 1.4,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: constraints.maxWidth * 0.7,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => 
                              const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${widget.product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 24,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Stock: ${widget.product.stock}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: widget.product.stock > 0 
                                      ? Colors.green[600]
                                      : Colors.red[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildAddButton(context),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: _buildFavoriteButton(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: const Icon(Icons.add_shopping_cart),
      iconSize: 20,
      color: Theme.of(context).primaryColor,
      onPressed: () {
        context.read<CartBloc>().add(AddProductToCartEvent(widget.product));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${widget.product.name} to cart'),
            duration: const Duration(milliseconds: 800),
          ),
        );
      },
    );
  }

  Widget _buildFavoriteButton() {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: _isProcessing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.grey,
              size: 20,
            ),
      onPressed: _isProcessing
          ? null
          : () async {
              setState(() => _isProcessing = true);
              try {
                widget.onFavoritePressed();
                setState(() => _isFavorite = !_isFavorite);
              } finally {
                setState(() => _isProcessing = false);
              }
            },
    );
  }
}