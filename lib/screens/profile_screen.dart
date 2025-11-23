import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/user_provider.dart';
import '../providers/order_provider.dart';
import '../utils/theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/app_header.dart';
import 'user/login_screen.dart';
import 'user/orders_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: const AppHeader(
        title: 'Profile',
        showBackButton: true,
        showNotifications: true,
        onSearchPressed: null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: AppTheme.tealGradient,
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.white,
                      border: Border.fromBorderSide(BorderSide(color: AppTheme.white, width: 4)),
                    ),
                    child: userProvider.user?.imageUrl != null
                        ? ClipOval(
                            child: Image.network(
                              userProvider.user!.imageUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 50,
                            color: AppTheme.primaryTeal,
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userProvider.user?.name ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                  Text(
                    userProvider.user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.white,
                    ),
                  ),
                ],
              ),
            ),

            // Stats Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${orderProvider.orders.length}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                      const Text(
                        'Orders',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppTheme.gray.withValues(alpha: 0.3),
                  ),
                  Column(
                    children: [
                      Text(
                        userProvider.user?.phone ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkGray,
                        ),
                      ),
                      const Text(
                        'Phone',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // If not logged in: show Login button and stop
            if (userProvider.user == null) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: CustomButton(
                  text: 'Login',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  width: double.infinity,
                ),
              ),
            ] else ...[
            // Menu Items (visible only when logged in)
            _buildMenuItem(
              context,
              icon: Icons.shopping_bag_outlined,
              title: 'My Orders',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrdersScreen()),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.location_on_outlined,
              title: 'Addresses',
              onTap: () {},
            ),
            _buildMenuItem(
              context,
              icon: Icons.payment_outlined,
              title: 'Payment Methods',
              onTap: () {},
            ),
            _buildMenuItem(
              context,
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () {},
            ),
            _buildMenuItem(
              context,
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {},
            ),
            _buildMenuItem(
              context,
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {},
            ),

            // Logout Button (visible only when logged in)
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomButton(
                text: 'Logout',
                backgroundColor: AppTheme.errorRed,
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  userProvider.clearUser();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                width: double.infinity,
              ),
            ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.lightGray),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryTeal),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.gray),
          ],
        ),
      ),
    );
  }
}
