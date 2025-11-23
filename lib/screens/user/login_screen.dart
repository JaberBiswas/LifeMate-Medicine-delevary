import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/theme.dart';
import '../../utils/validator.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (_auth.currentUser != null) {
        if (!mounted) return;
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.loadUser();

        if (!mounted) return;
        
        // Get the return route from arguments
        final returnRoute = ModalRoute.of(context)?.settings.arguments as String?;
        
        if (userProvider.isAdmin) {
          Navigator.pushReplacementNamed(context, '/admin/dashboard');
        } else {
          // If redirected from checkout, go to home; otherwise go to checkout or home
          if (returnRoute == '/checkout') {
            // Fast redirect to home page when coming from checkout
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            // Default: go to home page
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      }
    } catch (e, stackTrace) {
      // Log detailed error with file location
      debugPrint('❌ Login Error:');
      debugPrint('   File: lib/screens/user/login_screen.dart');
      debugPrint('   Method: _handleLogin');
      debugPrint('   Error: $e');
      debugPrint('   Stack: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.tealGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: AppTheme.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        size: 50,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to continue',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomTextField(
                              label: 'Email',
                              hint: 'Enter your email',
                              controller: _emailController,
                              validator: Validator.validateEmail,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: 'Password',
                              hint: 'Enter your password',
                              controller: _passwordController,
                              validator: Validator.validatePassword,
                              obscureText: _obscurePassword,
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() =>
                                      _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            CustomButton(
                              text: 'Sign In',
                              onPressed: _handleLogin,
                              isLoading: _isLoading,
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                if (!mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Don\'t have an account? Sign Up',
                                style: TextStyle(color: AppTheme.primaryTeal),
                              ),
                            ),
                            // Admin entry removed from user login UI
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

