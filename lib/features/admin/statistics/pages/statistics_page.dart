import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/avatar/ribal_avatar.dart';
import '../../../../core/widgets/feedback/empty_state.dart';
import '../../../../core/widgets/feedback/loading_state.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../bloc/statistics_bloc.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<StatisticsBloc>()..add(const StatisticsLoadRequested()),
      child: const _StatisticsPageContent(),
    );
  }
}

class _StatisticsPageContent extends StatelessWidget {
  const _StatisticsPageContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statistics_title),
      ),
      body: BlocConsumer<StatisticsBloc, StatisticsState>(
        listenWhen: (previous, current) =>
            previous.errorMessage == null && current.errorMessage != null,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Period selector
              _PeriodSelector(currentPeriod: state.period),
              const Divider(height: 1),
              // Content
              Expanded(
                child: state.isLoading
                    ? LoadingState(message: l10n.statistics_loading)
                    : RefreshIndicator(
                        onRefresh: () async {
                          context
                              .read<StatisticsBloc>()
                              .add(const StatisticsLoadRequested());
                        },
                        child: _StatisticsContent(state: state),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final StatisticsPeriod currentPeriod;

  const _PeriodSelector({required this.currentPeriod});

  String _getPeriodDisplayName(AppLocalizations l10n, StatisticsPeriod period) {
    switch (period) {
      case StatisticsPeriod.today:
        return l10n.date_today;
      case StatisticsPeriod.week:
        return l10n.statistics_thisWeek;
      case StatisticsPeriod.month:
        return l10n.statistics_thisMonth;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: StatisticsPeriod.values.map((period) {
          final isSelected = period == currentPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                context
                    .read<StatisticsBloc>()
                    .add(StatisticsPeriodChanged(period: period));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : context.colors.surface,
                  borderRadius: AppSpacing.borderRadiusSm,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : context.colors.border,
                  ),
                ),
                child: Text(
                  _getPeriodDisplayName(l10n, period),
                  textAlign: TextAlign.center,
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected ? Colors.white : context.colors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  final StatisticsState state;

  const _StatisticsContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = state.statistics;

    if (stats == null) {
      return EmptyState(
        icon: Icons.bar_chart_outlined,
        title: l10n.statistics_noData,
        message: l10n.statistics_noData,
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview cards
          _OverviewSection(stats: stats),
          const SizedBox(height: AppSpacing.xl),

          // Completion rates
          _RatesSection(stats: stats),
          const SizedBox(height: AppSpacing.xl),

          // Top performers
          _TopPerformersSection(performers: state.topPerformers),
        ],
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  final dynamic stats;

  const _OverviewSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.statistics_overview,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: l10n.statistics_totalTasks,
                value: stats.totalAssignments.toString(),
                icon: Icons.assignment,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatCard(
                label: l10n.statistics_completed,
                value: stats.completedAssignments.toString(),
                icon: Icons.check_circle,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: l10n.statistics_inProgress,
                value: stats.pendingAssignments.toString(),
                icon: Icons.pending,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatCard(
                label: l10n.statistics_apologized,
                value: stats.apologizedAssignments.toString(),
                icon: Icons.cancel,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.smd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTypography.headlineMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatesSection extends StatelessWidget {
  final dynamic stats;

  const _RatesSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.statistics_performanceRates,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _ProgressCard(
          title: l10n.statistics_completionRate,
          percentage: stats.completionRate,
          color: AppColors.success,
          icon: Icons.trending_up,
        ),
        const SizedBox(height: AppSpacing.sm),
        _ProgressCard(
          title: l10n.statistics_apologyRate,
          percentage: stats.apologizeRate,
          color: AppColors.error,
          icon: Icons.trending_down,
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final double percentage;
  final Color color;
  final IconData icon;

  const _ProgressCard({
    required this.title,
    required this.percentage,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: AppTypography.headlineSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.smd),
          ClipRRect(
            borderRadius: AppSpacing.borderRadiusFull,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: context.colors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopPerformersSection extends StatelessWidget {
  final List<TopPerformer> performers;

  const _TopPerformersSection({required this.performers});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_events, color: AppColors.warning, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Text(
              l10n.statistics_bestEmployees,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (performers.isEmpty)
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: context.colors.surfaceVariant,
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: context.colors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    l10n.statistics_noTasks,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: performers.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final performer = performers[index];
              return _PerformerCard(
                performer: performer,
                rank: index + 1,
              );
            },
          ),
      ],
    );
  }
}

class _PerformerCard extends StatelessWidget {
  final TopPerformer performer;
  final int rank;

  const _PerformerCard({
    required this.performer,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = performer.user;
    final perf = performer.performance;
    final isTopThree = rank <= 3;

    Color getRankColor() {
      switch (rank) {
        case 1:
          return const Color(0xFFFFD700); // Gold
        case 2:
          return const Color(0xFFC0C0C0); // Silver
        case 3:
          return const Color(0xFFCD7F32); // Bronze
        default:
          return context.colors.textTertiary;
      }
    }

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: isTopThree ? getRankColor().withOpacity(0.5) : context.colors.border,
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: getRankColor().withOpacity(isTopThree ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isTopThree
                  ? Icon(Icons.emoji_events, color: getRankColor(), size: 18)
                  : Text(
                      '#$rank',
                      style: AppTypography.labelMedium.copyWith(
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.smd),
          // Avatar
          RibalAvatar(user: user, size: RibalAvatarSize.md),
          const SizedBox(width: AppSpacing.smd),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${perf.completedAssignments}/${perf.totalAssignments} ${l10n.statistics_tasks}',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Completion rate
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.smd,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusFull,
            ),
            child: Text(
              '${perf.completionRate.toStringAsFixed(0)}%',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
