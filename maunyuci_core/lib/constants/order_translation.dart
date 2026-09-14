class OrderTranslation {
  static String translatePaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'unpaid':
        return 'Belum Lunas';
      case 'paid':
        return 'Lunas';
      case 'verifying':
        return 'Menunggu Verifikasi';
      case 'failed':
        return 'Ditolak / Gagal';
      default:
        return status;
    }
  }

  static String translatePaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'paylater':
        return 'Bayar Nanti';
      case 'paynow':
        return 'Bayar Sekarang';
      default:
        return method;
    }
  }

  static String translateOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'awaitingpayment':
        return 'Menunggu Pembayaran';
      case 'pending':
        return 'Menunggu';
      case 'confirmed':
        return 'Terkonfirmasi';
      case 'waitingfordropoff':
        return 'Menunggu Drop-off';
      case 'onpickup':
        return 'Sedang Dijemput';
      case 'washing':
        return 'Dicuci';
      case 'ready':
      case 'readyforpickup':
        return 'Siap Ambil';
      case 'completed':
      case 'complete':
        return 'Selesai';
      case 'ondelivery':
        return 'Sedang Diantar';
      case 'delivered':
        return 'Terkirim';
      case 'cancelled':
      case 'cancel':
        return 'Batal';
      default:
        return status;
    }
  }

  static String translateDeliveryType(String type) {
    switch (type.toLowerCase()) {
      case 'selfservice':
        return 'Antar Sendiri';
      case 'courier':
        return 'Layanan Kurir';
      default:
        return type;
    }
  }
}
