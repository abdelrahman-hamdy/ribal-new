import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/assignment_model.dart';
import '../../../data/models/label_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/user_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'assignment_detail_widgets.dart';

/// Shared task info card for assignment detail pages
class AssignmentInfoCard extends StatelessWidget {
  final AssignmentModel assignment;
  final TaskModel task;
  final List<LabelModel> labels;
  final UserModel? creator;
  final String? deadline;
  final bool showAttachmentViewRow;

  const AssignmentInfoCard({
    super.key,
    required this.assignment,
    required this.task,
    required this.labels,
    this.creator,
    this.deadline,
    this.showAttachmentViewRow = false,
  });

  @override
  Widget build(BuildContext context) {
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
          // Status badge
          AssignmentStatusBadge(status: assignment.status),
          const SizedBox(height: AppSpacing.md),

          // Labels
          if (labels.isNotEmpty) ...[
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: labels.map((label) => AssignmentLabelChip(label: label)).toList(),
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
          AssignmentCreatorRow(creator: creator),
          const SizedBox(height: AppSpacing.sm),

          // Assignment date
          AssignmentMetaRow(
            icon: Icons.calendar_today_outlined,
            label: 'تاريخ التكليف',
            value: DateFormat('d MMMM yyyy', 'ar').format(assignment.scheduledDate),
          ),

          // Deadline
          if (deadline != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AssignmentDeadlineRow(
              deadline: deadline!,
              assignment: assignment,
            ),
          ],

          // Task Attachment
          if (task.hasAttachment) ...[
            const SizedBox(height: AppSpacing.sm),
            const AssignmentMetaRow(
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

          // User's uploaded attachment (if completed with attachment)
          if (showAttachmentViewRow &&
              assignment.status.isCompleted &&
              assignment.hasAttachment) ...[
            const SizedBox(height: AppSpacing.sm),
            AssignmentAttachmentViewRow(attachmentUrl: assignment.attachmentUrl!),
          ],

          // Apologize message (if apologized)
          if (assignment.status.isApologized && assignment.hasApologizeMessage) ...[
            const Divider(height: AppSpacing.lg),
            AssignmentApologizeSection(message: assignment.apologizeMessage!),
          ],

          // Completion info (if completed)
          if (assignment.status.isCompleted && assignment.completedAt != null) ...[
            const Divider(height: AppSpacing.lg),
            AssignmentCompletionSection(assignment: assignment),
          ],
        ],
      ),
    );
  }
}
