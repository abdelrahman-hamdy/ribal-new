import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

/// Enhanced FCM service with local notifications support
@lazySingleton
class FCMNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'ribal_high_importance_channel', // id
    'Ribal Notifications', // name
    description: 'This channel is used for important Ribal notifications',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// Initialize FCM and local notifications
  Future<void> initialize({
    required Function(Map<String, dynamic> payload) onNotificationTapped,
    required Function(String? token) onTokenReceived,
  }) async {
    // Initialize local notifications
    await _initializeLocalNotifications(onNotificationTapped);

    // Request permissions
    final permissionGranted = await _requestPermission();
    if (!permissionGranted) return;

    // Get and save FCM token
    final token = await getToken();
    onTokenReceived(token);

    // Listen to token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      onTokenReceived(newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    // Handle notification taps (background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message, onNotificationTapped);
    });

    // Check for initial message (app opened from terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage, onNotificationTapped);
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications(
    Function(Map<String, dynamic> payload) onNotificationTapped,
  ) async {
    // Android initialization
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          try {
            final payload = jsonDecode(response.payload!);
            onNotificationTapped(payload);
          } catch (e) {
            // Silently ignore parse errors
          }
        }
      },
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }
  }

  /// Request notification permissions
  Future<bool> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (Platform.isIOS) {
      // Request iOS-specific permissions for local notifications
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Get FCM token
  /// On iOS, waits for APNs token to be available before requesting FCM token
  Future<String?> getToken() async {
    try {
      if (Platform.isIOS) {
        // For iOS, we MUST wait for the APNs token first
        // The FCM token cannot be generated without it
        String? apnsToken = await _messaging.getAPNSToken();

        // If APNs token is null, wait and retry (it might not be available immediately)
        if (apnsToken == null) {
          // Wait up to 10 seconds for APNs token to become available
          for (int i = 0; i < 10; i++) {
            await Future.delayed(const Duration(seconds: 1));
            apnsToken = await _messaging.getAPNSToken();
            if (apnsToken != null) break;
          }

          // If still null after 10 seconds, return null
          if (apnsToken == null) return null;
        }
      }

      return await _messaging.getToken();
    } catch (e) {
      return null;
    }
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Show local notification for FCM message
  Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;
    final apple = message.notification?.apple;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            subtitle: apple?.subtitle,
            sound: apple?.sound?.name,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(
    RemoteMessage message,
    Function(Map<String, dynamic> payload) onNotificationTapped,
  ) {
    final data = message.data;
    if (data.isNotEmpty) {
      onNotificationTapped(data);
    }
  }

  /// Get badge count (iOS only)
  Future<int?> getBadgeCount() async {
    if (Platform.isIOS) {
      // This requires additional native implementation
      return null;
    }
    return null;
  }

  /// Set badge count (iOS only)
  Future<void> setBadgeCount(int count) async {
    if (Platform.isIOS) {
      // This requires additional native implementation
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }
}
