class AuthProfileResponseModel {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String? profilePictureUrl;
  final String? defaultAddress;
  final double? defaultLatitude;
  final double? defaultLongitude;
  final String role;
  final String authProvider;

  AuthProfileResponseModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    this.profilePictureUrl,
    this.defaultAddress,
    this.defaultLatitude,
    this.defaultLongitude,
    required this.role,
    required this.authProvider,
  });

  factory AuthProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthProfileResponseModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '-',
      phoneNumber: (json['phoneNumber'] == null || json['phoneNumber'].toString().isEmpty)
          ? 'No HP belum dilengkapi'
          : json['phoneNumber'],
      email: (json['email'] == null || json['email'].toString().isEmpty)
          ? 'Email belum dilengkapi'
          : json['email'],
      profilePictureUrl: json['profilePictureUrl'],
      defaultAddress: json['defaultAddress'],
      defaultLatitude: json['defaultLatitude'] != null ? (json['defaultLatitude'] as num).toDouble() : null,
      defaultLongitude: json['defaultLongitude'] != null ? (json['defaultLongitude'] as num).toDouble() : null,
      role: json['role'] ?? 'Customer',
      authProvider: json['authProvider'] ?? 'Local',
    );
  }
}
