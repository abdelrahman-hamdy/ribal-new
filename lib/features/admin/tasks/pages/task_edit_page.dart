import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/ribal_button.dart';
import '../../../../core/widgets/feedback/error_state.dart';
import '../../../../core/widgets/feedback/loading_state.dart';
import '../../../../core/widgets/inputs/ribal_text_field.dart';
import '../../../../data/models/group_model.dart';
import '../../../../data/models/label_model.dart';
import '../../../../data/models/task_model.dart';
import '../../../../data/repositories/group_repository.dart';
import '../../../../data/repositories/label_repository.dart';
import '../../../../data/repositories/task_repository.dart';
import '../bloc/tasks_bloc.dart';

class TaskEditPage extends StatefulWidget {
  final String taskId;

  /// When true, hides "all users" option and forces group selection.
  /// Used for managers who can only assign to their groups.
  final bool isManagerMode;

  const TaskEditPage({
    super.key,
    required this.taskId,
    this.isManagerMode = false,
  });

  @override
  State<TaskEditPage> createState() => _TaskEditPageState();
}

class _TaskEditPageState extends State<TaskEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Task state
  TaskModel? _task;
  bool _isLoadingTask = true;
  String? _taskLoadError;

  // Form state
  bool _isRecurring = false;
  bool _attachmentRequired = false;
  AssigneeSelection _assigneeSelection = AssigneeSelection.all;
  final List<String> _selectedGroupIds = [];
  final List<String> _selectedLabelIds = [];

  // Data loading state
  List<GroupModel> _availableGroups = [];
  List<LabelModel> _availableLabels = [];
  bool _isLoadingGroups = true;
  bool _isLoadingLabels = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadTask();
    _loadGroups();
    _loadLabels();
  }

  Future<void> _loadTask() async {
    try {
      final taskRepository = GetIt.I<TaskRepository>();
      final task = await taskRepository.getTaskById(widget.taskId);

      if (!mounted) return;

      if (task == null) {
        setState(() {
          _isLoadingTask = false;
          _taskLoadError = 'المهمة غير موجودة';
        });
        return;
      }

      setState(() {
        _task = task;
        _titleController.text = task.title;
        _descriptionController.text = task.description;
        _isRecurring = task.isRecurring;
        _attachmentRequired = task.attachmentRequired;
        // In manager mode, force groups selection (managers can't assign to all users)
        _assigneeSelection = widget.isManagerMode
            ? AssigneeSelection.groups
            : task.assigneeSelection;
        _selectedGroupIds.clear();
        _selectedGroupIds.addAll(task.selectedGroupIds);
        _selectedLabelIds.clear();
        _selectedLabelIds.addAll(task.labelIds);
        _isLoadingTask = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTask = false;
          _taskLoadError = 'فشل في تحميل المهمة';
        });
      }
    }
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
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        }
        if (state.errorMessage != null && _isSubmitting) {
          setState(() => _isSubmitting = false);
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
          title: const Text('تعديل المهمة'),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // Show loading state while fetching task
    if (_isLoadingTask) {
      return const LoadingState(message: 'جاري تحميل المهمة...');
    }

    // Show error if task failed to load
    if (_taskLoadError != null) {
      return ErrorState(
        icon: Icons.error_outline,
        message: _taskLoadError!,
        retryLabel: 'إعادة المحاولة',
        onRetry: () {
          setState(() {
            _isLoadingTask = true;
            _taskLoadError = null;
          });
          _loadTask();
        },
      );
    }

    // Task not found
    if (_task == null) {
      return const ErrorState(
        icon: Icons.search_off,
        message: 'المهمة غير موجودة',
      );
    }

    // Show edit form
    return _buildEditForm();
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          // Task status info card
          _buildStatusInfoCard(),
          const SizedBox(height: AppSpacing.lg),

          // Title field
          RibalTextField(
            label: 'عنوان المهمة',
            hint: 'أدخل عنوان المهمة',
            controller: _titleController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'عنوان المهمة مطلوب';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Description field
          RibalTextField(
            label: 'وصف المهمة',
            hint: 'أدخل وصف المهمة',
            controller: _descriptionController,
            maxLines: 4,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Labels section
          Text(
            'التصنيفات',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildLabelsSelector(),
          const SizedBox(height: AppSpacing.md),

          // Recurring toggle
          SwitchListTile(
            title: const Text('مهمة متكررة'),
            subtitle: const Text('إعادة جدولة المهمة يومياً'),
            value: _isRecurring,
            onChanged: (value) => setState(() => _isRecurring = value),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Attachment required toggle
          SwitchListTile(
            title: const Text('المرفق مطلوب'),
            subtitle: const Text('يجب على المكلفين إرفاق ملف عند إتمام المهمة'),
            value: _attachmentRequired,
            onChanged: (value) => setState(() => _attachmentRequired = value),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Assignment target section
          Text(
            'تعيين المهمة إلى',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildAssignmentSelector(),
          const SizedBox(height: AppSpacing.md),

          // Group selection (always visible in manager mode, or when groups is selected)
          if (widget.isManagerMode || _assigneeSelection == AssigneeSelection.groups) ...[
            _buildGroupSelector(),
            const SizedBox(height: AppSpacing.md),
          ],

          const SizedBox(height: AppSpacing.xl),

          // Submit button
          RibalButton(
            text: 'حفظ التعديلات',
            onPressed: _isSubmitting ? null : _handleUpdateTask,
            isLoading: _isSubmitting,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildStatusInfoCard() {
    final task = _task!;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: task.isArchived
            ? AppColors.warningSurface
            : AppColors.successSurface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: task.isArchived
              ? AppColors.warning.withValues(alpha: 0.3)
              : AppColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            task.isArchived ? Icons.archive_outlined : Icons.check_circle_outline,
            color: task.isArchived ? AppColors.warning : AppColors.success,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.isArchived ? 'مهمة مؤرشفة' : 'مهمة نشطة',
                  style: AppTypography.labelLarge.copyWith(
                    color: task.isArchived ? AppColors.warning : AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (task.isRecurring && !task.isActive && !task.isArchived) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'المهمة المتكررة متوقفة مؤقتاً',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelsSelector() {
    if (_isLoadingLabels) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_availableLabels.isEmpty) {
      return Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        child: Row(
          children: [
            const Icon(Icons.label_off_outlined, color: AppColors.textTertiary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'لا توجد تصنيفات متاحة. يمكنك إنشاء تصنيفات من لوحة التحكم.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _availableLabels.map((label) {
        final isSelected = _selectedLabelIds.contains(label.id);
        final labelColor = LabelColor.fromHex(label.color);

        return FilterChip(
          selected: isSelected,
          showCheckmark: false,
          label: Text(label.name),
          avatar: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: labelColor.color,
              shape: BoxShape.circle,
            ),
          ),
          selectedColor: labelColor.surfaceColor,
          side: BorderSide(
            color: isSelected ? labelColor.color : AppColors.border,
          ),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedLabelIds.add(label.id);
              } else {
                _selectedLabelIds.remove(label.id);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildAssignmentSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Column(
        children: [
          // Only show "all users" option for admins (not in manager mode)
          if (!widget.isManagerMode) ...[
            RadioListTile<AssigneeSelection>(
              title: const Text('جميع المستخدمين'),
              subtitle: const Text('سيتم تعيين المهمة لجميع الموظفين'),
              value: AssigneeSelection.all,
              groupValue: _assigneeSelection,
              onChanged: (value) {
                setState(() {
                  _assigneeSelection = value!;
                  _selectedGroupIds.clear();
                });
              },
            ),
            const Divider(height: 1),
          ],
          RadioListTile<AssigneeSelection>(
            title: const Text('مجموعات محددة'),
            subtitle: const Text('اختر المجموعات التي ستتلقى المهمة'),
            value: AssigneeSelection.groups,
            groupValue: _assigneeSelection,
            onChanged: (value) {
              setState(() => _assigneeSelection = value!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSelector() {
    if (_isLoadingGroups) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_availableGroups.isEmpty) {
      return Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.warningSurface,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.warning),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'لا توجد مجموعات متاحة. قم بإنشاء مجموعات من لوحة التحكم أولاً.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'اختر المجموعات:',
              style: AppTypography.labelLarge,
            ),
          ),
          const Divider(height: 1),
          ..._availableGroups.map((group) => CheckboxListTile(
                title: Text(group.name),
                value: _selectedGroupIds.contains(group.id),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedGroupIds.add(group.id);
                    } else {
                      _selectedGroupIds.remove(group.id);
                    }
                  });
                },
              )),
        ],
      ),
    );
  }

  void _handleUpdateTask() {
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

      if (_task == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ: المهمة غير موجودة'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      // Create updated task model
      final updatedTask = _task!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        labelIds: _selectedLabelIds,
        isRecurring: _isRecurring,
        attachmentRequired: _attachmentRequired,
        assigneeSelection: _assigneeSelection,
        selectedGroupIds: _selectedGroupIds,
        updatedAt: DateTime.now(),
      );

      context.read<TasksBloc>().add(TaskUpdateRequested(task: updatedTask));
    }
  }
}
