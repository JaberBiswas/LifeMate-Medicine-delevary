import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../utils/constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadMedicineImage(File imageFile, String medicineId) async {
    try {
      final ref = _storage
          .ref()
          .child(AppConstants.medicineImagesPath)
          .child('$medicineId.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Error uploading image: $e';
    }
  }

  Future<String> uploadUserImage(File imageFile, String userId) async {
    try {
      final ref = _storage
          .ref()
          .child(AppConstants.userImagesPath)
          .child('$userId.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Error uploading image: $e';
    }
  }

  Future<String> uploadCategoryImage(File imageFile, String categoryId) async {
    try {
      final ref = _storage
          .ref()
          .child(AppConstants.categoryImagesPath)
          .child('$categoryId.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Error uploading image: $e';
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw 'Error deleting image: $e';
    }
  }
}

