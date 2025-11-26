import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/feedback/error_state.dart';
import '../../../../core/widgets/feedback/loading_state.dart';
import '../../../../core/widgets/task/task.dart';
import '../../../../l10n/generated/app_localizations.dart';
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

class _TaskDetailPageContent extends StatelessWidget {
  const _TaskDetailPageContent();

  void _showDeleteConfirmation(BuildContext context, String taskId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.task_delete),
        content: Text(l10n.task_deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<TaskDetailBloc>().add(TaskDetailDeleteRequested(taskId: taskId));
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.common_delete),
          ),
        ],
      ),
    );
  }

  void _showArchiveConfirmation(BuildContext context, String taskId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.task_stopRecurring),
        content: Text(l10n.task_stopRecurringConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<TaskDetailBloc>().add(TaskDetailArchiveRequested(taskId: taskId));
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.warning),
            child: Text(l10n.task_stopArchive),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.task_details),
      ),
      body: BlocConsumer<TaskDetailBloc, TaskDetailState>(
        listenWhen: (previous, current) {
          return (previous.errorMessage == null && current.errorMessage != null) ||
              (previous.successMessage == null && current.successMessage != null) ||
              (previous.isDeleted != current.isDeleted && current.isDeleted) ||
              (previous.isArchived != current.isArchived && current.isArchived);
        },
        listener: (context, state) {
          if (state.isDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage ?? l10n.task_deletedSuccess),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
            return;
          }
          if (state.isArchived) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage ?? l10n.task_archivedSuccess),
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
            return LoadingState(message: l10n.task_loading);
          }

          if (state.task == null) {
            return ErrorState(
              icon: Icons.error_outline,
              message: l10n.task_loadError,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<TaskDetailBloc>().add(const TaskDetailRefreshRequested());
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task info card (shared widget)
                  TaskInfoCard(state: state),
                  const SizedBox(height: AppSpacing.md),

                  // Actions section (shared widget)
                  TaskActionsSection(
                    state: state,
                    onEdit: () => context.push(Routes.adminTaskEditPath(state.taskId!)),
                    onDelete: () => _showDeleteConfirmation(context, state.taskId!),
                    onArchive: () => _showArchiveConfirmation(context, state.taskId!),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Assignees section (shared widget with admin-specific features)
                  TaskAssigneesSection(
                    state: state,
                    onUserTap: (userId) => context.push(Routes.adminUserDetailPath(userId)),
                    showAttachmentView: true,
                    showViewNotes: true,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
