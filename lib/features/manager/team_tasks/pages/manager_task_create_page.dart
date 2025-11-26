import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/ribal_button.dart';
import '../../../../core/widgets/tasks/task_form/task_form_fields.dart';
import '../../../../data/models/group_model.dart';
import '../../../../data/models/label_model.dart';
import '../../../../data/models/task_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/group_repository.dart';
import '../../../../data/repositories/label_repository.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../admin/tasks/bloc/tasks_bloc.dart';
import '../../../auth/bloc/auth_bloc.dart';

class ManagerTaskCreatePage extends StatefulWidget {
  const ManagerTaskCreatePage({super.key});

  @override
  State<ManagerTaskCreatePage> createState() => _ManagerTaskCreatePageState();
}

class _ManagerTaskCreatePageState extends State<ManagerTaskCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isRecurring = false;
  bool _attachmentRequired = false;
  AssigneeSelection _assigneeSelection = AssigneeSelection.groups;
  final List<String> _selectedGroupIds = [];
  final List<String> _selectedLabelIds = [];

  List<GroupModel> _availableGroups = [];
  List<LabelModel> _availableLabels = [];
  bool _isLoadingGroups = true;
  bool _isLoadingLabels = true;
  bool _isSubmitting = false;
  bool _canAssignToAll = false;

  @override
  void initState() {
    super.initState();
    _loadLabels();
    _loadManagerGroups();
  }

  Future<void> _loadLabels() async {
    try {
      final labelRepository = GetIt.I<LabelRepository>();
      final allLabels = await labelRepository.getAllLabels();
      final activeLabels = allLabels.where((label) => label.isActive).toList();
      if (mounted) {
        setState(() {
          _availableLabels = activeLabels;
          _isLoadingLabels = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLabels = false;
        });
      }
    }
  }

  Future<void> _loadManagerGroups() async {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        if (mounted) {
          setState(() => _isLoadingGroups = false);
        }
        return;
      }

      final currentUser = authState.user;
      _canAssignToAll = currentUser.canAssignToAll;

      // If manager can assign to all, load all groups
      // Otherwise, load only managed groups
      final groupRepository = GetIt.I<GroupRepository>();

      if (currentUser.canAssignToAll || currentUser.role == UserRole.admin) {
        final allGroups = await groupRepository.getAllGroups();
        if (mounted) {
          setState(() {
            _availableGroups = allGroups;
            _isLoadingGroups = false;
            // If can assign to all, allow the "all" option
            if (_canAssignToAll) {
              _assigneeSelection = AssigneeSelection.all;
            }
          });
        }
      } else if (currentUser.managedGroupIds.isNotEmpty) {
        final managedGroups =
            await groupRepository.getGroupsByIds(currentUser.managedGroupIds);
        if (mounted) {
          setState(() {
            _availableGroups = managedGroups;
            _isLoadingGroups = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _availableGroups = [];
            _isLoadingGroups = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingGroups = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => getIt<TasksBloc>(),
      child: BlocConsumer<TasksBloc, TasksState>(
        listener: (context, state) {
          if (state.successMessage != null && _isSubmitting) {
            _isSubmitting = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          }
          if (state.errorMessage != null && _isSubmitting) {
            _isSubmitting = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final currentUser =
                  authState is AuthAuthenticated ? authState.user : null;
              final canCreateTasks = _canManagerCreateTasks(currentUser);

              return Scaffold(
                appBar: AppBar(
                  title: Text(l10n.task_create),
                ),
                body: canCreateTasks
                    ? _buildTaskForm(context, state)
                    : _buildNoPermissionState(context),
              );
            },
          );
        },
      ),
    );
  }

  bool _canManagerCreateTasks(UserModel? user) {
    if (user == null) return false;
    if (user.role == UserRole.admin) return true;
    if (user.role == UserRole.manager) {
      return user.canAssignToAll || user.managedGroupIds.isNotEmpty;
    }
    return false;
  }

  Widget _buildNoPermissionState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: const BoxDecoration(
                color: AppColors.warningSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.block,
                size: 64,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.manager_cannotCreateTasks,
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.manager_noGroupsAssigned,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.infoSurface,
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      l10n.manager_canCreateOnlyWithGroups,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: Text(l10n.common_back),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskForm(BuildContext context, TasksState state) {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          TaskFormFields(
            titleController: _titleController,
            descriptionController: _descriptionController,
            isRecurring: _isRecurring,
            onRecurringChanged: (value) => setState(() => _isRecurring = value),
            attachmentRequired: _attachmentRequired,
            onAttachmentRequiredChanged: (value) =>
                setState(() => _attachmentRequired = value),
            availableLabels: _availableLabels,
            selectedLabelIds: _selectedLabelIds,
            onLabelsChanged: (labels) =>
                setState(() {
                  _selectedLabelIds.clear();
                  _selectedLabelIds.addAll(labels);
                }),
            isLoadingLabels: _isLoadingLabels,
            assigneeSelection: _assigneeSelection,
            onAssigneeSelectionChanged: (selection) =>
                setState(() {
                  _assigneeSelection = selection;
                  if (selection != AssigneeSelection.groups) {
                    _selectedGroupIds.clear();
                  }
                }),
            availableGroups: _availableGroups,
            selectedGroupIds: _selectedGroupIds,
            onGroupsChanged: (groups) =>
                setState(() {
                  _selectedGroupIds.clear();
                  _selectedGroupIds.addAll(groups);
                }),
            isLoadingGroups: _isLoadingGroups,
            showAssignToAll: _canAssignToAll,
          ),
          const SizedBox(height: AppSpacing.xl),
          RibalButton(
            text: l10n.task_create,
            onPressed: state.isLoading ? null : () => _handleCreateTask(context),
            isLoading: state.isLoading,
          ),
        ],
      ),
    );
  }

  void _handleCreateTask(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState?.validate() ?? false) {
      // Validate group selection if groups is chosen
      if (_assigneeSelection == AssigneeSelection.groups &&
          _selectedGroupIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.task_selectAtLeastOneGroup),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final authState = context.read<AuthBloc>().state;
      final userId = authState is AuthAuthenticated ? authState.user.id : '';

      if (userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.common_errorUserNotFound),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      _isSubmitting = true;

      context.read<TasksBloc>().add(TaskCreateRequested(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            labelIds: _selectedLabelIds,
            isRecurring: _isRecurring,
            attachmentRequired: _attachmentRequired,
            assigneeSelection: _assigneeSelection,
            selectedGroupIds: _selectedGroupIds,
            createdBy: userId,
          ));
    }
  }
}
