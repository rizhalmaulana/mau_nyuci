/// Backend enum: Models/Order.cs -> OrderStatus.
/// Nilai [value] harus sama persis dengan string dari API.
enum OrderStatus {
  pending('Pending'),
  confirmed('Confirmed'),
  waitingForDropOff('WaitingForDropOff'),
  onPickup('OnPickup'),
  awaitingPayment('AwaitingPayment'),
  washing('Washing'),
  readyForPickup('ReadyForPickup'),
  onDelivery('OnDelivery'),
  completed('Completed'),
  cancelled('Cancelled');

  final String value;
  const OrderStatus(this.value);

  static OrderStatus? fromString(String status) {
    for (var enumValue in OrderStatus.values) {
      if (enumValue.value.toLowerCase() == status.toLowerCase()) {
        return enumValue;
      }
    }
    return null;
  }

  /// Status yang masih dianggap "berjalan" (belum final).
  bool get isActive => this != completed && this != cancelled;

  /// Status final: tidak ada aksi lanjutan.
  bool get isFinal => this == completed || this == cancelled;
}
