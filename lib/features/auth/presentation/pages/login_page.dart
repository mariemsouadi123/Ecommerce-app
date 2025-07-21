import 'package:ecommerce_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ecommerce_app/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleLoading) return;
    
    setState(() => _isGoogleLoading = true);
    try {
      context.read<AuthBloc>().add(SignInWithGoogleEvent());
    } catch (e) {
      setState(() => _isGoogleLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error during Google Sign-In')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          ).animate().fadeIn(duration: 500.ms),
          
          // Content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    
                    // Logo with animation
                    Icon(Icons.bakery_dining_outlined,
                      size: 100,
                      color: Colors.brown.shade700,
                    )
                    .animate()
                    .scale(delay: 200.ms)
                    .fadeIn(),
                    
                    const SizedBox(height: 30),
                     Text('Welcome Back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade800,
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .slideY(begin: -0.2),
                    
                    Text('Sign in to continue',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.brown.shade600,
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(delay: 400.ms),
                    
                    const SizedBox(height: 40),
                    
                    // Email field with animation
                    _buildAnimatedTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      delay: 500.ms,
                      validator: (value) => 
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Password field with animation
                    _buildAnimatedTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outlined,
                      obscureText: true,
                      delay: 600.ms,
                      validator: (value) => 
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Login button with animation
                    BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthLoading && !state.isGoogleSignIn) {
      setState(() => _isEmailLoading = true);
    } else if (state is Authenticated) {
      Navigator.pop(context);
    } else if (state is AuthError) {
      setState(() => _isEmailLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  child: ElevatedButton(
    onPressed: _isEmailLoading ? null : () {
      if (_formKey.currentState?.validate() ?? false) {
        context.read<AuthBloc>().add(LoginEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
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
                        child: _isEmailLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : Text('LOGIN',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown.shade50,
                                ),
                              ),
                      )
                      .animate()
                      .fadeIn(delay: 700.ms)
                      .slideY(begin: 0.5),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Divider with animation
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text('OR',
                            style: TextStyle(color: Colors.brown.shade600),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    )
                    .animate()
                    .fadeIn(delay: 800.ms),
                    
                    const SizedBox(height: 20),
                    
                    // Google sign-in with animation
                   BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthLoading) {
      setState(() {
        _isEmailLoading = state.isGoogleSignIn ? false : true;
        _isGoogleLoading = state.isGoogleSignIn;
      });
    }
    if (state is Authenticated) {
      Navigator.pop(context);
    }
    if (state is AuthError) {
      setState(() {
        _isEmailLoading = false;
        _isGoogleLoading = state.isGoogleSignIn;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
                      },
                      child: OutlinedButton.icon(
                        icon: _isGoogleLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.brown,
                                ),
                              )
                            : Image.network(
                                'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                                height: 24,
                                width: 24,
                              ),
                        label: Text(
                          _isGoogleLoading ? 'Signing in...' : 'Continue with Google',
                          style: TextStyle(color: Colors.brown.shade800),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.brown.shade400),
                        ),
                        onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                      )
                      .animate()
                      .fadeIn(delay: 900.ms)
                      .slideY(begin: 0.5),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Register link with animation
                    Center(
                      child: TextButton(
                        onPressed: _isEmailLoading || _isGoogleLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => const RegisterPage(),
                                    transitionsBuilder: (_, a, __, c) => 
                                        FadeTransition(opacity: a, child: c),
                                  ),
                                );
                              },
                        child: Text.rich(
                          TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(color: Colors.brown.shade600),
                            children: [
                              TextSpan(
                                text: 'Register',
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
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