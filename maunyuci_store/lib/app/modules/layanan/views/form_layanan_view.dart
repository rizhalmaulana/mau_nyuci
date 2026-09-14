import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../data/providers/media_provider.dart';
import '../../../core/widgets/custom_snackbar.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_colors.dart';

import '../controllers/layanan_controller.dart';
import '../../../data/models/layanan_model.dart';
import '../../../core/utils/responsive_helper.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    String numericOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }
    final buffer = StringBuffer();
    for (int i = 0; i < numericOnly.length; i++) {
      buffer.write(numericOnly[i]);
      int index = numericOnly.length - 1 - i;
      if (index > 0 && index % 3 == 0) {
        buffer.write('.');
      }
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.toString().length),
    );
  }
}

class FormLayananView extends StatefulWidget {
  final LayananModel? layanan;

  const FormLayananView({super.key, this.layanan});

  @override
  State<FormLayananView> createState() => _FormLayananViewState();
}

class _FormLayananViewState extends State<FormLayananView> {
  final LayananController controller = Get.find<LayananController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _timeController;
  late TextEditingController _descController;

  String _selectedCategory = 'Laundry Kiloan';
  String _selectedUnit = 'Kg';
  String _selectedImage = '';
  String _selectedTimeUnit = 'Hari';
  
  File? _imageFile;
  final MediaProvider _mediaProvider = MediaProvider();
  bool _isSaving = false;

  final List<String> _categories = [
    'Laundry Kiloan',
    'Laundry Satuan',
    'Laundry Express',
    'Laundry Sepatu',
    'Laundry Tas',
    'Laundry Karpet',
    'Laundry Boneka',
    'Lainnya'
  ];

  final List<String> _units = [
    'Kg',
    'Pcs',
    'Meter',
    'Pasang',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.layanan?.name ?? '');
    
    // Format initial price
    String initialPrice = widget.layanan?.price.toInt().toString() ?? '';
    if (initialPrice.isNotEmpty) {
      final formatter = CurrencyInputFormatter();
      final formatted = formatter.formatEditUpdate(
        const TextEditingValue(text: ''), 
        TextEditingValue(text: initialPrice)
      );
      initialPrice = formatted.text;
    }
    _priceController = TextEditingController(text: initialPrice);

    // Parse initial time estimate
    String timeEst = widget.layanan?.timeEstimate ?? '';
    String timeNumber = '';
    if (timeEst.isNotEmpty) {
      final parts = timeEst.split(' ');
      if (parts.isNotEmpty) {
        timeNumber = parts[0];
        if (parts.length > 1) {
          String unit = parts[1];
          if (unit == 'Hari' || unit == 'Jam') {
            _selectedTimeUnit = unit;
          }
        }
      }
    }
    _timeController = TextEditingController(text: timeNumber);
    _descController = TextEditingController(text: widget.layanan?.description ?? '');

    if (widget.layanan != null) {
      _selectedCategory = widget.layanan!.category;
      _selectedUnit = widget.layanan!.unit;
      _selectedImage = widget.layanan!.imageAsset;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _timeController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String? newValue) {
    if (newValue == null) return;
    setState(() {
      _selectedCategory = newValue;
      // Smart Auto Unit Logic
      if (newValue == 'Laundry Kiloan' || newValue == 'Laundry Express') {
        _selectedUnit = 'Kg'; // Default Express to Kg, but user can change it
      } else if (newValue == 'Laundry Karpet') {
        _selectedUnit = 'Meter';
      } else if (newValue == 'Laundry Sepatu') {
        _selectedUnit = 'Pasang';
      } else {
        _selectedUnit = 'Pcs';
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _selectedImage = ''; 
      });
    }
  }

  void _showImageSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(24))),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(R.w(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Pilih Ikon Layanan', style: AppFonts.inter(fontSize: R.sp(16), fontWeight: FontWeight.bold)),
                SizedBox(height: R.h(16)),
                Obx(() => GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: R.w(12),
                    mainAxisSpacing: R.h(12),
                  ),
                  itemCount: controller.defaultAssets.length,
                  itemBuilder: (context, index) {
                    final asset = controller.defaultAssets[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImage = asset;
                          _imageFile = null;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(R.r(8)),
                        decoration: BoxDecoration(
                          color: AppColors.purple50,
                          borderRadius: BorderRadius.circular(R.r(12)),
                          border: Border.all(
                            color: _selectedImage == asset ? AppColors.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Image.network('${ApiConstants.cloudflareCatalogIconUrl}$asset', fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported)),
                      ),
                    );
                  },
                )),
                SizedBox(height: R.h(16)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null && _selectedImage.isEmpty) {
      CustomSnackbar.showWarning('Peringatan', 'Silakan pilih gambar layanan terlebih dahulu');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    String imageUrl = _selectedImage;
    
    // Upload image if a new local file is selected
    if (_imageFile != null) {
      final uploadRes = await _mediaProvider.uploadCatalogImage(_imageFile!);
      if (!uploadRes.success || uploadRes.data == null) {
        setState(() {
          _isSaving = false;
        });
        CustomSnackbar.showWarning('Error', uploadRes.message ?? 'Gagal mengunggah gambar');
        return;
      }
      imageUrl = uploadRes.data!;
    }

    // Remove dots from price string before parsing
    String rawPrice = _priceController.text.replaceAll('.', '');
    
    final newLayanan = LayananModel(
      id: widget.layanan?.id ?? const Uuid().v4(),
      imageAsset: imageUrl,
      name: _nameController.text,
      category: _selectedCategory,
      price: double.parse(rawPrice),
      unit: _selectedUnit,
      timeEstimate: '${_timeController.text} $_selectedTimeUnit',
      description: _descController.text,
    );

    bool success;
    if (widget.layanan == null) {
      success = await controller.addLayanan(newLayanan);
    } else {
      success = await controller.updateLayanan(newLayanan.id, newLayanan);
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }

    if (success) {
      Get.back();
      CustomSnackbar.showSuccess('Berhasil', 'Layanan berhasil disimpan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          widget.layanan == null ? 'Tambah Layanan' : 'Edit Layanan',
          style: AppFonts.inter(fontWeight: FontWeight.w600, fontSize: R.sp(16)),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.black87,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: R.w(24), 
          right: R.w(24), 
          top: R.h(20), 
          bottom: R.h(24) + MediaQuery.of(context).padding.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Selector
              Center(
                child: GestureDetector(
                  onTap: _showImageSelector,
                  child: Container(
                    width: R.r(120),
                    height: R.r(120),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(R.r(24)),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(R.r(16)),
                            child: _imageFile != null
                                ? Image.file(_imageFile!, fit: BoxFit.cover)
                                : (_selectedImage.isNotEmpty
                                    ? (_selectedImage.startsWith('http')
                                        ? Image.network(_selectedImage, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.image_not_supported, color: AppColors.grey500))
                                        : Image.network('${ApiConstants.cloudflareCatalogIconUrl}$_selectedImage', fit: BoxFit.contain, errorBuilder: (c, e, s) => Icon(Icons.image_not_supported, color: AppColors.grey500)))
                                    : Icon(Icons.add_photo_alternate, size: R.r(40), color: AppColors.primary.withValues(alpha: 0.5))),
                          ),
                        ),
                        Positioned(
                          right: -5,
                          bottom: -5,
                          child: Container(
                            padding: EdgeInsets.all(R.r(8)),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.white, width: 2),
                            ),
                            child: Icon(Icons.edit, size: R.r(16), color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: R.h(32)),

              // Category & Unit
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kategori', style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.w500, color: AppColors.inputText)),
                        SizedBox(height: R.h(8)),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: AppColors.primary)),
                            contentPadding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
                          ),
                          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey500),
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: AppFonts.inter(fontSize: R.sp(14))))).toList(),
                          onChanged: _onCategoryChanged,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: R.w(16)),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Satuan', style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.w500, color: AppColors.inputText)),
                        SizedBox(height: R.h(8)),
                        DropdownButtonFormField<String>(
                          value: _selectedUnit,
                          isExpanded: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: AppColors.primary)),
                            contentPadding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
                          ),
                          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey500),
                          items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u, style: AppFonts.inter(fontSize: R.sp(14))))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedUnit = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: R.h(20)),

              // Name
              Text('Nama Layanan', style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.w500, color: AppColors.inputText)),
              SizedBox(height: R.h(8)),
              TextFormField(
                controller: _nameController,
                style: AppFonts.inter(fontSize: R.sp(14)),
                decoration: InputDecoration(
                  hintText: 'Contoh: Cuci Kering',
                  hintStyle: AppFonts.inter(color: AppColors.hint, fontSize: R.sp(14)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: AppColors.primary)),
                  contentPadding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              SizedBox(height: R.h(20)),

              Text('Harga', style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.w500, color: AppColors.inputText)),
              SizedBox(height: R.h(8)),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                style: AppFonts.inter(fontSize: R.sp(14)),
                decoration: InputDecoration(
                  hintText: 'Contoh: 15.000',
                  hintStyle: AppFonts.inter(color: AppColors.hint, fontSize: R.sp(14)),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: R.w(16), right: R.w(8)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Rp', style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.w600, color: AppColors.black87)),
                      ],
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: AppColors.primary)),
                  contentPadding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Harga tidak boleh kosong' : null,
              ),
              SizedBox(height: R.h(20)),

              Text('Estimasi Selesai', style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.w500, color: AppColors.inputText)),
              SizedBox(height: R.h(8)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _timeController,
                      keyboardType: TextInputType.number,
                      style: AppFonts.inter(fontSize: R.sp(14)),
                      decoration: InputDecoration(
                        hintText: 'Contoh: 2',
                        hintStyle: AppFonts.inter(color: AppColors.hint, fontSize: R.sp(14)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: AppColors.primary)),
                        contentPadding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Estimasi tidak boleh kosong' : null,
                    ),
                  ),
                  SizedBox(width: R.w(16)),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _selectedTimeUnit,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: AppColors.primary)),
                        contentPadding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey500),
                      items: ['Hari', 'Jam'].map((c) => DropdownMenuItem(value: c, child: Text(c, style: AppFonts.inter(fontSize: R.sp(14))))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedTimeUnit = val;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: R.h(20)),

              // Description
              Text('Deskripsi (Opsional)', style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.w500, color: AppColors.inputText)),
              SizedBox(height: R.h(8)),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                style: AppFonts.inter(fontSize: R.sp(14)),
                decoration: InputDecoration(
                  hintText: 'Tuliskan deskripsi layanan di sini...',
                  hintStyle: AppFonts.inter(color: AppColors.hint, fontSize: R.sp(14)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: AppColors.primary)),
                  contentPadding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
                ),
              ),
              SizedBox(height: R.h(40)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor: AppColors.grey300,
                    padding: EdgeInsets.symmetric(vertical: R.h(16)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
                    elevation: 0,
                  ),
                  child: _isSaving 
                      ? SizedBox(
                          height: R.r(20), 
                          width: R.r(20), 
                          child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.white)
                        )
                      : Text('Simpan Layanan', style: AppFonts.inter(fontSize: R.sp(16), fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
