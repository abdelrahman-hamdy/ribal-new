import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/assignment/assignment.dart';
import '../../../../core/widgets/feedback/error_state.dart';
import '../../../../core/widgets/feedback/loading_state.dart';
import '../../../../data/models/assignment_model.dart';
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
                // Task info card (using shared widget)
                AssignmentInfoCard(
                  assignment: state.assignment!,
                  task: state.task!,
                  labels: state.labels,
                  creator: state.creator,
                  deadline: state.taskDeadline,
                  showAttachmentViewRow: false,
                ),
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
              _buildAttachmentUploadSection(context),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Submit button
            SizedBox(
              width: double.infinity,
              height: _buttonHeight,
              child: FilledButton.icon(
                onPressed: widget.state.isActionLoading ||
                        _isUploading ||
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

  Widget _buildAttachmentUploadSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warningSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
    );
  }

  void _submitTask(BuildContext context, String userId, bool attachmentRequired) {
    if (attachmentRequired) {
      context.read<AssignmentDetailBloc>().add(
            AssignmentDetailMarkCompletedRequested(
              assignmentId: widget.assignmentId,
              markedDoneBy: userId,
              attachmentUrl: _uploadedAttachmentUrl,
            ),
          );
    } else {
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
