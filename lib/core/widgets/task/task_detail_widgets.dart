import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/assignment_model.dart';
import '../../../data/models/label_model.dart';
import '../../../data/models/user_model.dart';
import '../../../features/admin/tasks/bloc/task_detail_bloc.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../animated/animated_count.dart';
import '../avatar/ribal_avatar.dart';
import '../feedback/empty_state.dart';
import '../notes/notes_dialog.dart';

/// Styled action button with icon and label
class TaskActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const TaskActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: AppSpacing.borderRadiusSm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Label chip for task labels
class TaskLabelChip extends StatelessWidget {
  final LabelModel label;

  const TaskLabelChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final labelColor = LabelColor.fromHex(label.color);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smd,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: labelColor.surfaceColor,
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Text(
        label.name,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: labelColor.color,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

/// Creator row showing who created the task
class TaskCreatorRow extends StatelessWidget {
  final UserModel? creator;

  const TaskCreatorRow({super.key, required this.creator});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (creator == null) {
      return Row(
        children: [
          Icon(Icons.person_outline, size: 18, color: context.colors.textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${l10n.task_createdBy}:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.colors.textTertiary,
                ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            l10n.user_unknown,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Text(
          '${l10n.task_createdBy}:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.colors.textTertiary,
              ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Using unified RibalAvatar
        RibalAvatar(
          user: creator!,
          size: RibalAvatarSize.xs,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          creator!.fullName,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

/// Generic metadata row
class TaskMetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const TaskMetaRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: context.colors.textTertiary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.colors.textTertiary,
              ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: valueColor ?? context.colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}

/// Task stats section showing completion status with animated counts
/// Always visible with 0 values during loading, animated to actual values when loaded
class TaskStatsSection extends StatelessWidget {
  final TaskDetailState state;

  const TaskStatsSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = state.isAssigneesLoading;
    final total = state.assignees.length;
    final completed = state.completedCount;
    final pending = state.pendingCount;
    final apologized = state.apologizedCount;

    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: context.colors.textSecondary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.statistics_taskStatistics,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            TaskStatIndicator(
              label: l10n.task_statusDone,
              count: completed,
              color: AppColors.progressDone,
              isLoading: isLoading,
            ),
            const SizedBox(width: AppSpacing.lg),
            TaskStatIndicator(
              label: l10n.task_statusPending,
              count: pending,
              color: AppColors.progressPending,
              isLoading: isLoading,
            ),
            const SizedBox(width: AppSpacing.lg),
            TaskStatIndicator(
              label: l10n.task_statusApologized,
              count: apologized,
              color: AppColors.progressOverdue,
              isLoading: isLoading,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        // Subtitle with animated counts
        Row(
          children: [
            AnimatedStatCount(
              isLoading: isLoading,
              count: completed,
              style: subtitleStyle,
            ),
            Text(' ${l10n.common_of} ', style: subtitleStyle),
            AnimatedStatCount(
              isLoading: isLoading,
              count: total,
              style: subtitleStyle,
            ),
            Text(' ${l10n.task_assigneesCompleted}', style: subtitleStyle),
          ],
        ),
      ],
    );
  }
}

/// Simple stat indicator with colored circle and animated count
class TaskStatIndicator extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isLoading;

  const TaskStatIndicator({
    super.key,
    required this.label,
    required this.count,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: context.colors.textSecondary,
      fontWeight: FontWeight.w600,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text('$label: ', style: textStyle),
        AnimatedStatCount(
          isLoading: isLoading,
          count: count,
          style: textStyle,
        ),
      ],
    );
  }
}

/// Task info card
class TaskInfoCard extends StatelessWidget {
  final TaskDetailState state;

  const TaskInfoCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final task = state.task!;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Labels
          if (state.labels.isNotEmpty) ...[
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: state.labels.map((label) => TaskLabelChip(label: label)).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Title
          Text(
            task.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Description
          if (task.description.isNotEmpty) ...[
            Text(
              task.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.colors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          const Divider(height: AppSpacing.lg),

          // Creator info
          TaskCreatorRow(creator: state.creator),
          const SizedBox(height: AppSpacing.sm),
          TaskMetaRow(
            icon: Icons.calendar_today_outlined,
            label: l10n.task_createdAt,
            value: DateFormat('d MMMM yyyy', 'ar').format(task.createdAt),
          ),
          const SizedBox(height: AppSpacing.sm),
          TaskMetaRow(
            icon: task.isRecurring ? Icons.repeat : Icons.event,
            label: l10n.task_type,
            value: task.isRecurring ? l10n.task_typeRecurring : l10n.task_typeOnce,
          ),

          // Attachment
          if (task.hasAttachment) ...[
            const SizedBox(height: AppSpacing.sm),
            TaskMetaRow(
              icon: Icons.attach_file,
              label: l10n.task_attachment,
              value: l10n.task_hasAttachment,
              valueColor: AppColors.primary,
            ),
          ],

          // Attachment required indicator
          if (task.attachmentRequired) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.upload_file, size: 18, color: AppColors.warning),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.task_attachmentRequired,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],

          // Task Stats Section - always show with animated counts
          const Divider(height: AppSpacing.xl),
          TaskStatsSection(state: state),
        ],
      ),
    );
  }
}

/// Actions section with edit, delete, archive buttons
class TaskActionsSection extends StatelessWidget {
  final TaskDetailState state;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onArchive;

  const TaskActionsSection({
    super.key,
    required this.state,
    required this.onEdit,
    required this.onDelete,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final task = state.task;
    if (task == null) return const SizedBox.shrink();

    final showArchive = task.isRecurring && !task.isArchived;

    return Row(
      children: [
        // Edit button
        Expanded(
          child: TaskActionButton(
            icon: Icons.edit_note_rounded,
            label: l10n.common_edit,
            color: AppColors.primary,
            onPressed: onEdit,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Archive button (only for recurring tasks)
        if (showArchive) ...[
          Expanded(
            child: TaskActionButton(
              icon: Icons.stop_circle_outlined,
              label: l10n.task_stop,
              color: AppColors.warning,
              onPressed: onArchive,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        // Delete button
        Expanded(
          child: TaskActionButton(
            icon: Icons.delete_outline_rounded,
            label: l10n.common_delete,
            color: AppColors.error,
            onPressed: onDelete,
          ),
        ),
      ],
    );
  }
}

/// Assignees section with list
class TaskAssigneesSection extends StatelessWidget {
  final TaskDetailState state;
  final void Function(String userId)? onUserTap;
  final bool showAttachmentView;
  final bool showViewNotes;

  const TaskAssigneesSection({
    super.key,
    required this.state,
    this.onUserTap,
    this.showAttachmentView = false,
    this.showViewNotes = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.task_assigneesToday,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.md),

        if (state.isAssigneesLoading)
          Skeletonizer(
            enabled: true,
            enableSwitchAnimation: true,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) => const TaskAssigneeCardSkeleton(),
            ),
          )
        else if (state.assignees.isEmpty)
          EmptyState(
            icon: Icons.people_outline,
            title: l10n.task_noAssigneesToday,
            message: l10n.task_noAssigneesTodaySubtitle,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.assignees.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final assignee = state.assignees[index];
              return TaskAssigneeCard(
                assignee: assignee,
                isLoading: state.loadingAssignmentId == assignee.assignment.id,
                onUserTap: onUserTap,
                showAttachmentView: showAttachmentView,
                showViewNotes: showViewNotes,
                taskId: state.taskId,
                taskTitle: state.task?.title,
              );
            },
          ),
      ],
    );
  }
}

/// Individual assignee card
class TaskAssigneeCard extends StatelessWidget {
  final AssigneeWithUser assignee;
  final bool isLoading;
  final void Function(String userId)? onUserTap;
  final bool showAttachmentView;
  final bool showViewNotes;
  final String? taskId;
  final String? taskTitle;

  const TaskAssigneeCard({
    super.key,
    required this.assignee,
    this.isLoading = false,
    this.onUserTap,
    this.showAttachmentView = false,
    this.showViewNotes = false,
    this.taskId,
    this.taskTitle,
  });

  Color _getAssignmentStatusColor(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.completed:
        return AppColors.progressDone;
      case AssignmentStatus.pending:
        return AppColors.progressPending;
      case AssignmentStatus.apologized:
      case AssignmentStatus.overdue:
        return AppColors.progressOverdue; // Both are "failed" states (red)
    }
  }

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
    final user = assignee.user;
    final assignment = assignee.assignment;
    final status = assignment.status;
    final statusColor = _getAssignmentStatusColor(status);

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          // Main row: Avatar, info, and primary action
          Row(
            children: [
              // Avatar
              if (user != null)
                RibalAvatar(
                  user: user,
                  size: RibalAvatarSize.md,
                  onTap: onUserTap != null ? () => onUserTap!(user.id) : null,
                )
              else
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.colors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.person, color: context.colors.textTertiary),
                  ),
                ),
              const SizedBox(width: AppSpacing.md),

              // Info
              Expanded(
                child: GestureDetector(
                  onTap: user != null && onUserTap != null ? () => onUserTap!(user.id) : null,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? l10n.user_unknown,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            _getStatusDisplayName(l10n, status),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: statusColor,
                                ),
                          ),
                          if (assignment.isCompletedByCreator) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              l10n.assignment_byAdmin,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.colors.textTertiary,
                                    fontSize: 10,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Primary action: Mark done button (prominent)
              if (status == AssignmentStatus.pending)
                TaskMarkDoneButton(
                  assignmentId: assignment.id,
                  isLoading: isLoading,
                ),
            ],
          ),

          // Secondary actions row (notes, attachment, apologize reason)
          if (_hasSecondaryActions(assignment)) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const SizedBox(width: 52), // Offset for avatar alignment
                // View notes button
                if (showViewNotes && taskId != null)
                  _SecondaryActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: assignee.notesCount > 0
                        ? '${l10n.notes_title} (${assignee.notesCount})'
                        : l10n.notes_title,
                    onTap: () => _showNotesDialog(context, user),
                  ),
                // Attachment button (orange)
                if (showAttachmentView && assignment.hasAttachment) ...[
                  if (showViewNotes && taskId != null)
                    const SizedBox(width: AppSpacing.sm),
                  _SecondaryActionButton(
                    icon: Icons.attach_file,
                    label: l10n.task_attachment,
                    color: AppColors.warning,
                    onTap: () => _openAttachment(context, assignment.attachmentUrl!),
                  ),
                ],
                // Apologize reason button (red, only for apologized users)
                if (assignment.status.isApologized && assignment.hasApologizeMessage) ...[
                  if ((showViewNotes && taskId != null) ||
                      (showAttachmentView && assignment.hasAttachment))
                    const SizedBox(width: AppSpacing.sm),
                  _SecondaryActionButton(
                    icon: Icons.info_outline,
                    label: l10n.assignment_apologizeReason,
                    color: AppColors.error,
                    onTap: () => _showApologizeReason(context, assignment.apologizeMessage!),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool _hasSecondaryActions(AssignmentModel assignment) {
    return (showViewNotes && taskId != null) ||
        (showAttachmentView && assignment.hasAttachment) ||
        assignment.status.isApologized;
  }

  void _showNotesDialog(BuildContext context, UserModel? user) {
    final l10n = AppLocalizations.of(context)!;
    // Ensure assignee name is not empty
    final assigneeName = user?.fullName.trim() ?? '';
    final displayName = assigneeName.isEmpty ? l10n.user_unknown : assigneeName;

    NotesDialog.show(
      context: context,
      assignmentId: assignee.assignment.id,
      taskId: taskId!,
      assigneeName: displayName,
      assigneeRole: user?.role ?? UserRole.employee,
      currentUserId: (context.read<AuthBloc>().state as AuthAuthenticated).user.id,
      currentUserName: (context.read<AuthBloc>().state as AuthAuthenticated).user.fullName,
      currentUserRole: (context.read<AuthBloc>().state as AuthAuthenticated).user.role,
      assigneeId: user?.id,
      taskTitle: taskTitle,
    );
  }

  Future<void> _openAttachment(BuildContext context, String url) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.error_fileOpen),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.error_fileOpenGeneric),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showApologizeReason(BuildContext context, String reason) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm),
            Text(l10n.assignment_apologizeReason),
          ],
        ),
        content: Text(reason),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.common_close),
          ),
        ],
      ),
    );
  }
}

/// Secondary action button (smaller, subtle)
class _SecondaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? context.colors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color != null ? color!.withValues(alpha: 0.1) : context.colors.surfaceVariant,
          borderRadius: AppSpacing.borderRadiusSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: buttonColor),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: buttonColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mark done button
class TaskMarkDoneButton extends StatelessWidget {
  final String assignmentId;
  final bool isLoading;

  const TaskMarkDoneButton({
    super.key,
    required this.assignmentId,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final currentUserId = authState is AuthAuthenticated ? authState.user.id : '';

        return GestureDetector(
          onTap: isLoading
              ? null
              : () {
                  context.read<TaskDetailBloc>().add(
                        TaskDetailMarkAsDoneRequested(
                          assignmentId: assignmentId,
                          markedDoneBy: currentUserId,
                        ),
                      );
                },
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.smd,
              vertical: AppSpacing.sm,
            ),
            decoration: const BoxDecoration(
              color: AppColors.success,
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, size: 16, color: Colors.white),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l10n.common_done,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

/// Skeleton for assignee card
class TaskAssigneeCardSkeleton extends StatelessWidget {
  const TaskAssigneeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: context.colors.border),
      ),
      child: const Row(
        children: [
          Bone.square(size: 44),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(words: 2),
                SizedBox(height: AppSpacing.xs),
                Bone.text(words: 1, fontSize: 12),
              ],
            ),
          ),
          Bone(width: 50, height: 32),
        ],
      ),
    );
  }
}
