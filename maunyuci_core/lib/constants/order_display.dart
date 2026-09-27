import 'order_status_enum.dart';

/// Single source of truth untuk tampilan status order di semua aplikasi
/// (maunyuci_customer & maunyuci_store).
///
/// Prinsip:
/// - [customerLabel]/[customerDescription] memakai sudut pandang customer,
///   bahasa manusiawi, tidak teknikal.
/// - [storeLabel]/[storeDescription] memakai sudut pandang operasional toko.
/// - [colorValue] adalah ARGB int agar core tidak bergantung pada
///   `material.dart`. Di UI cukup `Color(OrderDisplay.statusColor(status))`.
/// - Pencocokan status selalu case-insensitive + trim, dan tak dikenal
///   akan fallback ke string aslinya (tidak crash).
class OrderStatusInfo {
  final String value;
  final String customerLabel;
  final String storeLabel;
  final String customerDescription;
  final String storeDescription;

  /// Urutan alur normal 0..7. Final (Completed=98, Cancelled=99).
  final int step;

  /// True jika butuh aksi customer (antar cucian / bayar / ambil).
  final bool needsCustomerAction;

  /// ARGB, mis. 0xFFF59E0B.
  final int colorValue;

  const OrderStatusInfo({
    required this.value,
    required this.customerLabel,
    required this.storeLabel,
    required this.customerDescription,
    required this.storeDescription,
    required this.step,
    required this.needsCustomerAction,
    required this.colorValue,
  });
}

class OrderDisplay {
  // Warna badge (ARGB). Dipilih yang cukup kontras di atas background muda.
  static const int _orange = 0xFFF59E0B;
  static const int _blue = 0xFF2563EB;
  static const int _purple = 0xFF7C3AED;
  static const int _teal = 0xFF0D9488;
  static const int _green = 0xFF16A34A;
  static const int _grey = 0xFF6B7280;
  static const int _red = 0xFFDC2626;
  static const int _indigo = 0xFF4F46E5;

  static const Map<String, OrderStatusInfo> _byKey = {
    'pending': OrderStatusInfo(
      value: 'Pending',
      customerLabel: 'Menunggu Konfirmasi Toko',
      storeLabel: 'Perlu Konfirmasi',
      customerDescription: 'Pesanan kamu sudah masuk. Tunggu toko konfirmasi ya.',
      storeDescription: 'Pesanan baru masuk. Terima atau tolak pesanan ini.',
      step: 0,
      needsCustomerAction: false,
      colorValue: _orange,
    ),
    'confirmed': OrderStatusInfo(
      value: 'Confirmed',
      customerLabel: 'Pesanan Diterima',
      storeLabel: 'Diterima',
      customerDescription: 'Toko sudah menerima pesanan kamu dan siap diproses.',
      storeDescription: 'Pesanan sudah diterima. Lanjut ke penjemputan / proses cuci.',
      step: 1,
      needsCustomerAction: false,
      colorValue: _blue,
    ),
    'waitingfordropoff': OrderStatusInfo(
      value: 'WaitingForDropOff',
      customerLabel: 'Antar Cucian ke Toko',
      storeLabel: 'Tunggu Customer Antar',
      customerDescription: 'Kamu pilih antar sendiri. Antar cucian kamu ke toko ya.',
      storeDescription: 'Menunggu customer mengantar cucian ke toko (self-service).',
      step: 2,
      needsCustomerAction: true,
      colorValue: _orange,
    ),
    'onpickup': OrderStatusInfo(
      value: 'OnPickup',
      customerLabel: 'Kurir Menuju ke Kamu',
      storeLabel: 'Jemput Cucian',
      customerDescription: 'Kurir sedang dalam perjalanan menjemput cucian kamu.',
      storeDescription: 'Kurir sedang menjemput cucian customer.',
      step: 2,
      needsCustomerAction: false,
      colorValue: _indigo,
    ),
    'awaitingpayment': OrderStatusInfo(
      value: 'AwaitingPayment',
      customerLabel: 'Menunggu Pembayaran',
      storeLabel: 'Tahan: Tunggu Bayar',
      customerDescription: 'Cucian sudah ditimbang. Selesaikan pembayaran agar diproses.',
      storeDescription: 'Sudah ditimbang, ditahan sampai transfer customer masuk.',
      step: 3,
      needsCustomerAction: true,
      colorValue: _red,
    ),
    'washing': OrderStatusInfo(
      value: 'Washing',
      customerLabel: 'Sedang Dicuci',
      storeLabel: 'Proses Cuci',
      customerDescription: 'Cucian kamu sedang dicuci / disetrika.',
      storeDescription: 'Pesanan sedang dicuci / disetrika.',
      step: 4,
      needsCustomerAction: false,
      colorValue: _blue,
    ),
    'readyforpickup': OrderStatusInfo(
      value: 'ReadyForPickup',
      customerLabel: 'Siap Diambil',
      storeLabel: 'Siap Diambil Customer',
      customerDescription: 'Cucian sudah selesai. Ambil di toko ya.',
      storeDescription: 'Selesai (self-service). Menunggu diambil customer.',
      step: 5,
      needsCustomerAction: true,
      colorValue: _purple,
    ),
    'ondelivery': OrderStatusInfo(
      value: 'OnDelivery',
      customerLabel: 'Diantar ke Kamu',
      storeLabel: 'Antar ke Customer',
      customerDescription: 'Cucian bersih sedang diantar kurir ke kamu.',
      storeDescription: 'Selesai, kurir sedang antar balik ke customer.',
      step: 5,
      needsCustomerAction: false,
      colorValue: _teal,
    ),
    'completed': OrderStatusInfo(
      value: 'Completed',
      customerLabel: 'Selesai',
      storeLabel: 'Selesai',
      customerDescription: 'Pesanan selesai. Terima kasih!',
      storeDescription: 'Selesai dan sudah di tangan customer.',
      step: 98,
      needsCustomerAction: false,
      colorValue: _green,
    ),
    'cancelled': OrderStatusInfo(
      value: 'Cancelled',
      customerLabel: 'Dibatalkan',
      storeLabel: 'Dibatalkan',
      customerDescription: 'Pesanan ini dibatalkan.',
      storeDescription: 'Pesanan dibatalkan.',
      step: 99,
      needsCustomerAction: false,
      colorValue: _grey,
    ),
  };

  static String _key(String raw) => raw.trim().toLowerCase();

  static OrderStatusInfo? infoOf(String status) => _byKey[_key(status)];

  // ---- Order status ----
  static String customerLabel(String status) => infoOf(status)?.customerLabel ?? status;
  static String storeLabel(String status) => infoOf(status)?.storeLabel ?? status;
  static String customerDescription(String status) => infoOf(status)?.customerDescription ?? '';
  static String storeDescription(String status) => infoOf(status)?.storeDescription ?? '';
  static int statusColor(String status) => infoOf(status)?.colorValue ?? _grey;
  static int statusStep(String status) => infoOf(status)?.step ?? -1;
  static bool needsCustomerAction(String status) => infoOf(status)?.needsCustomerAction ?? false;

  static bool isFinal(String status) {
    final s = OrderStatus.fromString(status.trim());
    if (s != null) return s.isFinal;
    final k = _key(status);
    return k == 'completed' || k == 'complete' || k == 'cancelled' || k == 'cancel';
  }

  static bool isActive(String status) => !isFinal(status);

  /// Nilai backend dari label customer (untuk filter -> query API).
  /// Mengembalikan null jika label tidak dikenal.
  static String? valueForCustomerLabel(String label) {
    final needle = label.trim().toLowerCase();
    for (final info in _byKey.values) {
      if (info.customerLabel.toLowerCase() == needle) return info.value;
    }
    return null;
  }

  static String? valueForStoreLabel(String label) {
    final needle = label.trim().toLowerCase();
    for (final info in _byKey.values) {
      if (info.storeLabel.toLowerCase() == needle) return info.value;
    }
    return null;
  }

  /// Daftar label customer untuk opsi filter, urut sesuai alur.
  static List<String> get customerFilterLabels {
    final list = _byKey.values.toList()..sort((a, b) => a.step.compareTo(b.step));
    return list.map((e) => e.customerLabel).toList();
  }

  static List<String> get activeBackendValues =>
      OrderStatus.values.where((e) => e.isActive).map((e) => e.value).toList();

  static List<String> get finalBackendValues =>
      OrderStatus.values.where((e) => e.isFinal).map((e) => e.value).toList();

  // ---- Delivery type ----
  static String deliveryLabel(String type) {
    switch (_key(type)) {
      case 'selfservice':
      case 'self-service':
      case 'self_service':
        return 'Antar-Jemput Sendiri';
      case 'courier':
        return 'Kurir Toko';
      default:
        return type;
    }
  }

  static String deliveryDescription(String type) {
    switch (_key(type)) {
      case 'selfservice':
      case 'self-service':
      case 'self_service':
        return 'Kamu antar & ambil sendiri ke toko.';
      case 'courier':
        return 'Pakai kurir antar-jemput toko.';
      default:
        return '';
    }
  }

  // ---- Payment method ----
  static String paymentMethodLabel(String method) {
    switch (_key(method)) {
      case 'paynow':
      case 'pay-now':
      case 'pay_now':
        return 'Bayar Sekarang';
      case 'paylater':
      case 'pay-later':
      case 'pay_later':
        return 'Bayar Nanti';
      default:
        return method;
    }
  }

  static String paymentMethodDescription(String method) {
    switch (_key(method)) {
      case 'paynow':
      case 'pay-now':
      case 'pay_now':
        return 'Bayar di awal via transfer / e-wallet ke rekening toko.';
      case 'paylater':
      case 'pay-later':
      case 'pay_later':
        return 'Bayar nanti, tunai saat ambil / antar.';
      default:
        return '';
    }
  }

  // ---- Payment status ----
  static String paymentStatusLabel(String status) {
    switch (_key(status)) {
      case 'unpaid':
        return 'Belum Bayar';
      case 'verifying':
        return 'Verifikasi Pembayaran';
      case 'paid':
        return 'Lunas';
      case 'failed':
        return 'Pembayaran Ditolak';
      default:
        return status;
    }
  }

  static String paymentStatusDescription(String status) {
    switch (_key(status)) {
      case 'unpaid':
        return 'Belum ada pembayaran untuk pesanan ini.';
      case 'verifying':
        return 'Struk sudah diupload, menunggu dicek kasir.';
      case 'paid':
        return 'Pembayaran sudah lunas.';
      case 'failed':
        return 'Struk ditolak kasir (buram / salah). Upload ulang ya.';
      default:
        return '';
    }
  }

  /// Aturan dari OrderService: PayLater -> "Tunai/COD",
  /// PayNow -> nama bank/e-wallet toko.
  static String displayPaymentProvider(String paymentMethod, String? bankName) {
    if (_key(paymentMethod) == 'paylater' ||
        _key(paymentMethod) == 'pay-later' ||
        _key(paymentMethod) == 'pay_later') {
      return 'Tunai/COD';
    }
    final name = (bankName ?? '').trim();
    if (name.isEmpty || name == '-') return paymentMethodLabel(paymentMethod);
    return name;
  }
}
