/// Kurir milik toko dari GET Driver/store/{storeId}/drivers.
///
/// PENTING: [driverId] adalah DriverProfiles.Id yang wajib dikirim ke
/// PUT Order/{orderId}/confirm-pickup. Jangan pakai [userId].
class StoreDriverModel {
  final String driverId;
  final String userId;
  final String fullName;
  final String phoneNumber;
  final String vehicleNumber;
  final String vehicleType;
  final bool isAvailable;
  final int activeTaskCount;

  /// Batas backend: activeTaskCount >= 5 ditolak 400 "terlalu banyak tugas aktif".
  static const int maxActiveTasks = 5;

  const StoreDriverModel({
    required this.driverId,
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.isAvailable,
    required this.activeTaskCount,
  });

  factory StoreDriverModel.fromJson(Map<String, dynamic> json) {
    return StoreDriverModel(
      driverId: (json['driverId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      fullName: (json['fullName'] ?? '-').toString(),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      vehicleNumber: (json['vehicleNumber'] ?? '-').toString(),
      vehicleType: (json['vehicleType'] ?? '').toString(),
      isAvailable: json['isAvailable'] is bool
          ? json['isAvailable'] as bool
          : (json['isAvailable']?.toString().toLowerCase() == 'true'),
      activeTaskCount: (json['activeTaskCount'] as num?)?.toInt() ?? 0,
    );
  }

  /// Label sesuai spek: "{fullName} - {vehicleNumber} ({activeTaskCount} tugas)".
  String get displayLabel => '$fullName - $vehicleNumber ($activeTaskCount tugas)';

  bool get isBusy => activeTaskCount >= maxActiveTasks;

  /// Hanya yang selectable yang boleh dikirim ke backend.
  bool get isSelectable => isAvailable && !isBusy && driverId.isNotEmpty;

  String get unselectableReason {
    if (!isAvailable) return 'Nonaktif';
    if (isBusy) return 'Sibuk';
    if (driverId.isEmpty) return 'ID tidak valid';
    return '';
  }
}
