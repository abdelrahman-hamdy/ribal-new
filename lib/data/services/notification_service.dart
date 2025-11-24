import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Firebase Cloud Messaging service
@lazySingleton
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize FCM
  Future<void> initialize({
    required Function(String deepLink) onDeepLinkReceived,
  }) async {
    // Request permission
    await _requestPermission();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      _handleMessage(message, onDeepLinkReceived);
    });

    // Handle background/terminated messages
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleMessage(message, onDeepLinkReceived);
    });

    // Check for initial message (app opened from notification)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage, onDeepLinkReceived);
    }
  }

  /// Request notification permission
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

    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Listen to token refresh
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  /// Handle incoming message
  void _handleMessage(
    RemoteMessage message,
    Function(String deepLink) onDeepLinkReceived,
  ) {
    debugPrint('Received message: ${message.data}');

    final deepLink = message.data['deepLink'] as String?;
    if (deepLink != null && deepLink.isNotEmpty) {
      onDeepLinkReceived(deepLink);
    }
  }

  /// Parse notification data
  Map<String, dynamic>? parseNotificationData(RemoteMessage message) {
    try {
      if (message.data.containsKey('payload')) {
        return jsonDecode(message.data['payload'] as String);
      }
      return message.data;
    } catch (e) {
      debugPrint('Error parsing notification data: $e');
      return null;
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
}
