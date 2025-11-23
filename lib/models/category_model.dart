import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id; // slug/id
  final String name;
  final String description;
  final String imageUrl;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static CategoryModel fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: (map['name'] as String?) ?? id,
      description: (map['description'] as String?) ?? '',
      imageUrl: (map['imageUrl'] as String?) ?? '',
      sortOrder: (map['sortOrder'] as int?) ?? 0,
      isActive: (map['isActive'] as bool?) ?? true,
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: (map['updatedAt'] is Timestamp)
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  static String generateIdFromName(String name) {
    return name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-');
  }
}


