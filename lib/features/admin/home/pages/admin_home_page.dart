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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: _blocKey,
      create: (context) => getIt<TodayTasksBloc>()..add(const TodayTasksLoadRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الرئيسية'),
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
                        : 'مدير النظام';
                    return Text(
                      'مرحباً، $name',
                      style: AppTypography.displaySmall,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'نظرة عامة على المهام',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Stats grid - real data from TodayTasksBloc
                BlocBuilder<TodayTasksBloc, TodayTasksState>(
                  builder: (context, state) {
                    return TodayStatsGrid(
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
                  text: 'إنشاء مهمة جديدة',
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
      ),
    );
  }
}
