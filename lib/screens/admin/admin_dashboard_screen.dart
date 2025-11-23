import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/theme.dart';
import '../../models/medicine_model.dart';
import 'manage_categories_screen.dart';
import 'admin_products_screen.dart';
import 'manage_orders_screen.dart';
import 'manage_users_screen.dart';
import 'sales_screen.dart';
import 'admin_settings_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // Responsive + Sidebar state
  bool _isSidebarCollapsed = false; // tablet/desktop: 250 <-> 80
  bool _isMobileSidebarOpen = false; // mobile: 0 <-> 250 overlay

  static const double _sidebarExpandedWidth = 250;
  static const double _sidebarCollapsedWidth = 80;
  static const double _mobileBreakpoint = 600; // <600 = mobile

  bool get _isMobileLayout {
    final w = MediaQuery.of(context).size.width;
    return w < _mobileBreakpoint;
  }

  // Tablet/desktop helpers not used directly currently; rely on _isMobileLayout.

  double get _currentSidebarWidth {
    if (_isMobileLayout) {
      return _isMobileSidebarOpen ? _sidebarExpandedWidth : 0;
    }
    return _isSidebarCollapsed ? _sidebarCollapsedWidth : _sidebarExpandedWidth;
  }

  void _toggleSidebar() {
    if (_isMobileLayout) {
      setState(() {
        _isMobileSidebarOpen = !_isMobileSidebarOpen;
      });
      return;
    }
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  final List<Widget> _screens = [
    const _DashboardContent(),
    const ManageCategoriesScreen(),
    const AdminProductsScreen(),
    const ManageOrdersScreen(),
    const ManageUsersScreen(),
    const SalesScreen(),
    const AdminSettingsScreen(),
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard_outlined, 'label': 'Dashboard'},
    {'icon': Icons.category_outlined, 'label': 'Categories'},
    {'icon': Icons.medication_outlined, 'label': 'Products'},
    {'icon': Icons.shopping_bag_outlined, 'label': 'Orders'},
    {'icon': Icons.people_outlined, 'label': 'Users'},
    {'icon': Icons.bar_chart_outlined, 'label': 'Sales'},
    {'icon': Icons.settings_outlined, 'label': 'Settings'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Row(
                children: [
                  // Sidebar (inline for tablet/desktop, width 0 for mobile unless open)
                                    AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: _currentSidebarWidth,
                    decoration: BoxDecoration(
                      color: AppTheme.darkTeal,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.gray.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(2, 0),
                        ),
                      ],
                    ),
                    child: _currentSidebarWidth == 0
                        ? const SizedBox.shrink()
                        : ClipRect(
                            child: Material(
                              color: Colors.transparent,
                              child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                // Header
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: _isSidebarCollapsed ? 8 : 16,
                                    vertical: 16,
                                  ),
                                  decoration: const BoxDecoration(
                                    gradient: AppTheme.tealGradient,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: _isSidebarCollapsed ? 40 : 60,
                                        height: _isSidebarCollapsed ? 40 : 60,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.white,
                                        ),
                                        child: Icon(
                                          Icons.admin_panel_settings,
                                          size: _isSidebarCollapsed ? 20 : 30,
                                          color: AppTheme.primaryTeal,
                                        ),
                                      ),
                                      if (!_isMobileLayout && !_isSidebarCollapsed) ...[
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Admin Panel',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                        ),
                                        const Text(
                                          'LifeMate',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                // Menu Items
                                Expanded(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    itemCount: _menuItems.length,
                                    itemBuilder: (context, index) {
                                      final item = _menuItems[index];
                                      final isSelected = _selectedIndex == index;
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedIndex = index;
                                            if (_isMobileLayout) {
                                              _isMobileSidebarOpen = false;
                                            }
                                          });
                                          _pageController.jumpToPage(index);
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: _isSidebarCollapsed ? 8 : 12,
                                            vertical: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppTheme.primaryTeal
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Icon(
                                                item['icon'] as IconData,
                                                size: _isSidebarCollapsed ? 20 : 24,
                                                color: isSelected
                                                    ? AppTheme.white
                                                    : AppTheme.white.withValues(alpha: 0.7),
                                              ),
                                              // Show labels when sidebar is expanded. On mobile,
                                              // also show labels while the sidebar is open.
                                              if (!_isSidebarCollapsed && (!_isMobileLayout || _isMobileSidebarOpen)) ...[
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    item['label'] as String,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: isSelected
                                                          ? FontWeight.w600
                                                          : FontWeight.normal,
                                                      color: isSelected
                                                          ? AppTheme.white
                                                          : AppTheme.white
                                                              .withValues(alpha: 0.7),
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Footer
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: _isSidebarCollapsed ? 8 : 16,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.darkTeal,
                                    border: Border(
                                      top: BorderSide(
                                        color: AppTheme.white.withValues(alpha: 0.1),
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    '© 2024 LifeMate',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ),
                        ),

                  // Main Content Area with Header and Footer
                  Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    gradient: AppTheme.tealGradient,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          IconButton(
                            icon: Icon(
                              _isMobileLayout
                                  ? (_isMobileSidebarOpen
                                      ? Icons.close
                                      : Icons.menu)
                                  : (_isSidebarCollapsed
                                      ? Icons.chevron_right
                                      : Icons.chevron_left),
                              color: AppTheme.white,
                            ),
                            onPressed: _toggleSidebar,
                          ),
                          const Icon(Icons.dashboard_customize_outlined, color: AppTheme.white),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              _menuItems[_selectedIndex]['label'] as String,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.white,
                              ),
                            ),
                          ),
                        ],
                      )),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: AppTheme.white),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.account_circle_outlined, color: AppTheme.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _screens,
                  ),
                ),

                // Footer
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    border: Border(
                      top: BorderSide(color: AppTheme.gray.withValues(alpha: 0.15)),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '© 2024 LifeMate Admin',
                        style: TextStyle(fontSize: 12, color: AppTheme.gray),
                      ),
                      Text(
                        'v1.0.0',
                        style: TextStyle(fontSize: 12, color: AppTheme.gray),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
              // Mobile scrim overlay when sidebar is open
              if (_isMobileLayout && _isMobileSidebarOpen)
                Positioned(
                  left: _currentSidebarWidth,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _isMobileSidebarOpen = false;
                      });
                    },
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Stats Cards (responsive grid)
            LayoutBuilder(
              builder: (context, constraints) {
                final double w = constraints.maxWidth;
                int crossAxisCount = 4;
                if (w < 380) {
                  crossAxisCount = 1;
                } else if (w < 700) {
                  crossAxisCount = 2;
                } else if (w < 1000) {
                  crossAxisCount = 3;
                }
                final bool compact = w < 420;
                final TextScaler textScaler = MediaQuery.textScalerOf(context);
                double baseHeight;
                if (crossAxisCount == 1) {
                  baseHeight = 170;
                } else if (crossAxisCount == 2) {
                  baseHeight = 160;
                } else if (crossAxisCount == 3) {
                  baseHeight = 150;
                } else {
                  baseHeight = 140;
                }
                final double scaledBase = textScaler.scale(baseHeight);
                final double cardHeight = scaledBase.clamp(baseHeight, baseHeight * 1.3);
                // Add extra padding to prevent overflow
                final double finalHeight = cardHeight + 20;
                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    // Ensure enough vertical space to avoid overflows on all devices
                    mainAxisExtent: finalHeight,
                  ),
                  children: [
                    _buildStatCard(
                      'Total Orders',
                      '${orderProvider.orders.length}',
                      Icons.shopping_bag_outlined,
                      AppTheme.primaryTeal,
                      compact: compact,
                    ),
                    _buildStatCard(
                      'Total Products',
                      '${productProvider.medicines.length}',
                      Icons.medication_outlined,
                      AppTheme.successGreen,
                      compact: compact,
                    ),
                    _buildStatCard(
                      'Total Users',
                      'Loading...',
                      Icons.people_outlined,
                      AppTheme.lightTeal,
                      compact: compact,
                    ),
                    _buildStatCard(
                      'Total Sales',
                      '₹0.00',
                      Icons.attach_money_outlined,
                      AppTheme.darkTeal,
                      compact: compact,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Charts Section
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final bool isWide = width > 900;
                final bool isMedium = width > 600;

                if (isWide) {
                  // Two columns for wide screens
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildSalesBarChart(context, orderProvider),
                            const SizedBox(height: 24),
                            _buildSalesLineChart(context, orderProvider),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSalesPieChart(context, orderProvider, productProvider),
                      ),
                    ],
                  );
                } else if (isMedium) {
                  // Two columns for medium screens
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildSalesBarChart(context, orderProvider),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSalesPieChart(context, orderProvider, productProvider),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSalesLineChart(context, orderProvider),
                    ],
                  );
                } else {
                  // Single column for mobile
                  return Column(
                    children: [
                      _buildSalesBarChart(context, orderProvider),
                      const SizedBox(height: 24),
                      _buildSalesLineChart(context, orderProvider),
                      const SizedBox(height: 24),
                      _buildSalesPieChart(context, orderProvider, productProvider),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 24),

            // Recent Orders
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: const Text(
                            'Recent Orders',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ManageOrdersScreen(),
                              ),
                            );
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    orderProvider.orders.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text('No orders yet'),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: orderProvider.orders.take(5).length,
                            itemBuilder: (context, index) {
                              final order = orderProvider.orders[index];
                              return ListTile(
                                leading: const Icon(Icons.receipt_outlined),
                                title: Text('Order #${order.id.substring(0, 8)}'),
                                subtitle: Text(
                                    '₹${order.totalAmount.toStringAsFixed(2)}'),
                                trailing: Chip(
                                  label: Text(order.status.toUpperCase()),
                                  backgroundColor:
                                      AppTheme.primaryTeal.withValues(alpha: 0.2),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

    Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool compact = false,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 14 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Icon(icon, color: color, size: compact ? 26 : 32),
                ),
                Container(
                  padding: EdgeInsets.all(compact ? 6 : 8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: compact ? 16 : 20),     
                ),
              ],
            ),
            SizedBox(height: compact ? 10 : 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.gray,
              ),
            ),
            SizedBox(height: compact ? 2 : 4),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: compact ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bar Chart - Sales over last 7 days
  Widget _buildSalesBarChart(BuildContext context, OrderProvider orderProvider) {
    final now = DateTime.now();
    final List<Map<String, dynamic>> dailySales = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      final sales = orderProvider.orders
          .where((order) => 
              order.createdAt.isAfter(dayStart) && 
              order.createdAt.isBefore(dayEnd) &&
              order.status != 'cancelled')
          .fold<double>(0.0, (sum, order) => sum + order.totalAmount);
      
      return {
        'date': date,
        'sales': sales,
        'day': ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7],
      };
    });

    final maxSales = dailySales.isEmpty 
        ? 0.0 
        : dailySales.map((e) => e['sales'] as double).reduce((a, b) => a > b ? a : b);
    final maxY = maxSales > 0 ? (maxSales * 1.2).ceil().toDouble() : 1000.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Over Last 7 Days',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => AppTheme.primaryTeal,
                      tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < dailySales.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                dailySales[index]['day'] as String,
                                style: const TextStyle(
                                  color: AppTheme.gray,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '₹${value.toInt()}',
                            style: const TextStyle(
                              color: AppTheme.gray,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppTheme.gray.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: dailySales.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    final sales = data['sales'] as double;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: sales,
                          color: AppTheme.primaryTeal,
                          width: 30,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Line Chart - Sales trend over last 30 days
  Widget _buildSalesLineChart(BuildContext context, OrderProvider orderProvider) {
    final now = DateTime.now();
    final List<Map<String, dynamic>> weeklySales = List.generate(30, (index) {
      final date = now.subtract(Duration(days: 29 - index));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      final sales = orderProvider.orders
          .where((order) => 
              order.createdAt.isAfter(dayStart) && 
              order.createdAt.isBefore(dayEnd) &&
              order.status != 'cancelled')
          .fold<double>(0.0, (sum, order) => sum + order.totalAmount);
      
      return {'date': date, 'sales': sales};
    });

    final maxSales = weeklySales.isEmpty 
        ? 0.0 
        : weeklySales.map((e) => e['sales'] as double).reduce((a, b) => a > b ? a : b);
    final maxY = maxSales > 0 ? (maxSales * 1.2).ceil().toDouble() : 1000.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Trend (Last 30 Days)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppTheme.gray.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index == 0 || index == 14 || index == 29) {
                            final date = weeklySales[index]['date'] as DateTime;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${date.day}/${date.month}',
                                style: const TextStyle(
                                  color: AppTheme.gray,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '₹${value.toInt()}',
                            style: const TextStyle(
                              color: AppTheme.gray,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.gray.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      left: BorderSide(
                        color: AppTheme.gray.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      top: const BorderSide(color: Colors.transparent),
                      right: const BorderSide(color: Colors.transparent),
                    ),
                  ),
                  minX: 0,
                  maxX: 29,
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: weeklySales.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value['sales'] as double,
                        );
                      }).toList(),
                      isCurved: true,
                      color: AppTheme.successGreen,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.successGreen.withValues(alpha: 0.1),
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

  // Pie Chart - Sales by Category
  Widget _buildSalesPieChart(BuildContext context, OrderProvider orderProvider, ProductProvider productProvider) {
    // Calculate sales by category
    final Map<String, double> categorySales = {};
    
    for (final order in orderProvider.orders) {
      if (order.status == 'cancelled') continue;
      
      for (final item in order.items) {
        // Find medicine by ID to get category
        final medicine = productProvider.medicines.firstWhere(
          (m) => m.id == item.medicineId,
          orElse: () => MedicineModel(
            id: '',
            name: item.medicineName,
            description: '',
            price: item.price,
            imageUrl: item.imageUrl,
            category: 'Unknown',
            stock: 0,
            createdAt: DateTime.now(),
            isActive: true,
          ),
        );
        
        final category = medicine.category;
        final amount = item.subtotal;
        categorySales[category] = (categorySales[category] ?? 0.0) + amount;
      }
    }

    if (categorySales.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sales by Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                height: 250,
                child: Center(
                  child: Text('No sales data available'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final sortedCategories = categorySales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final totalSales = categorySales.values.fold<double>(0.0, (a, b) => a + b);
    final colors = [
      AppTheme.primaryTeal,
      AppTheme.successGreen,
      AppTheme.lightTeal,
      AppTheme.darkTeal,
      const Color(0xFFF97316), // Orange
      Colors.purple,
      Colors.blue,
      Colors.orange,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: sortedCategories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final value = entry.value.value;
                        final percentage = (value / totalSales * 100);
                        return PieChartSectionData(
                          value: value,
                          title: '${percentage.toStringAsFixed(1)}%',
                          color: colors[index % colors.length],
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sortedCategories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final category = entry.value.key;
                      final value = entry.value.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                category,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                '₹${value.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

