import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';
import '../services/firestore_data_service.dart';

class OrderProvider with ChangeNotifier {
  final FirestoreDataService _firestoreService = FirestoreDataService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<OrderModel> _orders = [];
  bool _isLoading = false;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  OrderProvider() {
    loadOrders();
  }

  Future<void> loadOrders() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _firestoreService
          .getUserOrders(userId)
          .listen(
        (orders) {
          _orders = orders;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Error in orders stream: $error');
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('Error loading orders: $e');
      _isLoading = false;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _firestoreService.getAllOrders().listen(
        (orders) {
          _orders = orders;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Error in all orders stream: $error');
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('Error loading all orders: $e');
      _isLoading = false;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> createOrder(OrderModel order) async {
    try {
      final orderId = await _firestoreService.createOrder(order);
      return orderId;
    } catch (e) {
      debugPrint('Error creating order: $e');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestoreService.updateOrder(orderId, {
        'status': status,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      debugPrint('Error updating order: $e');
      rethrow;
    }
  }
}

