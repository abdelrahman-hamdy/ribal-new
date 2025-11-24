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
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../avatar/ribal_avatar.dart';
import '../feedback/empty_state.dart';

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
          vertical: AppSpacing.smd,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: AppSpacing.borderRadiusSm,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
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

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.roleAdmin;
      case UserRole.manager:
        return AppColors.roleManager;
      case UserRole.employee:
        return AppColors.roleEmployee;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (creator == null) {
      return Row(
        children: [
          const Icon(Icons.person_outline, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'أنشئت بواسطة:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'غير معروف',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      );
    }

    final roleColor = _getRoleColor(creator!.role);

    return Row(
      children: [
        Text(
          'أنشئت بواسطة:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
        ),
        const SizedBox(width: AppSpacing.sm),
        CircleAvatar(
          radius: 10,
          backgroundColor: roleColor.withValues(alpha: 0.2),
          backgroundImage:
              creator!.avatarUrl != null ? NetworkImage(creator!.avatarUrl!) : null,
          child: creator!.avatarUrl == null
              ? Text(
                  creator!.initials,
                  style: TextStyle(
                    color: roleColor,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          creator!.fullName,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: roleColor,
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
        Icon(icon, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}

/// Task stats section showing completion status
class TaskStatsSection extends StatelessWidget {
  final TaskDetailState state;

  const TaskStatsSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final total = state.assignees.length;
    final completed = state.completedCount;
    final pending = state.pendingCount;
    final apologized = state.apologizedCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحصائيات المهمة',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            TaskStatIndicator(
              label: 'مكتمل',
              count: completed,
              color: AppColors.progressDone,
            ),
            const SizedBox(width: AppSpacing.lg),
            TaskStatIndicator(
              label: 'قيد الانتظار',
              count: pending,
              color: AppColors.progressPending,
            ),
            const SizedBox(width: AppSpacing.lg),
            TaskStatIndicator(
              label: 'معتذر',
              count: apologized,
              color: AppColors.progressOverdue,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '$completed من $total مكلف أنهوا المهمة',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

/// Simple stat indicator with colored circle
class TaskStatIndicator extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const TaskStatIndicator({
    super.key,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
        Text(
          '$label: $count',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
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
    final task = state.task!;

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
                    color: AppColors.textSecondary,
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
            label: 'تاريخ الإنشاء',
            value: DateFormat('d MMMM yyyy', 'ar').format(task.createdAt),
          ),
          const SizedBox(height: AppSpacing.sm),
          TaskMetaRow(
            icon: task.isRecurring ? Icons.repeat : Icons.event,
            label: 'النوع',
            value: task.isRecurring ? 'متكررة' : 'لمرة واحدة',
          ),

          // Attachment
          if (task.hasAttachment) ...[
            const SizedBox(height: AppSpacing.sm),
            const TaskMetaRow(
              icon: Icons.attach_file,
              label: 'مرفق',
              value: 'يوجد مرفق',
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
                  'مرفق مطلوب',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],

          // Task Stats Section
          if (state.assignees.isNotEmpty) ...[
            const Divider(height: AppSpacing.xl),
            TaskStatsSection(state: state),
          ],
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
    final task = state.task;
    if (task == null) return const SizedBox.shrink();

    final showArchive = task.isRecurring && !task.isArchived;

    return Row(
      children: [
        // Edit button
        Expanded(
          child: TaskActionButton(
            icon: Icons.edit_note_rounded,
            label: 'تعديل',
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
              label: 'إيقاف',
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
            label: 'حذف',
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

  const TaskAssigneesSection({
    super.key,
    required this.state,
    this.onUserTap,
    this.showAttachmentView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المكلفين اليوم',
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
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) => const TaskAssigneeCardSkeleton(),
            ),
          )
        else if (state.assignees.isEmpty)
          const EmptyState(
            icon: Icons.people_outline,
            title: 'لا يوجد مكلفين',
            message: 'لم يتم تكليف أي شخص بهذه المهمة اليوم',
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.assignees.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final assignee = state.assignees[index];
              return TaskAssigneeCard(
                assignee: assignee,
                isLoading: state.loadingAssignmentId == assignee.assignment.id,
                onUserTap: onUserTap,
                showAttachmentView: showAttachmentView,
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

  const TaskAssigneeCard({
    super.key,
    required this.assignee,
    this.isLoading = false,
    this.onUserTap,
    this.showAttachmentView = false,
  });

  Color _getAssignmentStatusColor(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.completed:
        return AppColors.progressDone;
      case AssignmentStatus.pending:
        return AppColors.progressPending;
      case AssignmentStatus.apologized:
        return AppColors.progressOverdue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = assignee.user;
    final assignment = assignee.assignment;
    final status = assignment.status;
    final statusColor = _getAssignmentStatusColor(status);

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
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
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.person, color: AppColors.textTertiary),
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
                    user?.fullName ?? 'مستخدم غير معروف',
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
                        status.displayNameAr,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: statusColor,
                            ),
                      ),
                      if (assignment.isCompletedByCreator) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '(بواسطة الإدارة)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: 10,
                              ),
                        ),
                      ],
                      // Show attachment indicator
                      if (showAttachmentView && assignment.hasAttachment) ...[
                        const SizedBox(width: AppSpacing.sm),
                        _AttachmentViewLink(attachmentUrl: assignment.attachmentUrl!),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Action button for pending assignments
          if (status == AssignmentStatus.pending)
            TaskMarkDoneButton(
              assignmentId: assignment.id,
              isLoading: isLoading,
            ),
        ],
      ),
    );
  }
}

/// Attachment view link widget
class _AttachmentViewLink extends StatelessWidget {
  final String attachmentUrl;

  const _AttachmentViewLink({required this.attachmentUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          final url = Uri.parse(attachmentUrl);
          final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
          if (!launched && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('لم يتمكن من فتح الملف'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('خطأ في فتح الملف'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.attach_file, size: 14, color: AppColors.primary),
          const SizedBox(width: 2),
          Text(
            'عرض المرفق',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
          ),
        ],
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
                        'تم',
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
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
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
