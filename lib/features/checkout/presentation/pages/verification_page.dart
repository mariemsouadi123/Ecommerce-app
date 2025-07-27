import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/checkout/presentation/bloc/checkout/checkout_bloc.dart';
import 'package:ecommerce_app/features/checkout/presentation/pages/payment_success_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerificationPage extends StatefulWidget {
  final String paymentId;
  final String userEmail;
  final List<CartItem> items;
  final double total;

  const VerificationPage({
    Key? key,
    required this.paymentId,
    required this.userEmail,
    required this.items,
    required this.total,
  }) : super(key: key);

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutBloc, CheckoutState>(
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
        return Scaffold(
          appBar: AppBar(title: const Text('Verify Payment')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'We sent a verification code to ${widget.userEmail}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      labelText: 'Verification Code',
                      hintText: 'Enter 6-digit code',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter verification code';
                      }
                      if (value.length != 6) {
                        return 'Code must be 6 digits';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: state is CheckoutLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<CheckoutBloc>().add(
                                SubmitVerificationCode(
                                  code: _codeController.text,
                                  paymentId: widget.paymentId,
                                ),
                              );
                            }
                          },
                    child: state is CheckoutLoading
                        ? CircularProgressIndicator()
                        : Text('VERIFY PAYMENT'),
                  ),
                  TextButton(
                    onPressed: state is CheckoutLoading
                        ? null
                        : () {
                            context.read<CheckoutBloc>().add(
                              ResendVerificationCode(
                                paymentId: widget.paymentId,
                                userEmail: widget.userEmail,
                              ),
                            );
                          },
                    child: Text('Resend Code'),
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