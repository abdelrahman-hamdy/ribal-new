import 'package:flutter/material.dart';

import '../../../data/models/assignment_model.dart';
import '../../../data/models/label_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/task_progress.dart';
import '../../../data/models/user_model.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../avatar/ribal_avatar.dart';

export '../../../data/models/user_model.dart' show UserRole;

// Extension import for context.colors
// ignore: unused_import

/// A reusable task list item widget that displays task information
/// Can be used in admin home page, manager home page, and assignment pages
class TaskListItem extends StatelessWidget {
  final TaskModel task;
  final List<LabelModel> labels;

  /// Task progress (for admin/manager view showing all assignments)
  final TaskProgress? taskProgress;

  /// Single assignment status (for employee view showing their own assignment)
  final AssignmentStatus? assignmentStatus;

  final UserModel? creator;

  /// Deadline text to display (e.g., "ينتهي خلال ساعة")
  final String? deadlineText;

  /// Whether the task deadline has passed
  final bool isPassed;

  final VoidCallback? onTap;

  const TaskListItem({
    super.key,
    required this.task,
    required this.labels,
    this.taskProgress,
    this.assignmentStatus,
    this.creator,
    this.deadlineText,
    this.isPassed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Cache theme lookup to avoid repeated tree traversals
    final theme = Theme.of(context);
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Labels (chip style with background)
            if (labels.isNotEmpty) ...[
              _LabelChips(labels: labels, theme: theme),
              const SizedBox(height: AppSpacing.sm),
            ],

            // Title row with deadline time floated to the left
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recurring icon + Title
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recurring icon (inline before title)
                      if (task.isRecurring) ...[
                        const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Icon(
                            Icons.repeat_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      // Attachment required icon
                      if (task.attachmentRequired) ...[
                        const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Icon(
                            Icons.upload_file,
                            size: 16,
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      // Title
                      Expanded(
                        child: Text(
                          task.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Deadline time (floated left) - red when passed
                if (deadlineText != null || isPassed) ...[
                  const SizedBox(width: AppSpacing.sm),
                  _DeadlineText(
                    deadlineText: deadlineText,
                    isPassed: isPassed,
                    theme: theme,
                    colors: colors,
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.smd),

            // Bottom row: Creator + Progress
            Row(
              children: [
                // Creator info with avatar
                if (creator != null) ...[
                  _CreatorInfo(creator: creator!, theme: theme),
                ],

                const Spacer(),

                // Progress indicator (for admin/manager) or Status badge (for employee)
                if (taskProgress != null)
                  _SegmentedProgressBadge(progress: taskProgress!, theme: theme, colors: colors)
                else if (assignmentStatus != null)
                  _StatusBadge(status: assignmentStatus!, theme: theme),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Deadline text widget with cached theme
class _DeadlineText extends StatelessWidget {
  final String? deadlineText;
  final bool isPassed;
  final ThemeData theme;
  final AppColorsExtension colors;

  const _DeadlineText({
    required this.deadlineText,
    required this.isPassed,
    required this.theme,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPassed ? Icons.error_outline : Icons.hourglass_bottom,
          size: 12,
          color: isPassed ? AppColors.error : colors.textTertiary,
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          isPassed ? l10n.task_deadlineExpired : deadlineText!,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isPassed ? AppColors.error : colors.textTertiary,
            fontSize: 11,
            fontWeight: isPassed ? FontWeight.w600 : null,
          ),
        ),
      ],
    );
  }
}

/// Label chips display - chip style with colored background (matches task details page)
class _LabelChips extends StatelessWidget {
  final List<LabelModel> labels;
  final ThemeData theme;

  const _LabelChips({required this.labels, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: labels.map((label) => _LabelChip(label: label, theme: theme)).toList(),
    );
  }
}

/// Label chip with colored background (matches task details page style)
class _LabelChip extends StatelessWidget {
  final LabelModel label;
  final ThemeData theme;

  const _LabelChip({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    final labelColor = LabelColor.fromHex(label.color);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: labelColor.surfaceColor,
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Text(
        label.name,
        style: theme.textTheme.labelSmall?.copyWith(
          color: labelColor.color,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// Creator info with small avatar and role-colored text
class _CreatorInfo extends StatelessWidget {
  final UserModel creator;
  final ThemeData theme;

  const _CreatorInfo({required this.creator, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Small avatar using unified RibalAvatar
        RibalAvatar(
          user: creator,
          size: RibalAvatarSize.xs,
        ),
        const SizedBox(width: AppSpacing.xs),
        // Name with normal text color (role color is now in avatar border)
        Text(
          creator.fullName,
          style: theme.textTheme.bodySmall?.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Status badge for displaying assignment status (for employee view)
class _StatusBadge extends StatelessWidget {
  final AssignmentStatus status;
  final ThemeData theme;

  const _StatusBadge({required this.status, required this.theme});

  String _getStatusDisplayName(AppLocalizations l10n, AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.pending:
        return l10n.task_statusPending;
      case AssignmentStatus.completed:
        return l10n.task_completed;
      case AssignmentStatus.apologized:
        return l10n.task_statusApologized;
      case AssignmentStatus.overdue:
        return l10n.task_statusOverdue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statusColor = AppColors.getStatusColor(status.name);
    final statusSurfaceColor = AppColors.getStatusSurfaceColor(status.name);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: statusSurfaceColor,
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            _getStatusDisplayName(l10n, status),
            style: theme.textTheme.labelSmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Segmented progress badge showing done/pending/overdue
class _SegmentedProgressBadge extends StatelessWidget {
  final TaskProgress progress;
  final ThemeData theme;
  final AppColorsExtension colors;

  const _SegmentedProgressBadge({
    required this.progress,
    required this.theme,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (progress.totalAssignments == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: colors.taskNoAssignmentsSurface,
          borderRadius: AppSpacing.borderRadiusFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.people_outline,
              size: 12,
              color: AppColors.taskNoAssignments,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              l10n.task_noAssignments,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.taskNoAssignments,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }

    // Calculate segments
    final completedFlex = progress.completedCount;
    // pendingCount already excludes overdue from TaskProgress calculation
    final pendingFlex = progress.pendingCount;
    // Red segment: overdue + apologized (both are "failed" states)
    final failedFlex = progress.overdueCount + progress.apologizedCount;
    final totalFlex = completedFlex + pendingFlex + failedFlex;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Segmented progress bar
          SizedBox(
            width: 40,
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Row(
                children: [
                  if (completedFlex > 0)
                    Expanded(
                      flex: completedFlex,
                      child: Container(color: AppColors.progressDone),
                    ),
                  if (pendingFlex > 0)
                    Expanded(
                      flex: pendingFlex,
                      child: Container(color: AppColors.progressPending),
                    ),
                  if (failedFlex > 0)
                    Expanded(
                      flex: failedFlex,
                      child: Container(color: AppColors.progressOverdue),
                    ),
                  // If all zero, show empty
                  if (totalFlex == 0)
                    Expanded(
                      child: Container(color: colors.surfaceDisabled),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          // Progress text
          Text(
            '${progress.completedCount}/${progress.totalAssignments}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
