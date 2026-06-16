import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:geolocator/geolocator.dart';

class PermissionService {
  static Future<bool> checkAndRequestCameraPermission() async {
    final status = await ph.Permission.camera.status;
    
    if (status.isDenied) {
      final result = await ph.Permission.camera.request();
      return result.isGranted;
    }
    
    return status.isGranted;
  }

  static Future<bool> checkAndRequestLocationPermission() async {
    final status = await ph.Permission.location.status;
    
    if (status.isDenied) {
      final result = await ph.Permission.location.request();
      return result.isGranted;
    }
    
    return status.isGranted;
  }

  static Future<bool> checkAndRequestStoragePermission() async {
    ph.PermissionStatus status;
    
    if (await ph.Permission.photos.isGranted) {
      return true;
    }
    
    status = await ph.Permission.photos.status;
    
    if (status.isDenied) {
      final result = await ph.Permission.photos.request();
      return result.isGranted || result.isLimited;
    }
    
    return status.isGranted || status.isLimited;
  }

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<bool> checkLocationServiceAndPermission() async {
    final isServiceEnabled = await isLocationServiceEnabled();
    if (!isServiceEnabled) {
      return false;
    }
    
    return await checkAndRequestLocationPermission();
  }

  static Future<Map<String, bool>> checkAllPermissions() async {
    final camera = await checkAndRequestCameraPermission();
    final location = await checkAndRequestLocationPermission();
    final storage = await checkAndRequestStoragePermission();
    
    return {
      'camera': camera,
      'location': location,
      'storage': storage,
    };
  }

  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  static Future<bool> openAppSettings() async {
    return await ph.openAppSettings();
  }
}
