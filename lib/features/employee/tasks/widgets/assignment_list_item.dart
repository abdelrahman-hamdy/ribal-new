import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/assignment_model.dart';

/// A list item widget for displaying employee assignments with action buttons
class AssignmentListItem extends StatelessWidget {
  final AssignmentWithTask assignmentWithTask;
  final String? deadlineText;
  final bool isOverdue;
  final VoidCallback? onMarkCompleted;
  final VoidCallback? onApologize;
  final VoidCallback? onReactivate;
  final VoidCallback? onTap;

  const AssignmentListItem({
    super.key,
    required this.assignmentWithTask,
    this.deadlineText,
    this.isOverdue = false,
    this.onMarkCompleted,
    this.onApologize,
    this.onReactivate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final assignment = assignmentWithTask.assignment;
    final status = assignment.status;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(
            color: _getBorderColor(status),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Status badge + Deadline
            Row(
              children: [
                _StatusBadge(status: status),
                const Spacer(),
                // Deadline indicator
                if (deadlineText != null || isOverdue)
                  _DeadlineIndicator(
                    text: deadlineText,
                    isOverdue: isOverdue,
                  )
                else if (assignmentWithTask.taskAttachmentUrl != null)
                  const Icon(
                    Icons.attachment,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Task title with attachment required icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Attachment required icon (before title)
                if (assignmentWithTask.taskAttachmentRequired) ...[
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
                    assignmentWithTask.taskTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Apologize message (if apologized)
            if (status.isApologized && assignment.hasApologizeMessage) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 14,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        assignment.apologizeMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.md),

            // Action buttons
            _ActionButtons(
              status: status,
              onMarkCompleted: onMarkCompleted,
              onApologize: onApologize,
              onReactivate: onReactivate,
            ),
          ],
        ),
      ),
    );
  }

  Color _getBorderColor(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.pending:
        return AppColors.border;
      case AssignmentStatus.completed:
        return AppColors.success.withValues(alpha: 0.5);
      case AssignmentStatus.apologized:
        return AppColors.error.withValues(alpha: 0.5);
    }
  }
}

/// Deadline indicator widget (same style as admin task list)
class _DeadlineIndicator extends StatelessWidget {
  final String? text;
  final bool isOverdue;

  const _DeadlineIndicator({
    this.text,
    this.isOverdue = false,
  });

  /// Convert "HH:mm" format to Arabic friendly format like "٦ مساءاً"
  String _formatTimeArabic(String? time) {
    if (time == null) return '';
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final isPm = hour >= 12;
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final period = isPm ? 'مساءً' : 'صباحاً';
      return '$hour12 $period';
    } catch (_) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = isOverdue ? AppColors.error : AppColors.textTertiary;
    final formattedTime = _formatTimeArabic(text);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isOverdue ? Icons.error_outline : Icons.schedule,
          size: 12,
          color: color,
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          isOverdue ? 'منتهي' : 'موعد التسليم: $formattedTime',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontSize: 11,
                fontWeight: isOverdue ? FontWeight.w600 : null,
              ),
        ),
      ],
    );
  }
}

/// Status badge widget with proper colors (green/orange/red)
class _StatusBadge extends StatelessWidget {
  final AssignmentStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);
    final statusSurfaceColor = statusColor.withValues(alpha: 0.1);

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
            status.displayNameAr,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.pending:
        return AppColors.warning; // Orange
      case AssignmentStatus.completed:
        return AppColors.success; // Green
      case AssignmentStatus.apologized:
        return AppColors.error; // Red
    }
  }
}

/// Action buttons for assignment with consistent border radius
class _ActionButtons extends StatelessWidget {
  final AssignmentStatus status;
  final VoidCallback? onMarkCompleted;
  final VoidCallback? onApologize;
  final VoidCallback? onReactivate;

  const _ActionButtons({
    required this.status,
    this.onMarkCompleted,
    this.onApologize,
    this.onReactivate,
  });

  // Consistent button styling
  static final _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
  );
  static const _buttonHeight = 36.0;
  static const _buttonPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.sm,
    vertical: AppSpacing.xs,
  );

  @override
  Widget build(BuildContext context) {
    // Completed - show completion indicator
    if (status.isCompleted) {
      return Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'تم التسليم',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      );
    }

    // Apologized - show reactivate button
    if (status.isApologized) {
      return SizedBox(
        width: double.infinity,
        height: _buttonHeight,
        child: OutlinedButton.icon(
          onPressed: onReactivate,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('إعادة تفعيل'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: _buttonShape,
            padding: _buttonPadding,
          ),
        ),
      );
    }

    // Pending - show mark completed and apologize buttons
    return SizedBox(
      height: _buttonHeight,
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: onMarkCompleted,
              icon: const Icon(Icons.check, size: 16),
              label: const Text('تسليم'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                shape: _buttonShape,
                padding: _buttonPadding,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onApologize,
              icon: const Icon(Icons.close, size: 16),
              label: const Text('اعتذار'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: _buttonShape,
                padding: _buttonPadding,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
