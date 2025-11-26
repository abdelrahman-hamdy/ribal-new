import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/assignment/assignment.dart';
import '../../../../core/widgets/feedback/error_state.dart';
import '../../../../core/widgets/feedback/loading_state.dart';
import '../../../../core/widgets/notes/notes.dart';
import '../../../../data/models/assignment_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.task_details),
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
            return LoadingState(message: l10n.assignment_loading);
          }

          if (state.assignment == null || state.task == null) {
            return ErrorState(
              icon: Icons.error_outline,
              message: l10n.error_loadTask,
            );
          }

          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final currentUser =
                  authState is AuthAuthenticated ? authState.user : null;

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
                      showAttachmentViewRow: true,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Action buttons
                    _ActionButtons(
                      state: state,
                      assignmentId: state.assignment!.id,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Notes section
                    if (currentUser != null) ...[
                      Text(
                        l10n.notes_title,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      NotesSection(
                        assignmentId: state.assignment!.id,
                        taskId: state.task!.id,
                        currentUserId: currentUser.id,
                        currentUserName: currentUser.fullName,
                        currentUserRole: currentUser.role,
                        height: 350,
                        recipientId: state.task!.createdBy,
                        taskTitle: state.task!.title,
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
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
    final l10n = AppLocalizations.of(context)!;

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
        _errorMessage = l10n.assignment_fileUploadError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          label: Text(l10n.assignment_reactivate),
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
        final userId = authState is AuthAuthenticated ? authState.user.id : '';
        final attachmentRequired = task.attachmentRequired;

        return Column(
          children: [
            // Attachment upload section (if required)
            if (attachmentRequired) ...[
              _buildAttachmentUploadSection(context, l10n),
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
                    ? l10n.assignment_mustUploadFirst
                    : l10n.assignment_submitTask),
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
                    : () {
                        final authState = context.read<AuthBloc>().state;
                        if (authState is AuthAuthenticated) {
                          _showApologizeDialog(
                            context,
                            widget.assignmentId,
                            authState.user.id,
                            authState.user.fullName,
                            authState.user.role,
                            l10n,
                          );
                        }
                      },
                icon: const Icon(Icons.close, size: 20),
                label: Text(l10n.assignment_apologize),
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

  Widget _buildAttachmentUploadSection(BuildContext context, AppLocalizations l10n) {
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
                l10n.task_attachmentRequired,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.assignment_attachmentRequiredHint,
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
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${l10n.common_uploading} ${(_uploadProgress * 100).toInt()}%',
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
                  const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      _fileName ?? l10n.assignment_attachmentUploaded,
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
                      l10n.common_change,
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
                    label: Text(l10n.common_selectFile),
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

  void _showApologizeDialog(
    BuildContext context,
    String assignmentId,
    String userId,
    String userName,
    UserRole userRole,
    AppLocalizations l10n,
  ) {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.assignment_apologize),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.assignment_apologizeMessage),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.assignment_apologizeReasonHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.common_cancel),
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
                      senderId: userId,
                      senderName: userName,
                      senderRole: userRole,
                    ),
                  );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(l10n.assignment_apologizeConfirm),
          ),
        ],
      ),
    );
  }
}
