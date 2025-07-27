import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/presentation/bloc/cart/cart_bloc.dart';
import 'package:ecommerce_app/features/checkout/presentation/pages/checkout_page.dart';
import 'package:ecommerce_app/features/favorites/presentation/bloc/favorite/favorite_bloc.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int quantity = 1;
  final PageController _imageController = PageController();
  int _currentImageIndex = 0;
  
  get userEmail => userEmail;

  void increaseQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          BlocBuilder<FavoriteBloc, FavoriteState>(
            builder: (context, state) {
              final isFavorite = state is FavoritesLoaded 
                  ? state.favorites.any((fav) => fav.product.id == widget.product.id)
                  : false;
              
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey<bool>(isFavorite),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                    ),
                  ),
                  onPressed: () {
                    if (isFavorite) {
                      context.read<FavoriteBloc>().add(
                        RemoveFromFavoritesEvent(widget.product),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Removed ${widget.product.name} from favorites'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    } else {
                      context.read<FavoriteBloc>().add(
                        AddToFavoritesEvent(widget.product),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added ${widget.product.name} to favorites'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Product Image Carousel
                SizedBox(
                  height: size.height * 0.4,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _imageController,
                        itemCount: 3, // Replace with actual image count
                        onPageChanged: (index) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Image.network(
                            widget.product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(Icons.image_not_supported, 
                                size: 100, 
                                color: Colors.grey[400]),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _currentImageIndex == index ? 24 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: _currentImageIndex == index 
                                  ? theme.primaryColor 
                                  : Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                theme.scaffoldBackgroundColor,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Product Details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name and Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.product.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '\$${widget.product.price.toStringAsFixed(2)}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Rating and Stock Status
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: 4.5,
                            itemBuilder: (context, index) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 20,
                            unratedColor: Colors.amber.withAlpha(50),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '4.5',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: widget.product.stock > 0 
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.product.stock > 0 ? 'In Stock' : 'Out of Stock',
                              style: TextStyle(
                                color: widget.product.stock > 0 
                                  ? Colors.green 
                                  : Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Product Details Section
                      _buildSectionTitle('Product Details'),
                      const SizedBox(height: 12),
                      Text(
                        widget.product.description ?? 'No description available',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Quantity Selector
                      _buildSectionTitle('Quantity'),
                      const SizedBox(height: 12),
                      Container(
                        width: 140,
                        decoration: BoxDecoration(
                          color: isDarkMode 
                            ? Colors.grey[800] 
                            : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: decreaseQuantity,
                              splashRadius: 20,
                            ),
                            Text(
                              quantity.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: increaseQuantity,
                              splashRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80), // Space for the button
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: BlocConsumer<CartBloc, CartState>(
                listener: (context, state) {
                  if (state is CartLoaded && state.items.isNotEmpty) {
                    // Show success message when items are added
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added $quantity ${widget.product.name} to cart'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final itemCount = state is CartLoaded 
                      ? state.items.fold(0, (sum, item) => sum + item.quantity) 
                      : 0;
                  
                  return Row(
                    children: [
                      // Cart Icon with Badge
                      InkWell(
                        onTap: () {
                          if (state is CartLoaded && state.items.isNotEmpty) {
                            final total = state.items.fold(
                              0.0, 
                              (sum, item) => sum + (item.product.price * item.quantity)
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutPage(
                                  items: state.items,
                                  total: total, userEmail: userEmail,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Your cart is empty'),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDarkMode 
                              ? Colors.grey[800] 
                              : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Badge(
                            isLabelVisible: itemCount > 0,
                            label: Text(itemCount.toString()),
                            child: const Icon(Icons.shopping_cart_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Add to Cart Button
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: widget.product.stock > 0
                                ? () {
                                    // Add items to cart
                                    for (int i = 0; i < quantity; i++) {
                                      context.read<CartBloc>().add(
                                        AddProductToCartEvent(widget.product),
                                      );
                                    }
                                  }
                                : null,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.product.stock > 0 ? 'ADD TO CART' : 'OUT OF STOCK',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (widget.product.stock > 0) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 18),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}