import 'order_display.dart';

/// Wrapper kompatibilitas. Kode baru disarankan memakai [OrderDisplay]
/// langsung agar bisa memilih sudut pandang customer vs store.
///
/// Catatan: [translateOrderStatus] mengembalikan label customer
/// (human-friendly). Untuk operasional toko pakai
/// `OrderDisplay.storeLabel(status)`.
class OrderTranslation {
  static String translatePaymentStatus(String status) =>
      OrderDisplay.paymentStatusLabel(status);

  static String translatePaymentMethod(String method) =>
      OrderDisplay.paymentMethodLabel(method);

  static String translateOrderStatus(String status) =>
      OrderDisplay.customerLabel(status);

  static String translateDeliveryType(String type) =>
      OrderDisplay.deliveryLabel(type);

  /// Tambahan yang sebelumnya belum ada.
  static String describeOrderStatusForCustomer(String status) =>
      OrderDisplay.customerDescription(status);

  static String describeOrderStatusForStore(String status) =>
      OrderDisplay.storeDescription(status);

  static String displayPaymentProvider(String paymentMethod, String? bankName) =>
      OrderDisplay.displayPaymentProvider(paymentMethod, bankName);
}
