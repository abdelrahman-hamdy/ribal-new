import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../app/di/injection.dart';
import '../../../data/models/assignment_model.dart';
import '../../../features/employee/tasks/bloc/assignments_bloc.dart';
import '../../../features/employee/tasks/widgets/assignment_list_item.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../feedback/empty_state.dart';
import '../feedback/error_state.dart';
import '../notifications/notification_badge.dart';

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
                if (state.isLoading && state.assignments.isEmpty) {
                  return const _AssignmentsLoadingState();
                }

                if (state.errorMessage != null && state.assignments.isEmpty) {
                  return ErrorState(
                    message: state.errorMessage!,
                    onRetry: () => context
                        .read<AssignmentsBloc>()
                        .add(AssignmentsLoadRequested(userId: userId)),
                  );
                }

                if (state.filteredAssignmentsWithTasks.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<AssignmentsBloc>()
                          .add(AssignmentsLoadRequested(userId: userId));
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 100),
                        EmptyState(
                          icon: Icons.task_outlined,
                          title: 'لا توجد مهام',
                          message: 'لم يتم تعيين أي مهام لك اليوم',
                        ),
                      ],
                    ),
                  );
                }

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
    return Container(
      padding: AppSpacing.pagePadding,
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSpacing.radiusLg),
          bottomRight: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحباً، $userName',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'مهامك لهذا اليوم',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Filter chips row
          BlocBuilder<AssignmentsBloc, AssignmentsState>(
            builder: (context, state) {
              final isLoading = state.isLoading && state.assignments.isEmpty;

              return Skeletonizer(
                enabled: isLoading,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'الكل',
                        count: isLoading ? 0 : state.assignments.length,
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
                        label: 'قيد الانتظار',
                        count: isLoading ? 0 : state.pendingCount,
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
                        label: 'مكتملة',
                        count: isLoading ? 0 : state.completedCount,
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
                        label: 'معتذر',
                        count: isLoading ? 0 : state.apologizedCount,
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Filter chip with color support
class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.color,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.smd,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: AppSpacing.borderRadiusFull,
          border: Border.all(
            color: isSelected ? color : AppColors.border,
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
            Text(
              '$label ($count)',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
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
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد التسليم'),
        content: const Text('هل أنت متأكد من تسليم هذه المهمة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
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
            child: const Text('تسليم'),
          ),
        ],
      ),
    );
  }

  void _showApologizeDialog(BuildContext context, String assignmentId) {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('الاعتذار عن المهمة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('يرجى إدخال سبب الاعتذار (اختياري):'),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'سبب الاعتذار...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
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
            child: const Text('اعتذار'),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loading state for assignments list
class _AssignmentsLoadingState extends StatelessWidget {
  const _AssignmentsLoadingState();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: AppSpacing.pagePadding,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) => const _SkeletonAssignmentItem(),
      ),
    );
  }
}

/// Skeleton placeholder for an assignment item
class _SkeletonAssignmentItem extends StatelessWidget {
  const _SkeletonAssignmentItem();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Status badge + Deadline
          Row(
            children: [
              // Skeleton status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.shimmerBase,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      width: 50,
                      height: 11,
                      decoration: BoxDecoration(
                        color: AppColors.shimmerBase,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Skeleton deadline
              Container(
                width: 60,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Skeleton title
          Container(
            width: double.infinity,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Skeleton action buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.shimmerBase,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.shimmerBase,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
