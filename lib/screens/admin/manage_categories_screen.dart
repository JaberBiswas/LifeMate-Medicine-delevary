import 'package:flutter/material.dart';
import '../../services/firestore_data_service.dart';
import '../../utils/theme.dart';
import '../../models/category_model.dart';
import 'category_form_screen.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() =>
      _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _firestoreService = FirestoreDataService();

  IconData? _parseIconFromImageUrl(String imageUrl) {
    if (imageUrl.startsWith('icon:')) {
      final codePointStr = imageUrl.substring(5);
      final codePoint = int.tryParse(codePointStr);
      if (codePoint != null) {
        return IconData(codePoint, fontFamily: 'MaterialIcons');
      }
    }
    return null;
  }

  Widget _buildCategoryImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return const Icon(
        Icons.image_not_supported,
        size: 32,
        color: AppTheme.gray,
      );
    }

    final icon = _parseIconFromImageUrl(imageUrl);
    if (icon != null) {
      return Icon(
        icon,
        color: AppTheme.primaryTeal,
        size: 32,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        imageUrl,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.broken_image,
          size: 32,
          color: AppTheme.gray,
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryTeal,
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add Category'),
            onPressed: () async {
              final created = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoryFormScreen(),
                ),
              );
              // No manual refresh needed; StreamBuilder updates from Firestore
              if (!mounted) return;
              if (created == true) {
                // Optional: already snackBar in form; skip here
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories List
          Expanded(
            child: StreamBuilder<List<CategoryModel>>(
              stream: _firestoreService.getCategoriesAdmin(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final categories = snapshot.data ?? [];

                if (categories.isEmpty) {
                  return const Center(
                    child: Text('No categories yet. Add one above.'),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('#')),
                        DataColumn(label: Text('Image')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Description')),
                        DataColumn(label: Text('Sort')),
                        DataColumn(label: Text('Active')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: List.generate((() {
                        final sorted = [...categories];
                        sorted.sort((a, b) {
                          final bySort = a.sortOrder.compareTo(b.sortOrder);
                          if (bySort != 0) return bySort;
                          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
                        });
                        return sorted.length;
                      })(), (index) {
                        final sortedList = [...categories]
                          ..sort((a, b) {
                            final bySort = a.sortOrder.compareTo(b.sortOrder);
                            if (bySort != 0) return bySort;
                            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
                          });
                        final cat = sortedList[index];
                        return DataRow(
                          cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: _buildCategoryImage(cat.imageUrl),
                              ),
                            ),
                            DataCell(Text(cat.name)),
                            DataCell(SizedBox(
                              width: 240,
                              child: Text(
                                cat.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                            DataCell(Text(cat.sortOrder.toString())),
                            DataCell(
                              Switch(
                                value: cat.isActive,
                                onChanged: (val) async {
                                  await _firestoreService.updateCategory(cat.id, {
                                    'isActive': val,
                                    'updatedAt': DateTime.now(),
                                  });
                                },
                              ),
                            ),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryTeal),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CategoryFormScreen(existing: cat),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Category'),
                                        content: Text('Are you sure you want to delete "${cat.name}"?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            style: TextButton.styleFrom(
                                              foregroundColor: AppTheme.errorRed,
                                            ),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirmed == true) {
                                      try {
                                        await _firestoreService.deleteCategory(cat.id);
                                        if (!mounted) return;
                                        final scaffoldMessenger = ScaffoldMessenger.of(this.context);
                                        scaffoldMessenger.showSnackBar(
                                          const SnackBar(
                                            content: Text('Category deleted successfully'),
                                            backgroundColor: AppTheme.successGreen,
                                          ),
                                        );
                                      } catch (e) {
                                        if (!mounted) return;
                                        final scaffoldMessenger = ScaffoldMessenger.of(this.context);
                                        scaffoldMessenger.showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            )),
                          ],
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

