import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/user_model.dart';
import '../services/firestore_data_service.dart';

class UserProvider with ChangeNotifier {
  final FirestoreDataService _firestoreService = FirestoreDataService();
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.role == 'admin';

  Future<void> loadUser() async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _user = await _firestoreService.getUser(uid);
      
      // Listen to user updates
      _firestoreService.getUserStream(uid).listen(
        (user) {
          _user = user;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Error in user stream: $error');
        },
      );
    } catch (e) {
      debugPrint('Error loading user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    if (_user == null) return;

    try {
      await _firestoreService.updateUser(_user!.id, data);
      await loadUser();
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  void setUser(UserModel? user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}

