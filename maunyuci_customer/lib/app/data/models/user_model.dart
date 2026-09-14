class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String profilePictureUrl;
  final String authProvider;
  final String? defaultAddress;
  final double? defaultLatitude;
  final double? defaultLongitude;
  final String role;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profilePictureUrl = '',
    this.authProvider = 'Local',
    this.defaultAddress,
    this.defaultLatitude,
    this.defaultLongitude,
    this.role = 'Customer',
  });

  String get name => fullName;
  String get profilePicture => profilePictureUrl;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      profilePictureUrl: json['profilePictureUrl'] ?? json['profilePicture'] ?? '',
      authProvider: json['authProvider'] ?? json['role'] ?? 'Local',
      defaultAddress: json['defaultAddress'],
      defaultLatitude: json['defaultLatitude'] != null ? (json['defaultLatitude'] as num).toDouble() : null,
      defaultLongitude: json['defaultLongitude'] != null ? (json['defaultLongitude'] as num).toDouble() : null,
      role: json['role'] ?? 'Customer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePictureUrl': profilePictureUrl,
      'authProvider': authProvider,
      'defaultAddress': defaultAddress,
      'defaultLatitude': defaultLatitude,
      'defaultLongitude': defaultLongitude,
      'role': role,
    };
  }
}
