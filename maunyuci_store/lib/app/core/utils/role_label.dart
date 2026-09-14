import '../../data/models/user_model.dart';

/// Konversi role BE menjadi teks ramah pengguna untuk ditampilkan di UI.
///
/// - `Owner` -> "Pemilik Laundry"
/// - `StoreStaff` -> isi `storeRole` dari BE (Kasir / Driver / Pencuci).
///   Varian bahasa Inggris (Cashier / Washer) ikut dinormalisasi.
String roleLabel(UserModel user) {
  if (user.role == 'Owner') return 'Pemilik Laundry';
  if (user.role == 'StoreStaff') {
    if (user.storeRole.isNotEmpty) return storeRoleLabel(user.storeRole);
    return 'Staff';
  }
  if (user.role.isNotEmpty) return user.role;
  return 'Mitra';
}

/// Normalisasi nilai `storeRole` BE ke label baku.
String storeRoleLabel(String value) {
  switch (value.trim().toLowerCase()) {
    case 'kasir':
    case 'cashier':
      return 'Kasir';
    case 'driver':
    case 'pengemudi':
      return 'Driver';
    case 'pencuci':
    case 'washer':
    case 'tukang cuci':
      return 'Pencuci';
    default:
      return value;
  }
}
