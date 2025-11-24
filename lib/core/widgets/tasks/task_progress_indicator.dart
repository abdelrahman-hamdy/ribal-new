import 'package:flutter/material.dart';

import '../../../data/models/task_progress.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Displays task progress with a visual breakdown of assignment statuses
///
/// Shows:
/// - Progress bar with colored segments (completed/pending/apologized)
/// - Completion percentage
/// - Status counts breakdown
class TaskProgressIndicator extends StatelessWidget {
  final TaskProgress progress;

  /// Show the detailed breakdown below the progress bar
  final bool showBreakdown;

  /// Compact mode for smaller spaces
  final bool compact;

  const TaskProgressIndicator({
    super.key,
    required this.progress,
    this.showBreakdown = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (progress.totalAssignments == 0) {
      return _NoAssignmentsIndicator(compact: compact);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar with percentage
        Row(
          children: [
            Expanded(
              child: _SegmentedProgressBar(progress: progress, compact: compact),
            ),
            const SizedBox(width: AppSpacing.sm),
            _PercentageBadge(progress: progress, compact: compact),
          ],
        ),

        // Status breakdown
        if (showBreakdown && !compact) ...[
          const SizedBox(height: AppSpacing.xs),
          _StatusBreakdown(progress: progress),
        ],
      ],
    );
  }
}

/// Segmented progress bar showing completed/pending/apologized proportions
class _SegmentedProgressBar extends StatelessWidget {
  final TaskProgress progress;
  final bool compact;

  const _SegmentedProgressBar({
    required this.progress,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final total = progress.totalAssignments;
    if (total == 0) return const SizedBox.shrink();

    final completedFlex = progress.completedCount;
    final pendingFlex = progress.pendingCount;
    final apologizedFlex = progress.apologizedCount;

    return Container(
      height: compact ? 4 : 6,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compact ? 2 : 3),
        color: AppColors.surfaceVariant,
      ),
      child: Row(
        children: [
          if (completedFlex > 0)
            Expanded(
              flex: completedFlex,
              child: Container(color: AppColors.completed),
            ),
          if (pendingFlex > 0)
            Expanded(
              flex: pendingFlex,
              child: Container(color: AppColors.pending),
            ),
          if (apologizedFlex > 0)
            Expanded(
              flex: apologizedFlex,
              child: Container(color: AppColors.apologized),
            ),
        ],
      ),
    );
  }
}

/// Percentage badge showing completion rate
class _PercentageBadge extends StatelessWidget {
  final TaskProgress progress;
  final bool compact;

  const _PercentageBadge({
    required this.progress,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = progress.completionPercentage;
    final color = _getColorForPercentage(percentage);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.xs : AppSpacing.sm,
        vertical: compact ? 2 : AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Text(
        '$percentage%',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: compact ? 10 : 11,
        ),
      ),
    );
  }

  Color _getColorForPercentage(int percentage) {
    if (percentage == 100) return AppColors.taskCompleted;
    if (percentage >= 75) return AppColors.success;
    if (percentage >= 50) return AppColors.taskInProgress;
    if (percentage >= 25) return AppColors.warning;
    return AppColors.taskNotStarted;
  }
}

/// Status breakdown showing counts for each status
class _StatusBreakdown extends StatelessWidget {
  final TaskProgress progress;

  const _StatusBreakdown({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.smd,
      runSpacing: AppSpacing.xxs,
      children: [
        if (progress.completedCount > 0)
          _StatusChip(
            count: progress.completedCount,
            label: 'مكتمل',
            color: AppColors.completed,
          ),
        if (progress.pendingCount > 0)
          _StatusChip(
            count: progress.pendingCount,
            label: 'قيد الانتظار',
            color: AppColors.pending,
          ),
        if (progress.apologizedCount > 0)
          _StatusChip(
            count: progress.apologizedCount,
            label: 'معتذر',
            color: AppColors.apologized,
          ),
      ],
    );
  }
}

/// Small status chip with count and label
class _StatusChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _StatusChip({
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
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          '$count $label',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

/// Indicator shown when task has no assignments
class _NoAssignmentsIndicator extends StatelessWidget {
  final bool compact;

  const _NoAssignmentsIndicator({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.xs : AppSpacing.sm,
        vertical: compact ? 2 : AppSpacing.xxs,
      ),
      decoration: const BoxDecoration(
        color: AppColors.taskNoAssignmentsSurface,
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: compact ? 10 : 12,
            color: AppColors.taskNoAssignments,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            'لا توجد تكليفات',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.taskNoAssignments,
              fontSize: compact ? 9 : 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact task status badge (alternative to full progress indicator)
/// Shows just the status with an icon
class TaskStatusBadge extends StatelessWidget {
  final TaskStatus status;
  final bool showIcon;

  const TaskStatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getTaskStatusColor(status.name);
    final surfaceColor = AppColors.getTaskStatusSurfaceColor(status.name);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              _getIconForStatus(status),
              size: 12,
              color: color,
            ),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            status.shortLabelAr,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForStatus(TaskStatus status) {
    switch (status) {
      case TaskStatus.noAssignments:
        return Icons.people_outline;
      case TaskStatus.notStarted:
        return Icons.hourglass_empty;
      case TaskStatus.inProgress:
        return Icons.trending_up;
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.partiallyDone:
        return Icons.pie_chart;
    }
  }
}

/// Compact progress text showing "X/Y completed"
class TaskProgressText extends StatelessWidget {
  final TaskProgress progress;
  final bool showPercentage;

  const TaskProgressText({
    super.key,
    required this.progress,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    if (progress.totalAssignments == 0) {
      return Text(
        'لا توجد تكليفات',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textTertiary,
        ),
      );
    }

    final text = showPercentage
        ? '${progress.completionPercentage}% (${progress.completedCount}/${progress.totalAssignments})'
        : '${progress.completedCount}/${progress.totalAssignments} مكتمل';

    final color = progress.isFullyCompleted
        ? AppColors.taskCompleted
        : AppColors.textSecondary;

    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: progress.isFullyCompleted ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
