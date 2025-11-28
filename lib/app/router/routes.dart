/// Route path constants
abstract final class Routes {
  // ============================================
  // AUTH ROUTES
  // ============================================

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String forgotPassword = '/forgot-password';

  // ============================================
  // ADMIN ROUTES
  // ============================================

  static const String adminHome = '/admin';
  static const String adminStatistics = '/admin/statistics';

  // Admin - Control Panel
  static const String adminControlPanel = '/admin/control-panel';
  static const String adminUsers = '/admin/control-panel/users';
  static const String adminUserDetail = '/admin/control-panel/users/:userId';
  static const String adminGroups = '/admin/control-panel/groups';
  static const String adminLabels = '/admin/control-panel/labels';
  static const String adminWhitelist = '/admin/control-panel/whitelist';
  static const String adminInvitations = '/admin/control-panel/invitations';
  static const String adminSettings = '/admin/control-panel/settings';

  // Admin - Tasks
  static const String adminTasks = '/admin/tasks';
  static const String adminTaskCreate = '/admin/tasks/create';
  static const String adminTaskDetail = '/admin/tasks/:taskId';
  static const String adminTaskEdit = '/admin/tasks/:taskId/edit';
  static const String adminArchive = '/admin/archive';

  // Admin - Profile
  static const String adminProfile = '/admin/profile';

  // ============================================
  // MANAGER ROUTES
  // ============================================

  static const String managerMyTasks = '/manager';
  static const String managerAssignmentDetail = '/manager/assignments/:assignmentId';
  static const String managerTeamTasks = '/manager/team';
  static const String managerTaskCreate = '/manager/team/create';
  static const String managerTaskDetail = '/manager/team/:taskId';
  static const String managerTaskEdit = '/manager/team/:taskId/edit';
  static const String managerProfile = '/manager/profile';

  // ============================================
  // EMPLOYEE ROUTES
  // ============================================

  static const String employeeTasks = '/employee';
  static const String employeeAssignmentDetail = '/employee/assignments/:assignmentId';
  static const String employeeProfile = '/employee/profile';

  // ============================================
  // SHARED ROUTES
  // ============================================

  static const String notifications = '/notifications';

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get admin user detail route
  static String adminUserDetailPath(String userId) =>
      '/admin/control-panel/users/$userId';

  /// Get admin task detail route
  static String adminTaskDetailPath(String taskId) =>
      '/admin/tasks/$taskId';

  /// Get admin task edit route
  static String adminTaskEditPath(String taskId) =>
      '/admin/tasks/$taskId/edit';

  /// Get manager assignment detail route
  static String managerAssignmentDetailPath(String assignmentId) =>
      '/manager/assignments/$assignmentId';

  /// Get manager task detail route
  static String managerTaskDetailPath(String taskId) =>
      '/manager/team/$taskId';

  /// Get manager task edit route
  static String managerTaskEditPath(String taskId) =>
      '/manager/team/$taskId/edit';

  /// Get employee assignment detail route
  static String employeeAssignmentDetailPath(String assignmentId) =>
      '/employee/assignments/$assignmentId';
}

/// Route names for named navigation
abstract final class RouteNames {
  // Auth
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String verifyEmail = 'verify-email';
  static const String forgotPassword = 'forgot-password';

  // Admin
  static const String adminHome = 'admin-home';
  static const String adminStatistics = 'admin-statistics';
  static const String adminControlPanel = 'admin-control-panel';
  static const String adminUsers = 'admin-users';
  static const String adminUserDetail = 'admin-user-detail';
  static const String adminGroups = 'admin-groups';
  static const String adminLabels = 'admin-labels';
  static const String adminWhitelist = 'admin-whitelist';
  static const String adminInvitations = 'admin-invitations';
  static const String adminSettings = 'admin-settings';
  static const String adminTasks = 'admin-tasks';
  static const String adminTaskCreate = 'admin-task-create';
  static const String adminTaskDetail = 'admin-task-detail';
  static const String adminTaskEdit = 'admin-task-edit';
  static const String adminArchive = 'admin-archive';
  static const String adminProfile = 'admin-profile';

  // Manager
  static const String managerMyTasks = 'manager-my-tasks';
  static const String managerAssignmentDetail = 'manager-assignment-detail';
  static const String managerTeamTasks = 'manager-team-tasks';
  static const String managerTaskCreate = 'manager-task-create';
  static const String managerTaskDetail = 'manager-task-detail';
  static const String managerTaskEdit = 'manager-task-edit';
  static const String managerProfile = 'manager-profile';

  // Employee
  static const String employeeTasks = 'employee-tasks';
  static const String employeeAssignmentDetail = 'employee-assignment-detail';
  static const String employeeProfile = 'employee-profile';

  // Shared
  static const String notifications = 'notifications';
}
