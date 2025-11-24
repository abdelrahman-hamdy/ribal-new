import 'package:flutter/material.dart';

import '../../../../data/models/group_model.dart';
import '../../../../data/models/label_model.dart';
import '../../../../data/models/task_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../inputs/ribal_text_field.dart';

/// Reusable task form fields widget
/// Can be used in both admin and manager task creation pages
class TaskFormFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final bool isRecurring;
  final ValueChanged<bool> onRecurringChanged;
  final bool attachmentRequired;
  final ValueChanged<bool> onAttachmentRequiredChanged;
  final List<LabelModel> availableLabels;
  final List<String> selectedLabelIds;
  final ValueChanged<List<String>> onLabelsChanged;
  final bool isLoadingLabels;
  final AssigneeSelection assigneeSelection;
  final ValueChanged<AssigneeSelection> onAssigneeSelectionChanged;
  final List<GroupModel> availableGroups;
  final List<String> selectedGroupIds;
  final ValueChanged<List<String>> onGroupsChanged;
  final bool isLoadingGroups;
  final bool showAssignToAll;

  const TaskFormFields({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.isRecurring,
    required this.onRecurringChanged,
    required this.attachmentRequired,
    required this.onAttachmentRequiredChanged,
    required this.availableLabels,
    required this.selectedLabelIds,
    required this.onLabelsChanged,
    required this.isLoadingLabels,
    required this.assigneeSelection,
    required this.onAssigneeSelectionChanged,
    required this.availableGroups,
    required this.selectedGroupIds,
    required this.onGroupsChanged,
    required this.isLoadingGroups,
    this.showAssignToAll = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title field
        RibalTextField(
          label: 'عنوان المهمة',
          hint: 'أدخل عنوان المهمة',
          controller: titleController,
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
          controller: descriptionController,
          maxLines: 4,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Labels section
        Text(
          'التصنيفات',
          style: AppTypography.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        _LabelsSelector(
          availableLabels: availableLabels,
          selectedLabelIds: selectedLabelIds,
          onLabelsChanged: onLabelsChanged,
          isLoading: isLoadingLabels,
        ),
        const SizedBox(height: AppSpacing.md),

        // Recurring toggle
        SwitchListTile(
          title: const Text('مهمة متكررة'),
          subtitle: const Text('إعادة جدولة المهمة يومياً'),
          value: isRecurring,
          onChanged: onRecurringChanged,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Attachment required toggle
        SwitchListTile(
          title: const Text('المرفق مطلوب'),
          subtitle: const Text('يجب على المكلفين إرفاق ملف عند إتمام المهمة'),
          value: attachmentRequired,
          onChanged: onAttachmentRequiredChanged,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Assignment target section
        Text(
          'تعيين المهمة إلى',
          style: AppTypography.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        _AssignmentSelector(
          assigneeSelection: assigneeSelection,
          onSelectionChanged: onAssigneeSelectionChanged,
          showAssignToAll: showAssignToAll,
        ),
        const SizedBox(height: AppSpacing.md),

        // Group selection (only visible when groups is selected)
        if (assigneeSelection == AssigneeSelection.groups) ...[
          _GroupSelector(
            availableGroups: availableGroups,
            selectedGroupIds: selectedGroupIds,
            onGroupsChanged: onGroupsChanged,
            isLoading: isLoadingGroups,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

/// Labels selector widget
class _LabelsSelector extends StatelessWidget {
  final List<LabelModel> availableLabels;
  final List<String> selectedLabelIds;
  final ValueChanged<List<String>> onLabelsChanged;
  final bool isLoading;

  const _LabelsSelector({
    required this.availableLabels,
    required this.selectedLabelIds,
    required this.onLabelsChanged,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (availableLabels.isEmpty) {
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
                'لا توجد تصنيفات متاحة',
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
      children: availableLabels.map((label) {
        final isSelected = selectedLabelIds.contains(label.id);
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
            final newList = List<String>.from(selectedLabelIds);
            if (selected) {
              newList.add(label.id);
            } else {
              newList.remove(label.id);
            }
            onLabelsChanged(newList);
          },
        );
      }).toList(),
    );
  }
}

/// Assignment type selector widget
class _AssignmentSelector extends StatelessWidget {
  final AssigneeSelection assigneeSelection;
  final ValueChanged<AssigneeSelection> onSelectionChanged;
  final bool showAssignToAll;

  const _AssignmentSelector({
    required this.assigneeSelection,
    required this.onSelectionChanged,
    required this.showAssignToAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Column(
        children: [
          if (showAssignToAll) ...[
            RadioListTile<AssigneeSelection>(
              title: const Text('جميع المستخدمين'),
              subtitle: const Text('سيتم تعيين المهمة لجميع الموظفين'),
              value: AssigneeSelection.all,
              groupValue: assigneeSelection,
              onChanged: (value) {
                if (value != null) {
                  onSelectionChanged(value);
                }
              },
            ),
            const Divider(height: 1),
          ],
          RadioListTile<AssigneeSelection>(
            title: const Text('مجموعات محددة'),
            subtitle: const Text('اختر المجموعات التي ستتلقى المهمة'),
            value: AssigneeSelection.groups,
            groupValue: assigneeSelection,
            onChanged: (value) {
              if (value != null) {
                onSelectionChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Group selector widget
class _GroupSelector extends StatelessWidget {
  final List<GroupModel> availableGroups;
  final List<String> selectedGroupIds;
  final ValueChanged<List<String>> onGroupsChanged;
  final bool isLoading;

  const _GroupSelector({
    required this.availableGroups,
    required this.selectedGroupIds,
    required this.onGroupsChanged,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (availableGroups.isEmpty) {
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
                'لا توجد مجموعات متاحة',
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
          ...availableGroups.map((group) => CheckboxListTile(
                title: Text(group.name),
                value: selectedGroupIds.contains(group.id),
                onChanged: (checked) {
                  final newList = List<String>.from(selectedGroupIds);
                  if (checked == true) {
                    newList.add(group.id);
                  } else {
                    newList.remove(group.id);
                  }
                  onGroupsChanged(newList);
                },
              )),
        ],
      ),
    );
  }
}
