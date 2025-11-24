part of 'notifications_bloc.dart';

/// Notifications events
abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

/// Load notifications for user
class NotificationsLoadRequested extends NotificationsEvent {
  final String userId;

  const NotificationsLoadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Notifications panel opened - mark all as seen
class NotificationsPanelOpened extends NotificationsEvent {
  final String userId;

  const NotificationsPanelOpened(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Mark single notification as read
class NotificationMarkAsReadRequested extends NotificationsEvent {
  final String notificationId;

  const NotificationMarkAsReadRequested(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Mark all notifications as read
class NotificationsMarkAllAsReadRequested extends NotificationsEvent {
  final String userId;

  const NotificationsMarkAllAsReadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Delete notification
class NotificationDeleteRequested extends NotificationsEvent {
  final String notificationId;

  const NotificationDeleteRequested(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Delete all notifications
class NotificationsDeleteAllRequested extends NotificationsEvent {
  final String userId;

  const NotificationsDeleteAllRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Internal event: notifications stream updated
class _NotificationsUpdated extends NotificationsEvent {
  final List<NotificationModel> notifications;
  final String? error;

  const _NotificationsUpdated(this.notifications, {this.error});

  @override
  List<Object?> get props => [notifications, error];
}
