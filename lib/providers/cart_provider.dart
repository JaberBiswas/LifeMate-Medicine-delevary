import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_model.dart';



class CartProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<CartModel> _cartItems = [];
  bool _isLoading = false;
  StreamSubscription<List<CartModel>>? _cartSubscription;

  List<CartModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  int get itemCount => _cartItems.length;
  double get totalAmount => _cartItems.fold(0.0, (acc, cartItem) => acc + cartItem.subtotal);

  CartProvider() {
    loadCart();
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadCart() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Cancel existing subscription if any
    await _cartSubscription?.cancel();

    _isLoading = true;
    notifyListeners();

    try {
      _cartSubscription = _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => CartModel.fromMap(doc.data()))
              .toList())
          .listen(
        (cartItems) {
          _cartItems = cartItems;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Error in cart stream: $error');
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('Error loading cart: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(CartModel cartItem) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw NotLoggedInException('Please log in to add items to cart');
    }

    try {
      // Ensure stream subscription is active before adding
      if (_cartSubscription == null || _cartSubscription!.isPaused) {
        await loadCart();
        // Wait a bit for the stream to initialize
        await Future.delayed(const Duration(milliseconds: 50));
      }
      
      await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(cartItem.medicineId)
          .set(cartItem.toMap());
      
      // Wait a bit for the stream to update
      await Future.delayed(const Duration(milliseconds: 50));
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      rethrow;
    }
  }

  Future<void> updateQuantity(String medicineId, int quantity) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      if (quantity <= 0) {
        await removeFromCart(medicineId);
        return;
      }
      await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(medicineId)
          .update({'quantity': quantity});
    } catch (e) {
      debugPrint('Error updating cart: $e');
      rethrow;
    }
  }

  Future<void> removeFromCart(String medicineId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(medicineId)
          .delete();
    } catch (e) {
      debugPrint('Error removing from cart: $e');
      rethrow;
    }
  }

  Future<void> clearCart() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final itemsSnapshot = await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .get();
      final batch = _firestore.batch();
      for (final doc in itemsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      rethrow;
    }
  }

  int getQuantity(String medicineId) {
    try {
      return _cartItems
          .firstWhere((item) => item.medicineId == medicineId)
          .quantity;
    } catch (e) {
      return 0;
    }
  }

  bool isInCart(String medicineId) {
    return _cartItems.any((item) => item.medicineId == medicineId);
  }
}

class NotLoggedInException implements Exception {
  final String message;
  NotLoggedInException(this.message);
  
  @override
  String toString() => message;
}

