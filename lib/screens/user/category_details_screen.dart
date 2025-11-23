import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/medicine_card.dart';
import '../../widgets/common_header.dart';
import '../../models/medicine_model.dart';
import 'product_details_screen.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final String categoryName;
  final IconData? categoryIcon;

  const CategoryDetailsScreen({
    super.key,
    required this.categoryName,
    this.categoryIcon,
  });

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  // Filter states
  String? selectedCategory;
  String? selectedBrand;
  PriceRange? selectedPriceRange;
  DiscountRange? selectedDiscount;
  double? minRating;
  bool showOffersOnly = false;
  
  // Price range slider values
  RangeValues priceRange = const RangeValues(100, 100000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Consumer<ProductProvider>(
          builder: (context, provider, child) {
            // Get all products matching the category
            List<MedicineModel> baseProducts = provider.allMedicines
                .where((medicine) =>
                    medicine.category.toLowerCase() ==
                    widget.categoryName.toLowerCase())
                .toList();

            // If no exact match, try partial match
            if (baseProducts.isEmpty) {
              baseProducts = provider.allMedicines
                  .where((medicine) => medicine.category
                      .toLowerCase()
                      .contains(widget.categoryName.toLowerCase()))
                  .toList();
            }

            // Apply filters
            List<MedicineModel> filteredProducts = _applyFilters(baseProducts);

            // If still no match and we have all products loaded, show empty state
            if (filteredProducts.isEmpty && !provider.isLoading) {
              return Column(
                children: [
                  CommonHeader(
                    showBackButton: true,
                    onSearchTap: () {
                      _showSearchDialog(context, provider);
                    },
                  ),
                  _buildCategoryHeader(filteredProducts.length),
                  _buildEmptyState(),
                ],
              );
            }

            if (provider.isLoading) {
              return const Column(
                children: [
                  CommonHeader(showBackButton: true),
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                      ),
                    ),
                  ),
                ],
              );
            }

            // Get unique values for filters
            final categories = baseProducts
                .map((p) => p.category)
                .toSet()
                .toList()
              ..sort();
            final brands = baseProducts
                .where((p) => p.manufacturer != null)
                .map((p) => p.manufacturer!)
                .toSet()
                .toList()
              ..sort();

            return Column(
              children: [
                // Common Header
                CommonHeader(
                  showBackButton: true,
                  onSearchTap: () {
                    _showSearchDialog(context, provider);
                  },
                ),

                // Category Header with Filter Button
                _buildCategoryHeader(filteredProducts.length),

                // Filter Chips Row
                _buildFilterChips(categories, brands),

                // Products List
                Expanded(
                  child: filteredProducts.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final medicine = filteredProducts[index];
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
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(int productCount) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.tealGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          if (widget.categoryIcon != null)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.categoryIcon,
                color: AppTheme.white,
                size: 28,
              ),
            ),
          if (widget.categoryIcon != null) const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.categoryName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$productCount ${productCount == 1 ? 'product' : 'products'} available',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          // Filter Button
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppTheme.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => _buildFilterSheet(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(List<String> categories, List<String> brands) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (selectedCategory != null)
            _buildChip(
              label: selectedCategory!,
              onRemove: () => setState(() => selectedCategory = null),
            ),
          if (selectedBrand != null)
            _buildChip(
              label: selectedBrand!,
              onRemove: () => setState(() => selectedBrand = null),
            ),
          if (selectedPriceRange != null)
            _buildChip(
              label: selectedPriceRange!.label,
              onRemove: () => setState(() {
                selectedPriceRange = null;
                priceRange = const RangeValues(100, 100000);
              }),
            )
          else if (priceRange.start > 100 || priceRange.end < 100000)
            _buildChip(
              label: '₹${priceRange.start.round()} - ₹${priceRange.end.round()}',
              onRemove: () => setState(() {
                priceRange = const RangeValues(100, 100000);
              }),
            ),
          if (selectedDiscount != null)
            _buildChip(
              label: selectedDiscount!.label,
              onRemove: () => setState(() => selectedDiscount = null),
            ),
          if (minRating != null)
            _buildChip(
              label: 'Rating: ${minRating!}+ ⭐',
              onRemove: () => setState(() => minRating = null),
            ),
          if (showOffersOnly)
            _buildChip(
              label: 'Offers Only',
              onRemove: () => setState(() => showOffersOnly = false),
            ),
        ],
      ),
    );
  }

  Widget _buildChip({required String label, required VoidCallback onRemove}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        onDeleted: onRemove,
        deleteIcon: const Icon(Icons.close, size: 18),
        backgroundColor: AppTheme.lightTeal,
        labelStyle: const TextStyle(color: AppTheme.primaryTeal),
      ),
    );
  }

  Widget _buildFilterSheet() {
    final productProvider = Provider.of<ProductProvider>(context);
    final baseProducts = productProvider.allMedicines
        .where((medicine) =>
            medicine.category.toLowerCase() ==
            widget.categoryName.toLowerCase())
        .toList();

    final categories = baseProducts.map((p) => p.category).toSet().toList()
      ..sort();
    final brands = baseProducts
        .where((p) => p.manufacturer != null)
        .map((p) => p.manufacturer!)
        .toSet()
        .toList()
      ..sort();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.lightGray),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTeal,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedCategory = null;
                      selectedBrand = null;
                      selectedPriceRange = null;
                      selectedDiscount = null;
                      minRating = null;
                      showOffersOnly = false;
                      priceRange = const RangeValues(100, 100000);
                    });
                  },
                  child: const Text(
                    'Clear All',
                    style: TextStyle(color: AppTheme.primaryTeal),
                  ),
                ),
              ],
            ),
          ),

          // Filter Options
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories Filter
                  _buildSectionTitle('Categories'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((category) {
                      final isSelected = selectedCategory == category;
                      return FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = selected ? category : null;
                          });
                        },
                        selectedColor: AppTheme.lightTeal,
                        checkmarkColor: AppTheme.primaryTeal,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.primaryTeal
                              : AppTheme.darkGray,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Brands Filter
                  _buildSectionTitle('Brands'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: brands.map((brand) {
                      final isSelected = selectedBrand == brand;
                      return FilterChip(
                        label: Text(brand),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedBrand = selected ? brand : null;
                          });
                        },
                        selectedColor: AppTheme.lightTeal,
                        checkmarkColor: AppTheme.primaryTeal,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.primaryTeal
                              : AppTheme.darkGray,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Price Range Filter
                  _buildSectionTitle('Price Range'),
                  const SizedBox(height: 12),
                  // Price Range Slider
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        RangeSlider(
                          values: priceRange,
                          min: 100,
                          max: 100000,
                          divisions: 999,
                          labels: RangeLabels(
                            '₹${priceRange.start.round()}',
                            '₹${priceRange.end.round()}',
                          ),
                          activeColor: AppTheme.primaryTeal,
                          inactiveColor: AppTheme.lightGray,
                          onChanged: (RangeValues values) {
                            setState(() {
                              priceRange = values;
                              // Clear selected price range chips when using slider
                              selectedPriceRange = null;
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₹${priceRange.start.round()}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                            Text(
                              '₹${priceRange.end.round()}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Price Range Chips (Quick Select)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: PriceRange.all.map((priceRangeChip) {
                      final isSelected = selectedPriceRange == priceRangeChip;
                      return FilterChip(
                        label: Text(priceRangeChip.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedPriceRange = selected ? priceRangeChip : null;
                            // Reset slider when chip is selected
                            if (selected) {
                              priceRange = RangeValues(
                                priceRangeChip.min,
                                priceRangeChip.max == double.infinity
                                    ? 100000
                                    : priceRangeChip.max,
                              );
                            }
                          });
                        },
                        selectedColor: AppTheme.lightTeal,
                        checkmarkColor: AppTheme.primaryTeal,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.primaryTeal
                              : AppTheme.darkGray,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Discount Filter
                  _buildSectionTitle('Discount'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: DiscountRange.all.map((discount) {
                      final isSelected = selectedDiscount == discount;
                      return FilterChip(
                        label: Text(discount.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedDiscount = selected ? discount : null;
                          });
                        },
                        selectedColor: AppTheme.lightTeal,
                        checkmarkColor: AppTheme.primaryTeal,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.primaryTeal
                              : AppTheme.darkGray,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Rating Filter
                  _buildSectionTitle('Minimum Rating'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [4.0, 3.5, 3.0].map((rating) {
                      final isSelected = minRating == rating;
                      return FilterChip(
                        label: Text('$rating+ ⭐'),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            minRating = selected ? rating : null;
                          });
                        },
                        selectedColor: AppTheme.lightTeal,
                        checkmarkColor: AppTheme.primaryTeal,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.primaryTeal
                              : AppTheme.darkGray,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Offers Filter
                  _buildSectionTitle('Special Offers'),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Show products with offers only'),
                    value: showOffersOnly,
                    onChanged: (value) {
                      setState(() {
                        showOffersOnly = value;
                      });
                    },
                    activeThumbColor: AppTheme.primaryTeal,
                  ),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppTheme.lightGray),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.darkGray,
      ),
    );
  }

  List<MedicineModel> _applyFilters(List<MedicineModel> products) {
    List<MedicineModel> filtered = List.from(products);

    // Category filter
    if (selectedCategory != null) {
      filtered = filtered
          .where((p) => p.category == selectedCategory)
          .toList();
    }

    // Brand filter
    if (selectedBrand != null) {
      filtered = filtered
          .where((p) => p.manufacturer == selectedBrand)
          .toList();
    }

    // Price range filter
    if (selectedPriceRange != null) {
      filtered = filtered.where((p) {
        final price = p.finalPrice;
        return price >= selectedPriceRange!.min &&
            price <= selectedPriceRange!.max;
      }).toList();
    } else {
      // Apply slider price range filter
      filtered = filtered.where((p) {
        final price = p.finalPrice;
        return price >= priceRange.start && price <= priceRange.end;
      }).toList();
    }

    // Discount filter
    if (selectedDiscount != null) {
      filtered = filtered.where((p) {
        if (p.discountPrice == null) return false;
        final discount = p.discountPercent;
        return discount >= selectedDiscount!.min &&
            discount <= selectedDiscount!.max;
      }).toList();
    }

    // Rating filter
    if (minRating != null) {
      filtered = filtered.where((p) {
        return p.rating != null && p.rating! >= minRating!;
      }).toList();
    }

    // Offers filter
    if (showOffersOnly) {
      filtered = filtered.where((p) => p.discountPrice != null).toList();
    }

    return filtered;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_alt_off_outlined,
            size: 80,
            color: AppTheme.gray.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No products found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.gray,
            ),
            textAlign: TextAlign.center,
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

// Price Range Model
class PriceRange {
  final double min;
  final double max;
  final String label;

  const PriceRange(this.min, this.max, this.label);

  static const List<PriceRange> all = [
    PriceRange(0, 100, 'Under ₹100'),
    PriceRange(100, 500, '₹100 - ₹500'),
    PriceRange(500, 1000, '₹500 - ₹1000'),
    PriceRange(1000, 2000, '₹1000 - ₹2000'),
    PriceRange(2000, double.infinity, 'Above ₹2000'),
  ];
}

// Discount Range Model
class DiscountRange {
  final double min;
  final double max;
  final String label;

  const DiscountRange(this.min, this.max, this.label);

  static const List<DiscountRange> all = [
    DiscountRange(0, 10, 'Up to 10%'),
    DiscountRange(10, 20, '10% - 20%'),
    DiscountRange(20, 30, '20% - 30%'),
    DiscountRange(30, 50, '30% - 50%'),
    DiscountRange(50, 100, 'Above 50%'),
  ];
}
