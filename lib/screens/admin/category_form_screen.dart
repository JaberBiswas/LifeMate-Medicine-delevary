import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/category_model.dart';
import '../../services/firestore_data_service.dart';
import '../../services/storage_service.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/icon_image_picker.dart';

class CategoryFormScreen extends StatefulWidget {
  const CategoryFormScreen({super.key, this.existing});

  final CategoryModel? existing;

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _firestoreService = FirestoreDataService();
  final _storageService = StorageService();

  bool _isActive = true;
  int _sortOrder = 0;
  bool _isSaving = false;

  // Icon/Image selection
  IconData? _selectedIcon;
  File? _selectedImage;
  String? _finalImageUrl;

  // Responsive + Sidebar state
  bool _isSidebarCollapsed = false;
  bool _isMobileSidebarOpen = false;

  static const double _sidebarExpandedWidth = 250;
  static const double _sidebarCollapsedWidth = 80;
  static const double _mobileBreakpoint = 600;

  bool get _isMobileLayout {
    final w = MediaQuery.of(context).size.width;
    return w < _mobileBreakpoint;
  }

  double get _currentSidebarWidth {
    if (_isMobileLayout) {
      return _isMobileSidebarOpen ? _sidebarExpandedWidth : 0;
    }
    return _isSidebarCollapsed ? _sidebarCollapsedWidth : _sidebarExpandedWidth;
  }

  void _toggleSidebar() {
    if (_isMobileLayout) {
      setState(() {
        _isMobileSidebarOpen = !_isMobileSidebarOpen;
      });
      return;
    }
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard_outlined, 'label': 'Dashboard'},
    {'icon': Icons.category_outlined, 'label': 'Categories'},
    {'icon': Icons.medication_outlined, 'label': 'Products'},
    {'icon': Icons.shopping_bag_outlined, 'label': 'Orders'},
    {'icon': Icons.people_outlined, 'label': 'Users'},
    {'icon': Icons.bar_chart_outlined, 'label': 'Sales'},
    {'icon': Icons.settings_outlined, 'label': 'Settings'},
  ];

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

  String? _getInitialImageUrl() {
    if (widget.existing?.imageUrl != null) {
      final existingUrl = widget.existing!.imageUrl;
      if (existingUrl.startsWith('icon:')) {
        return null; // Icon mode
      }
      return existingUrl; // Image mode
    }
    return null;
  }

  IconData? _getInitialIcon() {
    if (widget.existing?.imageUrl != null) {
      return _parseIconFromImageUrl(widget.existing!.imageUrl);
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _nameController.text = existing.name;
      _descController.text = existing.description;
      _isActive = existing.isActive;
      _sortOrder = existing.sortOrder;
      _selectedIcon = _getInitialIcon();
      _finalImageUrl = _getInitialImageUrl();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onIconSelected(IconData? icon) {
    setState(() {
      _selectedIcon = icon;
      _selectedImage = null;
      // Only clear _finalImageUrl if a new icon is actually selected
      if (icon != null) {
        _finalImageUrl = null;
      }
    });
  }

  void _onImageSelected(File? image) {
    setState(() {
      _selectedImage = image;
      _selectedIcon = null;
      // Only clear _finalImageUrl if a new image is actually selected
      if (image != null) {
        _finalImageUrl = null;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      String finalImageUrl = '';

      // Handle icon selection
      if (_selectedIcon != null) {
        finalImageUrl = 'icon:${_selectedIcon!.codePoint}';
      }
      // Handle image upload
      else if (_selectedImage != null) {
        final categoryId = widget.existing?.id ??
            CategoryModel.generateIdFromName(_nameController.text.trim());
        finalImageUrl = await _storageService.uploadCategoryImage(
          _selectedImage!,
          categoryId,
        );
      }
      // Keep existing image URL if no new selection
      else if (_finalImageUrl != null && _finalImageUrl!.isNotEmpty) {
        finalImageUrl = _finalImageUrl!;
      }
      // If existing category has imageUrl (icon or image), keep it
      else if (widget.existing?.imageUrl != null &&
          widget.existing!.imageUrl.isNotEmpty) {
        finalImageUrl = widget.existing!.imageUrl;
      }

      final now = DateTime.now();
      final model = CategoryModel(
        id: widget.existing?.id ??
            CategoryModel.generateIdFromName(_nameController.text.trim()),
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        imageUrl: finalImageUrl,
        sortOrder: _sortOrder,
        isActive: _isActive,
        createdAt: widget.existing?.createdAt ?? now,
        updatedAt: now,
      );
      await _firestoreService.upsertCategory(model);
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              widget.existing == null ? 'Category created' : 'Category updated'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Row(
                children: [
                  // Sidebar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: _currentSidebarWidth,
                    decoration: BoxDecoration(
                      color: AppTheme.darkTeal,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.gray.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(2, 0),
                        ),
                      ],
                    ),
                    child: _currentSidebarWidth == 0
                        ? const SizedBox.shrink()
                        : ClipRect(
                            child: Material(
                              color: Colors.transparent,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  // Header
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          _isSidebarCollapsed ? 8 : 16,
                                      vertical: 16,
                                    ),
                                    decoration: const BoxDecoration(
                                      gradient: AppTheme.tealGradient,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: _isSidebarCollapsed ? 40 : 60,
                                          height: _isSidebarCollapsed ? 40 : 60,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppTheme.white,
                                          ),
                                          child: Icon(
                                            Icons.admin_panel_settings,
                                            size: _isSidebarCollapsed ? 20 : 30,
                                            color: AppTheme.primaryTeal,
                                          ),
                                        ),
                                        if (!_isMobileLayout &&
                                            !_isSidebarCollapsed) ...[
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Admin Panel',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                          ),
                                          const Text(
                                            'LifeMate',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  // Menu Items
                                  Expanded(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      itemCount: _menuItems.length,
                                      itemBuilder: (context, index) {
                                        final item = _menuItems[index];
                                        return InkWell(
                                          onTap: () {
                                            if (index == 1) {
                                              // Categories - go back
                                              Navigator.pop(context);
                                            } else {
                                              // Navigate to other screens
                                              Navigator.pop(context);
                                            }
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  _isSidebarCollapsed ? 8 : 12,
                                              vertical: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: index == 1
                                                  ? AppTheme.primaryTeal
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  item['icon'] as IconData,
                                                  size: _isSidebarCollapsed
                                                      ? 20
                                                      : 24,
                                                  color: index == 1
                                                      ? AppTheme.white
                                                      : AppTheme.white
                                                          .withValues(
                                                              alpha: 0.7),
                                                ),
                                                if (!_isSidebarCollapsed &&
                                                    (!_isMobileLayout ||
                                                        _isMobileSidebarOpen)) ...[
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      item['label'] as String,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: index == 1
                                                            ? FontWeight.w600
                                                            : FontWeight
                                                                .normal,
                                                        color: index == 1
                                                            ? AppTheme.white
                                                            : AppTheme.white
                                                                .withValues(
                                                                    alpha: 0.7),
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  // Footer
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          _isSidebarCollapsed ? 8 : 16,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.darkTeal,
                                      border: Border(
                                        top: BorderSide(
                                          color: AppTheme.white
                                              .withValues(alpha: 0.1),
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      '© 2024 LifeMate',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.white,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),

                  // Main Content Area with Header and Footer
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          decoration: const BoxDecoration(
                            gradient: AppTheme.tealGradient,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        _isMobileLayout
                                            ? (_isMobileSidebarOpen
                                                ? Icons.close
                                                : Icons.menu)
                                            : (_isSidebarCollapsed
                                                ? Icons.chevron_right
                                                : Icons.chevron_left),
                                        color: AppTheme.white,
                                      ),
                                      onPressed: _toggleSidebar,
                                    ),
                                    const Icon(Icons.category_outlined,
                                        color: AppTheme.white),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: Text(
                                        widget.existing == null
                                            ? 'Add Category'
                                            : 'Edit Category',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.notifications_outlined,
                                        color: AppTheme.white),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.account_circle_outlined,
                                        color: AppTheme.white),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Page content
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextField(
                                    label: 'Category Name',
                                    hint: 'e.g., Antibiotic',
                                    controller: _nameController,
                                    prefixIcon:
                                        const Icon(Icons.category_outlined),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Name is required'
                                            : null,
                                  ),
                                  const SizedBox(height: 12),
                                  IconImagePicker(
                                    onIconSelected: _onIconSelected,
                                    onImageSelected: _onImageSelected,
                                    initialIcon: _getInitialIcon(),
                                    initialImageUrl: _getInitialImageUrl(),
                                  ),
                                  const SizedBox(height: 12),
                                  CustomTextField(
                                    label: 'Description',
                                    hint: 'Short description (optional)',
                                    controller: _descController,
                                    maxLines: 3,
                                    prefixIcon:
                                        const Icon(Icons.notes_outlined),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Text('Sort Order'),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: _sortOrder.toString(),
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                          onChanged: (v) {
                                            final parsed =
                                                int.tryParse(v.trim());
                                            setState(() =>
                                                _sortOrder = parsed ?? 0);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Active'),
                                      Switch(
                                        value: _isActive,
                                        onChanged: (val) =>
                                            setState(() => _isActive = val),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: CustomButton(
                                      text: widget.existing == null
                                          ? 'Create'
                                          : 'Save',
                                      isLoading: _isSaving,
                                      onPressed: _save,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Footer
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            border: Border(
                              top: BorderSide(
                                  color: AppTheme.gray.withValues(alpha: 0.15)),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '© 2024 LifeMate Admin',
                                style: TextStyle(
                                    fontSize: 12, color: AppTheme.gray),
                              ),
                              Text(
                                'v1.0.0',
                                style: TextStyle(
                                    fontSize: 12, color: AppTheme.gray),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Mobile scrim overlay when sidebar is open
              if (_isMobileLayout && _isMobileSidebarOpen)
                Positioned(
                  left: _currentSidebarWidth,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _isMobileSidebarOpen = false;
                      });
                    },
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
