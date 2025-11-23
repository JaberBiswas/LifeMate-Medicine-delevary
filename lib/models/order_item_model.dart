class OrderItemModel {
  final String medicineId;
  final String medicineName;
  final String imageUrl;
  final double price;
  final int quantity;

  OrderItemModel({
    required this.medicineId,
    required this.medicineName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
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
}

