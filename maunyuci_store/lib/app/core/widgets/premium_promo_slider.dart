import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_fonts.dart';
import '../constants/app_colors.dart';
import '../utils/responsive_helper.dart';
import '../../data/models/promo_banner_model.dart';
import '../../data/providers/promo_banner_provider.dart';

/// Banner slider promosi Premium di halaman Akun (Server-Driven UI).
/// Mengambil daftar dari `GET /api/PromoBanners?appType=Store`, memfilter
/// via `targetRoles`/`targetTiers`, dan fallback ke konten lokal bila
/// API kosong/gagal (fallback hanya untuk Owner non-Premium).
class PremiumPromoSlider extends StatefulWidget {
  final String role;
  final String membershipTier;

  const PremiumPromoSlider({
    super.key,
    required this.role,
    required this.membershipTier,
  });

  @override
  State<PremiumPromoSlider> createState() => _PremiumPromoSliderState();
}

class _PremiumPromoSliderState extends State<PremiumPromoSlider> {
  final PromoBannerProvider _provider = PromoBannerProvider();
  final PageController _pageController = PageController();
  final RxInt _currentPage = 0.obs;
  final RxList<PromoBannerModel> _slides = <PromoBannerModel>[].obs;
  Timer? _timer;

  static const String _defaultCtaValue =
      '+6281234567890|Halo CS MauNyuci, saya tertarik untuk berlangganan fitur Premium untuk toko saya.';

  static List<PromoBannerModel> _defaultSlides() => const [
        PromoBannerModel(
          id: 'local-1',
          title: 'Laporan Keuangan Otomatis',
          description: 'Masih rekap nota sampai tengah malam? Pantau omzet dan profit bersih real-time dari satu layar.',
          icon: 'pie_chart_outline',
          ctaValue: _defaultCtaValue,
          sortOrder: 1,
          targetRoles: ['Owner'],
        ),
        PromoBannerModel(
          id: 'local-2',
          title: 'Multi-Outlet & Kunci Kas',
          description: 'Punya 2–3 cabang tapi takut kas bocor? Kunci akses staf dan pantau semua transaksi dalam genggaman.',
          icon: 'store_outlined',
          ctaValue: _defaultCtaValue,
          sortOrder: 2,
          targetRoles: ['Owner'],
        ),
        PromoBannerModel(
          id: 'local-3',
          title: 'Auto-Reminder & Blast Promo',
          description: 'Baju selesai otomatis ternotifikasi, voucher terkirim ke pelanggan lama. Orderan datang sendiri.',
          icon: 'notifications_active_outlined',
          ctaValue: _defaultCtaValue,
          sortOrder: 3,
          targetRoles: ['Owner'],
        ),
        PromoBannerModel(
          id: 'local-4',
          title: 'Stok Tak Pernah Kehabisan',
          description: 'Deterjen dan parfum menipis langsung diingatkan. Produksi jalan terus, pelanggan tak kecewa.',
          icon: 'inventory_2_outlined',
          ctaValue: _defaultCtaValue,
          sortOrder: 4,
          targetRoles: ['Owner'],
        ),
        PromoBannerModel(
          id: 'local-5',
          title: 'Badge Toko Pilihan',
          description: 'Mau laundry-mu muncul paling atas di aplikasi Customer? Aktifkan prioritas listing sekarang!',
          icon: 'verified_outlined',
          ctaValue: _defaultCtaValue,
          sortOrder: 5,
          targetRoles: ['Owner'],
        ),
      ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients || _slides.isEmpty) return;
      final next = (_currentPage.value + 1) % _slides.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
    _loadBanners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadBanners() async {
    try {
      final response = await _provider.getBanners('Store');
      if (response.success && response.data != null) {
        final filtered = response.data!.where((b) {
          if (!b.isActive) return false;
          final roleOk = b.targetRoles.isEmpty || b.targetRoles.contains(widget.role);
          final tierOk = b.targetTiers.isEmpty || b.targetTiers.contains(widget.membershipTier);
          return roleOk && tierOk;
        }).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        if (filtered.isNotEmpty) {
          _slides.assignAll(filtered);
          return;
        }
      }
    } catch (_) {
      // Fallback lokal di bawah.
    }

    // Fallback: konten lokal hanya untuk Owner non-Premium.
    if (widget.role == 'Owner' && widget.membershipTier != 'Premium') {
      _slides.assignAll(_defaultSlides());
    }
  }

  IconData _iconFromName(String name) {
    switch (name) {
      case 'pie_chart_outline':
        return Icons.pie_chart_outline;
      case 'store_outlined':
        return Icons.store_outlined;
      case 'notifications_active_outlined':
        return Icons.notifications_active_outlined;
      case 'inventory_2_outlined':
        return Icons.inventory_2_outlined;
      case 'verified_outlined':
        return Icons.verified_outlined;
      case 'local_offer_outlined':
        return Icons.local_offer_outlined;
      case 'receipt_long_outlined':
        return Icons.receipt_long_outlined;
      case 'workspace_premium':
        return Icons.workspace_premium;
      default:
        return Icons.workspace_premium;
    }
  }

  Future<void> _handleCta(PromoBannerModel slide) async {
    switch (slide.ctaType.toLowerCase()) {
      case 'route':
        if (slide.ctaValue.isNotEmpty) Get.toNamed(slide.ctaValue);
        break;
      case 'url':
        final uri = Uri.tryParse(slide.ctaValue);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        break;
      case 'whatsapp':
      default:
        // Format: "nomor|pesan"
        final parts = slide.ctaValue.split('|');
        final phone = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0] : '+6281234567890';
        final message = parts.length > 1 ? parts.sublist(1).join('|') : 'Halo CS MauNyuci!';
        final uri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          Get.snackbar(
            'Gagal',
            'Tidak dapat membuka WhatsApp',
            backgroundColor: AppColors.danger.withValues(alpha: 0.9),
            colorText: AppColors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_slides.isEmpty) return const SizedBox.shrink();
      final bg = _slides[_currentPage.value.clamp(0, _slides.length - 1)];
      final hasImage = bg.imageUrl.isNotEmpty;
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(R.r(16)),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(R.r(16)),
          child: Stack(
            children: [
              // Background: foto CDN bila ada, gradient ungu bila tidak/gagal load.
              Positioned.fill(
                child: hasImage
                    ? Image.network(
                        bg.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.primary800],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primary800],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
              ),
              // Scrim gelap di atas foto agar teks/CTA tetap terbaca.
              if (hasImage)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.black.withValues(alpha: 0.15),
                          AppColors.black.withValues(alpha: 0.55),
                          AppColors.black.withValues(alpha: 0.78),
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              Column(
                children: [
            SizedBox(
              height: R.h(132),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => _currentPage.value = i,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: EdgeInsets.fromLTRB(R.w(12), R.h(12), R.w(12), R.h(8)),
                    child: Row(
                      children: [
                        Container(
                          width: R.r(52),
                          height: R.r(52),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(R.r(14)),
                          ),
                          child: slide.imageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(R.r(14)),
                                  child: Image.network(
                                    slide.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Icon(
                                      _iconFromName(slide.icon),
                                      color: AppColors.white,
                                      size: R.r(26),
                                    ),
                                  ),
                                )
                              : Icon(_iconFromName(slide.icon), color: AppColors.white, size: R.r(26)),
                        ),
                        SizedBox(width: R.w(10)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.workspace_premium, color: AppColors.warning, size: R.r(14)),
                                  SizedBox(width: R.w(4)),
                                  Text('PREMIUM', style: AppFonts.inter(fontSize: R.sp(9), fontWeight: FontWeight.bold, color: AppColors.warning)),
                                ],
                              ),
                              SizedBox(height: R.h(2)),
                              Text(slide.title, style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.bold, color: AppColors.white)),
                              SizedBox(height: R.h(2)),
                              Text(
                                slide.description,
                                style: AppFonts.inter(fontSize: R.sp(11), color: AppColors.white.withValues(alpha: 0.85), height: 1.35),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(R.w(12), 0, R.w(12), R.h(12)),
              child: Row(
                children: [
                  Row(
                    children: List.generate(_slides.length, (i) {
                      final active = _currentPage.value == i;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.only(right: R.w(5)),
                        width: active ? R.w(16) : R.w(6),
                        height: R.h(6),
                        decoration: BoxDecoration(
                          color: active ? AppColors.white : AppColors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(R.r(3)),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  Builder(
                    builder: (context) {
                      final slide = _slides[_currentPage.value.clamp(0, _slides.length - 1)];
                      return ElevatedButton(
                        onPressed: () => _handleCta(slide),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                          foregroundColor: AppColors.black,
                          padding: EdgeInsets.symmetric(horizontal: R.w(14), vertical: R.h(8)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(10))),
                          elevation: 0,
                        ),
                        child: Text(
                          slide.ctaText.isNotEmpty ? slide.ctaText : 'Coba 1 Bulan Gratis',
                          style: AppFonts.inter(fontSize: R.sp(12), fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            ],
          ),
        ],
      ),
    ),
  );
    });
  }
}
