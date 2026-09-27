import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/store_detail_controller.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/models/catalog_model.dart';
import '../../../data/models/store_model.dart';
import '../../home/controllers/home_controller.dart';
import 'package:image_picker/image_picker.dart';

class StoreDetailView extends GetView<StoreDetailController> {
  const StoreDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final store = controller.store;
        if (store == null) {
          return const Center(child: Text('Toko tidak ditemukan.'));
        }

        return CustomScrollView(
          slivers: [
            _buildSliverAppBar(store),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(R.w(16)),
                child: Column(
                  children: [
                    _buildStoreInfo(store),
                    SizedBox(height: R.h(16)),
                    if (store.hasPickupDeliveryService ?? false) ...[
                      _buildDeliveryConfiguration(store),
                      SizedBox(height: R.h(16)),
                    ],
                    _buildCatalogGrid(),
                    SizedBox(height: R.h(16)),
                    _buildPromoSelection(),
                    SizedBox(height: R.h(16)),
                    _buildPaymentSelection(),
                    SizedBox(height: R.h(16)),
                    SizedBox(height: R.h(100)), // Space for bottom bar
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.cart.isEmpty) return const SizedBox.shrink();
        return _buildCheckoutBar();
      }),
    );
  }

  Widget _buildSliverAppBar(StoreModel store) {
    return SliverAppBar(
      expandedHeight: R.h(220),
      pinned: false,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (store.storeImageUrl?.isNotEmpty ?? false)
              Image.network(
                store.storeImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/mau_nyuci.png', fit: BoxFit.cover),
              )
            else
              Image.asset('assets/images/mau_nyuci.png', fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              bottom: R.h(16),
              left: R.w(16),
              right: R.w(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(4)),
                        decoration: BoxDecoration(
                          color: (store.isCurrentlyOpen ?? false) ? AppColors.success : AppColors.danger400,
                          borderRadius: BorderRadius.circular(R.r(4)),
                        ),
                        child: Text(
                          store.isCurrentlyOpen ?? false ? 'Buka' : 'Tutup',
                          style: AppFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: R.sp(14)),
                        ),
                      ),
                      SizedBox(width: R.w(8)),
                      if ((store.averageRating ?? 0) > 0)
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: R.r(16)),
                            SizedBox(width: R.w(4)),
                            Text(
                              store.averageRating.toString(),
                              style: AppFonts.inter(color: Colors.white, fontSize: R.sp(12)),
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: R.h(8)),
                  Text(
                    store.name ?? 'Nama Toko',
                    style: AppFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: R.sp(25)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreInfo(StoreModel store) {
    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppColors.primary, size: R.r(20)),
              SizedBox(width: R.w(8)),
              Expanded(
                child: Text(
                  "Alamat Toko: ${store.address ?? ''}",
                  style: AppFonts.inter(color: AppColors.grey600, fontSize: R.sp(13)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(12)),
          Row(
            children: [
              Icon(Icons.access_time, color: AppColors.primary, size: R.r(20)),
              SizedBox(width: R.w(8)),
              Text(
                'Jam Operasional: ${store.operatingHoursFormatted}',
                style: AppFonts.inter(color: AppColors.grey600, fontSize: R.sp(13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryConfiguration(StoreModel store) {
    return Obx(() {
      final homeCtrl = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;
      return Container(
        padding: EdgeInsets.all(R.w(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(R.r(16)),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Opsi Pengantaran', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14), color: AppColors.grey800)),
                if (store.pickupDeliveryFee == null || store.pickupDeliveryFee == 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(4)),
                    decoration: BoxDecoration(color: AppColors.success50, borderRadius: BorderRadius.circular(R.r(4))),
                    child: Text('Gratis Ongkir', style: AppFonts.inter(fontSize: R.sp(10), color: AppColors.success700, fontWeight: FontWeight.bold)),
                  )
                else
                  Text(
                    'Ongkir: Rp${NumberFormat('#,###', 'id').format(store.pickupDeliveryFee ?? 0)}',
                    style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            SizedBox(height: R.h(12)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<DeliveryType>(
                    title: Text('Antar Jemput', style: AppFonts.inter(fontSize: R.sp(13))),
                    value: DeliveryType.courier,
                    groupValue: controller.selectedDeliveryType.value,
                    onChanged: (val) {
                      if (val != null) controller.onDeliveryTypeChanged(val);
                    },
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<DeliveryType>(
                    title: Text('Drop-off', style: AppFonts.inter(fontSize: R.sp(13))),
                    value: DeliveryType.dropoff,
                    groupValue: controller.selectedDeliveryType.value,
                    onChanged: (val) {
                      if (val != null) controller.onDeliveryTypeChanged(val);
                    },
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            if (controller.selectedDeliveryType.value == DeliveryType.courier) ...[
              SizedBox(height: R.h(12)),
              Container(
                padding: EdgeInsets.all(R.w(12)),
                decoration: BoxDecoration(
                  color: AppColors.orange50,
                  borderRadius: BorderRadius.circular(R.r(8)),
                  border: Border.all(color: AppColors.orange200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.orange700, size: R.sp(20)),
                    SizedBox(width: R.w(8)),
                    Expanded(
                      child: Text(
                        'Minimal Order Kiloan untuk Antar-Jemput: ${store.minOrderForPickup?.toInt() ?? 0} Kg',
                        style: AppFonts.inter(color: AppColors.orange800, fontSize: R.sp(11)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: R.h(16)),
              Text('Foto Cucian (Wajib)', style: AppFonts.inter(fontWeight: FontWeight.w600, fontSize: R.sp(13))),
              SizedBox(height: R.h(8)),
              _buildLaundryPhoto(),
              SizedBox(height: R.h(16)),
              Text('Alamat Anda', style: AppFonts.inter(fontWeight: FontWeight.w600, fontSize: R.sp(13))),
              SizedBox(height: R.h(8)),
              Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.danger400, size: R.sp(20)),
                  SizedBox(width: R.w(8)),
                  Expanded(
                    child: Text(
                      homeCtrl?.userAddress.value ?? 'Belum ada alamat',
                      style: AppFonts.inter(color: AppColors.grey600, fontSize: R.sp(13)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: R.h(20)),
              Text('Waktu Penjemputan', style: AppFonts.inter(fontWeight: FontWeight.w600, fontSize: R.sp(13))),
              SizedBox(height: R.h(8)),
              _buildTimeSlotDropdown(
                value: controller.pickupTimeSlot.value,
                onChanged: (val) => controller.pickupTimeSlot.value = val,
              ),
              SizedBox(height: R.h(16)),
              Text('Waktu Pengantaran', style: AppFonts.inter(fontWeight: FontWeight.w600, fontSize: R.sp(13))),
              SizedBox(height: R.h(8)),
              _buildTimeSlotDropdown(
                value: controller.deliveryTimeSlot.value,
                onChanged: (val) => controller.deliveryTimeSlot.value = val,
              ),
              SizedBox(height: R.h(16)),
              Text('Detail Alamat & Patokan (Wajib)', style: AppFonts.inter(fontWeight: FontWeight.w600, fontSize: R.sp(13))),
              SizedBox(height: R.h(8)),
              TextFormField(
                controller: controller.logisticsNoteController,
                style: AppFonts.inter(fontSize: R.sp(13)),
                decoration: InputDecoration(
                  hintText: 'Contoh: Kos Putri Melati, Kamar 03, Pagar Hitam. Jl Merpati RT 04 RW 02 Pasar Minggu',
                  hintStyle: AppFonts.inter(color: AppColors.grey500, fontSize: R.sp(13)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: AppColors.primary)),
                  contentPadding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
                ),
                maxLines: 2,
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildLaundryPhoto() {
    return Obx(() {
      final file = controller.laundryImageFile.value;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(R.r(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(R.r(12)),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            if (file != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(R.r(8)),
                child: Image.file(
                  file,
                  height: R.h(150),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: R.h(12)),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => controller.pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt, color: AppColors.primary),
                  label: Text('Kamera', style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(8))),
                  ),
                ),
                SizedBox(width: R.w(12)),
                OutlinedButton.icon(
                  onPressed: () => controller.pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library, color: AppColors.primary),
                  label: Text('Galeri', style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(8))),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    });
  }

  Widget _buildTimeSlotDropdown({required String? value, required ValueChanged<String?> onChanged}) {
    final timeslots = [
      '08:00 - 10:00',
      '10:00 - 12:00',
      '13:00 - 15:00',
      '15:00 - 17:00',
      '18:00 - 20:00'
    ];
    return DropdownButtonFormField<String>(
      value: value,
      items: timeslots.map((ts) => DropdownMenuItem(value: ts, child: Text(ts, style: AppFonts.inter(fontSize: R.sp(13))))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: AppColors.primary)),
        contentPadding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
        hintText: 'Pilih Slot Waktu',
        hintStyle: AppFonts.inter(color: AppColors.grey500, fontSize: R.sp(13)),
      ),
    );
  }

  Widget _buildCatalogGrid() {
    return Obx(() {
      if (controller.catalogList.isEmpty) {
        return Container(
          padding: EdgeInsets.all(R.w(32)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(R.r(16)),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: R.r(64), color: AppColors.grey400),
              SizedBox(height: R.h(16)),
              Text('Toko ini belum memiliki layanan', style: AppFonts.inter(color: AppColors.grey500, fontSize: R.sp(14))),
            ],
          ),
        );
      }

      Map<String, List<CatalogModel>> grouped = {};
      for (var item in controller.catalogList) {
        final category = item.category ?? 'Lainnya';
        if (!grouped.containsKey(category)) grouped[category] = [];
        grouped[category]!.add(item);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: grouped.entries.map((entry) {
          return Container(
            margin: EdgeInsets.only(bottom: R.h(16)),
            padding: EdgeInsets.all(R.w(16)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(R.r(16)),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.key, style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14), color: AppColors.grey800)),
                SizedBox(height: R.h(12)),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: entry.value.length,
                  separatorBuilder: (context, index) => SizedBox(height: R.h(8)),
                  itemBuilder: (context, index) {
                    final item = entry.value[index];
                    return Container(
                      padding: EdgeInsets.all(R.w(12)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(R.r(12)),
                        border: Border.all(color: AppColors.grey200),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: R.r(24),
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: item.imageAsset != null && item.imageAsset!.isNotEmpty
                                ? (item.imageAsset!.startsWith('http')
                                    ? Image.network(item.imageAsset!, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.local_laundry_service, color: AppColors.primary))
                                    : Image.network('${ApiConstants.cloudflareCatalogIconUrl}${item.imageAsset!}', fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.local_laundry_service, color: AppColors.primary)))
                                : const Icon(Icons.local_laundry_service, color: AppColors.primary),
                          ),
                          SizedBox(width: R.w(12)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name ?? 'Nama Layanan',
                                  style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: R.h(4)),
                                Text(
                                  '${NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(item.price ?? 0)}/${item.unit}',
                                  style: AppFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: R.sp(13)),
                                ),
                                SizedBox(height: R.h(6)),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: R.w(6), vertical: R.h(2)),
                                  decoration: BoxDecoration(
                                    color: AppColors.orange50,
                                    borderRadius: BorderRadius.circular(R.r(4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.access_time, size: R.sp(10), color: AppColors.orange700),
                                      SizedBox(width: R.w(4)),
                                      Text(
                                        item.timeEstimate != null && item.timeEstimate!.isNotEmpty ? "Estimasi ${item.timeEstimate}" : '-',
                                        style: AppFonts.inter(fontSize: R.sp(10), color: AppColors.orange700),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Obx(() {
                            final quantity = controller.getQuantity(item.id ?? '');
                            final isKiloan = item.unit?.toLowerCase() == 'kg';
                            
                            if (isKiloan) {
                              if (quantity > 0) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(4)),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(R.r(16)),
                                      ),
                                      child: Text(
                                        'Est. $quantity Kg',
                                        style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: R.sp(12)),
                                      ),
                                    ),
                                    SizedBox(width: R.w(4)),
                                    InkWell(
                                      onTap: () => controller.removeFromCart(item.id!),
                                      child: Icon(Icons.cancel, color: AppColors.danger400, size: R.r(24)),
                                    ),
                                  ],
                                );
                              }
                              return ElevatedButton(
                                onPressed: (controller.store?.isCurrentlyOpen ?? false) ? () => controller.addToCart(item.id!) : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(8)),
                                  minimumSize: Size.zero,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(8))),
                                ),
                                child: Text('Pilih', style: AppFonts.inter(color: Colors.white, fontSize: R.sp(12), fontWeight: FontWeight.bold)),
                              );
                            } else {
                              if (quantity > 0) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () => controller.removeFromCart(item.id!),
                                      child: Icon(Icons.remove_circle_outline, color: AppColors.primary, size: R.r(24)),
                                    ),
                                    SizedBox(width: R.w(8)),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(4)),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(R.r(16)),
                                      ),
                                      child: Text(
                                        '$quantity',
                                        style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: R.sp(12)),
                                      ),
                                    ),
                                    SizedBox(width: R.w(8)),
                                    InkWell(
                                      onTap: (controller.store?.isCurrentlyOpen ?? false) ? () => controller.addToCart(item.id!) : null,
                                      child: Icon(Icons.add_circle_outline, color: (controller.store?.isCurrentlyOpen ?? false) ? AppColors.primary : AppColors.grey400, size: R.r(24)),
                                    ),
                                  ],
                                );
                              }
                              return IconButton(
                                onPressed: (controller.store?.isCurrentlyOpen ?? false) ? () => controller.addToCart(item.id!) : null,
                                icon: Icon(Icons.add_circle_outline, color: (controller.store?.isCurrentlyOpen ?? false) ? AppColors.primary : AppColors.grey400, size: R.r(24)),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              );
                            }
                          }),
                          SizedBox(width: R.w(4)),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildPromoSelection() {
    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Voucher & Diskon', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14), color: AppColors.grey800)),
          SizedBox(height: R.h(12)),
          
          InkWell(
            onTap: () => _showPromoBottomSheet(Get.context!),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(12)),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(R.r(12)),
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_offer_outlined, color: AppColors.primary, size: R.sp(20)),
                  SizedBox(width: R.w(8)),
                  Expanded(
                    child: Obx(() {
                      if (controller.selectedPromo.value != null) {
                        final promo = controller.selectedPromo.value!;
                        return Text('Voucher Dipakai: ${promo.promoCode}', style: AppFonts.inter(fontSize: R.sp(13), color: AppColors.primary, fontWeight: FontWeight.bold));
                      }
                      return Text('Makin hemat pakai Voucher / Diskon', style: AppFonts.inter(fontSize: R.sp(13), color: AppColors.grey600));
                    }),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.grey500, size: R.sp(20)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showPromoBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: R.w(16),
          right: R.w(16),
          top: R.w(16),
          // Inset sistem agar tombol "Pakai" terbawah tidak tertutup
          // tombol navigasi HP (mode 3 tombol).
          bottom: R.w(16) + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(24))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pilih Voucher', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(16))),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
              ],
            ),
            SizedBox(height: R.h(16)),
            Container(
              constraints: BoxConstraints(maxHeight: Get.height * 0.6),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: R.h(12)),
                    padding: EdgeInsets.all(R.w(12)),
                    decoration: BoxDecoration(
                      border: Border.all(color: controller.selectedPromo.value == null ? AppColors.primary : AppColors.grey200),
                      borderRadius: BorderRadius.circular(R.r(12)),
                      color: controller.selectedPromo.value == null ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(R.w(8)),
                          decoration: BoxDecoration(color: AppColors.grey100, shape: BoxShape.circle),
                          child: Icon(Icons.do_not_disturb_alt, color: AppColors.grey600, size: R.sp(20)),
                        ),
                        SizedBox(width: R.w(12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tanpa Promo', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14))),
                              SizedBox(height: R.h(4)),
                              Text(
                                'Lanjutkan transaksi tanpa voucher.',
                                style: AppFonts.inter(fontSize: R.sp(11), color: AppColors.grey600),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            controller.selectedPromo.value = null;
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: controller.selectedPromo.value == null ? AppColors.grey300 : AppColors.primary,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(8)),
                            minimumSize: Size.zero,
                          ),
                          child: Text(controller.selectedPromo.value == null ? 'Dipakai' : 'Pakai', style: AppFonts.inter(fontSize: R.sp(12), color: controller.selectedPromo.value == null ? AppColors.grey700 : Colors.white, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  const Divider(),
                  if (controller.promos.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(R.w(16)),
                      child: Center(child: Text('Tidak ada promo tersedia.', style: AppFonts.inter(color: AppColors.grey500, fontSize: R.sp(13)))),
                    )
                  else
                    ...controller.promos.map((promo) {
                      final isPercent = promo.discountType.toLowerCase().contains('percent') || promo.discountType.toLowerCase().contains('persent');
                      String valueText;
                      if (isPercent) {
                        String numStr = promo.discountValue % 1 == 0 ? promo.discountValue.toInt().toString() : promo.discountValue.toString();
                        valueText = '$numStr%';
                      } else {
                        valueText = 'Rp${NumberFormat('#,###', 'id').format(promo.discountValue)}';
                      }

                      final isSelected = controller.selectedPromo.value?.id == promo.id;

                      return Container(
                        margin: EdgeInsets.only(bottom: R.h(12)),
                        padding: EdgeInsets.all(R.w(12)),
                        decoration: BoxDecoration(
                          border: Border.all(color: isSelected ? AppColors.primary : AppColors.grey200),
                          borderRadius: BorderRadius.circular(R.r(12)),
                          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(R.w(8)),
                              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: Icon(Icons.local_offer, color: AppColors.primary, size: R.sp(20)),
                            ),
                            SizedBox(width: R.w(12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(promo.promoCode, style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14))),
                                  SizedBox(height: R.h(4)),
                                  Text(
                                    'Diskon $valueText (Min. Belanja Rp${NumberFormat('#,###', 'id').format(promo.minOrderAmount)})',
                                    style: AppFonts.inter(fontSize: R.sp(11), color: AppColors.grey600),
                                  ),
                                  Text(
                                    'Berlaku untuk: ${promo.discountTarget == "Order" ? "Total Belanja" : "Ongkos Kirim"}',
                                    style: AppFonts.inter(fontSize: R.sp(11), color: AppColors.orange700, fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                controller.selectedPromo.value = promo;
                                Get.back();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected ? AppColors.grey300 : AppColors.primary,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(8)),
                                minimumSize: Size.zero,
                              ),
                              child: Text(isSelected ? 'Dipakai' : 'Pakai', style: AppFonts.inter(fontSize: R.sp(12), color: isSelected ? AppColors.grey700 : Colors.white, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      );
                    })
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildPaymentSelection() {
    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Metode Pembayaran', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14), color: AppColors.grey800)),
          SizedBox(height: R.h(12)),
          
          SwitchListTile(
            title: Text('Bayar Sekarang?', style: AppFonts.inter(fontSize: R.sp(14))),
            subtitle: Text(
              controller.paymentStatus.value == 'Lunas' 
                  ? '*Lunas (Bayar via Transfer/QRIS)' 
                  : '*Bayar Nanti (Tunai / Saat Selesai)', 
              style: AppFonts.inter(color: AppColors.primary, fontSize: R.sp(10), fontStyle: FontStyle.italic),
            ),
            value: controller.paymentStatus.value == 'Lunas',
            onChanged: (val) {
              controller.paymentStatus.value = val ? 'Lunas' : 'Belum Lunas';
              if (!val) {
                controller.selectedPaymentMethodId.value = null; // Reset when Belum Lunas
              }
            },
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
          ),

          if (controller.paymentStatus.value == 'Lunas') ...[
            const Divider(),
            SizedBox(height: R.h(8)),
            Text('Pilih Metode Transfer', style: AppFonts.inter(fontSize: R.sp(12))),
            SizedBox(height: R.h(8)),
            if (controller.bankAccounts.isEmpty)
              Container(
                padding: EdgeInsets.all(R.w(16)),
                decoration: BoxDecoration(
                  color: AppColors.orange50,
                  borderRadius: BorderRadius.circular(R.r(8)),
                  border: Border.all(color: AppColors.orange200),
                ),
                child: Center(
                  child: Text('Toko tidak menyediakan metode transfer.', style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.orange800)),
                ),
              )
            else
              ...controller.bankAccounts.map((bank) {
                final isQris = bank.bankName.toLowerCase().contains('qris');
                final hasImage = bank.qrisImageUrl != null && bank.qrisImageUrl!.isNotEmpty;
                final isSelected = controller.selectedPaymentMethodId.value == bank.id;

                return Column(
                  children: [
                    RadioListTile<String>(
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: R.h(2)),
                            child: _buildBankIconForCustomer(bank.bankName, isSelected),
                          ),
                          SizedBox(width: R.w(8)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(bank.bankName, style: AppFonts.inter(fontSize: R.sp(13), color: isSelected ? AppColors.primary : AppColors.black87)),
                                if (bank.accountNumber != '-')
                                  Text('${bank.accountNumber} (a/n ${bank.accountHolderName})', style: AppFonts.inter(fontSize: R.sp(11), color: AppColors.grey600)),
                                
                                if (isQris && hasImage && isSelected)
                                  Padding(
                                    padding: EdgeInsets.only(top: R.h(12), bottom: R.h(4)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () => _showQrisPreview(
                                              bank.qrisImageUrl!, bank.bankName),
                                          child: Stack(
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(R.r(8)),
                                                child: Image.network(
                                                  bank.qrisImageUrl!,
                                                  height: R.h(200),
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (c, e, s) =>
                                                      const Icon(Icons.qr_code_2, size: 60),
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.all(R.w(8)),
                                                padding: EdgeInsets.all(R.r(6)),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withValues(alpha: 0.6),
                                                  borderRadius:
                                                      BorderRadius.circular(R.r(8)),
                                                ),
                                                child: Icon(
                                                  Icons.zoom_in,
                                                  size: R.r(18),
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: R.h(8)),
                                        Text(
                                          'Ketuk gambar untuk memperbesar, lalu scan QRIS untuk membayar.',
                                          style: AppFonts.inter(
                                              fontSize: R.sp(11),
                                              color: AppColors.grey600),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      value: bank.id,
                      groupValue: controller.selectedPaymentMethodId.value,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        if (val != null) controller.selectedPaymentMethodId.value = val;
                      },
                    ),
                  ],
                );
              }),
          ],
        ],
      )),
    );
  }

  /// Pratinjau QRIS fullscreen: bisa pinch-to-zoom agar QR terbaca
  /// kamera aplikasi pembayaran.
  void _showQrisPreview(String imageUrl, String title) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.all(R.w(16)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(16))),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(R.w(16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppFonts.inter(
                      fontSize: R.sp(14),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: R.h(12)),
                  Flexible(
                    child: InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.qr_code_2,
                          size: 80,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: R.h(12)),
                  Text(
                    'Cubit untuk zoom • Scan QR ini dari aplikasi pembayaranmu',
                    textAlign: TextAlign.center,
                    style: AppFonts.inter(fontSize: R.sp(11), color: Colors.white70),
                  ),
                ],
              ),
            ),
            Positioned(
              top: R.h(4),
              right: R.w(4),
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: 'Tutup',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankIconForCustomer(String bankName, bool isSelected) {
    final l = bankName.toLowerCase();
    IconData icon = Icons.account_balance;
    Color color = isSelected ? AppColors.primary : AppColors.grey500;
    
    if (l.contains('cash') || l.contains('tunai')) {
      icon = Icons.payments_outlined;
    } else if (l.contains('qris')) {
      icon = Icons.qr_code_2;
    } else if (l.contains('gopay') || l.contains('ovo') || l.contains('dana') || l.contains('shopee') || l.contains('linkaja') || l.contains('e-wallet')) {
      icon = Icons.account_balance_wallet;
    }

    return Icon(icon, size: R.sp(20), color: color);
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() {
          final subtotal = controller.subtotal;
          final discount = controller.discountAmount;
          final delivery = controller.deliveryFee;
          final grandTotal = controller.grandTotal;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Subtotal', style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey600)),
                  Text('Rp${NumberFormat('#,###', 'id').format(subtotal)}', style: AppFonts.inter(fontSize: R.sp(12), fontWeight: FontWeight.w600)),
                ],
              ),
              if (discount > 0)
                Padding(
                  padding: EdgeInsets.only(top: R.h(4)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Diskon', style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.success600)),
                      Text('- Rp${NumberFormat('#,###', 'id').format(discount)}', style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.success600, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              if (delivery > 0)
                Padding(
                  padding: EdgeInsets.only(top: R.h(4)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ongkir', style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey600)),
                      Text('Rp${NumberFormat('#,###', 'id').format(delivery)}', style: AppFonts.inter(fontSize: R.sp(12), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              Divider(height: R.h(16), thickness: 1, color: Colors.grey.shade200),
              if (controller.hasKiloan)
                Padding(
                  padding: EdgeInsets.only(bottom: R.h(8)),
                  child: Text(
                    '*Harga akhir untuk layanan kiloan akan disesuaikan setelah pakaian Anda ditimbang oleh pihak toko.',
                    style: AppFonts.inter(fontSize: R.sp(10), color: AppColors.grey500, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.start,
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estimasi Total', style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey600)),
                      Text(
                        'Rp${NumberFormat('#,###', 'id').format(grandTotal)}',
                        style: AppFonts.inter(fontSize: R.sp(16), fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: R.h(44),
                    child: ElevatedButton(
                      onPressed: controller.isSubmitting.value ? null : () => controller.submitOrder(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(horizontal: R.w(24)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(R.r(8)),
                        ),
                      ),
                      child: controller.isSubmitting.value
                          ? SizedBox(
                              width: R.r(20),
                              height: R.r(20),
                              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Buat Pesanan',
                              style: AppFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: R.sp(14)),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
