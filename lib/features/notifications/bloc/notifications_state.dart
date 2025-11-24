part of 'notifications_bloc.dart';

/// Notifications state
class NotificationsState extends Equatable {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  /// Initial state
  factory NotificationsState.initial() => const NotificationsState();

  /// Get unread notifications (not fully read)
  List<NotificationModel> get unreadNotifications =>
      notifications.where((n) => !n.isRead).toList();

  /// Get read notifications
  List<NotificationModel> get readNotifications =>
      notifications.where((n) => n.isRead).toList();

  /// Check if there are unread notifications
  bool get hasUnreadNotifications => unreadNotifications.isNotEmpty;

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess ? null : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
        notifications,
        isLoading,
        errorMessage,
        successMessage,
      ];
}
