import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../widgets/admin_guard.dart';
import '../screens/user/login_screen.dart';
import '../screens/user/register_screen.dart';
import '../screens/user/home_screen.dart';
import '../screens/user/product_details_screen.dart';
import '../models/medicine_model.dart';
import '../screens/user/cart_screen.dart';
import '../screens/user/checkout_screen.dart';
import '../screens/user/orders_screen.dart';
import '../screens/user/profile_screen.dart';
import '../screens/user/newly_arrivals_screen.dart';
import '../screens/user/high_demand_screen.dart';
import '../screens/user/available_medicines_screen.dart';
import '../screens/user/popular_medicines_screen.dart';
import '../screens/user/best_selling_screen.dart';
import '../screens/user/best_booked_screen.dart';
import '../screens/user/popular_brands_screen.dart';
import '../screens/admin/admin_login_screen.dart';
import '../screens/admin/admin_register_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/manage_categories_screen.dart';
import '../screens/admin/admin_products_screen.dart';
import '../screens/admin/manage_orders_screen.dart';
import '../screens/admin/manage_users_screen.dart';
import '../screens/admin/sales_screen.dart';
import '../screens/admin/admin_settings_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const HomeScreen(),
    '/splash': (context) => const SplashScreen(),
    '/login': (context) => const LoginScreen(),
    '/register': (context) => const RegisterScreen(),
    '/home': (context) => const HomeScreen(),
    '/product-details': (context) {
      final args = ModalRoute.of(context)!.settings.arguments;
      return ProductDetailsScreen(medicine: args as MedicineModel);
    },
    '/cart': (context) => const CartScreen(),
    '/checkout': (context) => const CheckoutScreen(),
    '/orders': (context) => const OrdersScreen(),
    '/profile': (context) => const ProfileScreen(),
    '/newly-arrivals': (context) => const NewlyArrivalsScreen(),
    '/high-demand': (context) => const HighDemandScreen(),
    '/available-medicines': (context) => const AvailableMedicinesScreen(),
    '/popular-medicines': (context) => const PopularMedicinesScreen(),
    '/best-selling': (context) => const BestSellingScreen(),
    '/best-booked': (context) => const BestBookedScreen(),
    '/popular-brands': (context) => const PopularBrandsScreen(),
    '/admin/login': (context) => const AdminLoginScreen(),
    '/admin/register': (context) => const AdminRegisterScreen(),
    '/admin/dashboard': (context) => const AdminGuard(child: AdminDashboardScreen()),
    '/admin/categories': (context) => const AdminGuard(child: ManageCategoriesScreen()),
    '/admin/products': (context) => const AdminGuard(child: AdminProductsScreen()),
    '/admin/orders': (context) => const AdminGuard(child: ManageOrdersScreen()),
    '/admin/users': (context) => const AdminGuard(child: ManageUsersScreen()),
    '/admin/sales': (context) => const AdminGuard(child: SalesScreen()),
    '/admin/settings': (context) => const AdminGuard(child: AdminSettingsScreen()),
  };
}

