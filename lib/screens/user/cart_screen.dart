import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/common_header.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Reload cart when screen opens to ensure it's up to date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Common Header with back button
            const CommonHeader(
              showBackButton: true,
              showSearchBox: false,
              showNotification: false,
              showCart: false,
            ),
            Expanded(
              child: cartProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : cartProvider.cartItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 80,
                                color: AppTheme.gray.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Your cart is empty',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppTheme.gray,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Continue Shopping'),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartProvider.cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartProvider.cartItems[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: item.imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        width: 80,
                                        height: 80,
                                        color: AppTheme.lightGray,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        width: 80,
                                        height: 80,
                                        color: AppTheme.lightGray,
                                        child: const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.medicineName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '₹${item.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryTeal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline),
                                            onPressed: () {
                                              if (item.quantity > 1) {
                                                cartProvider.updateQuantity(
                                                  item.medicineId,
                                                  item.quantity - 1,
                                                );
                                              } else {
                                                cartProvider.removeFromCart(
                                                  item.medicineId,
                                                );
                                              }
                                            },
                                            color: AppTheme.primaryTeal,
                                          ),
                                          Text(
                                            '${item.quantity}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add_circle_outline),
                                            onPressed: () {
                                              cartProvider.updateQuantity(
                                                item.medicineId,
                                                item.quantity + 1,
                                              );
                                            },
                                            color: AppTheme.primaryTeal,
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          cartProvider.removeFromCart(
                                            item.medicineId,
                                          );
                                        },
                                        child: const Text(
                                          'Remove',
                                          style: TextStyle(
                                            color: AppTheme.errorRed,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
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
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '₹${cartProvider.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTeal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Proceed to Checkout',
                            onPressed: () {
                              Navigator.pushNamed(context, '/checkout');
                            },
                            width: double.infinity,
                          ),
                        ],
                      ),
                    ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

