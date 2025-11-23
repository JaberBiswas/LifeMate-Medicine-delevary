import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/order_model.dart';
import '../../models/order_item_model.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  String _paymentMethod = 'cash';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Check if user is authenticated
    if (!userProvider.isAuthenticated) {
      // Redirect to login, and pass the current route as a return route
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/login',
            arguments: '/checkout', // Return to checkout after login
          );
        }
      });
      return;
    }

    // User is authenticated, populate form fields
    if (userProvider.user != null) {
      _nameController.text = userProvider.user!.name;
      _phoneController.text = userProvider.user!.phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      if (cartProvider.cartItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your cart is empty')),
        );
        return;
      }

      final orderItems = cartProvider.cartItems.map((item) {
        return OrderItemModel(
          medicineId: item.medicineId,
          medicineName: item.medicineName,
          imageUrl: item.imageUrl,
          price: item.price,
          quantity: item.quantity,
        );
      }).toList();

      final order = OrderModel(
        id: '',
        userId: userProvider.user!.id,
        items: orderItems,
        totalAmount: cartProvider.totalAmount,
        status: AppConstants.orderPending,
        paymentStatus: AppConstants.paymentPending,
        paymentMethod: _paymentMethod,
        shippingAddress: {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'pincode': _pincodeController.text.trim(),
        },
        createdAt: DateTime.now(),
      );

      await orderProvider.createOrder(order);
      await cartProvider.clearCart();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/orders');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error placing order: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.lightGray,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...cartProvider.cartItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.medicineName} x ${item.quantity}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              '₹${item.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${cartProvider.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Shipping Address
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shipping Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Full Name',
                      controller: _nameController,
                      prefixIcon: const Icon(Icons.person_outlined),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Address',
                      controller: _addressController,
                      maxLines: 2,
                      prefixIcon: const Icon(Icons.home_outlined),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'City',
                            controller: _cityController,
                            prefixIcon: const Icon(Icons.location_city_outlined),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            label: 'State',
                            controller: _stateController,
                            prefixIcon: const Icon(Icons.map_outlined),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Pincode',
                      controller: _pincodeController,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.pin_outlined),
                    ),
                  ],
                ),
              ),

              // Payment Method
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: Icon(
                        _paymentMethod == 'cash'
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: _paymentMethod == 'cash'
                            ? AppTheme.primaryTeal
                            : AppTheme.gray,
                      ),
                      title: const Text('Cash on Delivery'),
                      selected: _paymentMethod == 'cash',
                      onTap: () {
                        setState(() => _paymentMethod = 'cash');
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        _paymentMethod == 'online'
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: _paymentMethod == 'online'
                            ? AppTheme.primaryTeal
                            : AppTheme.gray,
                      ),
                      title: const Text('Online Payment'),
                      selected: _paymentMethod == 'online',
                      onTap: () {
                        setState(() => _paymentMethod = 'online');
                      },
                    ),
                  ],
                ),
              ),

              // Place Order Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: CustomButton(
                  text: 'Place Order',
                  onPressed: _placeOrder,
                  isLoading: _isLoading,
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

