import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/theme.dart';
import '../screens/user/cart_screen.dart';
import '../screens/user/product_details_screen.dart';

/// Reusable header widget for all pages
/// This header includes: Brand logo/name, Search box, Notification, Cart
class CommonHeader extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final bool showSearchBox;
  final bool showNotification;
  final bool showCart;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CommonHeader({
    super.key,
    this.onSearchTap,
    this.onNotificationTap,
    this.showSearchBox = true,
    this.showNotification = true,
    this.showCart = true,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back Button (if enabled)
          if (showBackButton) ...[
            IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppTheme.primaryTeal,
              ),
              onPressed: () {
                if (onBackPressed != null) {
                  onBackPressed!();
                } else {
                  Navigator.pop(context);
                }
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Brand Logo and Name
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppTheme.tealGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: AppTheme.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'LifeMate',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Search Box
          if (showSearchBox) ...[
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                  ),
                ),
                child: TextField(
                  onTap: () {
                    if (onSearchTap != null) {
                      onSearchTap!();
                    } else {
                      _showSearchDialog(context, productProvider);
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search medicines...',
                    hintStyle: TextStyle(
                      color: AppTheme.gray,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppTheme.primaryTeal,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
          // Notification Icon
          if (showNotification) ...[
            Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.primaryTeal,
                    size: 24,
                  ),
                  onPressed: () {
                    if (onNotificationTap != null) {
                      onNotificationTap!();
                    }
                    // Handle notifications
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.errorRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
          // Cart Icon with Badge
          if (showCart) ...[
            Consumer<CartProvider>(
              builder: (context, cart, child) {
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                        color: AppTheme.primaryTeal,
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartScreen(),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                    if (cart.itemCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.errorRed,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cart.itemCount > 9 ? '9+' : cart.itemCount}',
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context, ProductProvider productProvider) {
    showDialog(
      context: context,
      builder: (context) => _SearchDialog(),
    );
  }
}

class _SearchDialog extends StatefulWidget {
  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query, BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.setSearchQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search medicines...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (query) => _performSearch(query, context),
              ),
            ),
            if (productProvider.isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )
            else if (productProvider.medicines.isEmpty && _searchController.text.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No results found'),
              )
            else
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: productProvider.medicines.length,
                  itemBuilder: (context, index) {
                    final medicine = productProvider.medicines[index];
                    return ListTile(
                      title: Text(medicine.name),
                      subtitle: Text('₹${medicine.finalPrice.toStringAsFixed(2)}'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsScreen(
                              medicine: medicine,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

