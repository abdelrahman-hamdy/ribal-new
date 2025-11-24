import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/injection.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/avatar/ribal_avatar.dart';
import '../../../../core/widgets/feedback/empty_state.dart';
import '../../../../core/widgets/feedback/error_state.dart';
import '../../../../core/widgets/feedback/loading_state.dart';
import '../../../../data/models/assignment_model.dart';
import '../../../../data/models/label_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../bloc/task_detail_bloc.dart';

class TaskDetailPage extends StatelessWidget {
  final String taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TaskDetailBloc>()
        ..add(TaskDetailLoadRequested(taskId: taskId)),
      child: const _TaskDetailPageContent(),
    );
  }
}

/// Actions section with equal width buttons
class _ActionsSection extends StatelessWidget {
  final TaskDetailState state;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onArchive;

  const _ActionsSection({
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
        // Archive button (only for recurring tasks)
        if (showArchive) ...[
          Expanded(
            child: _ActionButton(
              icon: Icons.stop_circle_outlined,
              label: 'إيقاف',
              color: AppColors.warning,
              onPressed: onArchive,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        // Edit button
        Expanded(
          child: _ActionButton(
            icon: Icons.edit_note_rounded,
            label: 'تعديل',
            color: AppColors.primary,
            onPressed: onEdit,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Delete button
        Expanded(
          child: _ActionButton(
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

/// Styled action button with label
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
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
            Icon(
              icon,
              color: color,
              size: 20,
            ),
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

class _TaskDetailPageContent extends StatelessWidget {
  const _TaskDetailPageContent();

  void _showDeleteConfirmation(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف المهمة'),
        content: const Text('هل أنت متأكد من حذف هذه المهمة؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<TaskDetailBloc>().add(TaskDetailDeleteRequested(taskId: taskId));
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showArchiveConfirmation(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إيقاف المهمة المتكررة'),
        content: const Text(
          'سيتم أرشفة هذه المهمة ولن يتم نشرها للموظفين حتى تقوم بإعادة تفعيلها من لوحة التحكم في قسم الأرشيف.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<TaskDetailBloc>().add(TaskDetailArchiveRequested(taskId: taskId));
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.warning),
            child: const Text('إيقاف وأرشفة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المهمة'),
      ),
      body: BlocConsumer<TaskDetailBloc, TaskDetailState>(
        listenWhen: (previous, current) {
          // Only trigger listener when messages change from null to a value
          return (previous.errorMessage == null && current.errorMessage != null) ||
              (previous.successMessage == null && current.successMessage != null) ||
              (previous.isDeleted != current.isDeleted && current.isDeleted) ||
              (previous.isArchived != current.isArchived && current.isArchived);
        },
        listener: (context, state) {
          if (state.isDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage ?? 'تم حذف المهمة بنجاح'),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
            return;
          }
          if (state.isArchived) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage ?? 'تم أرشفة المهمة بنجاح'),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
            return;
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state.successMessage != null && !state.isDeleted && !state.isArchived) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.task == null) {
            return const LoadingState(message: 'جاري تحميل المهمة...');
          }

          if (state.task == null) {
            return const ErrorState(
              icon: Icons.error_outline,
              message: 'فشل في تحميل المهمة',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<TaskDetailBloc>().add(const TaskDetailRefreshRequested());
              // Wait for assignees to reload
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task info card
                  _TaskInfoCard(state: state),
                  const SizedBox(height: AppSpacing.md),

                  // Actions section
                  _ActionsSection(
                    state: state,
                    onEdit: () => context.push(
                      Routes.adminTaskEditPath(state.taskId!),
                    ),
                    onDelete: () => _showDeleteConfirmation(context, state.taskId!),
                    onArchive: () => _showArchiveConfirmation(context, state.taskId!),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Assignees section
                  _AssigneesSection(state: state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Task information card
class _TaskInfoCard extends StatelessWidget {
  final TaskDetailState state;

  const _TaskInfoCard({required this.state});

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
              children: state.labels.map((label) => _LabelChip(label: label)).toList(),
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

          // Creator info with avatar
          _CreatorRow(creator: state.creator),
          const SizedBox(height: AppSpacing.sm),
          _MetaRow(
            icon: Icons.calendar_today_outlined,
            label: 'تاريخ الإنشاء',
            value: DateFormat('d MMMM yyyy', 'ar').format(task.createdAt),
          ),
          const SizedBox(height: AppSpacing.sm),
          _MetaRow(
            icon: task.isRecurring ? Icons.repeat : Icons.event,
            label: 'النوع',
            value: task.isRecurring ? 'متكررة' : 'لمرة واحدة',
          ),

          // Attachment
          if (task.hasAttachment) ...[
            const SizedBox(height: AppSpacing.sm),
            const _MetaRow(
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
            _TaskStatsSection(state: state),
          ],
        ],
      ),
    );
  }
}

/// Task stats section showing completion status with simple indicators
class _TaskStatsSection extends StatelessWidget {
  final TaskDetailState state;

  const _TaskStatsSection({required this.state});

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
        // Stats row with colored circle indicators
        Row(
          children: [
            _StatIndicator(
              label: 'مكتمل',
              count: completed,
              color: AppColors.progressDone,
            ),
            const SizedBox(width: AppSpacing.lg),
            _StatIndicator(
              label: 'قيد الانتظار',
              count: pending,
              color: AppColors.progressPending,
            ),
            const SizedBox(width: AppSpacing.lg),
            _StatIndicator(
              label: 'معتذر',
              count: apologized,
              color: AppColors.progressOverdue,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        // Summary text
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

/// Simple stat indicator with colored circle and text
class _StatIndicator extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatIndicator({
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

class _LabelChip extends StatelessWidget {
  final LabelModel label;

  const _LabelChip({required this.label});

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

class _CreatorRow extends StatelessWidget {
  final UserModel? creator;

  const _CreatorRow({required this.creator});

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
        // Small avatar like in task list item
        CircleAvatar(
          radius: 10,
          backgroundColor: roleColor.withValues(alpha: 0.2),
          backgroundImage: creator!.avatarUrl != null
              ? NetworkImage(creator!.avatarUrl!)
              : null,
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
        // Name with role color and bold weight
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

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _MetaRow({
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

/// Assignees section with list and mark done buttons
class _AssigneesSection extends StatelessWidget {
  final TaskDetailState state;

  const _AssigneesSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'المكلفين اليوم',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Assignees list with shimmer loading
        if (state.isAssigneesLoading)
          Skeletonizer(
            enabled: true,
            enableSwitchAnimation: true,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) => const _AssigneeCardSkeleton(),
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
              return _AssigneeCard(
                assignee: assignee,
                isLoading: state.loadingAssignmentId == assignee.assignment.id,
              );
            },
          ),
      ],
    );
  }
}

/// Individual assignee card with mark done button
class _AssigneeCard extends StatelessWidget {
  final AssigneeWithUser assignee;
  final bool isLoading;

  const _AssigneeCard({
    required this.assignee,
    this.isLoading = false,
  });

  /// Get status color matching admin homepage colors
  Color _getAssignmentStatusColor(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.completed:
        return AppColors.progressDone; // Green
      case AssignmentStatus.pending:
        return AppColors.progressPending; // Orange
      case AssignmentStatus.apologized:
        return AppColors.progressOverdue; // Red (treated as overdue/issue)
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
          // Avatar - using unified RibalAvatar, clickable to navigate to profile
          if (user != null)
            RibalAvatar(
              user: user,
              size: RibalAvatarSize.md,
              onTap: () => context.push(Routes.adminUserDetailPath(user.id)),
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

          // Info - clickable to navigate to profile
          Expanded(
            child: GestureDetector(
              onTap: user != null
                  ? () => context.push(Routes.adminUserDetailPath(user.id))
                  : null,
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
                      // Show attachment indicator if assignee has uploaded one
                      if (assignment.hasAttachment) ...[
                        const SizedBox(width: AppSpacing.sm),
                        GestureDetector(
                          onTap: () async {
                            try {
                              final url = Uri.parse(assignment.attachmentUrl!);
                              final launched = await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
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
                              const Icon(
                                Icons.attach_file,
                                size: 14,
                                color: AppColors.primary,
                              ),
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
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Action button
          if (status == AssignmentStatus.pending)
            _MarkDoneButton(
              assignmentId: assignment.id,
              isLoading: isLoading,
            ),
        ],
      ),
    );
  }
}

class _MarkDoneButton extends StatelessWidget {
  final String assignmentId;
  final bool isLoading;

  const _MarkDoneButton({
    required this.assignmentId,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final currentUserId = authState is AuthAuthenticated
            ? authState.user.id
            : '';

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
              color: AppColors.success, // Solid green background
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      ),
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

/// Simple skeleton template for assignee card
class _AssigneeCardSkeleton extends StatelessWidget {
  const _AssigneeCardSkeleton();

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
          // Avatar placeholder
          Bone.square(size: 44),
          SizedBox(width: AppSpacing.md),
          // Text placeholders
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
          // Button placeholder
          Bone(width: 50, height: 32),
        ],
      ),
    );
  }
}
