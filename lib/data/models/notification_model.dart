import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

/// Notification types enum
enum NotificationType {
  @JsonValue('taskAssigned')
  taskAssigned,
  @JsonValue('taskCompleted')
  taskCompleted,
  @JsonValue('taskApologized')
  taskApologized,
  @JsonValue('taskReactivated')
  taskReactivated,
  @JsonValue('taskMarkedDone')
  taskMarkedDone,
  @JsonValue('recurringScheduled')
  recurringScheduled,
  @JsonValue('invitationAccepted')
  invitationAccepted,
  @JsonValue('roleChanged')
  roleChanged,
}

/// Extension methods for NotificationType
extension NotificationTypeX on NotificationType {
  String get name {
    switch (this) {
      case NotificationType.taskAssigned:
        return 'taskAssigned';
      case NotificationType.taskCompleted:
        return 'taskCompleted';
      case NotificationType.taskApologized:
        return 'taskApologized';
      case NotificationType.taskReactivated:
        return 'taskReactivated';
      case NotificationType.taskMarkedDone:
        return 'taskMarkedDone';
      case NotificationType.recurringScheduled:
        return 'recurringScheduled';
      case NotificationType.invitationAccepted:
        return 'invitationAccepted';
      case NotificationType.roleChanged:
        return 'roleChanged';
    }
  }

  String get iconName {
    switch (this) {
      case NotificationType.taskAssigned:
        return 'task_add';
      case NotificationType.taskCompleted:
        return 'check_circle';
      case NotificationType.taskApologized:
        return 'warning';
      case NotificationType.taskReactivated:
        return 'refresh';
      case NotificationType.taskMarkedDone:
        return 'done_all';
      case NotificationType.recurringScheduled:
        return 'repeat';
      case NotificationType.invitationAccepted:
        return 'person_add';
      case NotificationType.roleChanged:
        return 'swap_horiz';
    }
  }

  String get iconColor {
    switch (this) {
      case NotificationType.taskAssigned:
        return '#2563EB'; // Blue
      case NotificationType.taskCompleted:
        return '#10B981'; // Green
      case NotificationType.taskApologized:
        return '#F59E0B'; // Orange
      case NotificationType.taskReactivated:
        return '#8B5CF6'; // Purple
      case NotificationType.taskMarkedDone:
        return '#10B981'; // Green
      case NotificationType.recurringScheduled:
        return '#14B8A6'; // Teal
      case NotificationType.invitationAccepted:
        return '#6366F1'; // Indigo
      case NotificationType.roleChanged:
        return '#F59E0B'; // Amber
    }
  }
}

/// Notification model
///
/// Two-level read system:
/// - isSeen: true when user opens notifications panel (resets badge count)
/// - isRead: true when user clicks on specific notification (removes highlight)
@freezed
class NotificationModel with _$NotificationModel {
  const NotificationModel._();

  const factory NotificationModel({
    required String id,
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    required String iconName,
    required String iconColor,
    String? deepLink,
    @Default(false) bool isSeen,
    @Default(false) bool isRead,
    required DateTime createdAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  /// Create from Firestore document
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel.fromJson({
      'id': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  /// Has deep link
  bool get hasDeepLink => deepLink != null && deepLink!.isNotEmpty;

  /// Check if notification is unread (not seen OR not read)
  bool get isUnread => !isSeen || !isRead;

  /// Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'iconName': iconName,
      'iconColor': iconColor,
      'deepLink': deepLink,
      'isSeen': isSeen,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
