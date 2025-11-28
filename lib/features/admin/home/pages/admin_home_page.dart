import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/ribal_button.dart';
import '../../../../core/widgets/notifications/notification_badge.dart';
import '../../../../core/widgets/tasks/today_tasks/today_stats_grid.dart';
import '../../../../core/widgets/tasks/today_tasks/today_tasks_section.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/bloc/auth_bloc.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  // Key to force bloc rebuild on refresh
  UniqueKey _blocKey = UniqueKey();

  Future<void> _handleRefresh() async {
    // Force TodayTasksBloc to rebuild and reload its data
    setState(() {
      _blocKey = UniqueKey();
    });

    // Small delay to show refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));
  }

  String _formatDate(DateTime dateTime, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName == 'ar';

    // Day names
    const daysAr = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    const daysEn = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final dayName = isArabic ? daysAr[dateTime.weekday % 7] : daysEn[dateTime.weekday % 7];

    return '$dayName • ${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName == 'ar';

    int hour = dateTime.hour;
    final isPM = hour >= 12;

    // Convert to 12-hour format
    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour = hour - 12;
    }

    final period = isPM
        ? (isArabic ? 'م' : 'PM')
        : (isArabic ? 'ص' : 'AM');

    return '$hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: _blocKey,
      create: (context) => getIt<TodayTasksBloc>()..add(const TodayTasksLoadRequested()),
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.nav_home),
              actions: [
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      return NotificationBadge(
                        userId: state.user.id,
                        onTap: () => context.push(Routes.notifications),
                      );
                    }
                    return IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () => context.push(Routes.notifications),
                    );
                  },
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppSpacing.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome message
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final name = state is AuthAuthenticated
                            ? state.user.firstName
                            : l10n.user_roleAdmin;

                        return Text(
                          l10n.user_welcomeName(name),
                          style: AppTypography.displaySmall.copyWith(
                            color: context.colors.textPrimary,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Subheading with date/time
                    Builder(
                      builder: (context) {
                        // Get KSA time (UTC+3)
                        final now = DateTime.now().toUtc().add(const Duration(hours: 3));
                        final dateText = _formatDate(now, context);
                        final timeText = _formatTime(now, context);

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                l10n.statistics_overview,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: AppSpacing.borderRadiusSm,
                              ),
                              child: Text(
                                '$dateText • $timeText',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Stats grid - real data from TodayTasksBloc
                    BlocBuilder<TodayTasksBloc, TodayTasksState>(
                      builder: (context, state) {
                        return TodayStatsGrid(
                          isLoading: !state.hasLoadedOnce,
                          totalTasksCount: state.totalTasksCount,
                          totalAssignmentsCount: state.totalAssignmentsCount,
                          completedTasksCount: state.totalCompletedCount,
                          pendingCount: state.totalPendingCount,
                          overdueCount: state.totalApologizedCount + state.totalOverdueCount,
                          onViewFullStats: () => context.push(Routes.adminStatistics),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Create task button
                    RibalButton(
                      text: l10n.task_createNew,
                      onPressed: () => context.push(Routes.adminTaskCreate),
                      icon: Icons.add_task,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Today's tasks section (uses external bloc)
                    TodayTasksSection(
                      getTaskDetailRoute: Routes.adminTaskDetailPath,
                      onNavigate: (route) => context.push(route),
                      useExternalBloc: true,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
