import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maunyuci_core/maunyuci_core.dart'; // To access OrderModel and related
import '../../data/models/store_model.dart';
import '../widgets/custom_snackbar.dart';

class PrinterService extends GetxService {
  static PrinterService get to => Get.find();

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  final RxList<BluetoothDevice> devices = <BluetoothDevice>[].obs;
  final Rx<BluetoothDevice?> selectedDevice = Rx<BluetoothDevice?>(null);
  final RxBool isConnected = false.obs;
  final RxBool isScanning = false.obs;

  @override
  void onInit() {
    super.onInit();
    initBluetooth();
  }

  void initBluetooth() {
    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          isConnected.value = true;
          break;
        case BlueThermalPrinter.DISCONNECTED:
          isConnected.value = false;
          selectedDevice.value = null;
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          isConnected.value = false;
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          isConnected.value = false;
          break;
        case BlueThermalPrinter.STATE_OFF:
          isConnected.value = false;
          break;
        case BlueThermalPrinter.STATE_ON:
          getDevices();
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          break;
        case BlueThermalPrinter.ERROR:
          isConnected.value = false;
          break;
        default:
          break;
      }
    });

    bluetooth.isConnected.then((value) {
      isConnected.value = value ?? false;
    });
  }

  Future<void> getDevices() async {
    isScanning.value = true;
    try {
      List<BluetoothDevice> result = await bluetooth.getBondedDevices();
      devices.value = result;
    } catch (e) {
      print("Error getting devices: $e");
    } finally {
      isScanning.value = false;
    }
  }

  Future<void> connect(BluetoothDevice device) async {
    try {
      await bluetooth.connect(device);
      selectedDevice.value = device;
      isConnected.value = true;
      CustomSnackbar.showSuccess('Berhasil', 'Terhubung ke ${device.name}');
    } catch (e) {
      CustomSnackbar.showError('Gagal', 'Tidak dapat terhubung ke printer. Pastikan printer menyala.');
    }
  }

  Future<void> disconnect() async {
    try {
      await bluetooth.disconnect();
      isConnected.value = false;
      selectedDevice.value = null;
      CustomSnackbar.showSuccess('Berhasil', 'Terputus dari printer');
    } catch (e) {
      print("Error disconnecting: $e");
    }
  }

  Future<void> printTest() async {
    if (!(await bluetooth.isConnected ?? false)) {
      CustomSnackbar.showError('Error', 'Printer tidak terhubung');
      return;
    }
    bluetooth.printNewLine();
    bluetooth.printCustom("TEST PRINT MAUNYUCI", 3, 1);
    bluetooth.printNewLine();
    bluetooth.printCustom("Printer berhasil terhubung", 1, 1);
    bluetooth.printNewLine();
    bluetooth.printNewLine();
    bluetooth.printNewLine();
  }

  Future<void> printReceipt(OrderModel order, {StoreModel? store}) async {
    if (!(await bluetooth.isConnected ?? false)) {
      CustomSnackbar.showError('Error', 'Printer tidak terhubung');
      return;
    }

    try {
      bluetooth.printNewLine();

      // HEADER
      if (store != null) {
        bluetooth.printCustom(store.name, 3, 1); // Size 3 (large), Align 1 (center)
        bluetooth.printCustom(store.address, 1, 1);
        if (store.phoneNumber?.isNotEmpty == true) {
          bluetooth.printCustom("Telp: ${store.phoneNumber}", 1, 1);
        }
      } else {
        bluetooth.printCustom("LAUNDRY MAUNYUCI", 3, 1);
      }
      
      bluetooth.printCustom("================================", 1, 1);

      // ORDER INFO
      final dateFormat = DateFormat('dd MMM yyyy HH:mm');
      bluetooth.printLeftRight("Tgl", dateFormat.format(order.createdAt), 1);
      bluetooth.printLeftRight("Order", '#${order.id.split('-').first.toUpperCase()}', 1);
      bluetooth.printLeftRight("Plg", order.customerName, 1);
      if (order.status.isNotEmpty) {
        bluetooth.printLeftRight("Status", order.status, 1);
      }
      bluetooth.printCustom("================================", 1, 1);

      // ITEMS
      for (var item in order.items ?? <OrderItemModel>[]) {
        bluetooth.printCustom(item.itemName, 1, 0); // Align 0 (left)
        final itemTotal = item.subTotal;
        final qtyPrice = "${item.quantity} ${item.unit} x ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(item.unitPrice)}";
        final totalStr = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(itemTotal);
        bluetooth.printLeftRight(qtyPrice, totalStr, 1);
      }
      
      bluetooth.printCustom("================================", 1, 1);

      // TOTALS
      final subtotalStr = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(order.totalAmount - order.deliveryFee);
      bluetooth.printLeftRight("Subtotal", subtotalStr, 1);

      if (order.deliveryFee > 0) {
        final deliveryStr = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(order.deliveryFee);
        bluetooth.printLeftRight("Ongkir", deliveryStr, 1);
      }

      bluetooth.printCustom("--------------------------------", 1, 1);
      
      final grandTotalStr = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(order.totalAmount);
      bluetooth.printLeftRight("TOTAL", grandTotalStr, 1, format: "%s%-10s %10s%s"); // Make total stand out if possible
      bluetooth.printLeftRight("Pembayaran", order.paymentStatus, 1);

      bluetooth.printCustom("================================", 1, 1);
      
      // FOOTER
      bluetooth.printCustom("Terima kasih telah", 1, 1);
      bluetooth.printCustom("mencuci di tempat kami!", 1, 1);
      
      bluetooth.printNewLine();
      bluetooth.printNewLine();
      bluetooth.printNewLine(); // paper tear space
      
    } catch (e) {
      CustomSnackbar.showError('Error', 'Gagal mencetak struk');
      print(e);
    }
  }
}
