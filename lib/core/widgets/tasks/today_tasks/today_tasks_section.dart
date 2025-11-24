import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../app/di/injection.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../feedback/empty_state.dart';
import '../task_list_item.dart';
import 'bloc/today_tasks_bloc.dart';

export 'bloc/today_tasks_bloc.dart';

/// A reusable section that displays today's tasks
/// Can be used in admin home page, manager home page
///
/// If [useExternalBloc] is true, it assumes a TodayTasksBloc is provided
/// higher in the widget tree and won't create its own.
class TodayTasksSection extends StatelessWidget {
  final String Function(String taskId) getTaskDetailRoute;
  final void Function(String route) onNavigate;
  final bool useExternalBloc;

  const TodayTasksSection({
    super.key,
    required this.getTaskDetailRoute,
    required this.onNavigate,
    this.useExternalBloc = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useExternalBloc) {
      return _TodayTasksSectionContent(
        getTaskDetailRoute: getTaskDetailRoute,
        onNavigate: onNavigate,
      );
    }

    return BlocProvider(
      create: (context) => getIt<TodayTasksBloc>()..add(const TodayTasksLoadRequested()),
      child: _TodayTasksSectionContent(
        getTaskDetailRoute: getTaskDetailRoute,
        onNavigate: onNavigate,
      ),
    );
  }
}

class _TodayTasksSectionContent extends StatelessWidget {
  final String Function(String taskId) getTaskDetailRoute;
  final void Function(String route) onNavigate;

  const _TodayTasksSectionContent({
    required this.getTaskDetailRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodayTasksBloc, TodayTasksState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with task-level stats
            _SectionHeader(
              totalTasksCount: state.totalTasksCount,
              completedTasksCount: state.completedTasksCount,
              inProgressTasksCount: state.inProgressTasksCount,
              notStartedTasksCount: state.notStartedTasksCount,
              pendingAssignmentsCount: state.totalPendingCount,
              completedAssignmentsCount: state.totalCompletedCount,
              overdueAssignmentsCount: state.totalOverdueCount,
            ),
            const SizedBox(height: AppSpacing.md),

            // Content
            if (state.isLoading && state.tasks.isEmpty)
              const _LoadingState()
            else if (state.tasks.isEmpty)
              const _EmptyState()
            else
              _TasksList(
                tasks: state.tasks,
                getTaskDetailRoute: getTaskDetailRoute,
                onNavigate: onNavigate,
              ),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final int totalTasksCount;
  final int completedTasksCount;
  final int inProgressTasksCount;
  final int notStartedTasksCount;
  final int pendingAssignmentsCount;
  final int completedAssignmentsCount;
  final int overdueAssignmentsCount;

  const _SectionHeader({
    required this.totalTasksCount,
    required this.completedTasksCount,
    required this.inProgressTasksCount,
    required this.notStartedTasksCount,
    required this.pendingAssignmentsCount,
    required this.completedAssignmentsCount,
    required this.overdueAssignmentsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مهام اليوم',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (totalTasksCount > 0) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '$completedTasksCount من $totalTasksCount مهمة مكتملة',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Assignment status indicators (pending/done/overdue)
        if (totalTasksCount > 0) ...[
          _StatusIndicator(
            count: pendingAssignmentsCount,
            label: 'قيد الانتظار',
            color: AppColors.progressPending,
          ),
          const SizedBox(width: AppSpacing.md),
          _StatusIndicator(
            count: completedAssignmentsCount,
            label: 'مكتمل',
            color: AppColors.progressDone,
          ),
          const SizedBox(width: AppSpacing.md),
          _StatusIndicator(
            count: overdueAssignmentsCount,
            label: 'متأخر',
            color: AppColors.progressOverdue,
          ),
        ],
      ],
    );
  }
}

/// Simple status indicator with colored circle and label
class _StatusIndicator extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _StatusIndicator({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
          '$count $label',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) => const _SkeletonTaskItem(),
      ),
    );
  }
}

/// Skeleton placeholder for a task item
class _SkeletonTaskItem extends StatelessWidget {
  const _SkeletonTaskItem();

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
          // Skeleton labels
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.shimmerBase,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xxs),
              Container(
                width: 50,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.shimmerBase,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xxs),
              Container(
                width: 40,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Skeleton title row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.shimmerBase,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Container(
                width: 60,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.smd),

          // Skeleton bottom row
          Row(
            children: [
              // Skeleton avatar
              const CircleAvatar(
                radius: 10,
                backgroundColor: AppColors.shimmerBase,
              ),
              const SizedBox(width: AppSpacing.xs),
              // Skeleton name
              Container(
                width: 80,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              // Skeleton progress
              Container(
                width: 70,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: const EmptyState(
        icon: Icons.check_circle_outline,
        title: 'لا توجد مهام اليوم',
        message: 'لم يتم جدولة أي مهام لهذا اليوم',
      ),
    );
  }
}

class _TasksList extends StatelessWidget {
  final List<TaskWithDetails> tasks;
  final String Function(String taskId) getTaskDetailRoute;
  final void Function(String route) onNavigate;

  const _TasksList({
    required this.tasks,
    required this.getTaskDetailRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final taskWithDetails = tasks[index];
        return TaskListItem(
          task: taskWithDetails.task,
          labels: taskWithDetails.labels,
          taskProgress: taskWithDetails.progress,
          creator: taskWithDetails.creator,
          deadlineText: '٨ مساءً',
          onTap: () => onNavigate(getTaskDetailRoute(taskWithDetails.task.id)),
        );
      },
    );
  }
}
