import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/weigh_laundry_controller.dart';
import 'package:intl/intl.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/responsive_helper.dart';

class WeighLaundryView extends GetView<WeighLaundryController> {
  const WeighLaundryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text('Timbang Cucian', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(16))),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.order.value == null || controller.weighItems.isEmpty) {
          return const Center(child: Text('Data tidak ditemukan'));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(R.w(16)),
                itemCount: controller.weighItems.length,
                separatorBuilder: (context, index) => SizedBox(height: R.h(12)),
                itemBuilder: (context, index) {
                  final item = controller.weighItems[index];
                  final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
                  
                  return Container(
                    padding: EdgeInsets.all(R.w(16)),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(R.r(12)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.itemImageUrl != null && item.itemImageUrl!.isNotEmpty) ...[
                              Container(
                                width: R.w(48),
                                height: R.h(48),
                                margin: EdgeInsets.only(right: R.w(12)),
                                decoration: BoxDecoration(
                                  color: AppColors.grey100,
                                  borderRadius: BorderRadius.circular(R.r(8)),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(R.r(8)),
                                  child: Image.network(
                                    '${ApiConstants.cloudflareCatalogIconUrl}${item.itemImageUrl}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Icon(Icons.local_laundry_service, color: AppColors.purple300, size: R.sp(24)),
                                  ),
                                ),
                              ),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14))),
                                  SizedBox(height: R.h(4)),
                                  Text(
                                    'Estimasi Awal: ${item.initialQuantity} ${item.unit} x ${formatter.format(item.unitPrice)}', 
                                    style: AppFonts.inter(color: AppColors.grey500, fontSize: R.sp(12))
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: R.h(16)),
                        Divider(height: 1, color: AppColors.grey200),
                        SizedBox(height: R.h(16)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Berat Aktual:', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(12), color: AppColors.grey600)),
                                SizedBox(height: R.h(4)),
                                Text(formatter.format(item.subTotal), style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14), color: AppColors.primary)),
                              ],
                            ),
                            _WeighQuantityInput(
                              key: ValueKey(item.orderItemId),
                              item: item,
                              onChanged: (newQty) =>
                                  controller.updateQuantity(item.orderItemId, newQty),
                              onDecrement: () => controller.updateQuantity(
                                  item.orderItemId,
                                  item.actualQuantity -
                                      (item.unit.toLowerCase() == 'kg' ? 0.5 : 1)),
                              onIncrement: () => controller.updateQuantity(
                                  item.orderItemId,
                                  item.actualQuantity +
                                      (item.unit.toLowerCase() == 'kg' ? 0.5 : 1)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Bottom Action
            Container(
              padding: EdgeInsets.all(R.w(24)),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
                ],
              ),
              child: SafeArea(
                // Obx wajib: tanpa ini isSubmitting tidak pernah me-rebuild
                // tombol sehingga user menekan tanpa indikator loading apa pun.
                child: SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isSubmitting.value ? null : () => controller.submitWeight(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                      padding: EdgeInsets.symmetric(vertical: R.h(16)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
                    ),
                    child: controller.isSubmitting.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                      : Text('Simpan Berat', style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.white, fontSize: R.sp(14))),
                  )),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

}

Widget _quantityButton({required IconData icon, required VoidCallback onPressed}) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: R.w(8)),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(R.r(8)),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(R.r(8)),
        child: Padding(
          padding: EdgeInsets.all(R.w(8)),
          child: Icon(icon, size: R.sp(16), color: AppColors.primary),
        ),
      ),
    ),
  );
}

/// Input angka timbang: tombol -/+ DAN keyboard.
///
/// Sebelumnya TextField dibuatkan TextEditingController BARU di setiap
/// build, sehingga tiap ketikan langsung di-rebuild + di-format ulang
/// (kursor loncat, angka seolah nambah sendiri seperti tombol +).
/// Widget ini memegang controller sendiri per item (key = orderItemId):
/// - Saat mengetik (fokus): teks milik user, tidak ditulis ulang.
/// - Saat tombol -/+ ditekan (tidak fokus): field ikut ter-update.
class _WeighQuantityInput extends StatefulWidget {
  final WeighLaundryItem item;
  final ValueChanged<double> onChanged;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _WeighQuantityInput({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  State<_WeighQuantityInput> createState() => _WeighQuantityInputState();
}

class _WeighQuantityInputState extends State<_WeighQuantityInput> {
  late final TextEditingController _textCtrl;
  late final FocusNode _focusNode;

  String _formatted(double v) =>
      v.toStringAsFixed(widget.item.unit.toLowerCase() == 'kg' ? 1 : 0);

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: _formatted(widget.item.actualQuantity));
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _WeighQuantityInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sinkron dari tombol -/+ hanya saat user TIDAK sedang mengetik,
    // agar ketikan + posisi kursor tidak dirusak rebuild.
    if (!_focusNode.hasFocus && _textCtrl.text != _formatted(widget.item.actualQuantity)) {
      _textCtrl.text = _formatted(widget.item.actualQuantity);
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _quantityButton(icon: Icons.remove, onPressed: widget.onDecrement),
        SizedBox(
          width: R.w(60),
          child: TextField(
            controller: _textCtrl,
            focusNode: _focusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14)),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: R.h(8), horizontal: R.w(4)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(8))),
            ),
            onChanged: (val) {
              final newQty = double.tryParse(val.replaceAll(',', '.'));
              if (newQty != null && newQty > 0) {
                widget.onChanged(newQty);
              }
            },
            onSubmitted: (_) => _focusNode.unfocus(),
          ),
        ),
        _quantityButton(icon: Icons.add, onPressed: widget.onIncrement),
        SizedBox(width: R.w(8)),
        Text(widget.item.unit,
            style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14))),
      ],
    );
  }
}
