import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/medicine_card.dart';
import '../../widgets/common_header.dart';
import '../../models/medicine_model.dart';
import 'product_details_screen.dart';

class AvailableMedicinesScreen extends StatelessWidget {
  const AvailableMedicinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Consumer<ProductProvider>(
          builder: (context, provider, child) {
            // Get all available medicines (stock > 0)
            List<MedicineModel> availableMedicines = provider.allMedicines
                .where((medicine) => medicine.stock > 0 && medicine.isActive)
                .toList();

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
                _buildHeader(availableMedicines.length),
                Expanded(
                  child: availableMedicines.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: availableMedicines.length,
                          itemBuilder: (context, index) {
                            final medicine = availableMedicines[index];
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
              Icons.medication,
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
                  'Available Medicines',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count ${count == 1 ? 'medicine' : 'medicines'} in stock',
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
            Icons.medication_outlined,
            size: 80,
            color: AppTheme.gray.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No medicines available',
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








