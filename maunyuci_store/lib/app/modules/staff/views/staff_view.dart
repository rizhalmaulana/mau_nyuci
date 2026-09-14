import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../data/models/staff_model.dart';
import '../../../core/utils/responsive_helper.dart';
import '../controllers/staff_controller.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_colors.dart';

class StaffView extends GetView<StaffController> {
  const StaffView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<StaffController>()) {
      Get.put(StaffController());
    }

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text('Kelola Staff', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(18), color: AppColors.black87)),
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.staffs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: R.r(64), color: AppColors.grey500),
                SizedBox(height: R.h(16)),
                Text('Belum ada staff terdaftar', style: AppFonts.inter(fontSize: R.sp(16), color: AppColors.grey500)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchStaffs,
          child: ListView.builder(
            padding: EdgeInsets.all(R.w(16)),
            itemCount: controller.staffs.length,
            itemBuilder: (context, index) {
              final staff = controller.staffs[index];
              return _buildStaffCard(staff);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStaffBottomSheet(context),
        backgroundColor: AppColors.deepPurple,
        child: const Icon(Icons.person_add, color: AppColors.white),
      ),
    );
  }

  Widget _buildStaffCard(StaffModel staff) {
    return Container(
      margin: EdgeInsets.only(bottom: R.h(12)),
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(12)),
        boxShadow: [
          BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.deepPurple50,
            radius: R.r(24),
            child: Icon(Icons.person, color: AppColors.deepPurple, size: R.r(24)),
          ),
          SizedBox(width: R.w(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff.name,
                  style: AppFonts.inter(fontSize: R.sp(16), fontWeight: FontWeight.bold),
                ),
                SizedBox(height: R.h(4)),
                Text(
                  staff.phoneNumber,
                  style: AppFonts.inter(fontSize: R.sp(14), color: AppColors.grey600),
                ),
                SizedBox(height: R.h(8)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(4)),
                  decoration: BoxDecoration(
                    color: AppColors.info50,
                    borderRadius: BorderRadius.circular(R.r(8)),
                  ),
                  child: Text(
                    staff.role,
                    style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.info700, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStaffBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(R.w(24)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(24))),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tambah Staff Baru', style: AppFonts.inter(fontSize: R.sp(18), fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                SizedBox(height: R.h(16)),
                TextFormField(
                  controller: controller.nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                SizedBox(height: R.h(16)),
                TextFormField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor HP',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Nomor HP tidak boleh kosong' : null,
                ),
                SizedBox(height: R.h(16)),
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.role.value,
                  decoration: InputDecoration(
                    labelText: 'Role (Posisi)',
                    prefixIcon: const Icon(Icons.work_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Cashier', child: Text('Kasir (Cashier)')),
                    DropdownMenuItem(value: 'Washer', child: Text('Tukang Cuci (Washer)')),
                    DropdownMenuItem(value: 'Driver', child: Text('Pengemudi (Driver)')),
                  ],
                  onChanged: (val) {
                    if (val != null) controller.role.value = val;
                  },
                )),
                SizedBox(height: R.h(12)),
                Container(
                  padding: EdgeInsets.all(R.w(12)),
                  decoration: BoxDecoration(
                    color: AppColors.warning50,
                    borderRadius: BorderRadius.circular(R.r(8)),
                    border: Border.all(color: AppColors.warning200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.warning700, size: R.r(20)),
                      SizedBox(width: R.w(8)),
                      Expanded(
                        child: Text(
                          'Sandi (password) default untuk akun ini adalah 123456. Beri tahu staff untuk menggantinya nanti.',
                          style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.warning900),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: R.h(24)),
                SizedBox(
                  width: double.infinity,
                  height: R.h(50),
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isSubmitting.value ? null : controller.addStaff,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
                    ),
                    child: controller.isSubmitting.value
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                        : Text('Daftarkan Staff', style: AppFonts.inter(fontSize: R.sp(16), fontWeight: FontWeight.bold, color: AppColors.white)),
                  )),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom), // Adjust for keyboard
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
