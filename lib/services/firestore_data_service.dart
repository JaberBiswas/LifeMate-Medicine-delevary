import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/medicine_model.dart';
import '../models/order_model.dart';
import '../models/category_model.dart';

class FirestoreDataService {
  FirestoreDataService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // Users - saved in 'users' collection
  Future<void> createUser(UserModel user) async {
    // Ensure deterministic id usage (Firebase Auth uid expected in user.id)
    await _db.collection('users').doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  // Admins - saved in 'admin' collection
  Future<void> createAdmin(UserModel admin) async {
    // Ensure deterministic id usage (Firebase Auth uid expected in admin.id)
    await _db.collection('admin').doc(admin.id).set(admin.toMap(), SetOptions(merge: true));
  }

  // Get user from either 'users' or 'admin' collection
  Future<UserModel?> getUser(String userId) async {
    // First check admin collection
    final adminDoc = await _db.collection('admin').doc(userId).get();
    if (adminDoc.exists) {
      final data = adminDoc.data();
      return UserModel.fromMap(data!, adminDoc.id);
    }
    // Then check users collection
    final userDoc = await _db.collection('users').doc(userId).get();
    if (!userDoc.exists) return null;
    final data = userDoc.data();
    return UserModel.fromMap(data!, userDoc.id);
  }

  // Get admin from 'admin' collection
  Future<UserModel?> getAdmin(String adminId) async {
    final doc = await _db.collection('admin').doc(adminId).get();
    if (!doc.exists) return null;
    final data = doc.data();
    return UserModel.fromMap(data!, doc.id);
  }

  // Stream user from either 'users' or 'admin' collection
  Stream<UserModel?> getUserStream(String userId) async* {
    // First check which collection the user is in
    final user = await getUser(userId);
    if (user == null) {
      yield null;
      return;
    }
    
    // Listen to the appropriate collection based on role
    if (user.role == 'admin') {
      yield* _db.collection('admin').doc(userId).snapshots().map((doc) {
        if (!doc.exists) return null;
        final data = doc.data();
        return UserModel.fromMap(data!, doc.id);
      });
    } else {
      yield* _db.collection('users').doc(userId).snapshots().map((doc) {
        if (!doc.exists) return null;
        final data = doc.data();
        return UserModel.fromMap(data!, doc.id);
      });
    }
  }

  // Update user - saves to correct collection based on role
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    // First check which collection the user is in
    final user = await getUser(userId);
    if (user == null) return;
    
    // Convert DateTime to Timestamp if present
    final updatedData = Map<String, dynamic>.from(data);
    if (updatedData.containsKey('createdAt') && updatedData['createdAt'] is DateTime) {
      updatedData['createdAt'] = Timestamp.fromDate(updatedData['createdAt']);
    }
    if (updatedData.containsKey('updatedAt') && updatedData['updatedAt'] is DateTime) {
      updatedData['updatedAt'] = Timestamp.fromDate(updatedData['updatedAt']);
    }
    
    // Save to appropriate collection based on role
    if (user.role == 'admin') {
      await _db.collection('admin').doc(userId).set(updatedData, SetOptions(merge: true));
    } else {
      await _db.collection('users').doc(userId).set(updatedData, SetOptions(merge: true));
    }
  }

  // Get user by email - checks both collections
  Future<UserModel?> getUserByEmail(String email) async {
    final emailLower = email.toLowerCase();
    
    // Check admin collection first
    final adminQuery = await _db
        .collection('admin')
        .where('email', isEqualTo: emailLower)
        .limit(1)
        .get();
    if (adminQuery.docs.isNotEmpty) {
      final doc = adminQuery.docs.first;
      final data = doc.data();
      return UserModel.fromMap(data, doc.id);
    }
    
    // Then check users collection
    final userQuery = await _db
        .collection('users')
        .where('email', isEqualTo: emailLower)
        .limit(1)
        .get();
    if (userQuery.docs.isEmpty) return null;
    final doc = userQuery.docs.first;
    final data = doc.data();
    return UserModel.fromMap(data, doc.id);
  }

  // Medicines (Products)
  Stream<List<MedicineModel>> getAllMedicines() {
    return _db
        .collection('medicines')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final medicines = snapshot.docs.map((d) {
            final data = d.data();
            return MedicineModel.fromMap(data, d.id);
          }).toList();
          // Sort in memory by createdAt descending to avoid composite index requirement
          medicines.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return medicines;
        });
  }

  // Admin stream includes inactive
  Stream<List<MedicineModel>> getAllMedicinesAdmin() {
    return _db
        .collection('medicines')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) {
              final data = d.data();
              return MedicineModel.fromMap(data, d.id);
            }).toList());
  }

  Future<void> addMedicine(MedicineModel medicine) async {
    final data = medicine.toMap();
    final id = data['id'] as String?;
    if (id == null || id.isEmpty) {
      await _db.collection('medicines').add(data);
    } else {
      await _db.collection('medicines').doc(id).set(data);
    }
  }

  Future<void> updateMedicine(String medicineId, Map<String, dynamic> data) async {
    await _db.collection('medicines').doc(medicineId).set(data, SetOptions(merge: true));
  }

  Future<void> deleteMedicine(String medicineId) async {
    await _db.collection('medicines').doc(medicineId).delete();
  }

  Stream<List<MedicineModel>> getMedicinesByCategory(String category) {
    return _db
        .collection('medicines')
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) {
              final data = d.data();
              return MedicineModel.fromMap(data, d.id);
            }).toList());
  }

  Stream<List<MedicineModel>> searchMedicines(String query) {
    final q = query.toLowerCase();
    // Firestore cannot do contains; fetch active and filter client-side as a fallback
    return _db
        .collection('medicines')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
                .map((d) {
                  final data = d.data();
                  return MedicineModel.fromMap(data, d.id);
                })
                .where((m) => m.name.toLowerCase().contains(q) || m.description.toLowerCase().contains(q))
                .toList());
  }

  // Categories
  Future<void> addCategory(String categoryName) async {
    // Backward-compat simple add: create minimal active category
    final id = CategoryModel.generateIdFromName(categoryName);
    if (id.isEmpty) return;
    final now = DateTime.now();
    await _db.collection('categories').doc(id).set({
      'name': categoryName.trim(),
      'description': '',
      'imageUrl': '',
      'sortOrder': 0,
      'isActive': true,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    }, SetOptions(merge: true));
  }

  Future<void> upsertCategory(CategoryModel category) async {
    final now = DateTime.now();
    final data = category.copyWith(updatedAt: now).toMap();
    final id = category.id.isNotEmpty
        ? category.id
        : CategoryModel.generateIdFromName(category.name);
    await _db.collection('categories').doc(id).set(data, SetOptions(merge: true));
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    if (data.containsKey('updatedAt') && data['updatedAt'] is DateTime) {
      data['updatedAt'] = Timestamp.fromDate(data['updatedAt']);
    }
    await _db.collection('categories').doc(id).set(data, SetOptions(merge: true));
  }

  Stream<List<CategoryModel>> getCategoriesAdmin() {
    return _db
        .collection('categories')
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) => snap.docs.map((d) => CategoryModel.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<CategoryModel>> getActiveCategoriesDetailed() {
    return _db
        .collection('categories')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) {
          final categories = snap.docs.map((d) => CategoryModel.fromMap(d.data(), d.id)).toList();
          // Sort in memory to avoid composite index requirement
          categories.sort((a, b) {
            final bySort = a.sortOrder.compareTo(b.sortOrder);
            if (bySort != 0) return bySort;
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
          return categories;
        });
  }

  // Backward-compatible: names list for user UI
  Stream<List<String>> getAllCategories() {
    return _db
        .collection('categories')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) {
          final categories = snap.docs.map((d) {
            final data = d.data();
            return {
              'name': (data['name'] as String?) ?? d.id,
              'sortOrder': (data['sortOrder'] as int?) ?? 0,
            };
          }).toList();
          // Sort in memory to avoid composite index requirement
          categories.sort((a, b) {
            final bySort = (a['sortOrder'] as int).compareTo(b['sortOrder'] as int);
            if (bySort != 0) return bySort;
            return (a['name'] as String).toLowerCase().compareTo((b['name'] as String).toLowerCase());
          });
          return categories.map((c) => c['name'] as String).toList();
        });
  }

  Future<void> deleteCategory(String id) async {
    await _db.collection('categories').doc(id).delete();
  }

  // Orders
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<OrderModel>> getAllOrders() {
    return _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<String> createOrder(OrderModel order) async {
    final map = order.toMap();
    // Ensure Firestore-friendly timestamps
    if (map['createdAt'] is DateTime) {
      map['createdAt'] = Timestamp.fromDate(map['createdAt']);
    }
    if (map['updatedAt'] is DateTime) {
      map['updatedAt'] = Timestamp.fromDate(map['updatedAt']);
    }
    final doc = await _db.collection('orders').add(map);
    return doc.id;
  }

  Future<void> updateOrder(String orderId, Map<String, dynamic> data) async {
    if (data['updatedAt'] is DateTime) {
      data['updatedAt'] = Timestamp.fromDate(data['updatedAt']);
    }
    await _db.collection('orders').doc(orderId).update(data);
  }

  // Users list (admin) - gets regular users from 'users' collection
  Stream<List<UserModel>> getAllUsers() {
    return _db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Admins list (admin) - gets admins from 'admin' collection
  Stream<List<UserModel>> getAllAdmins() {
    return _db
        .collection('admin')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}


