import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/feedback/empty_state.dart';
import '../../../../data/models/label_model.dart';
import '../../../../data/models/settings_model.dart';
import '../../../../data/models/task_model.dart';
import '../../../../data/repositories/label_repository.dart';
import '../../../../data/repositories/settings_repository.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../tasks/bloc/tasks_bloc.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TasksBloc>()..add(const TasksLoadArchivedRequested()),
      child: const _ArchivePageContent(),
    );
  }
}

class _ArchivePageContent extends StatelessWidget {
  const _ArchivePageContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.archive_title),
      ),
      body: BlocConsumer<TasksBloc, TasksState>(
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
          if (state.isLoading && state.archivedTasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.archivedTasks.isEmpty) {
            return EmptyState(
              icon: Icons.archive_outlined,
              title: l10n.archive_empty,
              message: l10n.archive_noArchived,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<TasksBloc>().add(const TasksLoadArchivedRequested());
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: state.archivedTasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final task = state.archivedTasks[index];
                return _ArchivedTaskCard(task: task);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ArchivedTaskCard extends StatefulWidget {
  final TaskModel task;

  const _ArchivedTaskCard({required this.task});

  @override
  State<_ArchivedTaskCard> createState() => _ArchivedTaskCardState();
}

class _ArchivedTaskCardState extends State<_ArchivedTaskCard> {
  List<LabelModel> _labels = [];
  SettingsModel _settings = SettingsModel.defaults();
  bool _isLoadingLabels = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final labelRepository = getIt<LabelRepository>();
    final settingsRepository = getIt<SettingsRepository>();

    try {
      final labels = await labelRepository.getLabelsByIds(widget.task.labelIds);

      // Try to get settings, but use defaults if permission denied
      SettingsModel settings;
      try {
        settings = await settingsRepository.getSettings();
      } catch (e) {
        // Use default settings if we can't fetch them (e.g., permission denied)
        settings = SettingsModel.defaults();
      }

      if (mounted) {
        setState(() {
          _labels = labels;
          _settings = settings;
          _isLoadingLabels = false;
        });
      }
    } catch (e) {
      // Handle any other errors gracefully
      if (mounted) {
        setState(() {
          _isLoadingLabels = false;
        });
      }
    }
  }

  void _showPublishOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isBeforeDeadline = _settings.isBeforeDeadline;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.dialogPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Title
              Text(
                l10n.archive_publishTask,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.task.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xl),
              // Publish for today only button
              _PublishOptionButton(
                icon: Icons.today,
                title: l10n.archive_publishForToday,
                subtitle: isBeforeDeadline
                    ? l10n.archive_publishForTodaySubtitle
                    : l10n.archive_deadlineExpired(_settings.taskDeadline),
                enabled: isBeforeDeadline,
                onTap: isBeforeDeadline
                    ? () {
                        Navigator.pop(bottomSheetContext);
                        _confirmPublishForToday(context);
                      }
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              // Publish as recurring button
              _PublishOptionButton(
                icon: Icons.repeat,
                title: l10n.archive_publishAsRecurring,
                subtitle: l10n.archive_publishAsRecurringSubtitle,
                enabled: true,
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _confirmPublishAsRecurring(context);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              // Cancel button
              TextButton(
                onPressed: () => Navigator.pop(bottomSheetContext),
                child: Text(l10n.common_cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmPublishForToday(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.archive_publishConfirmTitle),
        content: Text(l10n.archive_publishConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<TasksBloc>().add(
                TaskPublishForTodayRequested(taskId: widget.task.id),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: Text(l10n.common_publish),
          ),
        ],
      ),
    );
  }

  void _confirmPublishAsRecurring(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.archive_publishRecurringConfirmTitle),
        content: Text(l10n.archive_publishRecurringConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<TasksBloc>().add(
                TaskPublishAsRecurringRequested(taskId: widget.task.id),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: Text(l10n.common_publish),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Labels
          if (_labels.isNotEmpty && !_isLoadingLabels) ...[
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: _labels.map((label) => _LabelChip(label: label)).toList(),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          // Title
          Text(
            widget.task.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.task.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.task.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.colors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          // Meta info row
          Row(
            children: [
              // Original type indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: context.colors.surfaceVariant,
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.task.isRecurring ? Icons.repeat : Icons.event,
                      size: 14,
                      color: context.colors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      widget.task.isRecurring ? l10n.archive_wasRecurring : l10n.archive_wasOneTime,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Archive date
              Icon(
                Icons.archive_outlined,
                size: 14,
                color: context.colors.textTertiary,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                DateFormat('d MMM yyyy', locale).format(widget.task.updatedAt),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.colors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showPublishOptions(context),
              icon: const Icon(Icons.publish, size: 18),
              label: Text(l10n.archive_publishTask),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.smd),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PublishOptionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  const _PublishOptionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: enabled ? context.colors.surface : context.colors.surfaceVariant,
      borderRadius: AppSpacing.borderRadiusMd,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(
              color: enabled ? context.colors.border : context.colors.border.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: enabled
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : context.colors.surfaceVariant,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Icon(
                  icon,
                  color: enabled ? AppColors.primary : context.colors.textTertiary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: enabled ? context.colors.textPrimary : context.colors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: enabled ? context.colors.textSecondary : context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (enabled)
                Icon(
                  Icons.arrow_forward_ios,
                  color: context.colors.textTertiary,
                  size: 16,
                ),
              if (!enabled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                  child: Text(
                    l10n.archive_timeExpired,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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
