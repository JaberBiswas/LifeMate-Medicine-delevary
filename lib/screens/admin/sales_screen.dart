import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<OrderProvider>(context, listen: false).loadAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    final deliveredOrders = orderProvider.orders
        .where((order) => order.status == AppConstants.orderDelivered)
        .toList();

    final totalSales = deliveredOrders.fold(
      0.0,
      (sum, order) => sum + order.totalAmount,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Report'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Sales',
                    '₹${totalSales.toStringAsFixed(2)}',
                    Icons.attach_money_outlined,
                    AppTheme.successGreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Total Orders',
                    '${deliveredOrders.length}',
                    Icons.shopping_bag_outlined,
                    AppTheme.primaryTeal,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Sales List
            const Text(
              'Sales History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            orderProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : deliveredOrders.isEmpty
                    ? const Center(child: Text('No sales yet'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: deliveredOrders.length,
                        itemBuilder: (context, index) {
                          final order = deliveredOrders[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(Icons.receipt_outlined,
                                  color: AppTheme.successGreen),
                              title: Text(
                                'Order #${order.id.substring(0, 8)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                DateFormat('MMM dd, yyyy - HH:mm')
                                    .format(order.createdAt),
                              ),
                              trailing: Text(
                                '₹${order.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.successGreen,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.gray,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

