import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../app/di/injection.dart';
import '../../../app/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/feedback/empty_state.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/models/user_model.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/notifications_bloc.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationsBloc _notificationsBloc;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _notificationsBloc = getIt<NotificationsBloc>();

    // Get user ID and load notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        _userId = authState.user.id;
        _notificationsBloc.add(NotificationsLoadRequested(_userId!));
        // Mark all as seen when panel opens (resets badge count)
        _notificationsBloc.add(NotificationsPanelOpened(_userId!));
      }
    });
  }

  @override
  void dispose() {
    _notificationsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _notificationsBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.notification_title),
          actions: [
            BlocBuilder<NotificationsBloc, NotificationsState>(
              builder: (context, state) {
                if (state.hasUnreadNotifications) {
                  return TextButton(
                    onPressed: () {
                      if (_userId != null) {
                        _notificationsBloc
                            .add(NotificationsMarkAllAsReadRequested(_userId!));
                      }
                    },
                    child: Text(l10n.notification_markAllRead),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<NotificationsBloc, NotificationsState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            if (state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading && state.notifications.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state.notifications.isEmpty) {
              return EmptyState(
                icon: Icons.notifications_outlined,
                title: l10n.notification_noNotifications,
                message: l10n.notification_noNotificationsSubtitle,
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                if (_userId != null) {
                  _notificationsBloc.add(NotificationsLoadRequested(_userId!));
                }
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                itemCount: state.notifications.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return _NotificationTile(
                    notification: notification,
                    onTap: () => _onNotificationTap(notification),
                    onDismiss: () => _onNotificationDismiss(notification),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _onNotificationTap(NotificationModel notification) {
    // Mark as read when clicked (removes highlight)
    _notificationsBloc.add(NotificationMarkAsReadRequested(notification.id));

    // Navigate to deep link if available
    if (notification.hasDeepLink) {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) return;

      final userRole = authState.user.role;
      final deepLink = notification.deepLink!;

      // Convert generic deepLinks to role-specific routes
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

      // Navigate to the resolved route
      if (targetRoute.isNotEmpty) {
        // Pop notifications page first to go back to where user was
        context.pop();
        // Push to target route (maintains proper navigation stack)
        context.push(targetRoute);
      }
    }
  }

  void _onNotificationDismiss(NotificationModel notification) {
    _notificationsBloc.add(NotificationDeleteRequested(notification.id));
  }
}

/// Individual notification tile widget
class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    // Notification is highlighted if not yet read (clicked)
    final isUnread = !notification.isRead;
    final iconColor = _parseColor(notification.iconColor);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppSpacing.lg),
        color: AppColors.error,
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: AppSpacing.listItemPadding,
          // Unread notifications have highlighted background
          color: isUnread ? context.colors.primarySurface : context.colors.surface,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Icon(
                  _getIconData(notification.type),
                  color: iconColor,
                  size: AppSpacing.iconMd,
                ),
              ),
              const SizedBox(width: AppSpacing.smd),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: isUnread
                                ? AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: context.colors.textPrimary,
                                  )
                                : AppTypography.titleMedium.copyWith(
                                    color: context.colors.textPrimary,
                                  ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Blue dot indicator for unread
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      notification.body,
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.colors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      timeago.format(notification.createdAt, locale: 'ar'),
                      style: AppTypography.bodySmall.copyWith(
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }

  IconData _getIconData(NotificationType type) {
    switch (type) {
      case NotificationType.taskAssigned:
        return Icons.assignment_add;
      case NotificationType.taskCompleted:
        return Icons.check_circle_outline;
      case NotificationType.taskApologized:
        return Icons.warning_amber_outlined;
      case NotificationType.taskReactivated:
        return Icons.refresh;
      case NotificationType.taskMarkedDone:
        return Icons.done_all;
      case NotificationType.taskOverdue:
        return Icons.error_outline;
      case NotificationType.deadlineWarning:
        return Icons.schedule;
      case NotificationType.recurringScheduled:
        return Icons.repeat;
      case NotificationType.invitationAccepted:
        return Icons.person_add_alt;
      case NotificationType.roleChanged:
        return Icons.swap_horiz;
      case NotificationType.noteReceived:
        return Icons.chat_bubble_outline;
    }
  }
}
