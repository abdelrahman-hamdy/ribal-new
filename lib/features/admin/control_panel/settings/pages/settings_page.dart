import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../../core/utils/time_formatter.dart';
import '../../../../../data/models/settings_model.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../bloc/settings_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    // Load current settings from Firestore
    context.read<SettingsBloc>().add(const SettingsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings_general),
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          // Show success message
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          // Show error message
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        builder: (context, state) {
          // Show loading indicator on initial load
          if (state.isLoading && state.settings == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Use loaded settings or defaults
          final settings = state.settings ??
              SettingsModel(
                recurringTaskTime: AppConstants.defaultRecurringTime,
                taskDeadline: AppConstants.defaultDeadlineTime,
              );

          return Stack(
            children: [
              ListView(
                padding: AppSpacing.pagePadding,
                children: [
                  _buildSettingCard(
                    context: context,
                    title: l10n.settings_recurringTime,
                    subtitle: l10n.settings_recurringTimeSubtitle,
                    value24: settings.recurringTaskTime,
                    valueArabic:
                        TimeFormatter.formatTimeArabic(settings.recurringTaskTime, amLabel: l10n.time_am, pmLabel: l10n.time_pm),
                    icon: Icons.refresh,
                    onTap: () => _selectTime(
                      context: context,
                      currentValue: settings.recurringTaskTime,
                      title: l10n.settings_recurringTimeSelect,
                      onSelected: (time) {
                        // Validate that recurring time is before deadline
                        if (TimeFormatter.isAfter(time, settings.taskDeadline)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.settings_recurringTimeBeforeDeadline),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        _confirmAndSave(
                          context: context,
                          message: l10n.settings_changeRecurringTime(
                              TimeFormatter.formatTimeArabic(time, amLabel: l10n.time_am, pmLabel: l10n.time_pm)),
                          onConfirm: () {
                            context.read<SettingsBloc>().add(
                                  SettingsRecurringTimeChanged(time: time),
                                );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildSettingCard(
                    context: context,
                    title: l10n.settings_deadlineTime,
                    subtitle: l10n.settings_deadlineTimeSubtitle,
                    value24: settings.taskDeadline,
                    valueArabic:
                        TimeFormatter.formatTimeArabic(settings.taskDeadline, amLabel: l10n.time_am, pmLabel: l10n.time_pm),
                    icon: Icons.access_time,
                    onTap: () => _selectTime(
                      context: context,
                      currentValue: settings.taskDeadline,
                      title: l10n.settings_deadlineTimeSelect,
                      onSelected: (time) {
                        // Validate that deadline is after recurring time
                        if (TimeFormatter.isBefore(
                            time, settings.recurringTaskTime)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.settings_deadlineAfterRecurringTime),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        _confirmAndSave(
                          context: context,
                          message: l10n.settings_changeDeadlineTime(
                              TimeFormatter.formatTimeArabic(time, amLabel: l10n.time_am, pmLabel: l10n.time_pm)),
                          onConfirm: () {
                            context.read<SettingsBloc>().add(
                                  SettingsDeadlineChanged(time: time),
                                );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Theme settings section
                  _buildThemeSection(context),
                  const SizedBox(height: AppSpacing.lg),
                  // Time window display - simplified
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: context.colors.primarySurface.withValues(alpha: 0.3),
                      borderRadius: AppSpacing.borderRadiusMd,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: AppSpacing.borderRadiusSm,
                          ),
                          child: const Icon(
                            Icons.schedule,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.settings_dailyWindow,
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.settings_fromTo(
                                  TimeFormatter.formatTimeArabic(settings.recurringTaskTime, amLabel: l10n.time_am, pmLabel: l10n.time_pm),
                                  TimeFormatter.formatTimeArabic(settings.taskDeadline, amLabel: l10n.time_am, pmLabel: l10n.time_pm),
                                ),
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Loading overlay when saving
              if (state.isLoading && state.settings != null)
                Container(
                  color: Colors.black26,
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: AppSpacing.md),
                            Text(l10n.settings_saving),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: context.colors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: context.colors.primarySurface,
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: Icon(
                        _getThemeModeIcon(themeState.mode),
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.settings_appTheme,
                            style: AppTypography.titleMedium.copyWith(
                              color: context.colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.settings_chooseTheme,
                            style: AppTypography.bodySmall.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: context.colors.divider),
              // Theme options
              _buildThemeOption(
                context: context,
                title: l10n.theme_light,
                subtitle: l10n.theme_lightSubtitle,
                icon: Icons.light_mode_outlined,
                mode: AppThemeMode.light,
                currentMode: themeState.mode,
              ),
              Divider(height: 1, indent: 56, color: context.colors.divider),
              _buildThemeOption(
                context: context,
                title: l10n.theme_dark,
                subtitle: l10n.theme_darkSubtitle,
                icon: Icons.dark_mode_outlined,
                mode: AppThemeMode.dark,
                currentMode: themeState.mode,
              ),
              Divider(height: 1, indent: 56, color: context.colors.divider),
              _buildThemeOption(
                context: context,
                title: l10n.theme_system,
                subtitle: l10n.theme_systemSubtitle,
                icon: Icons.brightness_auto_outlined,
                mode: AppThemeMode.system,
                currentMode: themeState.mode,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required AppThemeMode mode,
    required AppThemeMode currentMode,
  }) {
    final isSelected = mode == currentMode;

    return InkWell(
      onTap: () {
        context.read<ThemeBloc>().add(ThemeModeChanged(mode));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.smd,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : context.colors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      color: isSelected ? AppColors.primary : context.colors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: context.colors.border,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getThemeModeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  Widget _buildSettingCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String value24,
    required String valueArabic,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: context.colors.primarySurface,
            borderRadius: AppSpacing.borderRadiusSm,
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: context.colors.primarySurface,
            borderRadius: AppSpacing.borderRadiusSm,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                valueArabic,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              Text(
                value24,
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                  fontSize: 9,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> _selectTime({
    required BuildContext context,
    required String currentValue,
    required String title,
    required Function(String) onSelected,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final parts = currentValue.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: title,
      cancelText: l10n.common_cancel,
      confirmText: l10n.common_confirm,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      final formattedTime =
          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      onSelected(formattedTime);
    }
  }

  Future<void> _confirmAndSave({
    required BuildContext context,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settings_confirmChange),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.common_cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.common_confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onConfirm();
    }
  }
}
