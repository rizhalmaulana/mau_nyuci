import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../data/providers/order_provider.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../order_detail/controllers/order_detail_controller.dart';

class WeighLaundryItem {
  final String orderItemId;
  final String name;
  final String unit;
  final double initialQuantity;
  double actualQuantity;
  final double unitPrice;
  final String? itemImageUrl;

  WeighLaundryItem({
    required this.orderItemId,
    required this.name,
    required this.unit,
    required this.initialQuantity,
    required this.actualQuantity,
    required this.unitPrice,
    this.itemImageUrl,
  });

  double get subTotal => unitPrice * actualQuantity;
}

class WeighLaundryController extends GetxController {
  final OrderProvider _orderProvider = OrderProvider();
  
  late String orderId;
  var isLoading = true.obs;
  var isSubmitting = false.obs;
  var order = Rxn<OrderModel>();
  
  var weighItems = <WeighLaundryItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    orderId = Get.arguments as String;
    fetchOrderDetail();
  }

  Future<void> fetchOrderDetail() async {
    isLoading.value = true;
    final response = await _orderProvider.getOrderById(orderId);
    if (response.success && response.data != null) {
      order.value = response.data;
      
      // Initialize weigh items
      if (order.value!.items != null) {
        weighItems.value = order.value!.items!.map((item) {
          return WeighLaundryItem(
            orderItemId: item.id,
            name: item.itemName,
            unit: item.unit,
            initialQuantity: item.quantity,
            actualQuantity: item.quantity > 0 ? item.quantity : 1.0, // Default to 1 if 0
            unitPrice: item.unitPrice,
            itemImageUrl: item.itemImageUrl,
          );
        }).toList();
      }
    } else {
      CustomSnackbar.showError('Mohon Maaf', response.message ?? 'Gagal mengambil detail pesanan');
      Get.back();
    }
    isLoading.value = false;
  }

  void updateQuantity(String orderItemId, double newQty) {
    if (newQty <= 0) return;
    int index = weighItems.indexWhere((item) => item.orderItemId == orderItemId);
    if (index != -1) {
      weighItems[index].actualQuantity = newQty;
      weighItems.refresh(); // Trigger Obx update
    }
  }

  Future<void> submitWeight() async {
    if (weighItems.isEmpty) {
      CustomSnackbar.showWarning('Perhatian', 'Tidak ada item untuk disimpan.');
      return;
    }

    // Backend butuh GUID valid. Jangan tembak request bila ID belum kep parsing.
    final invalid = weighItems.where((e) => e.orderItemId.trim().isEmpty).toList();
    if (invalid.isNotEmpty) {
      CustomSnackbar.showError(
        'ID Item Tidak Valid',
        'ID ${invalid.length} item tidak terbaca dari server (kosong). Tutup halaman ini, buka ulang, lalu coba lagi.',
      );
      return;
    }

    isSubmitting.value = true;

    List<Map<String, dynamic>> itemsPayload = weighItems.map((item) {
      return {
        'orderItemId': item.orderItemId,
        'actualQuantity': item.actualQuantity,
      };
    }).toList();

    final response = await _orderProvider.confirmWeight(orderId, itemsPayload);
    
    if (response.success) {
      // Refresh order detail di belakang layar.
      if (Get.isRegistered<OrderDetailController>()) {
        Get.find<OrderDetailController>().fetchOrderDetail();
      }

      // Kembali DULU, snackbar DITAMPILKAN SETELAHNYA di halaman detail.
      // Snackbar yang ditampilkan sebelum Get.back() ikut tertutup bersama
      // route ini sehingga user tidak pernah melihat info suksesnya.
      Get.back();
      Future.delayed(const Duration(milliseconds: 300), () {
        CustomSnackbar.showSuccess(
          'Berat Tersimpan!',
          response.message ?? 'Berat cucian berhasil disimpan.',
        );
      });
    } else {
      CustomSnackbar.showError('Mohon Maaf', response.message ?? 'Terjadi kesalahan saat menyimpan berat');
    }
    
    isSubmitting.value = false;
  }
}
