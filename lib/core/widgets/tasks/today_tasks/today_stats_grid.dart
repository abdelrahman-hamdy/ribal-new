import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

/// A grid of 6 boxes showing today's task statistics
/// 5 info boxes + 1 button box for viewing full stats
///
/// Order: Total Tasks, Total Assignments, Completed, Pending, Overdue, Full Stats Button
class TodayStatsGrid extends StatelessWidget {
  final int totalTasksCount;
  final int totalAssignmentsCount;
  final int completedTasksCount;
  final int pendingCount;
  final int overdueCount;
  final VoidCallback onViewFullStats;

  const TodayStatsGrid({
    super.key,
    required this.totalTasksCount,
    required this.totalAssignmentsCount,
    required this.completedTasksCount,
    required this.pendingCount,
    required this.overdueCount,
    required this.onViewFullStats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1: Total Tasks, Total Assignments, Completed
        Row(
          children: [
            Expanded(
              child: _StatBox(
                title: 'المهام',
                value: '$totalTasksCount',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatBox(
                title: 'التكليفات',
                value: '$totalAssignmentsCount',
                color: AppColors.roleAdmin, // Purple
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatBox(
                title: 'مكتملة',
                value: '$completedTasksCount',
                color: AppColors.progressDone,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        // Row 2: Pending, Overdue, View Stats Button
        Row(
          children: [
            Expanded(
              child: _StatBox(
                title: 'قيد الانتظار',
                value: '$pendingCount',
                color: AppColors.progressPending, // Orange
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatBox(
                title: 'متأخرة',
                value: '$overdueCount',
                color: AppColors.progressOverdue,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _ViewStatsButton(onTap: onViewFullStats),
            ),
          ],
        ),
      ],
    );
  }
}

/// Individual stat box with title and value (centered vertically)
class _StatBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatBox({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.smd,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Button box to view full statistics (with caret icon)
class _ViewStatsButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ViewStatsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.smd,
        ),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            // Centered content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bar_chart,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'الإحصائيات',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Caret icon on the end (appears on left in RTL)
            const Icon(
              Icons.chevron_right,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
