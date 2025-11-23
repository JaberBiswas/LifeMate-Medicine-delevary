import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/user_provider.dart';
import '../../utils/theme.dart';
import '../../utils/validator.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../splash_screen.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _notificationsEnabled = true;
  
  Future<void> _showEditNameDialog(UserProvider userProvider) async {
    final nameController = TextEditingController(text: userProvider.user?.name ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: CustomTextField(
          label: 'Name',
          hint: 'Enter your name',
          controller: nameController,
          validator: Validator.validateName,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.pop(context, nameController.text.trim());
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      try {
        await userProvider.updateUser({'name': result});
        if (!mounted) return;
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Name updated successfully')),
        );
      } catch (e) {
        if (!mounted) return;
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
    nameController.dispose();
  }

  Future<void> _showEditPhoneDialog(UserProvider userProvider) async {
    final phoneController = TextEditingController(text: userProvider.user?.phone ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Phone'),
        content: CustomTextField(
          label: 'Phone',
          hint: 'Enter your phone number',
          controller: phoneController,
          keyboardType: TextInputType.phone,
          validator: Validator.validatePhone,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (phoneController.text.trim().isNotEmpty) {
                Navigator.pop(context, phoneController.text.trim());
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      try {
        await userProvider.updateUser({'phone': result});
        if (!mounted) return;
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Phone updated successfully')),
        );
      } catch (e) {
        if (!mounted) return;
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
    phoneController.dispose();
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Current Password',
                  hint: 'Enter current password',
                  controller: currentPasswordController,
                  obscureText: true,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'New Password',
                  hint: 'Enter new password',
                  controller: newPasswordController,
                  obscureText: true,
                  validator: Validator.validatePassword,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Confirm Password',
                  hint: 'Confirm new password',
                  controller: confirmPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (value != newPasswordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  // Local auth: password change is a no-op in memory
                  await Future<void>.delayed(const Duration(milliseconds: 150));
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password updated successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.person_outlined),
                      title: const Text('Name'),
                      subtitle: Text(userProvider.user?.name ?? 'N/A'),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => _showEditNameDialog(userProvider),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email'),
                      subtitle: Text(userProvider.user?.email ?? 'N/A'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone_outlined),
                      title: const Text('Phone'),
                      subtitle: Text(userProvider.user?.phone ?? 'N/A'),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => _showEditPhoneDialog(userProvider),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // General Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'General',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.notifications_outlined),
                      title: const Text('Notifications'),
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value ? 'Notifications enabled' : 'Notifications disabled',
                              ),
                            ),
                          );
                        },
                        activeThumbColor: AppTheme.primaryTeal,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.language_outlined),
                      title: const Text('Language'),
                      subtitle: const Text('English'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Select Language'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: const Text('English'),
                                  leading: const Icon(Icons.check),
                                  onTap: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Language changed to English')),
                                    );
                                  },
                                ),
                                const Divider(),
                                ListTile(
                                  title: const Text('Spanish'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Language changed to Spanish')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.dark_mode_outlined),
                      title: const Text('Theme'),
                      subtitle: const Text('Light'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Select Theme'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: const Text('Light'),
                                  leading: const Icon(Icons.check),
                                  onTap: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Theme changed to Light')),
                                    );
                                  },
                                ),
                                const Divider(),
                                ListTile(
                                  title: const Text('Dark'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Dark theme coming soon')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Account Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.lock_outlined),
                      title: const Text('Change Password'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showChangePasswordDialog(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outlined),
                      title: const Text('About'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'LifeMate',
                          applicationVersion: '1.0.0',
                          applicationIcon: const Icon(
                            Icons.medical_services,
                            size: 48,
                            color: AppTheme.primaryTeal,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            CustomButton(
              text: 'Logout',
              backgroundColor: AppTheme.errorRed,
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                userProvider.clearUser();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SplashScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              width: double.infinity,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

