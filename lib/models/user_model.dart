class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String role;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? address;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
    this.address,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'user',
      imageUrl: map['imageUrl'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate(),
      address: map['address'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
      'address': address,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? role,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? address,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      address: address ?? this.address,
    );
  }
}

