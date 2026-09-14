import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/printer_settings_controller.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_colors.dart';

class PrinterSettingsView extends GetView<PrinterSettingsController> {
  const PrinterSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text('Pengaturan Printer', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(16))),
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(R.w(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Obx(() {
              final isConnected = controller.printerService.isConnected.value;
              final device = controller.printerService.selectedDevice.value;
              return Container(
                padding: EdgeInsets.all(R.w(16)),
                decoration: BoxDecoration(
                  color: isConnected ? AppColors.success50 : AppColors.orange50,
                  borderRadius: BorderRadius.circular(R.r(16)),
                  border: Border.all(color: isConnected ? AppColors.success200 : AppColors.orange200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(R.w(12)),
                      decoration: BoxDecoration(
                        color: isConnected ? AppColors.success100 : AppColors.orange100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isConnected ? Icons.print : Icons.print_disabled,
                        color: isConnected ? AppColors.success700 : AppColors.orange700,
                        size: R.r(24),
                      ),
                    ),
                    SizedBox(width: R.w(16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isConnected ? 'Printer Terhubung' : 'Printer Terputus',
                            style: AppFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: R.sp(14),
                              color: isConnected ? AppColors.success800 : AppColors.orange800,
                            ),
                          ),
                          SizedBox(height: R.h(4)),
                          Text(
                            isConnected && device != null 
                              ? '${device.name}\n${device.address}' 
                              : 'Silakan pilih printer dari daftar di bawah',
                            style: AppFonts.inter(
                              fontSize: R.sp(12),
                              color: isConnected ? AppColors.success700 : AppColors.orange700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isConnected)
                      IconButton(
                        icon: Icon(Icons.power_settings_new, color: AppColors.danger400),
                        onPressed: controller.disconnectDevice,
                        tooltip: 'Putuskan Koneksi',
                      )
                  ],
                ),
              );
            }),
            
            SizedBox(height: R.h(24)),
            
            // Devices List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Perangkat Tersedia',
                  style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14), color: AppColors.grey800),
                ),
                TextButton.icon(
                  onPressed: controller.scanDevices,
                  icon: Obx(() => controller.printerService.isScanning.value 
                    ? SizedBox(width: R.r(16), height: R.r(16), child: const CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.refresh, size: R.r(16))),
                  label: Text('Pindai Ulang', style: AppFonts.inter(fontSize: R.sp(12))),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              ],
            ),
            SizedBox(height: R.h(8)),
            
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(R.r(16)),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Obx(() {
                  if (controller.printerService.isScanning.value && controller.printerService.devices.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (controller.printerService.devices.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bluetooth_disabled, size: R.r(48), color: AppColors.grey300),
                          SizedBox(height: R.h(16)),
                          Text(
                            'Tidak ada perangkat Bluetooth ditemukan.\nPastikan Bluetooth menyala dan printer sudah di-pair di setting HP.',
                            textAlign: TextAlign.center,
                            style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey500),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: controller.printerService.devices.length,
                    separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.grey200),
                    itemBuilder: (context, index) {
                      final device = controller.printerService.devices[index];
                      final isConnectedToThis = controller.printerService.isConnected.value && 
                                               controller.printerService.selectedDevice.value?.address == device.address;
                                               
                      return ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(R.w(8)),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.bluetooth, color: AppColors.primary, size: R.r(20)),
                        ),
                        title: Text(device.name ?? 'Unknown Device', style: AppFonts.inter(fontWeight: FontWeight.w600, fontSize: R.sp(14))),
                        subtitle: Text(device.address ?? '', style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey500)),
                        trailing: isConnectedToThis
                          ? Container(
                              padding: EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(6)),
                              decoration: BoxDecoration(
                                color: AppColors.success100,
                                borderRadius: BorderRadius.circular(R.r(20)),
                              ),
                              child: Text('Terhubung', style: AppFonts.inter(fontSize: R.sp(10), fontWeight: FontWeight.bold, color: AppColors.success800)),
                            )
                          : ElevatedButton(
                              onPressed: () => controller.connectToDevice(device),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.white,
                                foregroundColor: AppColors.primary,
                                elevation: 0,
                                side: const BorderSide(color: AppColors.primary),
                                padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(0)),
                                minimumSize: Size(0, R.h(32)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(20))),
                              ),
                              child: Text('Hubungkan', style: AppFonts.inter(fontSize: R.sp(12), fontWeight: FontWeight.w600)),
                            ),
                      );
                    },
                  );
                }),
              ),
            ),
            
            SizedBox(height: R.h(16)),
            
            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton.icon(
                onPressed: controller.printerService.isConnected.value ? controller.testPrint : null,
                icon: Icon(Icons.print, size: R.r(18), color: AppColors.white),
                label: Text('Test Print', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14), color: AppColors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.grey300,
                  padding: EdgeInsets.symmetric(vertical: R.h(16)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  elevation: 0,
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
