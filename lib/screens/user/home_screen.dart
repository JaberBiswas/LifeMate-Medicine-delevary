import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/product_provider.dart';
import '../../services/firestore_data_service.dart';
import 'profile_screen.dart';
import '../../utils/theme.dart';
import '../../widgets/medicine_card.dart';
import '../../widgets/common_header.dart';
import '../../models/medicine_model.dart';
import '../../models/category_model.dart';
import 'product_details_screen.dart';
import 'category_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final ScrollController _availableScrollController = ScrollController();
  final ScrollController _newlyScrollController = ScrollController();
  final ScrollController _popularScrollController = ScrollController();
  final ScrollController _highDemandScrollController = ScrollController();
  final ScrollController _bestSellingScrollController = ScrollController();
  final ScrollController _bestBookedScrollController = ScrollController();

  final FirestoreDataService _firestoreService = FirestoreDataService();

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

  Widget _buildCategoryIconOrImage(CategoryModel category) {
    if (category.imageUrl.isEmpty) {
      return const Icon(
        Icons.category_outlined,
        color: AppTheme.primaryTeal,
        size: 28,
      );
    }

    final icon = _parseIconFromImageUrl(category.imageUrl);
    if (icon != null) {
      return Icon(
        icon,
        color: AppTheme.primaryTeal,
        size: 28,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: CachedNetworkImage(
        imageUrl: category.imageUrl,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (context, url, error) => const Icon(
          Icons.broken_image,
          color: AppTheme.primaryTeal,
          size: 28,
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> _specialties = [
    {'icon': Icons.favorite, 'label': 'Cardiology'},
    {'icon': Icons.face, 'label': 'Dermatology'},
    {'icon': Icons.local_hospital_outlined, 'label': 'General Medicine'},
    {'icon': Icons.pregnant_woman, 'label': 'Gynecology'},
    {'icon': Icons.health_and_safety_outlined, 'label': 'Odontology'},
    {'icon': Icons.science, 'label': 'Oncology'},
  ];

  // Popular brands (name + logo)
  final List<Map<String, String>> _popularBrands = [
    {
      'name': 'Pfizer',
      'logo': 'https://logo.clearbit.com/pfizer.com'
    },
    {
      'name': 'Novartis',
      'logo': 'https://logo.clearbit.com/novartis.com'
    },
    {
      'name': 'Roche',
      'logo': 'https://logo.clearbit.com/roche.com'
    },
    {
      'name': 'GSK',
      'logo': 'https://logo.clearbit.com/gsk.com'
    },
    {
      'name': 'Sanofi',
      'logo': 'https://logo.clearbit.com/sanofi.com'
    },
    {
      'name': 'Johnson & Johnson',
      'logo': 'https://logo.clearbit.com/jnj.com'
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _availableScrollController.dispose();
    _newlyScrollController.dispose();
    _popularScrollController.dispose();
    _highDemandScrollController.dispose();
    _bestSellingScrollController.dispose();
    _bestBookedScrollController.dispose();
    super.dispose();
  }

  // Dummy products for newly arrivals section
  List<MedicineModel> _getDummyProducts() {
    final now = DateTime.now();
    
    return [
      MedicineModel(
        id: 'dummy_1',
        name: 'Paracetamol 500mg',
        description: 'Pain reliever and fever reducer',
        price: 25.0,
        discountPrice: 20.0,
        imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400&h=400&fit=crop',
        category: 'Pain Relief',
        stock: 100,
        rating: 4.5,
        reviewCount: 120,
        createdAt: now.subtract(const Duration(days: 2)),
        isActive: true,
      ),
      MedicineModel(
        id: 'dummy_2',
        name: 'Cetirizine 10mg',
        description: 'Antihistamine for allergies',
        price: 45.0,
        discountPrice: 38.0,
        imageUrl: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=400&fit=crop',
        category: 'Allergy',
        stock: 80,
        rating: 4.3,
        reviewCount: 95,
        createdAt: now.subtract(const Duration(days: 5)),
        isActive: true,
      ),
      MedicineModel(
        id: 'dummy_3',
        name: 'Omeprazole 20mg',
        description: 'Acid reducer for stomach',
        price: 55.0,
        discountPrice: 48.0,
        imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400&h=400&fit=crop',
        category: 'Digestive',
        stock: 90,
        rating: 4.7,
        reviewCount: 150,
        createdAt: now.subtract(const Duration(days: 1)),
        isActive: true,
      ),
      MedicineModel(
        id: 'dummy_4',
        name: 'Azithromycin 250mg',
        description: 'Antibiotic for infections',
        price: 85.0,
        discountPrice: 75.0,
        imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=400&fit=crop',
        category: 'Antibiotic',
        stock: 60,
        rating: 4.4,
        reviewCount: 110,
        createdAt: now.subtract(const Duration(days: 3)),
        isActive: true,
      ),
      MedicineModel(
        id: 'dummy_5',
        name: 'Amoxicillin 250mg',
        description: 'Broad spectrum antibiotic',
        price: 95.0,
        discountPrice: 85.0,
        imageUrl: 'https://images.unsplash.com/photo-1551601651-2a8555f1a136?w=400&h=400&fit=crop',
        category: 'Antibiotic',
        stock: 70,
        rating: 4.6,
        reviewCount: 135,
        createdAt: now.subtract(const Duration(days: 4)),
        isActive: true,
      ),
      MedicineModel(
        id: 'dummy_6',
        name: 'Vitamin D3 60k IU',
        description: 'Bone health supplement',
        price: 120.0,
        discountPrice: 100.0,
        imageUrl: 'https://images.unsplash.com/photo-1559757175-0eb30cd8c063?w=400&h=400&fit=crop',
        category: 'Vitamins',
        stock: 50,
        rating: 4.8,
        reviewCount: 200,
        createdAt: now.subtract(const Duration(days: 6)),
        isActive: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section - Using reusable CommonHeader widget
            CommonHeader(
              onSearchTap: () {
                _showSearchDialog(context, productProvider);
              },
            ),

            // Main Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                children: [
                  _buildHomePage(context, productProvider), // Home
                  _buildCategoriesPage(context), // Category
                  _buildMedicinesPage(context, productProvider), // Orders
                  const ProfileScreen(), // Profile
                ],
              ),
            ),

            // Bottom Navigation
            Container(
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.gray.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() => _currentIndex = index);
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: AppTheme.primaryTeal,
                unselectedItemColor: AppTheme.gray,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.category_outlined),
                    activeIcon: Icon(Icons.category),
                    label: 'Category',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.receipt_long_outlined),
                    activeIcon: Icon(Icons.receipt_long),
                    label: 'Order',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage(BuildContext context, ProductProvider productProvider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Categories Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTeal,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'See all',
                    style: TextStyle(color: AppTheme.primaryTeal),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 100,
            child: StreamBuilder<List<CategoryModel>>(
              stream: _firestoreService.getActiveCategoriesDetailed(),
              builder: (context, snapshot) {
                final categories = snapshot.data ?? [];
                if (categories.isEmpty) {
                  return const Center(child: Text('No categories'));
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: InkWell(
                        onTap: () {
                          final icon = _parseIconFromImageUrl(category.imageUrl);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryDetailsScreen(
                                categoryName: category.name,
                                categoryIcon: icon ?? Icons.category_outlined,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.lightGray,
                                border: Border.all(
                                  color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Center(
                                child: _buildCategoryIconOrImage(category),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),


          // 2. Banner Image Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 180,
              child: PageView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: AppTheme.tealGradient,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: 'https://images.unsplash.com/photo-1559757175-0eb30cd8c063?w=800&h=400&fit=crop',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppTheme.lightGray,
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryTeal,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppTheme.lightGray,
                          child: const Icon(Icons.image, size: 48),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // (Popular Brands moved to bottom)


          // 3. Specialties Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Specialties',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTeal,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'See all',
                    style: TextStyle(color: AppTheme.primaryTeal),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _specialties.length,
              itemBuilder: (context, index) {
                final specialty = _specialties[index];
                return Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.tealGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        specialty['icon'] as IconData,
                        color: AppTheme.white,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        specialty['label'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          

          // 4. Newly Arrivals Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: AppTheme.tealGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Newly Arrivals',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/newly-arrivals');
                          },
                          child: const Text(
                            'See all',
                            style: TextStyle(color: AppTheme.white),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'New',
                            style: TextStyle(
                              color: AppTheme.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Consumer<ProductProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppTheme.white),
                        ),
                      );
                    }
                    
                    // Use dummy products if no real products are available
                    List<MedicineModel> medicinesToUse = provider.medicines;
                    if (medicinesToUse.isEmpty) {
                      medicinesToUse = _getDummyProducts();
                    }
                    
                    // Get newly arrived medicines (sorted by createdAt, newest first)
                    List<MedicineModel> newlyArrivedMedicines;
                    try {
                      newlyArrivedMedicines = List<MedicineModel>.from(medicinesToUse)
                        ..sort((a, b) {
                          try {
                            return b.createdAt.compareTo(a.createdAt);
                          } catch (e) {
                            return 0; // If sorting fails, maintain original order
                          }
                        });
                    } catch (e) {
                      // If sorting fails, just use the original list
                      newlyArrivedMedicines = medicinesToUse;
                    }
                    
                    // Display top 6 items horizontally
                    final displayMedicines = newlyArrivedMedicines.take(6).toList();

                    if (displayMedicines.isEmpty) {
                      return const Center(
                        child: Text(
                          'No newly arrived medicines',
                          style: TextStyle(color: AppTheme.white),
                        ),
                      );
                    }
                    return SizedBox(
                      height: 200,
                      child: Stack(
                        children: [
                          ListView.builder(
                            controller: _newlyScrollController,
                            scrollDirection: Axis.horizontal,
                            itemCount: displayMedicines.length,
                            itemBuilder: (context, index) {
                              final medicine = displayMedicines[index];
                              return Container(
                                width: 150,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: AppTheme.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailsScreen(medicine: medicine),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: medicine.imageUrl,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            placeholder: (context, url) => Container(
                                              color: AppTheme.lightGray,
                                              child: const Center(
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    AppTheme.primaryTeal,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Container(
                                              color: AppTheme.lightGray,
                                              child: const Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Name
                                            Text(
                                              medicine.name,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            // Short description
                                            Text(
                                              medicine.description,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: AppTheme.darkGray,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            // Reviews (rating + count)
                                            if (medicine.rating != null || medicine.reviewCount != null)
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (medicine.rating != null) ...[
                                                    const Icon(Icons.star, size: 12, color: AppTheme.primaryTeal),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      medicine.rating!.toStringAsFixed(1),
                                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                                    ),
                                                  ],
                                                  if (medicine.reviewCount != null) ...[
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      '(${medicine.reviewCount})',
                                                      style: const TextStyle(fontSize: 10, color: AppTheme.gray),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            if (medicine.rating != null || medicine.reviewCount != null)
                                              const SizedBox(height: 4),
                                            // Price row: current price and MRP (struck-through)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '₹${medicine.finalPrice.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.primaryTeal,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: Text(
                                                    'MRP ₹${medicine.price.toStringAsFixed(2)}',
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: AppTheme.gray,
                                                      decoration: TextDecoration.lineThrough,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    const double step = 170;
                                    final double target = (_newlyScrollController.offset - step)
                                        .clamp(0.0, _newlyScrollController.position.maxScrollExtent);
                                    _newlyScrollController.animateTo(
                                      target,
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeOut,
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.gray.withValues(alpha: 0.2),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(Icons.chevron_left, size: 24, color: AppTheme.primaryTeal),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    const double step = 170;
                                    final double max = _newlyScrollController.position.maxScrollExtent;
                                    final double target = (_newlyScrollController.offset + step).clamp(0.0, max);
                                    _newlyScrollController.animateTo(
                                      target,
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeOut,
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.gray.withValues(alpha: 0.2),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(Icons.chevron_right, size: 24, color: AppTheme.primaryTeal),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 5. High Demand Products Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'High Demand Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTeal,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/high-demand');
                  },
                  child: const Text(
                    'See all',
                    style: TextStyle(color: AppTheme.primaryTeal),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                List<MedicineModel> medicinesToUse = provider.medicines;
                if (medicinesToUse.isEmpty) {
                  medicinesToUse = _getDummyProducts();
                }

                final sorted = List<MedicineModel>.from(medicinesToUse)
                  ..sort((a, b) {
                    final aReviews = a.reviewCount ?? 0;
                    final bReviews = b.reviewCount ?? 0;
                    if (bReviews != aReviews) return bReviews.compareTo(aReviews);
                    final aRating = a.rating ?? 0;
                    final bRating = b.rating ?? 0;
                    return bRating.compareTo(aRating);
                  });

                final highDemand = sorted.take(12).toList();
                if (highDemand.isEmpty) return const SizedBox.shrink();

                return SizedBox(
                  height: 240,
                  child: Scrollbar(
                    controller: _highDemandScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    thickness: 4,
                    radius: const Radius.circular(8),
                    child: ListView.builder(
                      controller: _highDemandScrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: highDemand.length,
                      itemBuilder: (context, index) {
                      final medicine = highDemand[index];
                      return Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.gray.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsScreen(medicine: medicine),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                            // Product Image Section - fixed height for vertical list
                            SizedBox(
                              height: 140,
                              width: double.infinity,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                    child: medicine.imageUrl.isEmpty
                                        ? Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            color: AppTheme.lightGray,
                                            child: const Center(
                                              child: Icon(
                                                Icons.medication_outlined,
                                                color: AppTheme.primaryTeal,
                                                size: 48,
                                              ),
                                            ),
                                          )
                                        : CachedNetworkImage(
                                            imageUrl: medicine.imageUrl,
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              color: AppTheme.lightGray,
                                              child: const Center(
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    AppTheme.primaryTeal,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              color: AppTheme.lightGray,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.medication_outlined,
                                                  color: AppTheme.primaryTeal,
                                                  size: 48,
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                  // Discount Badge - in image section top-right
                                  if (medicine.discountPrice != null)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.successGreen,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${medicine.discountPercent.toStringAsFixed(0)}% OFF',
                                          style: const TextStyle(
                                            color: AppTheme.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Product Details Section
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                    // Product Name
                                    Text(
                                      medicine.name,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.darkGray,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    // Short description
                                    Text(
                                      medicine.description,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.darkGray,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    // Reviews
                                    (medicine.rating != null || medicine.reviewCount != null)
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (medicine.rating != null) ...[
                                                const Icon(Icons.star, size: 12, color: AppTheme.primaryTeal),
                                                const SizedBox(width: 2),
                                                Text(
                                                  medicine.rating!.toStringAsFixed(1),
                                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                                ),
                                              ],
                                              if (medicine.reviewCount != null) ...[
                                                const SizedBox(width: 6),
                                                Text(
                                                  '(${medicine.reviewCount})',
                                                  style: const TextStyle(fontSize: 10, color: AppTheme.gray),
                                                ),
                                              ],
                                            ],
                                          )
                                        : const SizedBox.shrink(),
                                    (medicine.rating != null || medicine.reviewCount != null)
                                        ? const SizedBox(height: 4)
                                        : const SizedBox.shrink(),
                                    // Price + MRP
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₹${medicine.finalPrice.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.darkGray,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            'MRP ₹${medicine.price.toStringAsFixed(0)}',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppTheme.gray,
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
            ),
          ),
          const SizedBox(height: 24),

          // 6. Available Medicines Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: AppTheme.tealGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Available Medicines',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/available-medicines');
                          },
                          child: const Text(
                            'See all',
                            style: TextStyle(color: AppTheme.white),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'All',
                            style: TextStyle(
                              color: AppTheme.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Consumer<ProductProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppTheme.white),
                        ),
                      );
                    }
                    // Use dummy products if no real products are available
                    final List<MedicineModel> medicinesToUse =
                        provider.medicines.isEmpty
                            ? _getDummyProducts()
                            : provider.medicines;

                    return SizedBox(
                      height: 200,
                      child: Stack(
                        children: [
                          ListView.builder(
                            controller: _availableScrollController,
                            scrollDirection: Axis.horizontal,
                            itemCount: medicinesToUse.take(5).length,
                            itemBuilder: (context, index) {
                              final medicine = medicinesToUse[index];
                              return Container(
                                width: 150,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: AppTheme.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailsScreen(medicine: medicine),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: medicine.imageUrl,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            placeholder: (context, url) => Container(
                                              color: AppTheme.lightGray,
                                              child: const Center(
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    AppTheme.primaryTeal,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Container(
                                              color: AppTheme.lightGray,
                                              child: const Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Name
                                            Text(
                                              medicine.name,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            // Short description
                                            Text(
                                              medicine.description,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: AppTheme.darkGray,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            // Reviews (rating + count)
                                            if (medicine.rating != null || medicine.reviewCount != null)
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (medicine.rating != null) ...[
                                                    const Icon(Icons.star, size: 12, color: AppTheme.primaryTeal),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      medicine.rating!.toStringAsFixed(1),
                                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                                    ),
                                                  ],
                                                  if (medicine.reviewCount != null) ...[
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      '(${medicine.reviewCount})',
                                                      style: const TextStyle(fontSize: 10, color: AppTheme.gray),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            if (medicine.rating != null || medicine.reviewCount != null)
                                              const SizedBox(height: 4),
                                            // Price row: current price and MRP (struck-through)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '₹${medicine.finalPrice.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.primaryTeal,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: Text(
                                                    'MRP ₹${medicine.price.toStringAsFixed(2)}',
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: AppTheme.gray,
                                                      decoration: TextDecoration.lineThrough,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    const double step = 170;
                                    final double target = (_availableScrollController.offset - step).clamp(0.0, _availableScrollController.position.maxScrollExtent);
                                    _availableScrollController.animateTo(
                                      target,
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeOut,
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.gray.withValues(alpha: 0.2),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(Icons.chevron_left, size: 24, color: AppTheme.primaryTeal),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    const double step = 170;
                                    final double max = _availableScrollController.position.maxScrollExtent;
                                    final double target = (_availableScrollController.offset + step).clamp(0.0, max);
                                    _availableScrollController.animateTo(
                                      target,
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeOut,
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.gray.withValues(alpha: 0.2),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(Icons.chevron_right, size: 24, color: AppTheme.primaryTeal),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 7. Popular Medicines Section (final, at bottom)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Popular Medicines',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/popular-medicines');
                          },
                          child: const Text(
                            'See all',
                            style: TextStyle(color: AppTheme.primaryTeal),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Top Rated',
                            style: TextStyle(
                              color: AppTheme.primaryTeal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Consumer<ProductProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                        ),
                      );
                    }

                    List<MedicineModel> medicinesToUse = provider.medicines;
                    if (medicinesToUse.isEmpty) {
                      medicinesToUse = _getDummyProducts();
                    }

                    final popular = List<MedicineModel>.from(medicinesToUse)
                      ..sort((a, b) {
                        final ar = a.rating ?? 0;
                        final br = b.rating ?? 0;
                        if (br != ar) return br.compareTo(ar);
                        final ac = a.reviewCount ?? 0;
                        final bc = b.reviewCount ?? 0;
                        return bc.compareTo(ac);
                      });
                    final display = popular.take(6).toList();

                    if (display.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return SizedBox(
                      height: 200,
                      child: Scrollbar(
                        controller: _popularScrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        thickness: 4,
                        radius: const Radius.circular(8),
                        child: ListView.builder(
                          controller: _popularScrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: display.length,
                          itemBuilder: (context, index) {
                              final medicine = display[index];
                              return Container(
                                width: 150,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: AppTheme.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductDetailsScreen(medicine: medicine),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: medicine.imageUrl,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            placeholder: (context, url) => Container(
                                              color: AppTheme.lightGray,
                                              child: const Center(
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                                                ),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Container(
                                              color: AppTheme.lightGray,
                                              child: const Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              medicine.name,
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              medicine.description,
                                              style: const TextStyle(fontSize: 10, color: AppTheme.darkGray),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            if (medicine.rating != null || medicine.reviewCount != null)
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (medicine.rating != null) ...[
                                                    const Icon(Icons.star, size: 12, color: AppTheme.primaryTeal),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      medicine.rating!.toStringAsFixed(1),
                                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                                    ),
                                                  ],
                                                  if (medicine.reviewCount != null) ...[
                                                    const SizedBox(width: 6),
                                                    Text('(${medicine.reviewCount})', style: const TextStyle(fontSize: 10, color: AppTheme.gray)),
                                                  ],
                                                ],
                                              ),
                                            if (medicine.rating != null || medicine.reviewCount != null)
                                              const SizedBox(height: 4),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '₹${medicine.finalPrice.toStringAsFixed(2)}',
                                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                                                ),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: Text(
                                                    'MRP ₹${medicine.price.toStringAsFixed(2)}',
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(fontSize: 10, color: AppTheme.gray, decoration: TextDecoration.lineThrough),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
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
                ),
              ],
            ),
          ),

          // Banner 2 Section (after Popular Medicines)
          Consumer<ProductProvider>(
            builder: (context, provider, _) {
              final meds = provider.medicines.isNotEmpty
                  ? provider.medicines
                  : _getDummyProducts();
              final images = meds.take(5).map((m) => m.imageUrl).toList();
              if (images.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: SizedBox(
                  height: 180,
                  child: PageView.builder(
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      final url = images[index % images.length];
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: AppTheme.tealGradient,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: kIsWeb
                              ? Image.network(url, fit: BoxFit.cover)
                              : CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.cover,
                                  placeholder: (context, _) => Container(
                                    color: AppTheme.lightGray,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, _, __) => Container(
                                    color: AppTheme.lightGray,
                                    child: const Icon(Icons.image, size: 48),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Best Selling Medicines (similar to Popular)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Best Selling Medicines',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/best-selling');
                          },
                          child: const Text(
                            'See all',
                            style: TextStyle(color: AppTheme.primaryTeal),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Trending',
                            style: TextStyle(
                              color: AppTheme.primaryTeal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Consumer<ProductProvider>(
                  builder: (context, provider, child) {
                    List<MedicineModel> meds = provider.medicines;
                    if (meds.isEmpty) {
                      meds = _getDummyProducts();
                    }

                    final bestSelling = List<MedicineModel>.from(meds)
                      ..sort((a, b) {
                        final ac = a.reviewCount ?? 0; // proxy for sales
                        final bc = b.reviewCount ?? 0;
                        if (bc != ac) return bc.compareTo(ac);
                        final ar = a.rating ?? 0;
                        final br = b.rating ?? 0;
                        return br.compareTo(ar);
                      });
                    final display = bestSelling.take(6).toList();

                    if (display.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return SizedBox(
                      height: 200,
                      child: Scrollbar(
                        controller: _bestSellingScrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        thickness: 4,
                        radius: const Radius.circular(8),
                        child: ListView.builder(
                          controller: _bestSellingScrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: display.length,
                          itemBuilder: (context, index) {
                            final medicine = display[index];
                            return Container(
                              width: 150,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailsScreen(medicine: medicine),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: medicine.imageUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          placeholder: (context, url) => Container(
                                            color: AppTheme.lightGray,
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Container(
                                            color: AppTheme.lightGray,
                                            child: const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            medicine.name,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            medicine.description,
                                            style: const TextStyle(fontSize: 10, color: AppTheme.darkGray),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          if (medicine.rating != null || medicine.reviewCount != null)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (medicine.rating != null) ...[
                                                  const Icon(Icons.star, size: 12, color: AppTheme.primaryTeal),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    medicine.rating!.toStringAsFixed(1),
                                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                                  ),
                                                ],
                                                if (medicine.reviewCount != null) ...[
                                                  const SizedBox(width: 6),
                                                  Text('(${medicine.reviewCount})', style: const TextStyle(fontSize: 10, color: AppTheme.gray)),
                                                ],
                                              ],
                                            ),
                                          if (medicine.rating != null || medicine.reviewCount != null)
                                            const SizedBox(height: 4),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '₹${medicine.finalPrice.toStringAsFixed(2)}',
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  'MRP ₹${medicine.price.toStringAsFixed(2)}',
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 10, color: AppTheme.gray, decoration: TextDecoration.lineThrough),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
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
                ),
              ],
            ),
          ),
          
          // Best Healthcare section (bottom)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.tealGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Best Healthcare',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Top services and trusted providers near you',
                    style: TextStyle(
                      color: AppTheme.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_hospital_outlined, color: AppTheme.white, size: 28),
                            SizedBox(height: 6),
                            Text('Doctors', style: TextStyle(color: AppTheme.white, fontSize: 12)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_pharmacy_outlined, color: AppTheme.white, size: 28),
                            SizedBox(height: 6),
                            Text('Pharmacy', style: TextStyle(color: AppTheme.white, fontSize: 12)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.biotech_outlined, color: AppTheme.white, size: 28),
                            SizedBox(height: 6),
                            Text('Lab Tests', style: TextStyle(color: AppTheme.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Best Booked Medicines section (bottom)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Best Booked Medicines',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/best-booked');
                          },
                          child: const Text(
                            'See all',
                            style: TextStyle(color: AppTheme.primaryTeal),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Popular',
                            style: TextStyle(
                              color: AppTheme.primaryTeal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Consumer<ProductProvider>(
                  builder: (context, provider, child) {
                    List<MedicineModel> meds = provider.medicines;
                    if (meds.isEmpty) {
                      meds = _getDummyProducts();
                    }

                    final bestBooked = List<MedicineModel>.from(meds)
                      ..sort((a, b) {
                        final ar = a.rating ?? 0;
                        final br = b.rating ?? 0;
                        if (br != ar) return br.compareTo(ar);
                        final ac = a.reviewCount ?? 0;
                        final bc = b.reviewCount ?? 0;
                        return bc.compareTo(ac);
                      });
                    final display = bestBooked.take(6).toList();

                    if (display.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return SizedBox(
                      height: 200,
                      child: Scrollbar(
                        controller: _bestBookedScrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        thickness: 4,
                        radius: const Radius.circular(8),
                        child: ListView.builder(
                          controller: _bestBookedScrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: display.length,
                          itemBuilder: (context, index) {
                            final medicine = display[index];
                            return Container(
                              width: 150,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailsScreen(medicine: medicine),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: medicine.imageUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          placeholder: (context, url) => Container(
                                            color: AppTheme.lightGray,
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Container(
                                            color: AppTheme.lightGray,
                                            child: const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            medicine.name,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            medicine.description,
                                            style: const TextStyle(fontSize: 10, color: AppTheme.darkGray),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          if (medicine.rating != null || medicine.reviewCount != null)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (medicine.rating != null) ...[
                                                  const Icon(Icons.star, size: 12, color: AppTheme.primaryTeal),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    medicine.rating!.toStringAsFixed(1),
                                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                                  ),
                                                ],
                                                if (medicine.reviewCount != null) ...[
                                                  const SizedBox(width: 6),
                                                  Text('(${medicine.reviewCount})', style: const TextStyle(fontSize: 10, color: AppTheme.gray)),
                                                ],
                                              ],
                                            ),
                                          if (medicine.rating != null || medicine.reviewCount != null)
                                            const SizedBox(height: 4),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '₹${medicine.finalPrice.toStringAsFixed(2)}',
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  'MRP ₹${medicine.price.toStringAsFixed(2)}',
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 10, color: AppTheme.gray, decoration: TextDecoration.lineThrough),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
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
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

        // Popular Brands Section (bottom of Home page)
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Popular Brands',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/popular-brands');
                },
                child: const Text(
                  'See all',
                  style: TextStyle(color: AppTheme.primaryTeal),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _popularBrands.length,
            itemBuilder: (context, index) {
              final brand = _popularBrands[index];
              return Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.tealGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: AppTheme.white,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: brand['logo'] ?? '',
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryTeal,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.local_pharmacy,
                            color: AppTheme.primaryTeal,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      brand['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.white,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        ],
      ),
    );
  }

  Widget _buildCategoriesPage(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: StreamBuilder<List<CategoryModel>>(
              stream: _firestoreService.getActiveCategoriesDetailed(),
              builder: (context, snapshot) {
                final categories = snapshot.data ?? [];
                if (categories.isEmpty) {
                  return const Center(child: Text('No categories'));
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return InkWell(
                      onTap: () {
                        final icon = _parseIconFromImageUrl(category.imageUrl);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryDetailsScreen(
                              categoryName: category.name,
                              categoryIcon: icon ?? Icons.category_outlined,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.lightGray,
                              border: Border.all(
                                color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Center(
                              child: _buildCategoryIconOrImage(category),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryTeal,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMedicinesPage(
      BuildContext context, ProductProvider productProvider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search medicines...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              productProvider.setSearchQuery(value);
            },
          ),
        ),
        Expanded(
          child: Consumer<ProductProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.medicines.isEmpty) {
                return const Center(
                  child: Text('No medicines found'),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.medicines.length,
                itemBuilder: (context, index) {
                  final medicine = provider.medicines[index];
                  return MedicineCard(
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
                  );
                },
              );
            },
          ),
        ),
        // (Removed misplaced sections from Medicines page)

      ],
    );
  }

  void _showSearchDialog(
      BuildContext context, ProductProvider productProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Medicines'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter medicine name...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            productProvider.setSearchQuery(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}