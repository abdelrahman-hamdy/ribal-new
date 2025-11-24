import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/user_model.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/auth/pages/verify_email_page.dart';
import '../../features/auth/pages/splash_page.dart';
import '../../features/admin/home/pages/admin_home_page.dart';
import '../../features/admin/statistics/pages/statistics_page.dart';
import '../../features/admin/control_panel/pages/control_panel_page.dart';
import '../../features/admin/control_panel/users/pages/users_page.dart';
import '../../features/admin/control_panel/users/pages/user_detail_page.dart';
import '../../features/admin/control_panel/groups/pages/groups_page.dart';
import '../../features/admin/control_panel/labels/pages/labels_page.dart';
import '../../features/admin/control_panel/whitelist/pages/whitelist_page.dart';
import '../../features/admin/control_panel/invitations/pages/invitations_page.dart';
import '../../features/admin/control_panel/settings/pages/settings_page.dart';
import '../../features/admin/tasks/pages/admin_tasks_page.dart';
import '../../features/admin/tasks/pages/task_create_page.dart';
import '../../features/admin/tasks/pages/task_detail_page.dart';
import '../../features/admin/tasks/pages/task_edit_page.dart';
import '../../features/admin/archive/pages/archive_page.dart';
import '../../features/manager/my_tasks/pages/manager_my_tasks_page.dart';
import '../../features/manager/my_tasks/pages/manager_assignment_detail_page.dart';
import '../../features/manager/team_tasks/pages/team_tasks_page.dart';
import '../../features/manager/team_tasks/pages/manager_task_create_page.dart';
import '../../features/manager/team_tasks/pages/manager_task_detail_page.dart';
import '../../features/employee/tasks/pages/employee_tasks_page.dart';
import '../../features/employee/tasks/pages/employee_assignment_detail_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/notifications/pages/notifications_page.dart';
import '../../features/admin/shell/admin_shell.dart';
import '../../features/manager/shell/manager_shell.dart';
import '../../features/employee/shell/employee_shell.dart';
import 'routes.dart';

/// App router configuration using GoRouter
abstract final class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _adminShellKey = GlobalKey<NavigatorState>();
  static final _managerShellKey = GlobalKey<NavigatorState>();
  static final _employeeShellKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    redirect: _handleRedirect,
    routes: [
      // ============================================
      // AUTH ROUTES
      // ============================================
      GoRoute(
        path: Routes.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: Routes.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: Routes.verifyEmail,
        name: RouteNames.verifyEmail,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return VerifyEmailPage(email: email);
        },
      ),

      // ============================================
      // ADMIN ROUTES (Shell)
      // ============================================
      ShellRoute(
        navigatorKey: _adminShellKey,
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: Routes.adminHome,
            name: RouteNames.adminHome,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminHomePage(),
            ),
            routes: [
              GoRoute(
                path: 'statistics',
                name: RouteNames.adminStatistics,
                builder: (context, state) => const StatisticsPage(),
              ),
            ],
          ),
          GoRoute(
            path: Routes.adminControlPanel,
            name: RouteNames.adminControlPanel,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ControlPanelPage(),
            ),
            routes: [
              GoRoute(
                path: 'users',
                name: RouteNames.adminUsers,
                builder: (context, state) => const UsersPage(),
                routes: [
                  GoRoute(
                    path: ':userId',
                    name: RouteNames.adminUserDetail,
                    builder: (context, state) {
                      final userId = state.pathParameters['userId']!;
                      return UserDetailPage(userId: userId);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'groups',
                name: RouteNames.adminGroups,
                builder: (context, state) => const GroupsPage(),
              ),
              GoRoute(
                path: 'labels',
                name: RouteNames.adminLabels,
                builder: (context, state) => const LabelsPage(),
              ),
              GoRoute(
                path: 'whitelist',
                name: RouteNames.adminWhitelist,
                builder: (context, state) => const WhitelistPage(),
              ),
              GoRoute(
                path: 'invitations',
                name: RouteNames.adminInvitations,
                builder: (context, state) => const InvitationsPage(),
              ),
              GoRoute(
                path: 'settings',
                name: RouteNames.adminSettings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
          GoRoute(
            path: Routes.adminTasks,
            name: RouteNames.adminTasks,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminTasksPage(),
            ),
            routes: [
              GoRoute(
                path: 'create',
                name: RouteNames.adminTaskCreate,
                builder: (context, state) => const TaskCreatePage(),
              ),
              GoRoute(
                path: ':taskId',
                name: RouteNames.adminTaskDetail,
                builder: (context, state) {
                  final taskId = state.pathParameters['taskId']!;
                  return TaskDetailPage(taskId: taskId);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: RouteNames.adminTaskEdit,
                    builder: (context, state) {
                      final taskId = state.pathParameters['taskId']!;
                      return TaskEditPage(taskId: taskId);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: Routes.adminArchive,
            name: RouteNames.adminArchive,
            builder: (context, state) => const ArchivePage(),
          ),
          GoRoute(
            path: Routes.adminProfile,
            name: RouteNames.adminProfile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfilePage(),
            ),
          ),
        ],
      ),

      // ============================================
      // MANAGER ROUTES (Shell)
      // ============================================
      ShellRoute(
        navigatorKey: _managerShellKey,
        builder: (context, state, child) => ManagerShell(child: child),
        routes: [
          GoRoute(
            path: Routes.managerMyTasks,
            name: RouteNames.managerMyTasks,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ManagerMyTasksPage(),
            ),
            routes: [
              GoRoute(
                path: 'assignments/:assignmentId',
                name: RouteNames.managerAssignmentDetail,
                builder: (context, state) {
                  final assignmentId = state.pathParameters['assignmentId']!;
                  return ManagerAssignmentDetailPage(assignmentId: assignmentId);
                },
              ),
            ],
          ),
          GoRoute(
            path: Routes.managerTeamTasks,
            name: RouteNames.managerTeamTasks,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TeamTasksPage(),
            ),
            routes: [
              GoRoute(
                path: 'create',
                name: RouteNames.managerTaskCreate,
                builder: (context, state) => const ManagerTaskCreatePage(),
              ),
              GoRoute(
                path: ':taskId',
                name: RouteNames.managerTaskDetail,
                builder: (context, state) {
                  final taskId = state.pathParameters['taskId']!;
                  return ManagerTaskDetailPage(taskId: taskId);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: RouteNames.managerTaskEdit,
                    builder: (context, state) {
                      final taskId = state.pathParameters['taskId']!;
                      return TaskEditPage(
                        taskId: taskId,
                        isManagerMode: true,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: Routes.managerProfile,
            name: RouteNames.managerProfile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfilePage(),
            ),
          ),
        ],
      ),

      // ============================================
      // EMPLOYEE ROUTES (Shell)
      // ============================================
      ShellRoute(
        navigatorKey: _employeeShellKey,
        builder: (context, state, child) => EmployeeShell(child: child),
        routes: [
          GoRoute(
            path: Routes.employeeTasks,
            name: RouteNames.employeeTasks,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: EmployeeTasksPage(),
            ),
            routes: [
              GoRoute(
                path: 'assignments/:assignmentId',
                name: RouteNames.employeeAssignmentDetail,
                builder: (context, state) {
                  final assignmentId = state.pathParameters['assignmentId']!;
                  return EmployeeAssignmentDetailPage(assignmentId: assignmentId);
                },
              ),
            ],
          ),
          GoRoute(
            path: Routes.employeeProfile,
            name: RouteNames.employeeProfile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfilePage(),
            ),
          ),
        ],
      ),

      // ============================================
      // SHARED ROUTES
      // ============================================
      GoRoute(
        path: Routes.notifications,
        name: RouteNames.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
    ],
  );

  /// Handle navigation redirects based on auth state
  static String? _handleRedirect(BuildContext context, GoRouterState state) {
    final authState = context.read<AuthBloc>().state;
    final isAuthRoute = state.matchedLocation == Routes.login ||
        state.matchedLocation == Routes.register ||
        state.matchedLocation == Routes.verifyEmail ||
        state.matchedLocation == Routes.splash;

    // Still checking auth, stay on splash
    if (authState is AuthInitial || authState is AuthLoading) {
      return isAuthRoute ? null : Routes.splash;
    }

    // Not authenticated
    if (authState is AuthUnauthenticated) {
      return isAuthRoute ? null : Routes.login;
    }

    // Email not verified
    if (authState is AuthEmailNotVerified) {
      if (state.matchedLocation == Routes.verifyEmail) {
        return null;
      }
      return '${Routes.verifyEmail}?email=${authState.email}';
    }

    // Authenticated - redirect to appropriate home based on role
    if (authState is AuthAuthenticated) {
      if (isAuthRoute) {
        switch (authState.user.role) {
          case UserRole.admin:
            return Routes.adminHome;
          case UserRole.manager:
            return Routes.managerMyTasks;
          case UserRole.employee:
            return Routes.employeeTasks;
        }
      }

      // Role-based route protection
      final isAdminRoute = state.matchedLocation.startsWith('/admin');
      final isManagerRoute = state.matchedLocation.startsWith('/manager');
      final isEmployeeRoute = state.matchedLocation.startsWith('/employee');

      if (isAdminRoute && authState.user.role != UserRole.admin) {
        return _getHomeForRole(authState.user.role);
      }
      if (isManagerRoute && authState.user.role != UserRole.manager) {
        return _getHomeForRole(authState.user.role);
      }
      if (isEmployeeRoute && authState.user.role != UserRole.employee) {
        return _getHomeForRole(authState.user.role);
      }
    }

    return null;
  }

  static String _getHomeForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Routes.adminHome;
      case UserRole.manager:
        return Routes.managerMyTasks;
      case UserRole.employee:
        return Routes.employeeTasks;
    }
  }
}
