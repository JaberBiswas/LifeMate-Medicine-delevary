import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_data_service.dart';
import '../../models/user_model.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../../utils/validator.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreDataService _firestoreService = FirestoreDataService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create admin auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final uid = credential.user!.uid;
      final admin = UserModel(
        id: uid,
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        role: AppConstants.adminRole,
        createdAt: DateTime.now(),
      );

      // Save admin to 'admin' collection
      await _firestoreService.createAdmin(admin);

        if (!mounted) return;
        final userProvider =
            Provider.of<UserProvider>(context, listen: false);
        await userProvider.loadUser();

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth specific errors
      String errorMessage = 'Registration failed';
      
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered. Please sign in instead.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak. Please use a stronger password.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address. Please check and try again.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred during registration.';
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 5),
          action: e.code == 'email-already-in-use'
              ? SnackBarAction(
                  label: 'Sign In',
                  textColor: AppTheme.white,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/admin/login');
                  },
                )
              : null,
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } catch (e, stackTrace) {
      // Log detailed error with file location
      debugPrint('❌ Admin Registration Error:');
      debugPrint('   File: lib/screens/admin/admin_register_screen.dart');
      debugPrint('   Method: _handleRegister');
      debugPrint('   Error: $e');
      debugPrint('   Stack: $stackTrace');
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${e.toString()}'),
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
                      'Admin Registration',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create admin account',
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
                              label: 'Full Name',
                              hint: 'Enter your full name',
                              controller: _nameController,
                              validator: Validator.validateName,
                              prefixIcon: const Icon(Icons.person_outlined),
                            ),
                            const SizedBox(height: 16),
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
                              label: 'Phone',
                              hint: 'Enter your phone number',
                              controller: _phoneController,
                              validator: Validator.validatePhone,
                              keyboardType: TextInputType.phone,
                              prefixIcon: const Icon(Icons.phone_outlined),
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
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: 'Confirm Password',
                              hint: 'Confirm your password',
                              controller: _confirmPasswordController,
                              validator: Validator.validatePassword,
                              obscureText: _obscureConfirmPassword,
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() => _obscureConfirmPassword =
                                      !_obscureConfirmPassword);
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            CustomButton(
                              text: 'Register as Admin',
                              onPressed: _handleRegister,
                              isLoading: _isLoading,
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: TextButton.icon(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/admin/login');
                                },
                                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                                label: const Text('Back to Login'),
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

