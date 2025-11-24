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
import '../bloc/assignment_detail_bloc.dart';

class EmployeeAssignmentDetailPage extends StatelessWidget {
  final String assignmentId;

  const EmployeeAssignmentDetailPage({super.key, required this.assignmentId});

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

/// Action buttons for assignment - StatefulWidget to handle attachment upload
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
  static final _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
  );
  static const _buttonHeight = 48.0;

  // Attachment upload state
  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadedAttachmentUrl;
  String? _errorMessage;

  final _imagePicker = ImagePicker();
  final _storageService = getIt<StorageService>();

  Future<void> _pickFile() async {
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (ctx) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('اختر من المعرض'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('التقط صورة'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedFile = File(pickedFile.path);
          _fileName = pickedFile.name;
          _errorMessage = null;
          _uploadedAttachmentUrl = null;
        });
        // Auto-upload after selection
        await _uploadFile();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل في اختيار الملف';
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _errorMessage = null;
    });

    try {
      final attachmentUrl = await _storageService.uploadTaskAttachment(
        taskId: widget.state.task?.id ?? '',
        file: _selectedFile!,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      setState(() {
        _isUploading = false;
        _uploadedAttachmentUrl = attachmentUrl;
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
        _errorMessage = 'فشل في رفع الملف. حاول مرة أخرى.';
      });
    }
  }

  void _clearFile() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
      _uploadedAttachmentUrl = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final assignment = widget.state.assignment!;
    final status = assignment.status;

    // Completed - show attachment if exists
    if (status.isCompleted) {
      if (assignment.hasAttachment) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.successSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'تم تسليم المهمة بنجاح',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () async {
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
                icon: const Icon(Icons.attach_file, size: 18),
                label: const Text('عرض المرفق المُسلّم'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      }
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

    // Pending - show attachment upload section if required, then buttons
    final task = widget.state.task;
    final attachmentRequired = task?.attachmentRequired ?? false;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userId = authState is AuthAuthenticated ? authState.user.id : '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Attachment upload section (for tasks that require attachment)
            if (attachmentRequired) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.warningSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Row(
                      children: [
                        Icon(Icons.upload_file, color: AppColors.warning, size: 20),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'هذه المهمة تتطلب إرفاق ملف',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'يرجى رفع صورة أو ملف قبل تسليم المهمة',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // File selection / uploaded status
                    if (_uploadedAttachmentUrl != null)
                      // File uploaded successfully
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.successSurface,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                _fileName ?? 'تم رفع الملف بنجاح',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: _clearFile,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      )
                    else if (_isUploading)
                      // Uploading progress
                      Column(
                        children: [
                          LinearProgressIndicator(value: _uploadProgress),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'جاري الرفع... ${(_uploadProgress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      )
                    else
                      // Select file button
                      OutlinedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.attach_file),
                        label: const Text('اختر ملف'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.warning,
                          side: const BorderSide(color: AppColors.warning),
                        ),
                      ),

                    // Error message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.error, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Submit button
            SizedBox(
              width: double.infinity,
              height: _buttonHeight,
              child: FilledButton.icon(
                onPressed: widget.state.isActionLoading || _isUploading ||
                        (attachmentRequired && _uploadedAttachmentUrl == null)
                    ? null
                    : () => _submitTask(context, userId, attachmentRequired),
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
                    ? 'ارفع الملف أولاً'
                    : 'تسليم المهمة'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.success.withValues(alpha: 0.5),
                  shape: _buttonShape,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Apologize button
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

  void _submitTask(BuildContext context, String userId, bool attachmentRequired) {
    if (attachmentRequired) {
      // Submit with attachment
      context.read<AssignmentDetailBloc>().add(
            AssignmentDetailMarkCompletedRequested(
              assignmentId: widget.assignmentId,
              markedDoneBy: userId,
              attachmentUrl: _uploadedAttachmentUrl,
            ),
          );
    } else {
      // Show simple confirmation dialog
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('تأكيد التسليم'),
          content: const Text('هل أنت متأكد من تسليم هذه المهمة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AssignmentDetailBloc>().add(
                      AssignmentDetailMarkCompletedRequested(
                        assignmentId: widget.assignmentId,
                        markedDoneBy: userId,
                      ),
                    );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              child: const Text('تسليم'),
            ),
          ],
        ),
      );
    }
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

/// Dialog for uploading attachment before completing task
class _AttachmentUploadDialog extends StatefulWidget {
  final String assignmentId;
  final String taskId;
  final String userId;
  final void Function(String attachmentUrl) onComplete;

  const _AttachmentUploadDialog({
    required this.assignmentId,
    required this.taskId,
    required this.userId,
    required this.onComplete,
  });

  @override
  State<_AttachmentUploadDialog> createState() => _AttachmentUploadDialogState();
}

class _AttachmentUploadDialogState extends State<_AttachmentUploadDialog> {
  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;

  final _imagePicker = ImagePicker();
  final _storageService = getIt<StorageService>();

  Future<void> _pickFile() async {
    try {
      // Show options to pick from gallery or camera
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('اختر من المعرض'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('التقط صورة'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedFile = File(pickedFile.path);
          _fileName = pickedFile.name;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل في اختيار الملف';
      });
    }
  }

  Future<void> _uploadAndComplete() async {
    if (_selectedFile == null) {
      setState(() {
        _errorMessage = 'يرجى اختيار ملف أولاً';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _errorMessage = null;
    });

    try {
      final attachmentUrl = await _storageService.uploadTaskAttachment(
        taskId: widget.taskId,
        file: _selectedFile!,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onComplete(attachmentUrl);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _errorMessage = 'فشل في رفع الملف. حاول مرة أخرى.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تسليم المهمة'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'هذه المهمة تتطلب إرفاق ملف. يرجى اختيار صورة أو ملف للتسليم.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),

            // File selection button
            if (_selectedFile == null)
              OutlinedButton.icon(
                onPressed: _isUploading ? null : _pickFile,
                icon: const Icon(Icons.attach_file),
                label: const Text('اختر ملف'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: const BorderSide(color: AppColors.warning),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.successSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _fileName ?? 'ملف محدد',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!_isUploading)
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          setState(() {
                            _selectedFile = null;
                            _fileName = null;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),

            // Upload progress
            if (_isUploading) ...[
              const SizedBox(height: AppSpacing.md),
              LinearProgressIndicator(value: _uploadProgress),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'جاري الرفع... ${(_uploadProgress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _isUploading || _selectedFile == null ? null : _uploadAndComplete,
          style: FilledButton.styleFrom(backgroundColor: AppColors.success),
          child: _isUploading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('تسليم'),
        ),
      ],
    );
  }
}
