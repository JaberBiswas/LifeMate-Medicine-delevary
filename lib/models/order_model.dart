import 'order_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItemModel> items;
  final double totalAmount;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final Map<String, dynamic>? shippingAddress;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? trackingNumber;
  final String? notes;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    this.shippingAddress,
    required this.createdAt,
    this.updatedAt,
    this.trackingNumber,
    this.notes,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      paymentStatus: map['paymentStatus'] ?? 'pending',
      paymentMethod: map['paymentMethod'] ?? 'cash',
      shippingAddress: map['shippingAddress'] as Map<String, dynamic>?,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate(),
      trackingNumber: map['trackingNumber'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'shippingAddress': shippingAddress,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
      'trackingNumber': trackingNumber,
      'notes': notes,
    };
  }
}

