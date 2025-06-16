import 'package:ecommerce_app/features/products/presentation/blocs/products/products_bloc.dart';
import 'package:ecommerce_app/features/products/presentation/widgets/product_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductsPage extends StatelessWidget {
  
  const ProductsPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppbar() => AppBar(title: const Text('Products'));

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          if (state is LoadingProductsState) {
            return const Center(child: CircularProgressIndicator()); // Replaced LoadingWidget
          } else if (state is LoadedProductsState) {
            return RefreshIndicator(
              onRefresh: () => _onRefresh(context),
              child: ProductListWidget(products: state.products),
            );
          } else if (state is ErrorProductsState) {
            return Center( 
              child: Text(
                state.message,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<void> _onRefresh(BuildContext context) async {
    BlocProvider.of<ProductsBloc>(context).add(RefreshProductsEvent());
  }
}