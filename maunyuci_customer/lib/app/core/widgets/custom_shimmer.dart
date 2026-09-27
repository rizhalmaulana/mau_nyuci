import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import '../utils/responsive_helper.dart';

/// Kotak abu-abu pembentuk skeleton. Harus dipakai di dalam
/// [Shimmer.fromColors] (lihat skeleton section di bawah).
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(R.r(borderRadius)),
      ),
    );
  }
}

class CustomShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const CustomShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Bar data: satu-satunya bagian yang di-shimmer.
/// Layout di sekitarnya (ikon, teks statis, kartu) tetap asli,
/// mengikuti pola beranda store (CustomShimmer.listOrder/box).
class DataBar extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const DataBar({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: ShimmerBox(width: width, height: height, borderRadius: borderRadius),
    );
  }
}

/// Skeleton header beranda: layout & ikon tetap asli,
/// yang di-shimmer hanya data (nama user + alamat).
/// Cermin dari HomeHeader (home_header_section.dart).
class HomeHeaderShimmer extends StatelessWidget {
  const HomeHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.w(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: R.h(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DataBar(width: R.w(180), height: R.h(20)),
                    SizedBox(height: R.h(4)),
                    Text(
                      'Ada yang bisa kami bantu cuci?',
                      style: AppFonts.fInterBodySmallRegular.copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                          fontSize: R.sp(12)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(R.r(10)),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(R.r(16)),
                ),
                child: SvgPicture.asset(
                  AppAssets.iconNotification,
                  width: R.r(24),
                  height: R.r(24),
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(24)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(8)),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(R.r(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: AppColors.white, size: R.r(20)),
                SizedBox(width: R.w(8)),
                Expanded(child: DataBar(height: R.h(12))),
                SizedBox(width: R.w(8)),
                SvgPicture.asset(
                  AppAssets.iconArrowRight,
                  width: R.r(20),
                  height: R.r(20),
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton kartu transaksi: kartu putih tetap asli,
/// yang di-shimmer hanya bar datanya. Cermin dari OrderItemCard.
class OrderCardShimmer extends StatelessWidget {
  const OrderCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(R.r(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: R.w(90), height: R.h(12)),
                ShimmerBox(width: R.w(70), height: R.h(20), borderRadius: 16),
              ],
            ),
            SizedBox(height: R.h(8)),
            const Divider(),
            SizedBox(height: R.h(8)),
            ShimmerBox(width: R.w(150), height: R.h(14)),
            SizedBox(height: R.h(12)),
            Row(
              children: [
                ShimmerBox(width: R.r(48), height: R.r(48), borderRadius: 8),
                SizedBox(width: R.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerBox(width: double.infinity, height: 12),
                      SizedBox(height: R.h(6)),
                      ShimmerBox(width: R.w(120), height: R.h(11)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: R.h(16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: R.w(70), height: R.h(12)),
                    SizedBox(height: R.h(4)),
                    ShimmerBox(width: R.w(90), height: R.h(11)),
                  ],
                ),
                ShimmerBox(width: R.w(80), height: R.h(16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton seksi Transaksi Berjalan: kartu + judul + pil tetap asli,
/// yang di-shimmer hanya daftar datanya.
/// Cermin dari ActiveTransactionSection.
class ActiveTransactionShimmer extends StatelessWidget {
  const ActiveTransactionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.w(24)),
      child: Container(
        padding: EdgeInsets.all(R.r(16)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(R.r(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaksi Berjalan',
                  style: AppFonts.fInterSubheadingSemibold.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(6)),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(R.r(20)),
                  ),
                  child: Text(
                    'Lihat Semua',
                    style: AppFonts.fInterCaptionMedium.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            SizedBox(height: R.h(16)),
            const OrderCardShimmer(),
            SizedBox(height: R.h(16)),
            const OrderCardShimmer(),
          ],
        ),
      ),
    );
  }
}

/// Skeleton seksi Riwayat: judul + pil tetap asli,
/// yang di-shimmer hanya daftar datanya.
/// Cermin dari HistoryOrderSection.
///
/// Catatan: OrderNowCard tidak punya skeleton karena isinya
/// statis (tanpa data) — langsung tampil asli saat loading.
class HistoryShimmer extends StatelessWidget {
  const HistoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.w(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat',
                    style: AppFonts.fInterSubheadingSemibold.copyWith(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: R.h(4)),
                  Text(
                    'pesanan terakhirmu ada di sini.',
                    style: AppFonts.fInterCaptionRegular.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(6)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(R.r(20)),
                ),
                child: Text(
                  'Lihat Semua',
                  style: AppFonts.fInterCaptionRegular.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(16)),
          const OrderCardShimmer(),
          SizedBox(height: R.h(16)),
          const OrderCardShimmer(),
        ],
      ),
    );
  }
}

// ===== Skeleton generik lama (dipertahankan agar kompatibel) =====

class ShimmerHeader extends StatelessWidget {
  const ShimmerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: R.w(120),
            height: R.h(24),
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: BorderRadius.circular(R.r(4)),
            ),
          ),
          SizedBox(height: R.h(8)),
          Container(
            width: R.w(200),
            height: R.h(16),
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: BorderRadius.circular(R.r(4)),
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final double? width;
  final double height;

  const ShimmerCard({
    super.key,
    this.width,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(R.r(12)),
        ),
      ),
    );
  }
}

class ShimmerListItem extends StatelessWidget {
  final double height;

  const ShimmerListItem({
    super.key,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Padding(
        padding: EdgeInsets.only(bottom: R.h(12)),
        child: Row(
          children: [
            Container(
              width: R.r(60),
              height: R.r(60),
              decoration: BoxDecoration(
                color: AppColors.shimmerBase,
                borderRadius: BorderRadius.circular(R.r(8)),
              ),
            ),
            SizedBox(width: R.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: R.h(14),
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius: BorderRadius.circular(R.r(4)),
                    ),
                  ),
                  SizedBox(height: R.h(8)),
                  Container(
                    width: R.w(100),
                    height: R.h(12),
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius: BorderRadius.circular(R.r(4)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
