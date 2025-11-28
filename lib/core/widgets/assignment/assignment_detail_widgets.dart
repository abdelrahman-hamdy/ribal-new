import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/assignment_model.dart';
import '../../../data/models/label_model.dart';
import '../../../data/models/user_model.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/ksa_timezone.dart';
import '../../utils/time_formatter.dart';
import '../avatar/ribal_avatar.dart';

/// Status badge widget for assignment status
class AssignmentStatusBadge extends StatelessWidget {
  final AssignmentStatus status;

  const AssignmentStatusBadge({super.key, required this.status});

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
    final statusColor = _getStatusColor(status);
    final statusSurfaceColor = statusColor.withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smd,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: statusSurfaceColor,
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.pending:
        return AppColors.warning;
      case AssignmentStatus.completed:
        return AppColors.success;
      case AssignmentStatus.apologized:
      case AssignmentStatus.overdue:
        return AppColors.error; // Both are "failed" states
    }
  }
}

/// Label chip for displaying task labels
class AssignmentLabelChip extends StatelessWidget {
  final LabelModel label;

  const AssignmentLabelChip({super.key, required this.label});

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
class AssignmentCreatorRow extends StatelessWidget {
  final UserModel? creator;

  const AssignmentCreatorRow({super.key, required this.creator});

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

/// Generic metadata row for displaying icon + label + value
class AssignmentMetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const AssignmentMetaRow({
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

/// Deadline row with overdue detection
class AssignmentDeadlineRow extends StatelessWidget {
  final String deadline;
  final AssignmentModel assignment;

  const AssignmentDeadlineRow({
    super.key,
    required this.deadline,
    required this.assignment,
  });

  bool _isDeadlinePassed() {
    if (!assignment.status.isPending) return false;

    final now = KsaTimezone.now();
    final today = KsaTimezone.today();
    final scheduledDate = assignment.scheduledDate;

    final isToday = scheduledDate.year == today.year &&
        scheduledDate.month == today.month &&
        scheduledDate.day == today.day;
    if (!isToday) return false;

    try {
      final parts = deadline.split(':');
      final deadlineDateTime = today.add(Duration(
        hours: int.parse(parts[0]),
        minutes: int.parse(parts[1]),
      ));
      return now.isAfter(deadlineDateTime);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isOverdue = _isDeadlinePassed();
    final color = isOverdue ? AppColors.error : context.colors.textTertiary;
    final formattedTime = TimeFormatter.formatTimeArabic(
      deadline,
      amLabel: l10n.date_formatAM,
      pmLabel: l10n.date_formatPM,
    );

    return Row(
      children: [
        Icon(
          isOverdue ? Icons.error_outline : Icons.schedule,
          size: 18,
          color: color,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${l10n.task_deadlineAt}:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
              ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Row(
            children: [
              Text(
                formattedTime,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (isOverdue) ...[
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Text(
                    l10n.task_deadlineExpired,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.error,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Apologize message section
class AssignmentApologizeSection extends StatelessWidget {
  final String message;

  const AssignmentApologizeSection({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.assignment_apologizeReason,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
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
                size: 16,
                color: AppColors.error,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Completion info section
class AssignmentCompletionSection extends StatelessWidget {
  final AssignmentModel assignment;

  const AssignmentCompletionSection({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Format the date with localized AM/PM
    final dateFormatter = DateFormat('d MMMM yyyy', 'ar');
    final timeFormatter = DateFormat('h:mm', 'ar');
    final hour = assignment.completedAt!.hour;
    final isPM = hour >= 12;
    final period = isPM ? l10n.date_formatPM : l10n.date_formatAM;
    final formattedDateTime = '${dateFormatter.format(assignment.completedAt!)} - ${timeFormatter.format(assignment.completedAt!)} $period';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.assignment_completionInfo,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: AppSpacing.borderRadiusSm,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${l10n.assignment_completedAt} $formattedDateTime',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                    ),
              ),
            ],
          ),
        ),
        if (assignment.isCompletedByCreator) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.assignment_completedByAdmin,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.colors.textTertiary,
                  fontSize: 11,
                ),
          ),
        ],
      ],
    );
  }
}

/// Attachment view row with clickable link
class AssignmentAttachmentViewRow extends StatelessWidget {
  final String attachmentUrl;

  const AssignmentAttachmentViewRow({super.key, required this.attachmentUrl});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        const Icon(Icons.check_circle, size: 18, color: AppColors.success),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${l10n.task_attachment}:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.colors.textTertiary,
              ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              try {
                final uri = Uri.parse(attachmentUrl);
                final launched = await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
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
                      content: Text(l10n.error_fileOpenError),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text(
              l10n.task_attachmentView,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
