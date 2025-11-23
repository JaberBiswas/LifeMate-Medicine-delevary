import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class AdminGuard extends StatelessWidget {
  final Widget child;
  const AdminGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (userProvider.isAdmin) {
          return child;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!Navigator.of(context).canPop()) {
            Navigator.pushReplacementNamed(context, '/admin/login');
          } else {
            Navigator.pushNamedAndRemoveUntil(context, '/admin/login', (_) => false);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin access required')),
          );
        });

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}



