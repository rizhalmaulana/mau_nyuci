class UserModel {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String profilePictureUrl;
  final String role;
  final String storeRole;
  final String authProvider;
  final String membershipTier;

  UserModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.profilePictureUrl,
    required this.role,
    this.storeRole = '',
    required this.authProvider,
    required this.membershipTier,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      profilePictureUrl: json['profilePictureUrl'] ?? '',
      role: json['role'] ?? '',
      storeRole: json['storeRole'] ?? '',
      authProvider: json['authProvider'] ?? '',
      membershipTier: json['membershipTier'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'role': role,
      'storeRole': storeRole,
      'authProvider': authProvider,
      'membershipTier': membershipTier,
    };
  }
}
