enum OrderStatus {
  pending('Pending'),
  pickingUp('PickingUp'),
  washing('Washing'),
  delivering('Delivering'),
  confirmed('Confirmed'),
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
}
