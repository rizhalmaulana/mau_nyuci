import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import '../constants/app_assets.dart';
import '../../data/repositories/address_repository.dart';

class CustomLocationPicker extends StatefulWidget {
  const CustomLocationPicker({super.key});

  @override
  State<CustomLocationPicker> createState() => _CustomLocationPickerState();
}

class _CustomLocationPickerState extends State<CustomLocationPicker> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _recentAddresses = [];
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadRecentAddresses();
  }

  Future<void> _loadRecentAddresses() async {
    final list = await Get.find<AddressRepository>().getRecentAddresses();
    setState(() {
      _recentAddresses = list;
    });
  }

  Future<void> _searchAddress(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 5,
          'addressdetails': 1,
        },
        options: Options(headers: {'User-Agent': 'MauNyuci/1.0'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        setState(() {
          _searchResults = data.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final address = await _reverseGeocode(position.latitude, position.longitude);
      
      await Get.find<AddressRepository>().saveAddress(
        address,
        position.latitude,
        position.longitude,
      );

      Get.back(result: {
        'address': address,
        'lat': position.latitude,
        'lng': position.longitude,
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Tidak dapat获取位置信息',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _reverseGeocode(double lat, double lon) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'format': 'json',
        },
        options: Options(headers: {'User-Agent': 'MauNyuci/1.0'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['display_name'] ?? 'Unknown location';
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
    }
    return 'Unknown location';
  }

  void _selectAddress(Map<String, dynamic> address) async {
    final lat = double.tryParse(address['lat']?.toString() ?? '0');
    final lon = double.tryParse(address['lon']?.toString() ?? '0');
    
    if (lat != null && lon != null) {
      await Get.find<AddressRepository>().saveAddress(
        address['display_name'],
        lat,
        lon,
      );
    }

    Get.back(result: {
      'address': address['display_name'],
      'lat': lat,
      'lng': lon,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Pilih Lokasi',
                  style: AppFonts.fInterSubheadingSemibold.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              decoration: InputDecoration(
                hintText: 'Cari alamat...',
                hintStyle: AppFonts.fInterBodySmallRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _searchResults = [];
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {});
                Future.delayed(const Duration(milliseconds: 500), () {
                  _searchAddress(value);
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _getCurrentLocation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Berdasarkan Lokasi Saat Ini',
                    style: AppFonts.fInterBodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final item = _searchResults[index];
                  return _buildAddressTile(
                    item['display_name'] ?? '',
                    item['lat']?.toString(),
                    item['lon']?.toString(),
                  );
                },
              ),
            )
          else if (_recentAddresses.isNotEmpty)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Riwayat Alamat',
                      style: AppFonts.fInterBodySmallMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _recentAddresses.length,
                      itemBuilder: (context, index) {
                        final item = _recentAddresses[index];
                        return _buildAddressTile(
                          item['address'],
                          item['lat']?.toString(),
                          item['lng']?.toString(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: Center(
                child: Text(
                  'Cari alamat atau gunakan lokasi saat ini',
                  style: AppFonts.fInterBodySmallRegular.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressTile(String displayName, String? lat, String? lon) {
    return GestureDetector(
      onTap: () {
        _selectAddress({
          'display_name': displayName,
          'lat': lat,
          'lon': lon,
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                displayName,
                style: AppFonts.fInterBodySmallRegular.copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }
}