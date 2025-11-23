import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Fast visit - show home page immediately without login check
    // Minimal delay for splash screen visibility
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // Load user data in background (non-blocking)
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.loadUser();

    // Ensure navigation happens after first frame
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.tealGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38B2AC).withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.medical_services,
                  size: 60,
                  color: AppTheme.primaryTeal,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'LifeMate',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your Health Companion',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.white,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

