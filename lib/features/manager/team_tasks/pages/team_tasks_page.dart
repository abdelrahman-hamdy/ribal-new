import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/notifications/notification_badge.dart';
import '../../../../core/widgets/tasks/today_tasks/today_tasks_section.dart';
import '../../../auth/bloc/auth_bloc.dart';

class TeamTasksPage extends StatefulWidget {
  const TeamTasksPage({super.key});

  @override
  State<TeamTasksPage> createState() => _TeamTasksPageState();
}

class _TeamTasksPageState extends State<TeamTasksPage> {
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userId = authState is AuthAuthenticated ? authState.user.id : null;

        return BlocProvider(
          key: _blocKey,
          // Filter tasks by current user (manager sees only their created tasks)
          create: (context) => getIt<TodayTasksBloc>()
            ..add(TodayTasksLoadRequested(creatorId: userId)),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('إدارة المهام'),
              actions: [
                if (authState is AuthAuthenticated)
                  NotificationBadge(
                    userId: authState.user.id,
                    onTap: () => context.push(Routes.notifications),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => context.push(Routes.notifications),
                  ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppSpacing.pagePadding,
                child: TodayTasksSection(
                  getTaskDetailRoute: Routes.managerTaskDetailPath,
                  onNavigate: (route) => context.push(route),
                  useExternalBloc: true,
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await context.push(Routes.managerTaskCreate);
                // Refresh tasks list after returning from task creation
                if (mounted) {
                  setState(() {
                    _blocKey = UniqueKey();
                  });
                }
              },
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }
}
