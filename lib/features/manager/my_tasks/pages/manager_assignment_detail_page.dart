import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/feedback/error_state.dart';
import '../../../../core/widgets/feedback/loading_state.dart';
import '../../../../data/models/assignment_model.dart';
import '../../../../data/models/label_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/services/storage_service.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../employee/tasks/bloc/assignment_detail_bloc.dart';

class ManagerAssignmentDetailPage extends StatelessWidget {
  final String assignmentId;

  const ManagerAssignmentDetailPage({super.key, required this.assignmentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AssignmentDetailBloc>()
        ..add(AssignmentDetailLoadRequested(assignmentId: assignmentId)),
      child: const _AssignmentDetailContent(),
    );
  }
}

class _AssignmentDetailContent extends StatelessWidget {
  const _AssignmentDetailContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المهمة'),
      ),
      body: BlocConsumer<AssignmentDetailBloc, AssignmentDetailState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage ||
            previous.successMessage != current.successMessage,
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
              ),
            );
          }
          if (state.errorMessage != null && !state.isLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.assignment == null) {
            return const LoadingState(message: 'جاري تحميل المهمة...');
          }

          if (state.assignment == null || state.task == null) {
            return const ErrorState(
              icon: Icons.error_outline,
              message: 'فشل في تحميل المهمة',
            );
          }

          return SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task info card
                _TaskInfoCard(state: state),
                const SizedBox(height: AppSpacing.lg),

                // Action buttons
                _ActionButtons(
                  state: state,
                  assignmentId: state.assignment!.id,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Task information card
class _TaskInfoCard extends StatelessWidget {
  final AssignmentDetailState state;

  const _TaskInfoCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final task = state.task!;
    final assignment = state.assignment!;

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
          // Status badge
          _StatusBadge(status: assignment.status),
          const SizedBox(height: AppSpacing.md),

          // Labels
          if (state.labels.isNotEmpty) ...[
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children:
                  state.labels.map((label) => _LabelChip(label: label)).toList(),
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
          _CreatorRow(creator: state.creator),
          const SizedBox(height: AppSpacing.sm),

          // Assignment date
          _MetaRow(
            icon: Icons.calendar_today_outlined,
            label: 'تاريخ التكليف',
            value: DateFormat('d MMMM yyyy', 'ar').format(assignment.scheduledDate),
          ),

          // Deadline
          if (state.taskDeadline != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _DeadlineRow(
              deadline: state.taskDeadline!,
              assignment: assignment,
            ),
          ],

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

          // Attachment Required indicator
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
          if (assignment.status.isCompleted && assignment.hasAttachment) ...[
            const SizedBox(height: AppSpacing.sm),
            _AttachmentViewRow(attachmentUrl: assignment.attachmentUrl!),
          ],

          // Apologize message (if apologized)
          if (assignment.status.isApologized &&
              assignment.hasApologizeMessage) ...[
            const Divider(height: AppSpacing.lg),
            _ApologizeMessageSection(message: assignment.apologizeMessage!),
          ],

          // Completion info (if completed)
          if (assignment.status.isCompleted && assignment.completedAt != null) ...[
            const Divider(height: AppSpacing.lg),
            _CompletionInfoSection(assignment: assignment),
          ],
        ],
      ),
    );
  }
}

/// Status badge widget
class _StatusBadge extends StatelessWidget {
  final AssignmentStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
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
            status.displayNameAr,
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
        return AppColors.error;
    }
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

class _DeadlineRow extends StatelessWidget {
  final String deadline;
  final AssignmentModel assignment;

  const _DeadlineRow({
    required this.deadline,
    required this.assignment,
  });

  bool _isDeadlinePassed() {
    // Only show overdue for pending assignments on today
    if (!assignment.status.isPending) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduledDate = assignment.scheduledDate;

    // Check if assignment is for today
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

  /// Convert "HH:mm" format to Arabic friendly format like "٦ مساءاً"
  String _formatTimeArabic(String time) {
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
    final isOverdue = _isDeadlinePassed();
    final color = isOverdue ? AppColors.error : AppColors.textTertiary;
    final formattedTime = _formatTimeArabic(deadline);

    return Row(
      children: [
        Icon(
          isOverdue ? Icons.error_outline : Icons.schedule,
          size: 18,
          color: color,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'موعد التسليم:',
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
                    'منتهي',
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

class _ApologizeMessageSection extends StatelessWidget {
  final String message;

  const _ApologizeMessageSection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'سبب الاعتذار',
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

class _CompletionInfoSection extends StatelessWidget {
  final AssignmentModel assignment;

  const _CompletionInfoSection({required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات الإكمال',
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
                'تم التسليم في ${DateFormat('d MMMM yyyy - h:mm a', 'ar').format(assignment.completedAt!)}',
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
            '(تم التسليم بواسطة الإدارة)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
          ),
        ],
      ],
    );
  }
}

/// Attachment view row with clickable link
class _AttachmentViewRow extends StatelessWidget {
  final String attachmentUrl;

  const _AttachmentViewRow({required this.attachmentUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle, size: 18, color: AppColors.success),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'المرفق:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
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
            child: Text(
              'عرض المرفق',
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

/// Action buttons for assignment (StatefulWidget to handle upload)
class _ActionButtons extends StatefulWidget {
  final AssignmentDetailState state;
  final String assignmentId;

  const _ActionButtons({
    required this.state,
    required this.assignmentId,
  });

  @override
  State<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<_ActionButtons> {
  final _storageService = getIt<StorageService>();

  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadedAttachmentUrl;
  String? _errorMessage;

  static final _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
  );
  static const _buttonHeight = 48.0;

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.path);
        _fileName = result.name;
        _errorMessage = null;
        _uploadedAttachmentUrl = null;
      });
      await _uploadFile();
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    final taskId = widget.state.task?.id;
    if (taskId == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _errorMessage = null;
    });

    try {
      final attachmentUrl = await _storageService.uploadTaskAttachment(
        taskId: taskId,
        file: _selectedFile!,
        onProgress: (progress) {
          setState(() => _uploadProgress = progress);
        },
      );

      setState(() {
        _uploadedAttachmentUrl = attachmentUrl;
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
        _errorMessage = 'فشل في رفع الملف';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignment = widget.state.assignment!;
    final task = widget.state.task!;
    final status = assignment.status;

    // Completed - no actions needed
    if (status.isCompleted) {
      return const SizedBox.shrink();
    }

    // Apologized - show reactivate button
    if (status.isApologized) {
      return SizedBox(
        width: double.infinity,
        height: _buttonHeight,
        child: OutlinedButton.icon(
          onPressed: widget.state.isActionLoading
              ? null
              : () => context.read<AssignmentDetailBloc>().add(
                    AssignmentDetailReactivateRequested(
                        assignmentId: widget.assignmentId),
                  ),
          icon: widget.state.isActionLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh, size: 20),
          label: const Text('إعادة تفعيل'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: _buttonShape,
          ),
        ),
      );
    }

    // Pending - show mark completed and apologize buttons
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userId =
            authState is AuthAuthenticated ? authState.user.id : '';

        // Check if attachment is required
        final attachmentRequired = task.attachmentRequired;

        return Column(
          children: [
            // Attachment upload section (if required)
            if (attachmentRequired) ...[
              _buildAttachmentUploadSection(context),
              const SizedBox(height: AppSpacing.md),
            ],

            SizedBox(
              width: double.infinity,
              height: _buttonHeight,
              child: FilledButton.icon(
                onPressed: (widget.state.isActionLoading ||
                        _isUploading ||
                        (attachmentRequired && _uploadedAttachmentUrl == null))
                    ? null
                    : () => _submitCompletion(context, userId),
                icon: widget.state.isActionLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check, size: 20),
                label: Text(attachmentRequired && _uploadedAttachmentUrl == null
                    ? 'يجب رفع المرفق أولاً'
                    : 'تسليم المهمة'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  shape: _buttonShape,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: _buttonHeight,
              child: OutlinedButton.icon(
                onPressed: widget.state.isActionLoading
                    ? null
                    : () => _showApologizeDialog(context, widget.assignmentId),
                icon: const Icon(Icons.close, size: 20),
                label: const Text('الاعتذار عن المهمة'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: _buttonShape,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAttachmentUploadSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.upload_file, size: 20, color: AppColors.warning),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'مرفق مطلوب',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'يجب رفع مرفق قبل تسليم المهمة',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Upload button or progress
          if (_isUploading)
            Column(
              children: [
                LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: AppColors.border,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'جاري الرفع... ${(_uploadProgress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            )
          else if (_uploadedAttachmentUrl != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      size: 16, color: AppColors.success),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      _fileName ?? 'تم رفع المرفق',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickFile,
                    child: Text(
                      'تغيير',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file, size: 18),
                    label: const Text('اختيار ملف'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: const BorderSide(color: AppColors.warning),
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                        ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  void _submitCompletion(BuildContext context, String userId) {
    context.read<AssignmentDetailBloc>().add(
          AssignmentDetailMarkCompletedRequested(
            assignmentId: widget.assignmentId,
            markedDoneBy: userId,
            attachmentUrl: _uploadedAttachmentUrl,
          ),
        );
  }

  void _showApologizeDialog(BuildContext context, String assignmentId) {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('الاعتذار عن المهمة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('يرجى إدخال سبب الاعتذار (اختياري):'),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'سبب الاعتذار...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AssignmentDetailBloc>().add(
                    AssignmentDetailApologizeRequested(
                      assignmentId: assignmentId,
                      message: messageController.text.isNotEmpty
                          ? messageController.text
                          : null,
                    ),
                  );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('اعتذار'),
          ),
        ],
      ),
    );
  }
}
