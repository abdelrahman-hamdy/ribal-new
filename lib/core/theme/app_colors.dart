import 'package:flutter/material.dart';

/// Ribal app color palette
///
/// Usage: AppColors.primary, AppColors.success, etc.
/// Never hardcode color values - always use this class.
abstract final class AppColors {
  // ============================================
  // PRIMARY COLORS
  // ============================================

  /// Primary brand color - Professional Blue
  static const Color primary = Color(0xFF2563EB);

  /// Lighter shade of primary
  static const Color primaryLight = Color(0xFF3B82F6);

  /// Darker shade of primary
  static const Color primaryDark = Color(0xFF1D4ED8);

  /// Very light primary for backgrounds
  static const Color primarySurface = Color(0xFFEFF6FF);

  // ============================================
  // SECONDARY COLORS
  // ============================================

  /// Secondary accent color - Warm Amber
  static const Color secondary = Color(0xFFF59E0B);

  /// Lighter shade of secondary
  static const Color secondaryLight = Color(0xFFFBBF24);

  /// Darker shade of secondary
  static const Color secondaryDark = Color(0xFFD97706);

  /// Very light secondary for backgrounds
  static const Color secondarySurface = Color(0xFFFFFBEB);

  // ============================================
  // SEMANTIC COLORS
  // ============================================

  /// Success - Green
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);
  static const Color successSurface = Color(0xFFECFDF5);

  /// Error - Red
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorSurface = Color(0xFFFEF2F2);

  /// Warning - Amber (same as secondary)
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningSurface = Color(0xFFFFFBEB);

  /// Info - Blue
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);
  static const Color infoSurface = Color(0xFFEFF6FF);

  // ============================================
  // ASSIGNMENT STATUS COLORS (per-user status)
  // ============================================

  /// Pending status - Gray
  static const Color pending = Color(0xFF6B7280);
  static const Color pendingSurface = Color(0xFFF3F4F6);

  /// Completed status - Green (same as success)
  static const Color completed = Color(0xFF10B981);
  static const Color completedSurface = Color(0xFFECFDF5);

  /// Apologized status - Orange
  static const Color apologized = Color(0xFFF59E0B);
  static const Color apologizedSurface = Color(0xFFFFFBEB);

  // ============================================
  // TASK STATUS COLORS (task-level derived status)
  // ============================================

  /// Not started - Gray (all pending)
  static const Color taskNotStarted = Color(0xFF6B7280);
  static const Color taskNotStartedSurface = Color(0xFFF3F4F6);

  /// In progress - Blue (some completed, some pending)
  static const Color taskInProgress = Color(0xFF3B82F6);
  static const Color taskInProgressSurface = Color(0xFFEFF6FF);

  /// Completed - Green (100% done)
  static const Color taskCompleted = Color(0xFF10B981);
  static const Color taskCompletedSurface = Color(0xFFECFDF5);

  /// Partially done - Amber (some completed, rest apologized)
  static const Color taskPartiallyDone = Color(0xFFF59E0B);
  static const Color taskPartiallyDoneSurface = Color(0xFFFFFBEB);

  /// No assignments - Light gray
  static const Color taskNoAssignments = Color(0xFF9CA3AF);
  static const Color taskNoAssignmentsSurface = Color(0xFFF9FAFB);

  // ============================================
  // TASK PROGRESS INDICATOR COLORS (for progress bar segments)
  // ============================================

  /// Pending indicator - Orange
  static const Color progressPending = Color(0xFFF59E0B);
  static const Color progressPendingSurface = Color(0xFFFFFBEB);

  /// Done indicator - Green
  static const Color progressDone = Color(0xFF10B981);
  static const Color progressDoneSurface = Color(0xFFECFDF5);

  /// Overdue indicator - Red
  static const Color progressOverdue = Color(0xFFEF4444);
  static const Color progressOverdueSurface = Color(0xFFFEF2F2);

  // ============================================
  // NOTIFICATION TYPE COLORS
  // ============================================

  static const Color notificationTaskAssigned = Color(0xFF2563EB);    // Blue
  static const Color notificationTaskCompleted = Color(0xFF10B981);   // Green
  static const Color notificationTaskApologized = Color(0xFFF59E0B);  // Orange
  static const Color notificationTaskReactivated = Color(0xFF8B5CF6); // Purple
  static const Color notificationRecurring = Color(0xFF14B8A6);       // Teal
  static const Color notificationInvitation = Color(0xFF6366F1);      // Indigo
  static const Color notificationRoleChanged = Color(0xFFF59E0B);     // Amber

  // ============================================
  // NEUTRAL COLORS
  // ============================================

  /// Main background color
  static const Color background = Color(0xFFF8FAFC);

  /// Surface color for cards, sheets
  static const Color surface = Color(0xFFFFFFFF);

  /// Alternative surface color
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  /// Disabled surface
  static const Color surfaceDisabled = Color(0xFFE2E8F0);

  // ============================================
  // TEXT COLORS
  // ============================================

  /// Primary text - Darkest
  static const Color textPrimary = Color(0xFF1E293B);

  /// Secondary text - Medium
  static const Color textSecondary = Color(0xFF64748B);

  /// Tertiary text - Light
  static const Color textTertiary = Color(0xFF94A3B8);

  /// Disabled text
  static const Color textDisabled = Color(0xFFCBD5E1);

  /// Text on primary color
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Text on dark backgrounds
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ============================================
  // BORDER & DIVIDER COLORS
  // ============================================

  /// Default border color
  static const Color border = Color(0xFFE2E8F0);

  /// Focused border color
  static const Color borderFocused = Color(0xFF2563EB);

  /// Error border color
  static const Color borderError = Color(0xFFEF4444);

  /// Divider color
  static const Color divider = Color(0xFFF1F5F9);

  // ============================================
  // ROLE COLORS
  // ============================================

  /// Admin role color
  static const Color roleAdmin = Color(0xFF7C3AED);
  static const Color roleAdminSurface = Color(0xFFF5F3FF);

  /// Manager role color
  static const Color roleManager = Color(0xFF2563EB);
  static const Color roleManagerSurface = Color(0xFFEFF6FF);

  /// Employee role color
  static const Color roleEmployee = Color(0xFF10B981);
  static const Color roleEmployeeSurface = Color(0xFFECFDF5);

  // ============================================
  // SHIMMER COLORS (for loading skeletons)
  // ============================================

  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);

  // ============================================
  // OVERLAY COLORS
  // ============================================

  /// Black overlay for modals
  static const Color overlayDark = Color(0x80000000);

  /// Light overlay
  static const Color overlayLight = Color(0x0A000000);

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get color for assignment status
  static Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return pending;
      case 'completed':
        return completed;
      case 'apologized':
        return apologized;
      default:
        return pending;
    }
  }

  /// Get surface color for assignment status
  static Color getStatusSurfaceColor(String status) {
    switch (status) {
      case 'pending':
        return pendingSurface;
      case 'completed':
        return completedSurface;
      case 'apologized':
        return apologizedSurface;
      default:
        return pendingSurface;
    }
  }

  /// Get color for task status (task-level derived status)
  static Color getTaskStatusColor(String status) {
    switch (status) {
      case 'not_started':
        return taskNotStarted;
      case 'in_progress':
        return taskInProgress;
      case 'completed':
        return taskCompleted;
      case 'partially_done':
        return taskPartiallyDone;
      case 'no_assignments':
        return taskNoAssignments;
      default:
        return taskNotStarted;
    }
  }

  /// Get surface color for task status
  static Color getTaskStatusSurfaceColor(String status) {
    switch (status) {
      case 'not_started':
        return taskNotStartedSurface;
      case 'in_progress':
        return taskInProgressSurface;
      case 'completed':
        return taskCompletedSurface;
      case 'partially_done':
        return taskPartiallyDoneSurface;
      case 'no_assignments':
        return taskNoAssignmentsSurface;
      default:
        return taskNotStartedSurface;
    }
  }

  /// Get color for user role
  static Color getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return roleAdmin;
      case 'manager':
        return roleManager;
      case 'employee':
        return roleEmployee;
      default:
        return roleEmployee;
    }
  }

  /// Get surface color for user role
  static Color getRoleSurfaceColor(String role) {
    switch (role) {
      case 'admin':
        return roleAdminSurface;
      case 'manager':
        return roleManagerSurface;
      case 'employee':
        return roleEmployeeSurface;
      default:
        return roleEmployeeSurface;
    }
  }
}
