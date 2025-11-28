import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'app/app.dart';
import 'app/di/injection.dart';
import 'app/router/app_router.dart';
import 'app/router/routes.dart';
import 'core/services/hive_cache_service.dart';
import 'data/models/user_model.dart';
import 'data/services/fcm_notification_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'firebase_options.dart';

/// Background message handler (must be top-level function)
/// This is called when app is in background or terminated
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('🔔 Background message received: ${message.messageId}');
  debugPrint('🔔 Title: ${message.notification?.title}');
  debugPrint('🔔 Body: ${message.notification?.body}');
  debugPrint('🔔 Data: ${message.data}');

  // You can process the message here if needed
  // For example, update local database, show notification, etc.
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Enable Firestore offline persistence for better performance
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Initialize dependency injection
  await configureDependencies();

  // Initialize Hive cache service for local data caching
  final hiveCacheService = getIt<HiveCacheService>();
  await hiveCacheService.initialize();

  // Initialize FCM Notification Service
  try {
    final fcmService = getIt<FCMNotificationService>();
    final authBloc = getIt<AuthBloc>();

    await fcmService.initialize(
      onNotificationTapped: (payload) async {
        debugPrint('🔔 FCM notification tapped with payload: $payload');

        // Handle navigation based on deepLink in payload
        if (payload.containsKey('deepLink')) {
          final deepLink = payload['deepLink'] as String;
          final authState = authBloc.state;

          if (authState is! AuthAuthenticated) {
            debugPrint('⚠️ User not authenticated, skipping navigation');
            return;
          }

          final userRole = authState.user.role;
          final String targetRoute;

          // Handle task deepLinks: /tasks/{id} → role-specific task detail route
          final taskMatch = RegExp(r'^/tasks/(.+)$').firstMatch(deepLink);
          if (taskMatch != null) {
            final taskId = taskMatch.group(1)!;
            targetRoute = switch (userRole) {
              UserRole.admin => Routes.adminTaskDetailPath(taskId),
              UserRole.manager => Routes.managerTaskDetailPath(taskId),
              // Employees don't have task detail pages, navigate to their tasks page
              UserRole.employee => Routes.employeeTasks,
            };
          }
          // Handle assignment deepLinks: /assignments/{id} → role-specific assignment detail route
          else {
            final assignmentMatch = RegExp(r'^/assignments/(.+)$').firstMatch(deepLink);
            if (assignmentMatch != null) {
              final assignmentId = assignmentMatch.group(1)!;
              targetRoute = switch (userRole) {
                UserRole.manager => Routes.managerAssignmentDetailPath(assignmentId),
                UserRole.employee => Routes.employeeAssignmentDetailPath(assignmentId),
                // Admins don't have assignment detail pages, navigate to tasks page
                UserRole.admin => Routes.adminTasks,
              };
            } else {
              // For other deepLinks, use as-is (e.g., "/" for home page)
              targetRoute = deepLink;
            }
          }

          // Navigate using GoRouter (use push to maintain navigation stack)
          if (targetRoute.isNotEmpty) {
            debugPrint('🔔 Navigating to: $targetRoute');
            AppRouter.router.push(targetRoute);
          }
        }
      },
      onTokenReceived: (token) async {
        debugPrint('🔔 FCM Token received: $token');

        if (token == null) {
          debugPrint('⚠️ FCM token is null');
          return;
        }

        // Save token to Firestore when user is authenticated
        final authState = authBloc.state;
        if (authState is AuthAuthenticated) {
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(authState.user.id)
                .update({
              'fcmToken': token,
              'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
            });
            debugPrint('✅ FCM token saved to Firestore for user: ${authState.user.id}');
          } catch (e) {
            debugPrint('❌ Error saving FCM token to Firestore: $e');
          }
        } else {
          debugPrint('⚠️ User not authenticated yet, token will be saved on login');
          // Token will be saved when user logs in via auth_bloc
        }
      },
    );
    debugPrint('✅ FCM Notification Service initialized');
  } catch (e) {
    debugPrint('❌ Error initializing FCM: $e');
  }

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set up Bloc observer for debugging
  Bloc.observer = AppBlocObserver();

  runApp(const RibalApp());
}

/// Bloc observer for logging state changes during development
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}
