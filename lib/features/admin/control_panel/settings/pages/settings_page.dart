import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _recurringTime = AppConstants.defaultRecurringTime;
  String _deadlineTime = AppConstants.defaultDeadlineTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات العامة'),
      ),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          _buildSettingCard(
            title: 'وقت المهام المتكررة',
            subtitle: 'الوقت الذي يتم فيه جدولة المهام المتكررة يومياً',
            value: _recurringTime,
            onTap: () => _selectTime(
              currentValue: _recurringTime,
              onSelected: (time) => setState(() => _recurringTime = time),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSettingCard(
            title: 'الموعد النهائي للمهام',
            subtitle: 'الوقت الذي تنتهي فيه المهام يومياً',
            value: _deadlineTime,
            onTap: () => _selectTime(
              currentValue: _deadlineTime,
              onSelected: (time) => setState(() => _deadlineTime = time),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.smd,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: AppSpacing.borderRadiusSm,
          ),
          child: Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> _selectTime({
    required String currentValue,
    required Function(String) onSelected,
  }) async {
    final parts = currentValue.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime != null) {
      final formattedTime =
          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      onSelected(formattedTime);
      // TODO: Save to Firebase
    }
  }
}
