import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// Top-level function untuk menangani pesan di background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Callback yang dipanggil setiap notifikasi ditekan (foreground,
  /// background, maupun terminated). Di-set oleh tiap aplikasi
  /// (customer/store/driver) untuk redirect ke halaman detail,
  /// karena core tidak boleh tahu tentang routes aplikasi.
  static Future<void> Function(Map<String, dynamic> data)? onNotificationTap;

  /// Dipanggil setiap FCM token di-rotate. Di-set oleh aplikasi untuk
  /// re-sync token baru ke backend. Tanpa ini, push berhenti sampai
  /// user login ulang (token lama di backend sudah basi).
  static Future<void> Function(String token)? onFcmTokenRefresh;

  /// true jika pop-up sistem diizinkan (hasil request saat init).
  static bool notificationsAllowed = false;

  /// Ambil orderId dari payload FCM backend (NotificationDispatcher).
  /// Kunci yang didukung: orderId, referenceId, relatedId.
  /// Sengaja TIDAK memakai kunci 'id' (itu id notifikasi, bukan order).
  static String? extractOrderId(Map<String, dynamic> data) {
    for (final key in ['orderId', 'referenceId', 'relatedId']) {
      final value = data[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static Future<void> _handleTap(Map<String, dynamic> data) async {
    try {
      debugPrint('Notification tapped with data: $data');
      final handler = onNotificationTap;
      if (handler != null) await handler(data);
    } catch (e) {
      debugPrint('onNotificationTap error: $e');
    }
  }

  Future<void> init() async {
    if (_isInitialized) return;

    // Request permissions (for iOS and Android 13+)
    await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // WAJIB di Android 13+: FCM requestPermission() di atas TIDAK meminta
    // izin sistem POST_NOTIFICATIONS. Tanpa request ini, SEMUA notifikasi
    // (pop-up lokal maupun tray FCM) diblokir sistem secara diam-diam.
    // Ini penyebab klasik "di HP A work, di HP B tidak muncul".
    if (Platform.isAndroid) {
      try {
        var status = await Permission.notification.status;
        if (!status.isGranted) {
          status = await Permission.notification.request();
        }
        notificationsAllowed = status.isGranted;
        debugPrint('POST_NOTIFICATIONS granted: $notificationsAllowed ($status)');
      } catch (e) {
        debugPrint('Notification permission request failed: $e');
      }
    } else {
      final settings = await _fcm.getNotificationSettings();
      notificationsAllowed = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }

    // Token bisa di-rotate Firebase kapan saja — teruskan ke backend
    // agar push tidak berhenti diam-diam.
    _fcm.onTokenRefresh.listen((newToken) async {
      try {
        debugPrint('FCM token refreshed');
        final handler = onFcmTokenRefresh;
        if (handler != null) await handler(newToken);
      } catch (e) {
        debugPrint('onFcmTokenRefresh error: $e');
      }
    });

    // Configure Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // For iOS (Darwin) initialization
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Ketuk pop-up saat foreground: payload berisi data FCM backend.
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final decoded = jsonDecode(payload) as Map<String, dynamic>;
          await _handleTap(decoded.map((k, v) => MapEntry(k.toString(), v.toString())));
        } catch (e) {
          debugPrint('Failed to parse notification payload: $e');
        }
      },
    );

    // Create a high importance channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // name
      description: 'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Register Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message, channel);
      }
    });

    // Ketuk pop-up saat aplikasi di background.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleTap(message.data);
    });

    // Ketuk pop-up saat aplikasi terminated (dihandle setelah frame pertama
    // agar navigator sudah siap).
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleTap(initialMessage.data);
      });
    }

    _isInitialized = true;
  }

  void _showLocalNotification(RemoteMessage message, AndroidNotificationChannel channel) {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      _localNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        // Teruskan data FCM (orderId) agar bisa di-redirect saat diketuk.
        payload: jsonEncode(message.data),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
          ),
          // iOS: tanpa ini pop-up foreground tidak tampil & tidak bunyi.
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    }
  }

  Future<String?> getFcmToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      debugPrint("Failed to get FCM token: $e");
      return null;
    }
  }

  // Helper method to show generic local notification from SignalR
  Future<void> showSignalRNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'signalr_channel',
      'SignalR Notifications',
      channelDescription: 'Real-time in-app notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _localNotificationsPlugin.show(
      id: DateTime.now().millisecond, // random id
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }
}
