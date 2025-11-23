import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/user/product_details_screen.dart';
import '../screens/user/cart_screen.dart';
import '../providers/product_provider.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showSearch;
  final bool showCart;
  final bool showBackButton;
  final bool showNotifications;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchPressed;

  const AppHeader({
    super.key,
    this.title,
    this.showSearch = true,
    this.showCart = true,
    this.showBackButton = true,
    this.showNotifications = false,
    this.onSearchChanged,
    this.onSearchPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBackButton,
      title: title != null ? Text(title!) : null,
      actions: [
        if (showSearch)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              if (onSearchPressed != null) {
                onSearchPressed!();
              } else {
                showSearchDialog(context);
              }
            },
          ),
        if (showNotifications)
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notifications
            },
          ),
        if (showCart)
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ),
              );
            },
          ),
      ],
    );
  }

  void showSearchDialog(BuildContext context) {
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
