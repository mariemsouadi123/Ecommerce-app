import 'package:ecommerce_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.brown.shade800,
      ),
      body: Stack(
        children: [
          // Animated background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.brown.shade100,
                  Colors.brown.shade50,
                  Colors.brown.shade100,
                ],
              ),
            ),
          ).animate().fadeIn(),
          
          // Content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Animated title
                    Text('Create Your Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade800,
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideY(begin: -0.2),
                    
                    const SizedBox(height: 40),
                    
                    // Name field
                    _buildAnimatedTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      delay: 300.ms,
                      validator: (value) => 
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Email field
                    _buildAnimatedTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      delay: 400.ms,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required';
                        if (!value!.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Password field
                    _buildAnimatedTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outlined,
                      obscureText: true,
                      delay: 500.ms,
                      validator: (value) => 
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Address field
                    _buildAnimatedTextField(
                      controller: _addressController,
                      label: 'Address',
                      icon: Icons.home_outlined,
                      delay: 600.ms,
                      validator: (value) => 
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Phone field
                    _buildAnimatedTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      delay: 700.ms,
                      validator: (value) => 
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Register button
                    BlocListener<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthLoading) {
                          setState(() => _isLoading = true);
                        } else {
                          setState(() => _isLoading = false);
                        }
                        if (state is Authenticated) Navigator.pop(context);
                        if (state is AuthError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                        }
                      },
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () {
                          if (_formKey.currentState?.validate() ?? false) {
                            context.read<AuthBloc>().add(RegisterEvent(
                              name: _nameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                              address: _addressController.text,
                              phone: _phoneController.text,
                            ));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          shadowColor: Colors.brown.shade300,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : Text('REGISTER',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown.shade50,
                                ),
                              ),
                      )
                      .animate()
                      .fadeIn(delay: 800.ms)
                      .slideY(begin: 0.5),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Login link
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text.rich(
                          TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(color: Colors.brown.shade600),
                            children: [
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 900.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Duration delay,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.brown.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.brown.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.brown.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.brown.shade700, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.brown.shade600),
      ),
    )
    .animate()
    .fadeIn(delay: delay)
    .slideX(begin: -0.2);
  }
}