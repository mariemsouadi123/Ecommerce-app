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
          // Gradient background
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
          ).animate().fadeIn(duration: 500.ms),
          
          // Decorative circles from Register page
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
                    const SizedBox(height: 40),
                    
                    // Logo
                    Container(
                      height: 120,
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
                    
                    // Title
                    Text('Welcome Back',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5E3023),
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .slideY(begin: -0.2),
                    
                    Text('Sign in to continue',
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFF5E3023).withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(delay: 400.ms),
                    
                    const SizedBox(height: 40),
                    
                    // Email field
                    _buildAnimatedTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      delay: 500.ms,
                      validator: (value) => 
                          value?.isEmpty ?? true ? 'Required' : null,
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
                    
                    const SizedBox(height: 30),
                    
                    // Login button
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
                              backgroundColor: const Color(0xFFC8553D),
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
                          backgroundColor: const Color(0xFFFF6B35),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        child: _isEmailLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              )
                            : Text('LOGIN',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      )
                      .animate()
                      .fadeIn(delay: 700.ms)
                      .slideY(begin: 0.5),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: const Color(0xFF5E3023).withOpacity(0.3),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('OR',
                            style: TextStyle(
                              color: const Color(0xFF5E3023).withOpacity(0.6),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: const Color(0xFF5E3023).withOpacity(0.3),
                          ),
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(delay: 800.ms),
                    
                    const SizedBox(height: 20),
                    
                    // Google sign-in
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
                                  color: Color(0xFF5E3023),
                                ),
                              )
                            : Image.network(
                                'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                                height: 24,
                                width: 24,
                              ),
                        label: Text(
                          _isGoogleLoading ? 'Signing in...' : 'Continue with Google',
                          style: TextStyle(
                            color: const Color(0xFF5E3023),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          side: BorderSide(
                            color: const Color(0xFF5E3023).withOpacity(0.5),
                          ),
                        ),
                        onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                      )
                      .animate()
                      .fadeIn(delay: 900.ms)
                      .slideY(begin: 0.5),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Register link
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
                            style: TextStyle(
                              color: const Color(0xFF5E3023).withOpacity(0.7),
                            ),
                            children: [
                              TextSpan(
                                text: 'Register',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFF6B35),
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
      ),
    )
    .animate()
    .fadeIn(delay: delay)
    .slideX(begin: -0.2);
  }
}