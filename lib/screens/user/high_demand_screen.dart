import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/medicine_card.dart';
import '../../widgets/common_header.dart';
import '../../models/medicine_model.dart';
import 'product_details_screen.dart';

class HighDemandScreen extends StatelessWidget {
  const HighDemandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Consumer<ProductProvider>(
          builder: (context, provider, child) {
            List<MedicineModel> medicines = provider.allMedicines;
            
            // Sort by review count and rating (high demand = high reviews + high rating)
            List<MedicineModel> highDemand = List<MedicineModel>.from(medicines)
              ..sort((a, b) {
                final aReviews = a.reviewCount ?? 0;
                final bReviews = b.reviewCount ?? 0;
                if (bReviews != aReviews) return bReviews.compareTo(aReviews);
                final aRating = a.rating ?? 0;
                final bRating = b.rating ?? 0;
                return bRating.compareTo(aRating);
              });

            if (provider.isLoading) {
              return const Column(
                children: [
                  CommonHeader(showBackButton: true),
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                CommonHeader(
                  showBackButton: true,
                  onSearchTap: () {
                    _showSearchDialog(context, provider);
                  },
                ),
                _buildHeader(highDemand.length),
                Expanded(
                  child: highDemand.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: highDemand.length,
                          itemBuilder: (context, index) {
                            final medicine = highDemand[index];
                            return MedicineCard(
                              medicine: medicine,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailsScreen(medicine: medicine),
                                  ),
                                );
                              },
                            );
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

  Widget _buildHeader(int count) {
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
              Icons.trending_up,
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
                  'High Demand Products',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count ${count == 1 ? 'product' : 'products'} available',
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_flat,
            size: 80,
            color: AppTheme.gray.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No high demand products',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGray,
            ),
          ),
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








