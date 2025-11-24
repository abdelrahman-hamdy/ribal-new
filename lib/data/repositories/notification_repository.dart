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
  Future<void> markAllAsSeen(String userId) async {
    final snapshot = await _firestoreService.notificationsCollection
        .where(FirebaseConstants.notificationUserId, isEqualTo: userId)
        .where(FirebaseConstants.notificationIsSeen, isEqualTo: false)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestoreService.batch;
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {FirebaseConstants.notificationIsSeen: true});
    }
    await batch.commit();
  }

  /// Mark all notifications as read for user
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _firestoreService.notificationsCollection
        .where(FirebaseConstants.notificationUserId, isEqualTo: userId)
        .where(FirebaseConstants.notificationIsRead, isEqualTo: false)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestoreService.batch;
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        FirebaseConstants.notificationIsRead: true,
        FirebaseConstants.notificationIsSeen: true,
      });
    }
    await batch.commit();
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _firestoreService.deleteDocument(
      _firestoreService.notificationDoc(notificationId),
    );
  }

  /// Delete all notifications for user
  Future<void> deleteAllNotifications(String userId) async {
    final snapshot = await _firestoreService.notificationsCollection
        .where(FirebaseConstants.notificationUserId, isEqualTo: userId)
        .get();

    final batch = _firestoreService.batch;
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
