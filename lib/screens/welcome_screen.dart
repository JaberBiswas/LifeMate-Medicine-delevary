import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/product_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/theme.dart';
import '../utils/validator.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/medicine_card.dart';
import 'admin/admin_register_screen.dart';
import 'user/product_details_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // Admin Login Controllers
  final _adminFormKey = GlobalKey<FormState>();
  final _adminEmailController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isAdminLoading = false;
  bool _obscureAdminPassword = true;

  @override
  void dispose() {
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleAdminLogin() async {
    if (!_adminFormKey.currentState!.validate()) return;

    setState(() => _isAdminLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: _adminEmailController.text.trim(),
        password: _adminPasswordController.text,
      );

      if (!mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadUser();

      if (userProvider.isAdmin) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/admin/dashboard');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are not authorized as admin'),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Admin Login Error: $e');
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
        setState(() => _isAdminLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth >= 900; // two-pane only on wide screens

    return Scaffold(
      body: isWide
          // Wide layout: side-by-side
          ? Row(
              children: [
                Expanded(child: _buildAdminLoginSection()),
                Container(
                  width: 2,
                  color: AppTheme.gray.withValues(alpha: 0.3),
                ),
                Expanded(child: _buildHomeSection()),
              ],
            )
          // Narrow layout: stack vertically to avoid horizontal overflow
          : Column(
              children: [
                Expanded(child: _buildAdminLoginSection()),
                Container(
                  height: 2,
                  color: AppTheme.gray.withValues(alpha: 0.3),
                ),
                Expanded(child: _buildHomeSection()),
              ],
            ),
    );
  }

  // Admin Login Section
  Widget _buildAdminLoginSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.tealGradient,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _adminFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
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
                          controller: _adminEmailController,
                          validator: Validator.validateEmail,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Password',
                          hint: 'Enter your password',
                          controller: _adminPasswordController,
                          validator: Validator.validatePassword,
                          obscureText: _obscureAdminPassword,
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureAdminPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() =>
                                  _obscureAdminPassword = !_obscureAdminPassword);
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Sign In',
                          onPressed: _handleAdminLogin,
                          isLoading: _isAdminLoading,
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
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Home/Products Section
  Widget _buildHomeSection() {
    return Container(
      color: AppTheme.white,
      child: SafeArea(
        child: Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.gray.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: AppTheme.tealGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_pharmacy,
                          color: AppTheme.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LifeMate',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkGray,
                              ),
                            ),
                            Text(
                              'Browse Products',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.gray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          // Navigate to full home page
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                      ),
                    ],
                  ),
                ),
                
                // Products List
                Expanded(
                  child: productProvider.medicines.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.medication_outlined,
                                size: 64,
                                color: AppTheme.gray.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No products available',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.gray,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/home');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryTeal,
                                  foregroundColor: AppTheme.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text('View Full Home Page'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: productProvider.medicines.length,
                          itemBuilder: (context, index) {
                            final medicine = productProvider.medicines[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: MedicineCard(
                                medicine: medicine,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProductDetailsScreen(medicine: medicine),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
                
                // Footer with button to go to full home
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray,
                    border: Border(
                      top: BorderSide(
                        color: AppTheme.gray.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        foregroundColor: AppTheme.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'View Full Home Page →',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
