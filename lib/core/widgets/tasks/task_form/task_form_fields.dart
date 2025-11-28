import 'package:flutter/material.dart';

import '../../../../data/models/group_model.dart';
import '../../../../data/models/label_model.dart';
import '../../../../data/models/task_model.dart';
import '../../../../l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title field
        RibalTextField(
          label: l10n.task_title,
          hint: l10n.task_titleHint,
          controller: titleController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.task_titleRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),

        // Description field
        RibalTextField(
          label: l10n.task_description,
          hint: l10n.task_descriptionHint,
          controller: descriptionController,
          maxLines: 4,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Labels section
        Text(
          l10n.task_labels,
          style: AppTypography.titleMedium.copyWith(
            color: context.colors.textPrimary,
          ),
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
          title: Text(l10n.task_recurring),
          subtitle: Text(l10n.task_recurringLabel),
          value: isRecurring,
          onChanged: onRecurringChanged,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Attachment required toggle
        SwitchListTile(
          title: Text(l10n.task_attachmentRequired),
          subtitle: Text(l10n.task_attachmentRequiredSubtitle),
          value: attachmentRequired,
          onChanged: onAttachmentRequiredChanged,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Assignment target section
        Text(
          l10n.task_assignTo,
          style: AppTypography.titleMedium.copyWith(
            color: context.colors.textPrimary,
          ),
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
      final l10n = AppLocalizations.of(context)!;
      return Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: context.colors.surfaceVariant,
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        child: Row(
          children: [
            Icon(Icons.label_off_outlined, color: context.colors.textTertiary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                l10n.task_noLabelsAvailableShort,
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.textSecondary,
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
            color: isSelected ? labelColor.color : context.colors.border,
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
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.border),
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Column(
        children: [
          if (showAssignToAll) ...[
            RadioListTile<AssigneeSelection>(
              title: Text(l10n.task_allUsers),
              subtitle: Text(l10n.task_allUsersSubtitle),
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
            title: Text(l10n.task_specificGroups),
            subtitle: Text(l10n.task_specificGroupsSubtitle),
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
    final l10n = AppLocalizations.of(context)!;

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
                l10n.task_noGroupsAvailableShort,
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
        border: Border.all(color: context.colors.border),
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              l10n.task_selectGroups,
              style: AppTypography.labelLarge.copyWith(
                color: context.colors.textPrimary,
              ),
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
