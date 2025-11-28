import 'package:injectable/injectable.dart';

import '../../core/constants/firebase_constants.dart';
import '../models/notification_model.dart';
import '../services/firestore_service.dart';

/// Notification repository for CRUD operations
@lazySingleton
class NotificationRepository {
  final FirestoreService _firestoreService;

  NotificationRepository(this._firestoreService);

  /// Create notification
  Future<NotificationModel> createNotification(
    NotificationModel notification,
  ) async {
    final docRef = await _firestoreService.createDocument(
      _firestoreService.notificationsCollection,
      notification.toFirestore(),
    );

    return notification.copyWith(id: docRef.id);
  }

  /// Create notification for specific type
  Future<NotificationModel> createTypedNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    String? deepLink,
  }) async {
    final notification = NotificationModel(
      id: '',
      userId: userId,
      type: type,
      title: title,
      body: body,
      iconName: type.iconName,
      iconColor: type.iconColor,
      deepLink: deepLink,
      createdAt: DateTime.now(),
    );

    return await createNotification(notification);
  }

  /// Get notifications for user
  Future<List<NotificationModel>> getNotificationsForUser(
    String userId, {
    int limit = 50,
  }) async {
    final snapshot = await _firestoreService.notificationsCollection
        .where(FirebaseConstants.notificationUserId, isEqualTo: userId)
        .orderBy(FirebaseConstants.notificationCreatedAt, descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => NotificationModel.fromFirestore(doc))
        .toList();
  }

  /// Stream notifications for user
  Stream<List<NotificationModel>> streamNotificationsForUser(
    String userId, {
    int limit = 50,
  }) {
    return _firestoreService.notificationsCollection
        .where(FirebaseConstants.notificationUserId, isEqualTo: userId)
        .orderBy(FirebaseConstants.notificationCreatedAt, descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  /// Get unseen notifications count (for badge)
  /// This counts notifications that haven't been seen yet
  Future<int> getUnseenCount(String userId) async {
    final snapshot = await _firestoreService.notificationsCollection
        .where(FirebaseConstants.notificationUserId, isEqualTo: userId)
        .where(FirebaseConstants.notificationIsSeen, isEqualTo: false)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  /// Stream unseen notifications count (for real-time badge)
  Stream<int> streamUnseenCount(String userId) {
    return _firestoreService.notificationsCollection
        .where(FirebaseConstants.notificationUserId, isEqualTo: userId)
        .where(FirebaseConstants.notificationIsSeen, isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Mark notification as read (when user clicks on it)
  Future<void> markAsRead(String notificationId) async {
    await _firestoreService.updateDocument(
      _firestoreService.notificationDoc(notificationId),
      {
        FirebaseConstants.notificationIsRead: true,
        FirebaseConstants.notificationIsSeen: true,
      },
    );
  }

  /// Mark all notifications as seen (when user opens notifications panel)
  /// This resets the badge count but keeps individual items highlighted
  /// Processes in batches of 50 for performance and free tier limits
  Future<void> markAllAsSeen(String userId) async {
    // Process in batches to avoid fetching all documents at once
    while (true) {
      final snapshot = await _firestoreService.notificationsCollection
          .where(FirebaseConstants.notificationUserId, isEqualTo: userId)
          .where(FirebaseConstants.notificationIsSeen, isEqualTo: false)
          .limit(50) // Process 50 at a time for free tier
          .get();

      if (snapshot.docs.isEmpty) break;

      final batch = _firestoreService.batch;
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {FirebaseConstants.notificationIsSeen: true});
      }
      await batch.commit();

      // If we got less than 50, we're done
      if (snapshot.docs.length < 50) break;
    }
  }

  /// Mark all notifications as read for user
  /// Processes in batches of 50 for performance and free tier limits
  Future<void> markAllAsRead(String userId) async {
    // Process in batches to avoid fetching all documents at once
    while (true) {
      final snapshot = await _firestoreService.notificationsCollection
          .where(FirebaseConstants.notificationUserId, isEqualTo: userId)
          .where(FirebaseConstants.notificationIsRead, isEqualTo: false)
          .limit(50) // Process 50 at a time for free tier
          .get();

      if (snapshot.docs.isEmpty) break;

      final batch = _firestoreService.batch;
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          FirebaseConstants.notificationIsRead: true,
          FirebaseConstants.notificationIsSeen: true,
        });
      }
      await batch.commit();

      // If we got less than 50, we're done
      if (snapshot.docs.length < 50) break;
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _firestoreService.deleteDocument(
      _firestoreService.notificationDoc(notificationId),
    );
  }

  /// Delete all notifications for user
  /// Processes in batches of 50 for performance and free tier limits
  Future<void> deleteAllNotifications(String userId) async {
    // Process in batches to avoid fetching all documents at once
    while (true) {
      final snapshot = await _firestoreService.notificationsCollection
          .where(FirebaseConstants.notificationUserId, isEqualTo: userId)
          .limit(50) // Process 50 at a time for free tier
          .get();

      if (snapshot.docs.isEmpty) break;

      final batch = _firestoreService.batch;
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // If we got less than 50, we're done
      if (snapshot.docs.length < 50) break;
    }
  }
}
