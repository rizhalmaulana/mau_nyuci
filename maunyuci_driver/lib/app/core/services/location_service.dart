import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const int updateIntervalSeconds = 60;
  static const double minDistanceDeltaMeters = 50.0;

  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'location_service',
      'Location Tracking',
      description: 'Digunakan untuk melacak lokasi driver',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'location_service',
        initialNotificationTitle: 'MauNyuci Driver',
        initialNotificationContent: 'Membaca lokasi Anda',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  static Future<void> startService() async {
    final service = FlutterBackgroundService();
    var isRunning = await service.isRunning();
    if (!isRunning) {
      service.startService();
    }
  }

  static Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke("stopService");
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  final prefs = await SharedPreferences.getInstance();
  final apiClient = ApiClientNetwork();

  Timer.periodic(const Duration(seconds: LocationService.updateIntervalSeconds), (timer) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      double lastLat = prefs.getDouble('last_lat') ?? 0.0;
      double lastLng = prefs.getDouble('last_lng') ?? 0.0;

      double distance = Geolocator.distanceBetween(
        lastLat,
        lastLng,
        position.latitude,
        position.longitude,
      );

      // Smart Update Strategy
      if (lastLat == 0.0 || distance >= LocationService.minDistanceDeltaMeters) {
        final response = await apiClient.putReq<dynamic>(
          ApiConstants.driverLocation,
          data: {
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
        );

        if (response.success) {
          await prefs.setDouble('last_lat', position.latitude);
          await prefs.setDouble('last_lng', position.longitude);
        }
      }
    } catch (e) {
      debugPrint('Background location error: $e');
    }
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}
