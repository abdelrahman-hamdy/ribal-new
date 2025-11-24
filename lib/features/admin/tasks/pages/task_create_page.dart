import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/ribal_button.dart';
import '../../../../core/widgets/tasks/task_form/task_form_fields.dart';
import '../../../../data/models/group_model.dart';
import '../../../../data/models/label_model.dart';
import '../../../../data/models/task_model.dart';
import '../../../../data/repositories/group_repository.dart';
import '../../../../data/repositories/label_repository.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../bloc/tasks_bloc.dart';

class TaskCreatePage extends StatefulWidget {
  const TaskCreatePage({super.key});

  @override
  State<TaskCreatePage> createState() => _TaskCreatePageState();
}

class _TaskCreatePageState extends State<TaskCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isRecurring = false;
  bool _attachmentRequired = false;
  AssigneeSelection _assigneeSelection = AssigneeSelection.all;
  final List<String> _selectedGroupIds = [];
  final List<String> _selectedLabelIds = [];

  List<GroupModel> _availableGroups = [];
  List<LabelModel> _availableLabels = [];
  bool _isLoadingGroups = true;
  bool _isLoadingLabels = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadGroups();
    _loadLabels();
  }

  Future<void> _loadLabels() async {
    try {
      final labelRepository = GetIt.I<LabelRepository>();
      // Use getAllLabels and filter locally to avoid composite index requirement
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

  Future<void> _loadGroups() async {
    try {
      final groupRepository = GetIt.I<GroupRepository>();
      final groups = await groupRepository.getAllGroups();
      if (mounted) {
        setState(() {
          _availableGroups = groups;
          _isLoadingGroups = false;
        });
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
    return BlocListener<TasksBloc, TasksState>(
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
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إنشاء مهمة'),
        ),
        body: Form(
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
                onAttachmentRequiredChanged: (value) => setState(() => _attachmentRequired = value),
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
                showAssignToAll: true,
              ),
              const SizedBox(height: AppSpacing.xl),
              BlocBuilder<TasksBloc, TasksState>(
                builder: (context, state) {
                  return RibalButton(
                    text: 'إنشاء المهمة',
                    onPressed: state.isLoading ? null : _handleCreateTask,
                    isLoading: state.isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCreateTask() {
    if (_formKey.currentState?.validate() ?? false) {
      // Validate group selection if groups is chosen
      if (_assigneeSelection == AssigneeSelection.groups &&
          _selectedGroupIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى اختيار مجموعة واحدة على الأقل'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get current user ID
      final authState = context.read<AuthBloc>().state;
      final userId = authState is AuthAuthenticated ? authState.user.id : '';

      if (userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ في الحصول على بيانات المستخدم'),
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
