class MedicineModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String imageUrl;
  final String category;
  final String? manufacturer;
  final int stock;
  final String? expiryDate;
  final List<String>? tags;
  final bool isPrescriptionRequired;
  final String? strength;
  final double? rating;
  final int? reviewCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  MedicineModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.imageUrl,
    required this.category,
    this.manufacturer,
    required this.stock,
    this.expiryDate,
    this.tags,
    this.isPrescriptionRequired = false,
    this.strength,
    this.rating,
    this.reviewCount,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory MedicineModel.fromMap(Map<String, dynamic> map, String id) {
    return MedicineModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      discountPrice: map['discountPrice']?.toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      manufacturer: map['manufacturer'],
      stock: map['stock'] ?? 0,
      expiryDate: map['expiryDate'],
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
      isPrescriptionRequired: map['isPrescriptionRequired'] ?? false,
      strength: map['strength'],
      rating: map['rating']?.toDouble(),
      reviewCount: map['reviewCount'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'imageUrl': imageUrl,
      'category': category,
      'manufacturer': manufacturer,
      'stock': stock,
      'expiryDate': expiryDate,
      'tags': tags,
      'isPrescriptionRequired': isPrescriptionRequired,
      'strength': strength,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
      'isActive': isActive,
    };
  }

  double get finalPrice => discountPrice ?? price;
  double get discountPercent => discountPrice != null
      ? ((price - discountPrice!) / price * 100)
      : 0.0;
}

