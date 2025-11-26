import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/buttons/ribal_button.dart';
import '../../../../../core/widgets/feedback/empty_state.dart';
import '../../../../../core/widgets/inputs/ribal_text_field.dart';
import '../../../../../data/models/label_model.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../auth/bloc/auth_bloc.dart';
import '../bloc/labels_bloc.dart';

class LabelsPage extends StatelessWidget {
  const LabelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LabelsBloc>()..add(const LabelsLoadRequested()),
      child: const _LabelsPageContent(),
    );
  }
}

class _LabelsPageContent extends StatelessWidget {
  const _LabelsPageContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.label_title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: _SearchField(),
          ),
        ),
      ),
      body: BlocConsumer<LabelsBloc, LabelsState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.labels.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.filteredLabels.isEmpty) {
            if (state.searchQuery.isNotEmpty) {
              return EmptyState(
                icon: Icons.search_off,
                title: l10n.common_no_results,
                message: l10n.label_noLabelsMatchingSearch(state.searchQuery),
              );
            }
            return EmptyState(
              icon: Icons.label_outline,
              title: l10n.label_noLabels,
              message: l10n.label_noLabelsSubtitle,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<LabelsBloc>().add(const LabelsLoadRequested());
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: state.filteredLabels.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final label = state.filteredLabels[index];
                return _LabelCard(label: label);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<LabelsBloc>(),
        child: _LabelFormDialog(
          onSubmit: (name, color) {
            final authState = context.read<AuthBloc>().state;
            final userId = authState is AuthAuthenticated ? authState.user.id : '';

            if (userId.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.common_errorUserNotFound),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }

            context.read<LabelsBloc>().add(
              LabelCreateRequested(
                name: name,
                color: color,
                createdBy: userId,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      onChanged: (value) {
        if (value.isEmpty) {
          context.read<LabelsBloc>().add(const LabelsSearchCleared());
        } else {
          context.read<LabelsBloc>().add(LabelsSearchRequested(query: value));
        }
      },
      decoration: InputDecoration(
        hintText: l10n.label_searchHint,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: context.colors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _LabelCard extends StatelessWidget {
  final LabelModel label;

  const _LabelCard({required this.label});

  String _getColorName(AppLocalizations l10n, LabelColor color) {
    switch (color) {
      case LabelColor.red:
        return l10n.color_red;
      case LabelColor.orange:
        return l10n.color_orange;
      case LabelColor.amber:
        return l10n.color_amber;
      case LabelColor.yellow:
        return l10n.color_yellow;
      case LabelColor.lime:
        return l10n.color_lime;
      case LabelColor.green:
        return l10n.color_green;
      case LabelColor.emerald:
        return l10n.color_emerald;
      case LabelColor.teal:
        return l10n.color_teal;
      case LabelColor.cyan:
        return l10n.color_cyan;
      case LabelColor.sky:
        return l10n.color_sky;
      case LabelColor.blue:
        return l10n.color_blue;
      case LabelColor.indigo:
        return l10n.color_indigo;
      case LabelColor.violet:
        return l10n.color_violet;
      case LabelColor.purple:
        return l10n.color_purple;
      case LabelColor.fuchsia:
        return l10n.color_fuchsia;
      case LabelColor.pink:
        return l10n.color_pink;
      case LabelColor.rose:
        return l10n.color_rose;
      case LabelColor.stone:
        return l10n.color_stone;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labelColor = LabelColor.fromHex(label.color);

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          // Color indicator
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: labelColor.surfaceColor,
              borderRadius: AppSpacing.borderRadiusSm,
              border: Border.all(color: labelColor.color, width: 2),
            ),
            child: Icon(
              Icons.label,
              color: labelColor.color,
              size: AppSpacing.iconLg,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!label.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceVariant,
                          borderRadius: AppSpacing.borderRadiusFull,
                        ),
                        child: Text(
                          l10n.label_disabled,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: context.colors.textTertiary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: labelColor.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _getColorName(l10n, labelColor),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  label.isActive ? Icons.visibility : Icons.visibility_off,
                  size: 20,
                ),
                onPressed: () {
                  context.read<LabelsBloc>().add(
                    LabelToggleActiveRequested(
                      labelId: label.id,
                      isActive: !label.isActive,
                    ),
                  );
                },
                tooltip: label.isActive ? l10n.label_deactivate : l10n.label_activate,
                color: label.isActive ? context.colors.textSecondary : context.colors.textTertiary,
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => _showEditDialog(context, label),
                tooltip: l10n.common_edit,
                color: AppColors.primary,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () => _confirmDelete(context, label),
                tooltip: l10n.common_delete,
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, LabelModel label) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<LabelsBloc>(),
        child: _LabelFormDialog(
          label: label,
          onSubmit: (name, color) {
            context.read<LabelsBloc>().add(
              LabelUpdateRequested(
                label: label.copyWith(name: name, color: color),
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, LabelModel label) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.common_confirmDelete),
        content: Text(l10n.label_deleteConfirmMessage(label.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<LabelsBloc>().add(
                LabelDeleteRequested(labelId: label.id),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.common_delete),
          ),
        ],
      ),
    );
  }
}

class _LabelFormDialog extends StatefulWidget {
  final LabelModel? label;
  final void Function(String name, String color) onSubmit;

  const _LabelFormDialog({
    this.label,
    required this.onSubmit,
  });

  @override
  State<_LabelFormDialog> createState() => _LabelFormDialogState();
}

class _LabelFormDialogState extends State<_LabelFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  LabelColor _selectedColor = LabelColor.defaultColor;
  bool _isSubmitting = false;

  bool get _isEditing => widget.label != null;

  @override
  void initState() {
    super.initState();
    if (widget.label != null) {
      _nameController.text = widget.label!.name;
      _selectedColor = LabelColor.fromHex(widget.label!.color);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<LabelsBloc, LabelsState>(
      listener: (context, state) {
        if (state.successMessage != null && _isSubmitting) {
          Navigator.pop(context);
        }
        if (state.errorMessage != null) {
          setState(() => _isSubmitting = false);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: AppSpacing.dialogPadding,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    _isEditing ? l10n.label_edit : l10n.label_create,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Name field
                  RibalTextField(
                    controller: _nameController,
                    label: l10n.label_name,
                    hint: l10n.label_nameHint,
                    prefixIcon: Icons.label_outline,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.label_nameRequired;
                      }
                      if (value.length < 2) {
                        return l10n.label_nameTooShort;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Color selection
                  Text(
                    l10n.label_color,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ColorPicker(
                    selectedColor: _selectedColor,
                    onColorSelected: (color) {
                      setState(() => _selectedColor = color);
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Preview
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceVariant,
                      borderRadius: AppSpacing.borderRadiusMd,
                    ),
                    child: Row(
                      children: [
                        Text(
                          l10n.label_preview,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedColor.surfaceColor,
                            borderRadius: AppSpacing.borderRadiusFull,
                            border: Border.all(color: _selectedColor.color),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _selectedColor.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                _nameController.text.isEmpty ? l10n.label_name : _nameController.text,
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: _selectedColor.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Submit button
                  RibalButton(
                    text: _isEditing ? l10n.label_saveChanges : l10n.label_createLabel,
                    isLoading: _isSubmitting,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Cancel button
                  RibalButton(
                    text: l10n.common_cancel,
                    variant: RibalButtonVariant.outline,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      widget.onSubmit(_nameController.text.trim(), _selectedColor.hex);
    }
  }
}

class _ColorPicker extends StatelessWidget {
  final LabelColor selectedColor;
  final ValueChanged<LabelColor> onColorSelected;

  const _ColorPicker({
    required this.selectedColor,
    required this.onColorSelected,
  });

  String _getColorName(AppLocalizations l10n, LabelColor color) {
    switch (color) {
      case LabelColor.red:
        return l10n.color_red;
      case LabelColor.orange:
        return l10n.color_orange;
      case LabelColor.amber:
        return l10n.color_amber;
      case LabelColor.yellow:
        return l10n.color_yellow;
      case LabelColor.lime:
        return l10n.color_lime;
      case LabelColor.green:
        return l10n.color_green;
      case LabelColor.emerald:
        return l10n.color_emerald;
      case LabelColor.teal:
        return l10n.color_teal;
      case LabelColor.cyan:
        return l10n.color_cyan;
      case LabelColor.sky:
        return l10n.color_sky;
      case LabelColor.blue:
        return l10n.color_blue;
      case LabelColor.indigo:
        return l10n.color_indigo;
      case LabelColor.violet:
        return l10n.color_violet;
      case LabelColor.purple:
        return l10n.color_purple;
      case LabelColor.fuchsia:
        return l10n.color_fuchsia;
      case LabelColor.pink:
        return l10n.color_pink;
      case LabelColor.rose:
        return l10n.color_rose;
      case LabelColor.stone:
        return l10n.color_stone;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: LabelColor.values.map((color) {
        final isSelected = color == selectedColor;
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Tooltip(
            message: _getColorName(l10n, color),
            child: AnimatedContainer(
              duration: AppSpacing.animationFast,
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? context.colors.textPrimary : Colors.transparent,
                  width: 3,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.color.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    )
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
