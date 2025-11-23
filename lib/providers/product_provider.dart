import 'package:flutter/foundation.dart';
import '../models/medicine_model.dart';
import '../services/firestore_data_service.dart';

class ProductProvider with ChangeNotifier {
  final FirestoreDataService _firestoreService = FirestoreDataService();

  List<MedicineModel> _medicines = [];
  List<MedicineModel> _filteredMedicines = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;

  List<MedicineModel> get medicines => _filteredMedicines;
  List<MedicineModel> get allMedicines => _medicines;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  ProductProvider() {
    loadMedicines();
    loadCategories();
  }

  Future<void> loadMedicines() async {
    _isLoading = true;
    notifyListeners();

    try {
      _firestoreService.getAllMedicines().listen(
        (medicines) {
          _medicines = medicines;
          _applyFilters();
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Error in medicines stream: $error');
          if (error.toString().contains('YOUR_PROJECT_ID') || 
              error.toString().contains('400') ||
              error.toString().contains('Bad Request') ||
              error.toString().contains('Firebase is not properly configured')) {
            debugPrint('⚠️ Firebase configuration error. Please configure Firebase.');
          }
          _isLoading = false;
          _medicines = [];
          _applyFilters();
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('Error loading medicines: $e');
      if (e.toString().contains('YOUR_PROJECT_ID') || 
          e.toString().contains('Firebase is not properly configured')) {
        debugPrint('⚠️ Firebase is not configured. Please update firebase_options.dart');
      }
      _isLoading = false;
      _medicines = [];
      _applyFilters();
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      _firestoreService.getAllCategories().listen(
        (categories) {
          _categories = ['All', ...categories];
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Error in categories stream: $error');
          if (error.toString().contains('YOUR_PROJECT_ID') || 
              error.toString().contains('400') ||
              error.toString().contains('Bad Request') ||
              error.toString().contains('Firebase is not properly configured')) {
            debugPrint('⚠️ Firebase configuration error. Please configure Firebase.');
          }
          _categories = ['All'];
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('Error loading categories: $e');
      if (e.toString().contains('YOUR_PROJECT_ID') || 
          e.toString().contains('Firebase is not properly configured')) {
        debugPrint('⚠️ Firebase is not configured. Please update firebase_options.dart');
      }
      _categories = ['All'];
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredMedicines = _medicines;

    if (_selectedCategory != 'All') {
      _filteredMedicines = _filteredMedicines
          .where((medicine) => medicine.category == _selectedCategory)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      _filteredMedicines = _filteredMedicines
          .where((medicine) =>
              medicine.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              medicine.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    notifyListeners();
  }

  MedicineModel? getMedicineById(String id) {
    try {
      return _medicines.firstWhere((medicine) => medicine.id == id);
    } catch (e) {
      return null;
    }
  }
}

