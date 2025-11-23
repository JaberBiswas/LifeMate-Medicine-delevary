import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../utils/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderProvider.orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 80,
                        color: AppTheme.gray.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No orders yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.gray,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orderProvider.orders.length,
                  itemBuilder: (context, index) {
                    final order = orderProvider.orders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text(
                          'Order #${order.id.substring(0, 8)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('MMM dd, yyyy - HH:mm')
                                  .format(order.createdAt),
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildStatusChip(order.status),
                                const SizedBox(width: 8),
                                Text(
                                  '₹${order.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryTeal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Items',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...order.items.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: CachedNetworkImage(
                                            imageUrl: item.imageUrl,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorWidget: (context, url, error) =>
                                                Container(
                                              width: 50,
                                              height: 50,
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
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                'Qty: ${item.quantity} x ₹${item.price.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppTheme.gray,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '₹${item.subtotal.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total Amount',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '₹${order.totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryTeal,
                                      ),
                                    ),
                                  ],
                                ),
                                if (order.shippingAddress != null) ...[
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Shipping Address',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${order.shippingAddress!['name']}\n'
                                    '${order.shippingAddress!['address']}\n'
                                    '${order.shippingAddress!['city']}, ${order.shippingAddress!['state']} - ${order.shippingAddress!['pincode']}\n'
                                    'Phone: ${order.shippingAddress!['phone']}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = AppTheme.gray;
        break;
      case 'confirmed':
      case 'processing':
        color = Colors.blue;
        break;
      case 'shipped':
        color = Colors.orange;
        break;
      case 'delivered':
        color = AppTheme.successGreen;
        break;
      case 'cancelled':
        color = AppTheme.errorRed;
        break;
      default:
        color = AppTheme.gray;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

