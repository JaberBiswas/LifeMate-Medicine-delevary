import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/product_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/medicine_card.dart';
import '../../widgets/common_header.dart';
import '../../models/medicine_model.dart';
import 'product_details_screen.dart';

class PopularBrandsScreen extends StatelessWidget {
  const PopularBrandsScreen({super.key});

  // Popular brands (name + logo)
  final List<Map<String, String>> _popularBrands = const [
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Consumer<ProductProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                CommonHeader(
                  showBackButton: true,
                  onSearchTap: () {
                    _showSearchDialog(context, provider);
                  },
                ),
                _buildHeader(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _popularBrands.length,
                    itemBuilder: (context, index) {
                      final brand = _popularBrands[index];
                      final brandMedicines = provider.allMedicines
                          .where((medicine) =>
                              medicine.manufacturer?.toLowerCase() ==
                              brand['name']?.toLowerCase())
                          .toList();
                      
                      return _buildBrandSection(context, brand, brandMedicines);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.tealGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.business,
              color: AppTheme.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Popular Brands',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_popularBrands.length} brands available',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandSection(BuildContext context, Map<String, String> brand, List<MedicineModel> medicines) {
    const topBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    );
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gray.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: AppTheme.tealGradient,
              borderRadius: topBorderRadius,
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: AppTheme.white,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: brand['logo'] ?? '',
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.local_pharmacy,
                        color: AppTheme.primaryTeal,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brand['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.white,
                        ),
                      ),
                      Text(
                        '${medicines.length} ${medicines.length == 1 ? 'product' : 'products'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Medicines List
          if (medicines.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No products from ${brand['name']}',
                  style: const TextStyle(
                    color: AppTheme.gray,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...medicines.map((medicine) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: MedicineCard(
                  medicine: medicine,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(medicine: medicine),
                      ),
                    );
                  },
                ),
              );
            }),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context, ProductProvider provider) {
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
            provider.setSearchQuery(value);
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

