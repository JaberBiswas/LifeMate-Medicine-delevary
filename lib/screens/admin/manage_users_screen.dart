import 'package:flutter/material.dart';
import '../../services/firestore_data_service.dart';
import '../../models/user_model.dart';
import '../../utils/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreDataService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: firestoreService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return const Center(child: Text('No users yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryTeal,
                    backgroundImage: user.imageUrl != null
                        ? CachedNetworkImageProvider(user.imageUrl!)
                        : null,
                    child: user.imageUrl == null
                        ? Text(
                            user.name[0].toUpperCase(),
                            style: const TextStyle(color: AppTheme.white),
                          )
                        : null,
                  ),
                  title: Text(user.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email),
                      Text(user.phone),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: user.role == 'admin'
                              ? AppTheme.primaryTeal.withValues(alpha: 0.2)
                              : AppTheme.gray.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user.role.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: user.role == 'admin'
                                ? AppTheme.primaryTeal
                                : AppTheme.gray,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.edit_outlined),
                                title: const Text('Edit User'),
                                onTap: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Edit user functionality coming soon')),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.block_outlined, color: AppTheme.errorRed),
                                title: const Text('Block User'),
                                onTap: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Block user functionality coming soon')),
                                  );
                                },
                              ),
                              if (user.role != 'admin')
                                ListTile(
                                  leading: const Icon(Icons.admin_panel_settings_outlined),
                                  title: const Text('Make Admin'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Make admin functionality coming soon')),
                                    );
                                  },
                                ),
                              ListTile(
                                leading: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
                                title: const Text('Delete User'),
                                onTap: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Delete user functionality coming soon')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

