import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/injection.dart';
import '../../../data/models/assignment_model.dart';
import '../../../features/employee/tasks/bloc/assignments_bloc.dart';
import '../../../features/employee/tasks/widgets/assignment_list_item.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../animated/animated_count.dart';
import '../feedback/empty_state.dart';
import '../feedback/error_state.dart';
import '../notifications/notification_badge.dart';
import '../skeletons/assignment_list_item_skeleton.dart';

export '../../../features/employee/tasks/bloc/assignments_bloc.dart';

/// A reusable section that displays user's assigned tasks
/// Can be used in employee tasks page, manager my tasks page
class MyAssignmentsPage extends StatelessWidget {
  final String userId;
  final String userName;
  final String Function(String assignmentId) getAssignmentDetailRoute;
  final void Function(String route) onNavigate;
  final String appBarTitle;
  final VoidCallback? onNotificationTap;

  const MyAssignmentsPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.getAssignmentDetailRoute,
    required this.onNavigate,
    this.appBarTitle = 'مهام اليوم',
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AssignmentsBloc>()
        ..add(AssignmentsLoadRequested(userId: userId)),
      child: _MyAssignmentsContent(
        userName: userName,
        userId: userId,
        getAssignmentDetailRoute: getAssignmentDetailRoute,
        onNavigate: onNavigate,
        appBarTitle: appBarTitle,
        onNotificationTap: onNotificationTap,
      ),
    );
  }
}

class _MyAssignmentsContent extends StatelessWidget {
  final String userName;
  final String userId;
  final String Function(String assignmentId) getAssignmentDetailRoute;
  final void Function(String route) onNavigate;
  final String appBarTitle;
  final VoidCallback? onNotificationTap;

  const _MyAssignmentsContent({
    required this.userName,
    required this.userId,
    required this.getAssignmentDetailRoute,
    required this.onNavigate,
    required this.appBarTitle,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          if (onNotificationTap != null)
            NotificationBadge(
              userId: userId,
              onTap: onNotificationTap!,
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message with stats
          _WelcomeHeader(userName: userName, userId: userId),

          // Assignment list with pull-to-refresh
          Expanded(
            child: BlocBuilder<AssignmentsBloc, AssignmentsState>(
              builder: (context, state) {
                // Initial loading - always show skeleton first
                if (!state.hasLoadedOnce) {
                  return const AssignmentListSkeletonList(itemCount: 5);
                }

                // Error state (only after load attempt)
                if (state.errorMessage != null && state.assignments.isEmpty) {
                  return ErrorState(
                    message: state.errorMessage!,
                    onRetry: () => context
                        .read<AssignmentsBloc>()
                        .add(AssignmentsLoadRequested(userId: userId)),
                  );
                }

                // Empty state (only after successful load with no data)
                if (state.filteredAssignmentsWithTasks.isEmpty) {
                  final l10n = AppLocalizations.of(context)!;
                  return RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<AssignmentsBloc>()
                          .add(AssignmentsLoadRequested(userId: userId));
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 100),
                        EmptyState(
                          icon: Icons.task_outlined,
                          title: l10n.task_noTasks,
                          message: l10n.task_noTasksAssignedToday,
                        ),
                      ],
                    ),
                  );
                }

                // Has data - show assignments list
                return _AssignmentsList(
                  assignments: state.filteredAssignmentsWithTasks,
                  userId: userId,
                  deadlineText: state.formattedDeadline,
                  isDeadlinePassed: state.isDeadlinePassed,
                  getAssignmentDetailRoute: getAssignmentDetailRoute,
                  onNavigate: onNavigate,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Welcome header with stats
class _WelcomeHeader extends StatelessWidget {
  final String userName;
  final String userId;

  const _WelcomeHeader({
    required this.userName,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Get KSA time (UTC+3)
    final now = DateTime.now().toUtc().add(const Duration(hours: 3));
    final dateText = _formatDate(now, context);
    final timeText = _formatTime(now, context);

    return Container(
      padding: AppSpacing.pagePadding,
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppSpacing.radiusLg),
          bottomRight: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Text(
            l10n.user_welcomeName(userName),
            style: AppTypography.headlineMedium.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Subheading with date/time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  l10n.task_todayTasks,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Text(
                  '$dateText • $timeText',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Filter chips row - always visible with animated counts
          BlocBuilder<AssignmentsBloc, AssignmentsState>(
            builder: (context, state) {
              final isLoading = !state.hasLoadedOnce;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: l10n.common_all,
                      count: state.assignments.length,
                      isLoading: isLoading,
                      color: AppColors.primary,
                      isSelected: state.filterStatus == null,
                      onTap: isLoading
                          ? null
                          : () => context
                              .read<AssignmentsBloc>()
                              .add(const AssignmentsFilterChanged(status: null)),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _FilterChip(
                      label: l10n.task_statusPending,
                      count: state.pendingCount,
                      isLoading: isLoading,
                      color: AppColors.warning,
                      isSelected: state.filterStatus == AssignmentStatus.pending,
                      onTap: isLoading
                          ? null
                          : () => context.read<AssignmentsBloc>().add(
                              const AssignmentsFilterChanged(
                                  status: AssignmentStatus.pending)),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _FilterChip(
                      label: l10n.task_completed,
                      count: state.completedCount,
                      isLoading: isLoading,
                      color: AppColors.success,
                      isSelected:
                          state.filterStatus == AssignmentStatus.completed,
                      onTap: isLoading
                          ? null
                          : () => context.read<AssignmentsBloc>().add(
                              const AssignmentsFilterChanged(
                                  status: AssignmentStatus.completed)),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _FilterChip(
                      label: l10n.task_statusApologized,
                      count: state.apologizedCount,
                      isLoading: isLoading,
                      color: AppColors.error,
                      isSelected:
                          state.filterStatus == AssignmentStatus.apologized,
                      onTap: isLoading
                          ? null
                          : () => context.read<AssignmentsBloc>().add(
                              const AssignmentsFilterChanged(
                                  status: AssignmentStatus.apologized)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName == 'ar';

    // Day names
    const daysAr = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    const daysEn = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final dayName = isArabic ? daysAr[dateTime.weekday % 7] : daysEn[dateTime.weekday % 7];

    return '$dayName • ${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName == 'ar';

    int hour = dateTime.hour;
    final isPM = hour >= 12;

    // Convert to 12-hour format
    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour = hour - 12;
    }

    final period = isPM
        ? (isArabic ? 'م' : 'PM')
        : (isArabic ? 'ص' : 'AM');

    return '$hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }
}

/// Filter chip with animated count and color support
class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isLoading;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isLoading,
    required this.color,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: isSelected ? color : context.colors.textSecondary,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.smd,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : context.colors.surface,
          borderRadius: AppSpacing.borderRadiusFull,
          border: Border.all(
            color: isSelected ? color : context.colors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color indicator dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: textStyle),
            Text(' (', style: textStyle),
            AnimatedStatCount(
              isLoading: isLoading,
              count: count,
              style: textStyle,
            ),
            Text(')', style: textStyle),
          ],
        ),
      ),
    );
  }
}

/// Assignments list with pull-to-refresh
class _AssignmentsList extends StatelessWidget {
  final List<AssignmentWithTask> assignments;
  final String userId;
  final String? deadlineText;
  final bool isDeadlinePassed;
  final String Function(String assignmentId) getAssignmentDetailRoute;
  final void Function(String route) onNavigate;

  const _AssignmentsList({
    required this.assignments,
    required this.userId,
    required this.getAssignmentDetailRoute,
    required this.onNavigate,
    this.deadlineText,
    this.isDeadlinePassed = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssignmentsBloc, AssignmentsState>(
      listenWhen: (previous, current) =>
          previous.successMessage != current.successMessage ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
            ),
          );
        }
        if (state.errorMessage != null && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: RefreshIndicator(
        onRefresh: () async {
          context
              .read<AssignmentsBloc>()
              .add(AssignmentsLoadRequested(userId: userId));
        },
        child: ListView.separated(
          padding: AppSpacing.pagePadding,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: assignments.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final assignmentWithTask = assignments[index];
            final assignment = assignmentWithTask.assignment;
            // Only show deadline for pending assignments
            final showDeadline = assignment.status.isPending && deadlineText != null;

            return AssignmentListItem(
              assignmentWithTask: assignmentWithTask,
              deadlineText: showDeadline ? deadlineText : null,
              isOverdue: showDeadline && isDeadlinePassed,
              onTap: () => onNavigate(getAssignmentDetailRoute(assignment.id)),
              onMarkCompleted: assignment.status.isPending
                  ? () {
                      // If task requires attachment, navigate to detail page
                      if (assignmentWithTask.taskAttachmentRequired) {
                        onNavigate(getAssignmentDetailRoute(assignment.id));
                      } else {
                        _showMarkCompletedDialog(context, assignment.id, userId);
                      }
                    }
                  : null,
              onApologize: assignment.status.isPending
                  ? () => _showApologizeDialog(context, assignment.id)
                  : null,
              onReactivate: assignment.status.isApologized
                  ? () => context.read<AssignmentsBloc>().add(
                      AssignmentReactivateRequested(assignmentId: assignment.id))
                  : null,
            );
          },
        ),
      ),
    );
  }

  void _showMarkCompletedDialog(
    BuildContext context,
    String assignmentId,
    String userId,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.assignment_submitConfirmTitle),
        content: Text(l10n.assignment_completeConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AssignmentsBloc>().add(
                    AssignmentMarkCompletedRequested(
                      assignmentId: assignmentId,
                      markedDoneBy: userId,
                    ),
                  );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: Text(l10n.assignment_submit),
          ),
        ],
      ),
    );
  }

  void _showApologizeDialog(BuildContext context, String assignmentId) {
    final l10n = AppLocalizations.of(context)!;
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.assignment_apologize),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.assignment_apologizeMessage),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.assignment_apologizeReasonHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AssignmentsBloc>().add(
                    AssignmentApologizeRequested(
                      assignmentId: assignmentId,
                      message: messageController.text.isNotEmpty
                          ? messageController.text
                          : null,
                    ),
                  );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(l10n.assignment_apologizeConfirm),
          ),
        ],
      ),
    );
  }
}
