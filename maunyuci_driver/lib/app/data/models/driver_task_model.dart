class DriverTaskModel {
  final String orderId;
  final String customerName;
  final String address;
  final String taskType;
  final String status;
  final double totalAmount;
  final double distanceInKm;

  DriverTaskModel({
    required this.orderId,
    required this.customerName,
    required this.address,
    required this.taskType,
    required this.status,
    required this.totalAmount,
    required this.distanceInKm,
  });

  factory DriverTaskModel.fromJson(Map<String, dynamic> json) {
    return DriverTaskModel(
      orderId: json['orderId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? 'Customer',
      address: json['address']?.toString() ?? json['deliveryAddress']?.toString() ?? json['pickupAddress']?.toString() ?? '-',
      taskType: json['taskType']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      distanceInKm: (json['distanceInKm'] ?? 0).toDouble(),
    );
  }
}

class DriverTaskDetailModel extends DriverTaskModel {
  final String? customerPhone;
  final String? customerPhotoUrl;
  final double? latitude;
  final double? longitude;
  final String? courierNotes;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? customerLaundryImageUrl;
  final String? pickupTimeSlot;
  final String? deliveryTimeSlot;

  DriverTaskDetailModel({
    required super.orderId,
    required super.customerName,
    required super.address,
    required super.taskType,
    required super.status,
    required super.totalAmount,
    required super.distanceInKm,
    this.customerPhone,
    this.customerPhotoUrl,
    this.latitude,
    this.longitude,
    this.courierNotes,
    this.paymentMethod,
    this.paymentStatus,
    this.customerLaundryImageUrl,
    this.pickupTimeSlot,
    this.deliveryTimeSlot,
  });

  factory DriverTaskDetailModel.fromJson(Map<String, dynamic> json) {
    return DriverTaskDetailModel(
      orderId: json['orderId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? 'Customer',
      address: json['address']?.toString() ?? json['deliveryAddress']?.toString() ?? json['pickupAddress']?.toString() ?? '-',
      taskType: json['taskType']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      distanceInKm: (json['distanceInKm'] ?? 0).toDouble(),
      customerPhone: json['customerPhone']?.toString(),
      customerPhotoUrl: json['customerPhotoUrl']?.toString(),
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      courierNotes: json['courierNotes']?.toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      paymentStatus: json['paymentStatus']?.toString(),
      customerLaundryImageUrl: json['customerLaundryImageUrl']?.toString(),
      pickupTimeSlot: json['pickupTimeSlot']?.toString(),
      deliveryTimeSlot: json['deliveryTimeSlot']?.toString(),
    );
  }
}
