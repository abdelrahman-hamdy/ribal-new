import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../animated/animated_count.dart';

/// A grid of 6 boxes showing today's task statistics
/// 5 info boxes + 1 button box for viewing full stats
///
/// Order: Total Tasks, Total Assignments, Completed, Pending, Overdue, Full Stats Button
class TodayStatsGrid extends StatelessWidget {
  final bool isLoading;
  final int totalTasksCount;
  final int totalAssignmentsCount;
  final int completedTasksCount;
  final int pendingCount;
  final int overdueCount;
  final VoidCallback onViewFullStats;

  const TodayStatsGrid({
    super.key,
    this.isLoading = false,
    required this.totalTasksCount,
    required this.totalAssignmentsCount,
    required this.completedTasksCount,
    required this.pendingCount,
    required this.overdueCount,
    required this.onViewFullStats,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Row 1: Total Tasks, Total Assignments, Completed
        Row(
          children: [
            Expanded(
              child: _StatBox(
                title: l10n.statistics_totalTasks,
                count: totalTasksCount,
                color: AppColors.primary,
                isLoading: isLoading,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatBox(
                title: l10n.statistics_totalAssignments,
                count: totalAssignmentsCount,
                color: AppColors.roleAdmin, // Purple
                isLoading: isLoading,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatBox(
                title: l10n.statistics_completed,
                count: completedTasksCount,
                color: AppColors.progressDone,
                isLoading: isLoading,
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
                title: l10n.statistics_inProgress,
                count: pendingCount,
                color: AppColors.progressPending, // Orange
                isLoading: isLoading,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatBox(
                title: l10n.task_overdue,
                count: overdueCount,
                color: AppColors.progressOverdue,
                isLoading: isLoading,
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

/// Individual stat box with title and animated count value (centered vertically)
class _StatBox extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final bool isLoading;

  const _StatBox({
    required this.title,
    required this.count,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xxs),
          AnimatedStatCount(
            isLoading: isLoading,
            count: count,
            style: AppTypography.displaySmall.copyWith(
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
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 75,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: context.colors.primarySurface,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
                    l10n.statistics_title,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Caret icon on the end (appears on left in RTL)
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
