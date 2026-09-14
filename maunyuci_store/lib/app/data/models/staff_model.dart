class StaffModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String storeId;
  final bool isActive;
  final String role;
  
  StaffModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.storeId,
    this.isActive = true,
    this.role = 'Kasir',
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] ?? '',
      name: json['fullName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      storeId: json['storeId'] ?? '',
      isActive: json['isActive'] ?? true,
      role: json['role'] ?? 'Kasir',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'storeId': storeId,
      'isActive': isActive,
      'role': role,
    };
  }
}
