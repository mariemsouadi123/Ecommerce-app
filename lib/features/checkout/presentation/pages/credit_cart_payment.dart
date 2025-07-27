import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/checkout/presentation/bloc/checkout/checkout_bloc.dart';
import 'package:ecommerce_app/features/checkout/presentation/pages/verification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreditCardPaymentPage extends StatefulWidget {
  final List<CartItem> items;
  final double total;
  final String userEmail;

  const CreditCardPaymentPage({
    Key? key,
    required this.items,
    required this.total,
    required this.userEmail,
  }) : super(key: key);

  @override
  _CreditCardPaymentPageState createState() => _CreditCardPaymentPageState();
}

class _CreditCardPaymentPageState extends State<CreditCardPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvcController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        if (state is VerificationCodeSent) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VerificationPage(
                paymentId: state.paymentId,
                userEmail: state.userEmail,
                items: state.items,
                total: state.total,
              ),
            ),
          );
        } else if (state is CheckoutError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Credit Card Payment')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _cardNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Card Number',
                      hintText: '4242 4242 4242 4242',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter card number';
                      }
                      if (!RegExp(r'^[0-9]{16}$').hasMatch(value.replaceAll(' ', ''))) {
                        return 'Invalid card number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expiryDateController,
                          decoration: const InputDecoration(
                            labelText: 'Expiry Date',
                            hintText: 'MM/YY',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter expiry date';
                            }
                            if (!RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$').hasMatch(value)) {
                              return 'Invalid expiry date';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _cvcController,
                          decoration: const InputDecoration(
                            labelText: 'CVC',
                            hintText: '123',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter CVC';
                            }
                            if (!RegExp(r'^[0-9]{3,4}$').hasMatch(value)) {
                              return 'Invalid CVC';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: state is CheckoutLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<CheckoutBloc>().add(
                                SubmitPaymentDetails(
                                  cardNumber: _cardNumberController.text,
                                  expiryDate: _expiryDateController.text,
                                  cvc: _cvcController.text,
                                  total: widget.total,
                                  userEmail: widget.userEmail,
                                  items: widget.items,
                                ),
                              );
                            }
                          },
                    child: state is CheckoutLoading
                        ? const CircularProgressIndicator()
                        : const Text('CONTINUE TO VERIFICATION'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}