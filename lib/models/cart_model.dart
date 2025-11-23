class CartModel {
  final String medicineId;
  final String medicineName;
  final String imageUrl;
  final double price;
  final int quantity;

  CartModel({
    required this.medicineId,
    required this.medicineName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      medicineId: map['medicineId'] ?? '',
      medicineName: map['medicineName'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicineId': medicineId,
      'medicineName': medicineName,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
    };
  }

  double get subtotal => price * quantity;

  CartModel copyWith({
    String? medicineId,
    String? medicineName,
    String? imageUrl,
    double? price,
    int? quantity,
  }) {
    return CartModel(
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}

