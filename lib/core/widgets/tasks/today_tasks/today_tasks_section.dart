import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/time_formatter.dart';
import '../../animated/animated_count.dart';
import '../../feedback/empty_state.dart';
import '../../skeletons/task_list_item_skeleton.dart';
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
        // Determine content to show based on loading state
        Widget content;
        if (!state.hasLoadedOnce) {
          // Initial loading - always show skeleton
          content = const _LoadingState();
        } else if (state.tasks.isEmpty) {
          // Loaded but empty - show empty state
          content = const _EmptyState();
        } else {
          // Has data - show tasks list
          content = _TasksList(
            tasks: state.tasks,
            getTaskDetailRoute: getTaskDetailRoute,
            onNavigate: onNavigate,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with task-level stats (always visible)
            _SectionHeader(
              isLoading: !state.hasLoadedOnce,
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
            content,
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final bool isLoading;
  final int totalTasksCount;
  final int completedTasksCount;
  final int inProgressTasksCount;
  final int notStartedTasksCount;
  final int pendingAssignmentsCount;
  final int completedAssignmentsCount;
  final int overdueAssignmentsCount;

  const _SectionHeader({
    required this.isLoading,
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
    final l10n = AppLocalizations.of(context)!;
    // Show stats always - with placeholder during loading, actual values after
    final showStats = isLoading || totalTasksCount > 0;
    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: context.colors.textSecondary,
    );

    return Row(
      children: [
        // Title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.task_today,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              // Subtitle with animated counts
              if (!isLoading && totalTasksCount == 0)
                Text(l10n.task_noTasks, style: subtitleStyle)
              else
                Row(
                  children: [
                    AnimatedStatCount(
                      isLoading: isLoading,
                      count: completedTasksCount,
                      style: subtitleStyle,
                    ),
                    Text(' ${l10n.common_of} ', style: subtitleStyle),
                    AnimatedStatCount(
                      isLoading: isLoading,
                      count: totalTasksCount,
                      style: subtitleStyle,
                    ),
                    Text(' ${l10n.task_tasksCompleted}', style: subtitleStyle),
                  ],
                ),
            ],
          ),
        ),

        // Assignment status indicators (pending/done/overdue) - always visible
        if (showStats) ...[
          _StatusIndicator(
            isLoading: isLoading,
            count: pendingAssignmentsCount,
            label: l10n.task_statusPending,
            color: AppColors.progressPending,
          ),
          const SizedBox(width: AppSpacing.md),
          _StatusIndicator(
            isLoading: isLoading,
            count: completedAssignmentsCount,
            label: l10n.task_statusDone,
            color: AppColors.progressDone,
          ),
          const SizedBox(width: AppSpacing.md),
          _StatusIndicator(
            isLoading: isLoading,
            count: overdueAssignmentsCount,
            label: l10n.task_statusOverdue,
            color: AppColors.progressOverdue,
          ),
        ],
      ],
    );
  }
}

/// Simple status indicator with colored circle, animated count, and label
class _StatusIndicator extends StatelessWidget {
  final bool isLoading;
  final int count;
  final String label;
  final Color color;

  const _StatusIndicator({
    required this.isLoading,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: context.colors.textSecondary,
      fontWeight: FontWeight.w500,
    );

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
        AnimatedStatCount(
          isLoading: isLoading,
          count: count,
          style: textStyle,
          suffix: ' $label',
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const TaskListSkeletonList(itemCount: 3);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: context.colors.border),
      ),
      child: EmptyState(
        icon: Icons.check_circle_outline,
        title: l10n.task_noTasksToday,
        message: l10n.task_noTasksTodaySubtitle,
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
        // Format deadline from DateTime to Arabic time string
        final deadlineText = taskWithDetails.deadline != null
            ? TimeFormatter.formatTimeArabic(
                '${taskWithDetails.deadline!.hour.toString().padLeft(2, '0')}:'
                '${taskWithDetails.deadline!.minute.toString().padLeft(2, '0')}')
            : '';
        return TaskListItem(
          task: taskWithDetails.task,
          labels: taskWithDetails.labels,
          taskProgress: taskWithDetails.progress,
          creator: taskWithDetails.creator,
          deadlineText: deadlineText,
          onTap: () => onNavigate(getTaskDetailRoute(taskWithDetails.task.id)),
        );
      },
    );
  }
}
