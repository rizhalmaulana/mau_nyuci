import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import 'custom_snackbar.dart';

class MapPickerView extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapPickerView({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<MapPickerView> createState() => _MapPickerViewState();
}

class _MapPickerViewState extends State<MapPickerView> {
  final MapController _mapController = MapController();
  
  // Default to Monas if no initial location is provided
  LatLng _centerPosition = const LatLng(-6.175392, 106.827153);
  
  String _currentAddress = 'Mengambil alamat...';
  bool _isLoadingAddress = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (widget.initialLat != null && widget.initialLng != null) {
      _centerPosition = LatLng(widget.initialLat!, widget.initialLng!);
      _fetchAddress(_centerPosition);
    } else {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _centerPosition = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_centerPosition, 15.0);
        _fetchAddress(_centerPosition);
      } catch (e) {
        // Fallback to default and fetch address
        _fetchAddress(_centerPosition);
      }
    }
  }

  void _onPositionChanged(MapPosition position, bool hasGesture) {
    if (position.center != null) {
      setState(() {
        _centerPosition = position.center!;
        _isLoadingAddress = true;
        _currentAddress = 'Mencari alamat...';
      });

      if (_debounceTimer?.isActive ?? false) {
        _debounceTimer!.cancel();
      }
      
      _debounceTimer = Timer(const Duration(milliseconds: 2000), () {
        _fetchAddress(_centerPosition);
      });
    }
  }

  Future<void> _fetchAddress(LatLng position) async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      final dio = Dio();
      final response = await dio.get(
        'https://us1.locationiq.com/v1/reverse.php',
        queryParameters: {
          'key': 'pk.ec69b070d8e0ca24dd6cf88f750ceede',
          'lat': position.latitude,
          'lon': position.longitude,
          'format': 'json',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (mounted) {
          setState(() {
            _currentAddress = data['display_name'] ?? 'Alamat tidak ditemukan';
            _isLoadingAddress = false;
          });
        }
      } else {
        throw Exception('Gagal mendapatkan alamat');
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = 'Gagal mendapatkan alamat';
        if (e is DioException && e.response?.statusCode == 429) {
          errorMsg = 'Terlalu banyak permintaan, tunggu sebentar...';
        }
        setState(() {
          _currentAddress = errorMsg;
          _isLoadingAddress = false;
        });
      }
    }
  }

  void _confirmLocation() {
    if (_isLoadingAddress) {
      CustomSnackbar.showError('Tunggu Sebentar', 'Sedang memuat alamat lokasi');
      return;
    }
    
    Get.back(result: {
      'address': _currentAddress,
      'lat': _centerPosition.latitude,
      'lng': _centerPosition.longitude,
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'MauNyuci Maps',
          style: AppFonts.fInterSubheadingSemibold.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _centerPosition,
              initialZoom: 15.0,
              onPositionChanged: _onPositionChanged,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.maunyuci_customer',
              ),
            ],
          ),
          
          // Center Marker (Fixed in center)
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0), // Offset slightly so pin points to exact center
              child: Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 40,
              ),
            ),
          ),
          
          // Info Card Bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lokasi Terpilih',
                    style: AppFonts.fInterBodySmallSemibold.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _isLoadingAddress
                            ? Row(
                                children: [
                                  const SizedBox(
                                    width: 14, 
                                    height: 14, 
                                    child: CircularProgressIndicator(strokeWidth: 2)
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Mencari alamat...',
                                    style: AppFonts.fInterBodySmallRegular.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                _currentAddress,
                                style: AppFonts.fInterBodySmallRegular.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Pilih Lokasi Ini',
                        style: AppFonts.fInterBodyMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Locate me button
          Positioned(
            right: 16,
            bottom: 180, // Above the info card
            child: FloatingActionButton(
              backgroundColor: AppColors.white,
              onPressed: () async {
                try {
                  final position = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high,
                  );
                  _mapController.move(
                    LatLng(position.latitude, position.longitude), 
                    15.0
                  );
                } catch (e) {
                  CustomSnackbar.showError('Mohon Maaf', 'Gagal mendapatkan lokasi saat ini');
                }
              },
              child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
