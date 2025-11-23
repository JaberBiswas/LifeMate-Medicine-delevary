import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medicine_model.dart';
import '../../models/cart_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/common_header.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'category_details_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final MedicineModel medicine;

  const ProductDetailsScreen({super.key, required this.medicine});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  String _selectedRatingType = 'Text'; // 'Text', 'Photo', 'Video'

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final isInCart = cartProvider.isInCart(widget.medicine.id);

    // Get similar products from same category
    final similarProducts = productProvider.allMedicines
        .where((medicine) =>
            medicine.category == widget.medicine.category &&
            medicine.id != widget.medicine.id)
        .take(5)
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            // Common Header with back button
            const CommonHeader(
              showBackButton: true,
              showSearchBox: false,
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section
                    Container(
                      width: double.infinity,
                      height: 280,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGray,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.gray.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: widget.medicine.imageUrl.isEmpty
                            ? Center(
                                child: Icon(
                                  Icons.medication_outlined,
                                  size: 80,
                                  color: AppTheme.primaryTeal.withValues(alpha: 0.5),
                                ),
                              )
                            : CachedNetworkImage(
                                imageUrl: widget.medicine.imageUrl,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.primaryTeal,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Center(
                                  child: Icon(
                                    Icons.error_outline,
                                    size: 50,
                                    color: AppTheme.gray,
                                  ),
                                ),
                              ),
                      ),
                    ),

                    // Product Info Section - Aligned with image margins
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Medicine Name
                          Text(
                            widget.medicine.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkGray,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Rating and Reviews
                          if (widget.medicine.rating != null)
                            Row(
                              children: [
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < widget.medicine.rating!.floor()
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: AppTheme.successGreen,
                                      size: 18,
                                    );
                                  }),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.medicine.rating!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.darkGray,
                                  ),
                                ),
                                if (widget.medicine.reviewCount != null) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${widget.medicine.reviewCount} reviews)',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.gray,
                                    ),
                                  ),
                                ],
                              ],
                            ),

                          const SizedBox(height: 16),

                          // Price Section
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${widget.medicine.finalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTeal,
                                ),
                              ),
                              if (widget.medicine.discountPrice != null) ...[
                                const SizedBox(width: 12),
                                Text(
                                  '₹${widget.medicine.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    decoration: TextDecoration.lineThrough,
                                    color: AppTheme.gray,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.successGreen,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${widget.medicine.discountPercent.toStringAsFixed(0)}% OFF',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Quantity Selector
                          Row(
                            children: [
                              const Text(
                                'Quantity:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.darkGray,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.primaryTeal),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        if (_quantity > 1) {
                                          setState(() => _quantity--);
                                        }
                                      },
                                      color: AppTheme.primaryTeal,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Text(
                                        '$_quantity',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        if (_quantity < widget.medicine.stock) {
                                          setState(() => _quantity++);
                                        }
                                      },
                                      color: AppTheme.primaryTeal,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Description
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkGray,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.medicine.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.gray,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Delivery Information Section
                          const Text(
                            'Delivery Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkGray,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: AppTheme.tealGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      widget.medicine.isPrescriptionRequired
                                          ? Icons.medical_services
                                          : Icons.local_shipping_outlined,
                                      color: AppTheme.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        widget.medicine.isPrescriptionRequired
                                            ? 'Prescription Required'
                                            : 'Prescription Not Required',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: AppTheme.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Free delivery on orders above ₹500',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: AppTheme.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Delivery within 24-48 hours',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Medicine Specifications Section
                          const Text(
                            'Specifications',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkGray,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.lightGray.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                _buildSpecRow('Category', widget.medicine.category,
                                    Icons.category_outlined),
                                if (widget.medicine.manufacturer != null) ...[
                                  const Divider(height: 20),
                                  _buildSpecRow('Manufacturer',
                                      widget.medicine.manufacturer!,
                                      Icons.business_outlined),
                                ],
                                const Divider(height: 20),
                                _buildSpecRow('Stock Available',
                                    '${widget.medicine.stock} units',
                                    Icons.inventory_2_outlined),
                                if (widget.medicine.expiryDate != null) ...[
                                  const Divider(height: 20),
                                  _buildSpecRow('Expiry Date',
                                      widget.medicine.expiryDate!,
                                      Icons.calendar_today_outlined),
                                ],
                                if (widget.medicine.tags != null &&
                                    widget.medicine.tags!.isNotEmpty) ...[
                                  const Divider(height: 20),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.label_outline,
                                          size: 20, color: AppTheme.primaryTeal),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Tags',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.gray,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 6,
                                              children: widget.medicine.tags!
                                                  .map((tag) => Chip(
                                                        label: Text(
                                                          tag,
                                                          style: const TextStyle(
                                                              fontSize: 11),
                                                        ),
                                                        backgroundColor:
                                                            AppTheme.lightTeal,
                                                        padding:
                                                            const EdgeInsets.all(4),
                                                      ))
                                                  .toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Customer Ratings Section
                          _buildCustomerRatingsSection(),

                          const SizedBox(height: 24),

                          // Similar Products Section
                          if (similarProducts.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Similar Products',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.darkGray,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CategoryDetailsScreen(
                                          categoryName: widget.medicine.category,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'View All',
                                    style: TextStyle(color: AppTheme.primaryTeal),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: similarProducts.length,
                                itemBuilder: (context, index) {
                                  final medicine = similarProducts[index];
                                  return Container(
                                    width: 160,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.lightGray,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.gray.withValues(alpha: 0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProductDetailsScreen(
                                              medicine: medicine,
                                            ),
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(12),
                                                topRight: Radius.circular(12),
                                              ),
                                              child: medicine.imageUrl.isEmpty
                                                  ? Container(
                                                      color: AppTheme.lightGray,
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.medication_outlined,
                                                          color:
                                                              AppTheme.primaryTeal,
                                                        ),
                                                      ),
                                                    )
                                                  : CachedNetworkImage(
                                                      imageUrl: medicine.imageUrl,
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                      placeholder: (context, url) =>
                                                          Container(
                                                        color: AppTheme.lightGray,
                                                        child: const Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                        ),
                                                      ),
                                                      errorWidget:
                                                          (context, url, error) =>
                                                              Container(
                                                        color: AppTheme.lightGray,
                                                        child: const Icon(
                                                          Icons.error,
                                                        ),
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
                                                Text(
                                                  medicine.name,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '₹${medicine.finalPrice.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.primaryTeal,
                                                  ),
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
                            const SizedBox(height: 100), // Bottom padding for fixed buttons
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Fixed Bottom Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.gray.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: isInCart ? 'View Cart' : 'Add to Cart',
                        backgroundColor: isInCart ? AppTheme.lightTeal : null,
                        onPressed: isInCart
                            ? () {
                                Navigator.pushNamed(context, '/cart');
                              }
                            : () async {
                                try {
                                  await cartProvider.addToCart(
                                    CartModel(
                                      medicineId: widget.medicine.id,
                                      medicineName: widget.medicine.name,
                                      imageUrl: widget.medicine.imageUrl,
                                      price: widget.medicine.finalPrice,
                                      quantity: _quantity,
                                    ),
                                  );
                                  if (!context.mounted) return;
                                  // Verify the item was added by checking if it's in the cart
                                  // Wait a short moment for the stream to propagate
                                  await Future.delayed(const Duration(milliseconds: 150));
                                  if (!context.mounted) return;
                                  
                                  final wasAdded = cartProvider.isInCart(widget.medicine.id);
                                  if (wasAdded) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Added to cart successfully'),
                                        backgroundColor: AppTheme.successGreen,
                                      ),
                                    );
                                  } else {
                                    throw Exception('Item was not added to cart');
                                  }
                                } catch (e) {
                                  if (!context.mounted) return;
                                  final isNotLoggedIn = e is NotLoggedInException;
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isNotLoggedIn 
                                          ? 'Please log in to add items to cart'
                                          : 'Failed to add to cart: ${e.toString()}'),
                                      backgroundColor: AppTheme.errorRed,
                                      action: isNotLoggedIn
                                          ? SnackBarAction(
                                              label: 'Login',
                                              textColor: AppTheme.white,
                                              onPressed: () {
                                                Navigator.pushNamed(context, '/login');
                                              },
                                            )
                                          : null,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Buy Now',
                        onPressed: () async {
                          try {
                            // Add to cart first if not already in cart
                            if (!isInCart) {
                              await cartProvider.addToCart(
                                CartModel(
                                  medicineId: widget.medicine.id,
                                  medicineName: widget.medicine.name,
                                  imageUrl: widget.medicine.imageUrl,
                                  price: widget.medicine.finalPrice,
                                  quantity: _quantity,
                                ),
                              );
                            }
                            if (!context.mounted) return;
                            Navigator.pushNamed(context, '/checkout');
                          } catch (e) {
                            if (!context.mounted) return;
                            final isNotLoggedIn = e is NotLoggedInException;
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isNotLoggedIn 
                                    ? 'Please log in to proceed'
                                    : 'Failed to add to cart: ${e.toString()}'),
                                backgroundColor: AppTheme.errorRed,
                                action: isNotLoggedIn
                                    ? SnackBarAction(
                                        label: 'Login',
                                        textColor: AppTheme.white,
                                        onPressed: () {
                                          Navigator.pushNamed(context, '/login');
                                        },
                                      )
                                    : null,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryTeal),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.gray,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerRatingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Ratings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 12),
        // Rating Type Selector
        Row(
          children: [
            Expanded(
              child: _buildRatingTypeButton('Text', Icons.text_fields),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildRatingTypeButton('Photo', Icons.photo),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildRatingTypeButton('Video', Icons.video_library),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Content based on selected type
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.lightGray.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildRatingContent(),
        ),
      ],
    );
  }

  Widget _buildRatingTypeButton(String type, IconData icon) {
    final isSelected = _selectedRatingType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRatingType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal : AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : AppTheme.lightGray,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppTheme.white : AppTheme.gray,
            ),
            const SizedBox(width: 6),
            Text(
              type,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.white : AppTheme.gray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingContent() {
    switch (_selectedRatingType) {
      case 'Photo':
        return Column(
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 48,
              color: AppTheme.primaryTeal.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'Photo Reviews',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No photo reviews yet. Be the first to share your experience!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.gray,
              ),
            ),
          ],
        );
      case 'Video':
        return Column(
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 48,
              color: AppTheme.primaryTeal.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'Video Reviews',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No video reviews yet. Share your video review with others!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.gray,
              ),
            ),
          ],
        );
      default: // Text
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.medicine.reviewCount != null && widget.medicine.reviewCount! > 0)
              ...List.generate(
                (widget.medicine.reviewCount! > 5 ? 5 : widget.medicine.reviewCount!).toInt(),
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryTeal.withValues(alpha: 0.2),
                            ),
                            child: Center(
                              child: Text(
                                'U${index + 1}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryTeal,
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
                                  'Customer ${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.darkGray,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex < (widget.medicine.rating ?? 4.0).floor()
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: AppTheme.successGreen,
                                      size: 14,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Great product! Works as expected. Very satisfied with the quality and delivery.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.gray,
                          height: 1.5,
                        ),
                      ),
                      if (index < (widget.medicine.reviewCount! > 5 ? 4 : widget.medicine.reviewCount! - 1))
                        const Divider(height: 24),
                    ],
                  ),
                ),
              )
            else
              const Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: AppTheme.gray,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No Reviews Yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Be the first to review this product!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.gray,
                    ),
                  ),
                ],
              ),
          ],
        );
    }
  }
}
