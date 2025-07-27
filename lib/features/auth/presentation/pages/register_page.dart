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
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF5E3023),
        iconTheme: const IconThemeData(color: Color(0xFF5E3023)),
      ),
      body: Stack(
        children: [
          // Animated gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFEE3BC), // Light beige
                  const Color(0xFFFFF9F0), // Off-white
                  const Color(0xFFFEE3BC), // Light beige
                ],
              ),
            ),
          ).animate().fadeIn(),
          
          // Decorative elements
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFD88C9A).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ).animate().scale(delay: 200.ms, duration: 1000.ms),
          ),
          
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ).animate().scale(delay: 300.ms, duration: 1000.ms),
          ),
          
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
                    
                    // Logo
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://maison-kayser.com/wp-content/themes/kayser/images/international_logo.png',
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                    .animate()
                    .scale(delay: 200.ms)
                    .fadeIn(),
                    
                    const SizedBox(height: 30),
                    
                    // Title with artistic typography
                    Text('Create Your Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5E3023),
                        letterSpacing: 1.1,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .slideY(begin: -0.2),
                    
                    const SizedBox(height: 40),
                    
                    // Name field
                    _buildAnimatedTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      delay: 400.ms,
                      validator: (value) => 
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Email field
                    _buildAnimatedTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      delay: 500.ms,
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
                      delay: 600.ms,
                      validator: (value) => 
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Address field
                    _buildAnimatedTextField(
                      controller: _addressController,
                      label: 'Address',
                      icon: Icons.home_outlined,
                      delay: 700.ms,
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
                      delay: 800.ms,
                      validator: (value) => 
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Register button with artistic design
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
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: const Color(0xFFC8553D),
                            ),
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
                          backgroundColor: const Color(0xFFFF6B35), // Red-orange
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          shadowColor: const Color(0xFFFF6B35).withOpacity(0.4),
                          animationDuration: const Duration(milliseconds: 300),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              )
                            : Text('CREATE ACCOUNT',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.1,
                                ),
                              ),
                      )
                      .animate()
                      .fadeIn(delay: 900.ms)
                      .slideY(begin: 0.5)
                      .shimmer(delay: 1200.ms, duration: 800.ms),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Login link with artistic design
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text.rich(
                          TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(
                              color: const Color(0xFF5E3023).withOpacity(0.7),
                              fontSize: 15,
                            ),
                            children: [
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFF6B35),
                                  fontSize: 15,
                                  decoration: TextDecoration.underline,
                                  decorationColor: const Color(0xFFFF6B35),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 1000.ms),
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
      style: TextStyle(color: const Color(0xFF5E3023)),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF5E3023).withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF5E3023).withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF5E3023).withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
        ),
        labelStyle: TextStyle(
          color: const Color(0xFF5E3023).withOpacity(0.7),
        ),
        floatingLabelStyle: const TextStyle(color: Color(0xFFFF6B35)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    )
    .animate()
    .fadeIn(delay: delay)
    .slideX(begin: -0.2);
  }
}