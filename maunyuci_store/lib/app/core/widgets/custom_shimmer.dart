import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';
import '../utils/responsive_helper.dart';

class CustomShimmer {
  static Widget listOrder() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: R.h(12)),
          padding: EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(12)),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(R.r(12)),
            border: Border.all(color: AppColors.grey200),
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
                    Container(width: R.w(100), height: R.h(14), color: AppColors.white),
                    Container(width: R.w(60), height: R.h(14), color: AppColors.white),
                  ],
                ),
                SizedBox(height: R.h(24)),
                Container(width: R.w(120), height: R.h(16), color: AppColors.white),
                SizedBox(height: R.h(8)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: R.w(80), height: R.h(12), color: AppColors.white),
                    Container(width: R.w(80), height: R.h(12), color: AppColors.white),
                  ],
                ),
                SizedBox(height: R.h(12)),
                Row(
                  children: [
                    Container(width: R.w(36), height: R.h(36), decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(R.r(6)))),
                    SizedBox(width: R.w(12)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: R.w(100), height: R.h(12), color: AppColors.white),
                        SizedBox(height: R.h(4)),
                        Container(width: R.w(60), height: R.h(10), color: AppColors.white),
                      ],
                    )
                  ],
                ),
                SizedBox(height: R.h(12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: R.w(80), height: R.h(12), color: AppColors.white),
                    Container(width: R.w(80), height: R.h(14), color: AppColors.white),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget box({required double width, required double height, double borderRadius = 4, Color? baseColor, Color? highlightColor}) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? AppColors.shimmerBase,
      highlightColor: highlightColor ?? AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
