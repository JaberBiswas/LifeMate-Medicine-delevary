import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_data_service.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../utils/theme.dart';
import '../../utils/validator.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'admin_register_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreDataService _firestore = FirestoreDataService();
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
        // Ensure Firestore profile exists in admin collection
        final uid = _auth.currentUser!.uid;
        final existing = await _firestore.getAdmin(uid);
        if (existing == null) {
          // Check if user exists in users collection (legacy migration)
          final userCheck = await _firestore.getUser(uid);
          if (userCheck == null || userCheck.role != 'admin') {
            // Create new admin in admin collection
            await _firestore.createAdmin(
              UserModel(
                id: uid,
                email: _emailController.text.trim(),
                name: '',
                phone: '',
                role: 'admin',
                createdAt: DateTime.now(),
              ),
            );
          }
        }

        if (!mounted) return;
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.loadUser();

        if (!mounted) return;
        if (userProvider.isAdmin) {
          Navigator.pushReplacementNamed(context, '/admin/dashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are not authorized as admin'),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth specific errors
      String errorMessage = 'Login failed';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No admin account found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address. Please check and try again.';
          break;
        case 'user-disabled':
          errorMessage = 'This admin account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed login attempts. Please try again later.';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred during login.';
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 5),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } catch (e, stackTrace) {
      // Log detailed error with file location
      debugPrint('❌ Admin Login Error:');
      debugPrint('   File: lib/screens/admin/admin_login_screen.dart');
      debugPrint('   Method: _handleLogin');
      debugPrint('   Error: $e');
      debugPrint('   Stack: $stackTrace');
      
      // Check if it's a Firestore permission error
      String errorMessage = 'Login failed';
      if (e.toString().contains('permission-denied')) {
        errorMessage = 'Permission denied. Please ensure Firestore security rules are configured correctly.';
      } else {
        errorMessage = e.toString();
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 5),
          backgroundColor: AppTheme.errorRed,
        ),
      );
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
                        Icons.admin_panel_settings,
                        size: 50,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Admin Login',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to manage your store',
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
                              hint: 'Enter admin email',
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AdminRegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Don\'t have an admin account? Register',
                                style: TextStyle(color: AppTheme.primaryTeal),
                              ),
                            ),
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

