import 'package:flutter/material.dart';

/// Ribal app color palette
///
/// Usage: AppColors.primary, AppColors.success, etc.
/// Never hardcode color values - always use this class.
///
/// For theme-aware colors (background, surface, text), use:
/// - context.colors.background
/// - context.colors.surface
/// - context.colors.textPrimary
/// etc.
abstract final class AppColors {
  // ============================================
  // PRIMARY COLORS (Theme-independent - same in light/dark)
  // ============================================

  /// Primary brand color - Professional Blue
  static const Color primary = Color(0xFF2563EB);

  /// Lighter shade of primary
  static const Color primaryLight = Color(0xFF3B82F6);

  /// Darker shade of primary
  static const Color primaryDark = Color(0xFF1D4ED8);

  /// Very light primary for backgrounds (light mode)
  static const Color primarySurface = Color(0xFFEFF6FF);

  /// Dark primary surface for backgrounds (dark mode)
  static const Color primarySurfaceDark = Color(0xFF1E3A5F);

  // ============================================
  // SECONDARY COLORS (Theme-independent)
  // ============================================

  /// Secondary accent color - Warm Amber
  static const Color secondary = Color(0xFFF59E0B);

  /// Lighter shade of secondary
  static const Color secondaryLight = Color(0xFFFBBF24);

  /// Darker shade of secondary
  static const Color secondaryDark = Color(0xFFD97706);

  /// Very light secondary for backgrounds (light mode)
  static const Color secondarySurface = Color(0xFFFFFBEB);

  /// Dark secondary surface (dark mode)
  static const Color secondarySurfaceDark = Color(0xFF4A3728);

  // ============================================
  // SEMANTIC COLORS (Theme-independent)
  // ============================================

  /// Success - Green
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);
  static const Color successSurface = Color(0xFFECFDF5);
  static const Color successSurfaceDark = Color(0xFF1A3A2E);

  /// Error - Red
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorSurface = Color(0xFFFEF2F2);
  static const Color errorSurfaceDark = Color(0xFF3D2626);

  /// Warning - Amber (same as secondary)
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningSurface = Color(0xFFFFFBEB);
  static const Color warningSurfaceDark = Color(0xFF4A3728);

  /// Info - Blue
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);
  static const Color infoSurface = Color(0xFFEFF6FF);
  static const Color infoSurfaceDark = Color(0xFF1E3A5F);

  // ============================================
  // ASSIGNMENT STATUS COLORS (per-user status)
  // ============================================

  /// Pending status - Gray
  static const Color pending = Color(0xFF6B7280);
  static const Color pendingSurface = Color(0xFFF3F4F6);
  static const Color pendingSurfaceDark = Color(0xFF374151);

  /// Completed status - Green (same as success)
  static const Color completed = Color(0xFF10B981);
  static const Color completedSurface = Color(0xFFECFDF5);
  static const Color completedSurfaceDark = Color(0xFF1A3A2E);

  /// Apologized status - Orange
  static const Color apologized = Color(0xFFF59E0B);
  static const Color apologizedSurface = Color(0xFFFFFBEB);
  static const Color apologizedSurfaceDark = Color(0xFF4A3728);

  // ============================================
  // TASK STATUS COLORS (task-level derived status)
  // ============================================

  /// Not started - Gray (all pending)
  static const Color taskNotStarted = Color(0xFF6B7280);
  static const Color taskNotStartedSurface = Color(0xFFF3F4F6);
  static const Color taskNotStartedSurfaceDark = Color(0xFF374151);

  /// In progress - Blue (some completed, some pending)
  static const Color taskInProgress = Color(0xFF3B82F6);
  static const Color taskInProgressSurface = Color(0xFFEFF6FF);
  static const Color taskInProgressSurfaceDark = Color(0xFF1E3A5F);

  /// Completed - Green (100% done)
  static const Color taskCompleted = Color(0xFF10B981);
  static const Color taskCompletedSurface = Color(0xFFECFDF5);
  static const Color taskCompletedSurfaceDark = Color(0xFF1A3A2E);

  /// Partially done - Amber (some completed, rest apologized)
  static const Color taskPartiallyDone = Color(0xFFF59E0B);
  static const Color taskPartiallyDoneSurface = Color(0xFFFFFBEB);
  static const Color taskPartiallyDoneSurfaceDark = Color(0xFF4A3728);

  /// No assignments - Light gray
  static const Color taskNoAssignments = Color(0xFF9CA3AF);
  static const Color taskNoAssignmentsSurface = Color(0xFFF9FAFB);
  static const Color taskNoAssignmentsSurfaceDark = Color(0xFF1F2937);

  // ============================================
  // TASK PROGRESS INDICATOR COLORS (for progress bar segments)
  // ============================================

  /// Pending indicator - Orange
  static const Color progressPending = Color(0xFFF59E0B);
  static const Color progressPendingSurface = Color(0xFFFFFBEB);
  static const Color progressPendingSurfaceDark = Color(0xFF4A3728);

  /// Done indicator - Green
  static const Color progressDone = Color(0xFF10B981);
  static const Color progressDoneSurface = Color(0xFFECFDF5);
  static const Color progressDoneSurfaceDark = Color(0xFF1A3A2E);

  /// Overdue indicator - Red
  static const Color progressOverdue = Color(0xFFEF4444);
  static const Color progressOverdueSurface = Color(0xFFFEF2F2);
  static const Color progressOverdueSurfaceDark = Color(0xFF3D2626);

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
  // NEUTRAL COLORS - LIGHT THEME
  // ============================================

  /// Main background color (light)
  static const Color backgroundLight = Color(0xFFF8FAFC);

  /// Surface color for cards, sheets (light)
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Alternative surface color (light)
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);

  /// Disabled surface (light)
  static const Color surfaceDisabledLight = Color(0xFFE2E8F0);

  // ============================================
  // NEUTRAL COLORS - DARK THEME
  // ============================================

  /// Main background color (dark)
  static const Color backgroundDark = Color(0xFF0F172A);

  /// Surface color for cards, sheets (dark)
  static const Color surfaceDark = Color(0xFF1E293B);

  /// Alternative surface color (dark)
  static const Color surfaceVariantDark = Color(0xFF334155);

  /// Disabled surface (dark)
  static const Color surfaceDisabledDark = Color(0xFF475569);

  // ============================================
  // TEXT COLORS - LIGHT THEME
  // ============================================

  /// Primary text - Darkest (light theme)
  static const Color textPrimaryLight = Color(0xFF1E293B);

  /// Secondary text - Medium (light theme)
  static const Color textSecondaryLight = Color(0xFF64748B);

  /// Tertiary text - Light (light theme)
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  /// Disabled text (light theme)
  static const Color textDisabledLight = Color(0xFFCBD5E1);

  // ============================================
  // TEXT COLORS - DARK THEME
  // ============================================

  /// Primary text - Brightest (dark theme)
  static const Color textPrimaryDark = Color(0xFFF1F5F9);

  /// Secondary text - Medium (dark theme)
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  /// Tertiary text - Dim (dark theme)
  static const Color textTertiaryDark = Color(0xFF64748B);

  /// Disabled text (dark theme)
  static const Color textDisabledDark = Color(0xFF475569);

  /// Text on primary color
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Text on dark backgrounds
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ============================================
  // BORDER & DIVIDER COLORS - LIGHT THEME
  // ============================================

  /// Default border color (light)
  static const Color borderLight = Color(0xFFE2E8F0);

  /// Focused border color
  static const Color borderFocused = Color(0xFF2563EB);

  /// Error border color
  static const Color borderError = Color(0xFFEF4444);

  /// Divider color (light)
  static const Color dividerLight = Color(0xFFF1F5F9);

  // ============================================
  // BORDER & DIVIDER COLORS - DARK THEME
  // ============================================

  /// Default border color (dark)
  static const Color borderDark = Color(0xFF334155);

  /// Divider color (dark)
  static const Color dividerDark = Color(0xFF1E293B);

  // ============================================
  // ROLE COLORS
  // ============================================

  /// Admin role color
  static const Color roleAdmin = Color(0xFF7C3AED);
  static const Color roleAdminSurface = Color(0xFFF5F3FF);
  static const Color roleAdminSurfaceDark = Color(0xFF2D2347);

  /// Manager role color
  static const Color roleManager = Color(0xFF2563EB);
  static const Color roleManagerSurface = Color(0xFFEFF6FF);
  static const Color roleManagerSurfaceDark = Color(0xFF1E3A5F);

  /// Employee role color
  static const Color roleEmployee = Color(0xFF10B981);
  static const Color roleEmployeeSurface = Color(0xFFECFDF5);
  static const Color roleEmployeeSurfaceDark = Color(0xFF1A3A2E);

  // ============================================
  // SHIMMER COLORS (for loading skeletons)
  // ============================================

  static const Color shimmerBaseLight = Color(0xFFE2E8F0);
  static const Color shimmerHighlightLight = Color(0xFFF8FAFC);
  static const Color shimmerBaseDark = Color(0xFF334155);
  static const Color shimmerHighlightDark = Color(0xFF475569);

  // ============================================
  // OVERLAY COLORS
  // ============================================

  /// Black overlay for modals
  static const Color overlayDark = Color(0x80000000);

  /// Light overlay
  static const Color overlayLight = Color(0x0A000000);

  // ============================================
  // LEGACY COMPATIBILITY (for existing code)
  // Maps to light theme values by default
  // Prefer using context.colors.xxx for theme-aware colors
  // ============================================

  /// @deprecated Use context.colors.background instead
  static const Color background = backgroundLight;

  /// @deprecated Use context.colors.surface instead
  static const Color surface = surfaceLight;

  /// @deprecated Use context.colors.surfaceVariant instead
  static const Color surfaceVariant = surfaceVariantLight;

  /// @deprecated Use context.colors.surfaceDisabled instead
  static const Color surfaceDisabled = surfaceDisabledLight;

  /// @deprecated Use context.colors.textPrimary instead
  static const Color textPrimary = textPrimaryLight;

  /// @deprecated Use context.colors.textSecondary instead
  static const Color textSecondary = textSecondaryLight;

  /// @deprecated Use context.colors.textTertiary instead
  static const Color textTertiary = textTertiaryLight;

  /// @deprecated Use context.colors.textDisabled instead
  static const Color textDisabled = textDisabledLight;

  /// @deprecated Use context.colors.border instead
  static const Color border = borderLight;

  /// @deprecated Use context.colors.divider instead
  static const Color divider = dividerLight;

  /// @deprecated Use context.colors.shimmerBase instead
  static const Color shimmerBase = shimmerBaseLight;

  /// @deprecated Use context.colors.shimmerHighlight instead
  static const Color shimmerHighlight = shimmerHighlightLight;

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
  static Color getStatusSurfaceColor(String status, {bool isDark = false}) {
    switch (status) {
      case 'pending':
        return isDark ? pendingSurfaceDark : pendingSurface;
      case 'completed':
        return isDark ? completedSurfaceDark : completedSurface;
      case 'apologized':
        return isDark ? apologizedSurfaceDark : apologizedSurface;
      default:
        return isDark ? pendingSurfaceDark : pendingSurface;
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
  static Color getTaskStatusSurfaceColor(String status, {bool isDark = false}) {
    switch (status) {
      case 'not_started':
        return isDark ? taskNotStartedSurfaceDark : taskNotStartedSurface;
      case 'in_progress':
        return isDark ? taskInProgressSurfaceDark : taskInProgressSurface;
      case 'completed':
        return isDark ? taskCompletedSurfaceDark : taskCompletedSurface;
      case 'partially_done':
        return isDark ? taskPartiallyDoneSurfaceDark : taskPartiallyDoneSurface;
      case 'no_assignments':
        return isDark ? taskNoAssignmentsSurfaceDark : taskNoAssignmentsSurface;
      default:
        return isDark ? taskNotStartedSurfaceDark : taskNotStartedSurface;
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
  static Color getRoleSurfaceColor(String role, {bool isDark = false}) {
    switch (role) {
      case 'admin':
        return isDark ? roleAdminSurfaceDark : roleAdminSurface;
      case 'manager':
        return isDark ? roleManagerSurfaceDark : roleManagerSurface;
      case 'employee':
        return isDark ? roleEmployeeSurfaceDark : roleEmployeeSurface;
      default:
        return isDark ? roleEmployeeSurfaceDark : roleEmployeeSurface;
    }
  }
}

// ============================================
// THEME EXTENSION FOR THEME-AWARE COLORS
// ============================================

/// Custom colors that adapt to light/dark theme
/// Access via: context.colors.background, context.colors.textPrimary, etc.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceDisabled,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.border,
    required this.divider,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.primarySurface,
    required this.secondarySurface,
    required this.successSurface,
    required this.errorSurface,
    required this.warningSurface,
    required this.infoSurface,
    required this.pendingSurface,
    required this.completedSurface,
    required this.apologizedSurface,
    required this.taskNotStartedSurface,
    required this.taskInProgressSurface,
    required this.taskCompletedSurface,
    required this.taskPartiallyDoneSurface,
    required this.taskNoAssignmentsSurface,
    required this.progressPendingSurface,
    required this.progressDoneSurface,
    required this.progressOverdueSurface,
    required this.roleAdminSurface,
    required this.roleManagerSurface,
    required this.roleEmployeeSurface,
  });

  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color surfaceDisabled;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color border;
  final Color divider;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color primarySurface;
  final Color secondarySurface;
  final Color successSurface;
  final Color errorSurface;
  final Color warningSurface;
  final Color infoSurface;
  final Color pendingSurface;
  final Color completedSurface;
  final Color apologizedSurface;
  final Color taskNotStartedSurface;
  final Color taskInProgressSurface;
  final Color taskCompletedSurface;
  final Color taskPartiallyDoneSurface;
  final Color taskNoAssignmentsSurface;
  final Color progressPendingSurface;
  final Color progressDoneSurface;
  final Color progressOverdueSurface;
  final Color roleAdminSurface;
  final Color roleManagerSurface;
  final Color roleEmployeeSurface;

  /// Light theme colors
  static const light = AppColorsExtension(
    background: AppColors.backgroundLight,
    surface: AppColors.surfaceLight,
    surfaceVariant: AppColors.surfaceVariantLight,
    surfaceDisabled: AppColors.surfaceDisabledLight,
    textPrimary: AppColors.textPrimaryLight,
    textSecondary: AppColors.textSecondaryLight,
    textTertiary: AppColors.textTertiaryLight,
    textDisabled: AppColors.textDisabledLight,
    border: AppColors.borderLight,
    divider: AppColors.dividerLight,
    shimmerBase: AppColors.shimmerBaseLight,
    shimmerHighlight: AppColors.shimmerHighlightLight,
    primarySurface: AppColors.primarySurface,
    secondarySurface: AppColors.secondarySurface,
    successSurface: AppColors.successSurface,
    errorSurface: AppColors.errorSurface,
    warningSurface: AppColors.warningSurface,
    infoSurface: AppColors.infoSurface,
    pendingSurface: AppColors.pendingSurface,
    completedSurface: AppColors.completedSurface,
    apologizedSurface: AppColors.apologizedSurface,
    taskNotStartedSurface: AppColors.taskNotStartedSurface,
    taskInProgressSurface: AppColors.taskInProgressSurface,
    taskCompletedSurface: AppColors.taskCompletedSurface,
    taskPartiallyDoneSurface: AppColors.taskPartiallyDoneSurface,
    taskNoAssignmentsSurface: AppColors.taskNoAssignmentsSurface,
    progressPendingSurface: AppColors.progressPendingSurface,
    progressDoneSurface: AppColors.progressDoneSurface,
    progressOverdueSurface: AppColors.progressOverdueSurface,
    roleAdminSurface: AppColors.roleAdminSurface,
    roleManagerSurface: AppColors.roleManagerSurface,
    roleEmployeeSurface: AppColors.roleEmployeeSurface,
  );

  /// Dark theme colors
  static const dark = AppColorsExtension(
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    surfaceVariant: AppColors.surfaceVariantDark,
    surfaceDisabled: AppColors.surfaceDisabledDark,
    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
    textTertiary: AppColors.textTertiaryDark,
    textDisabled: AppColors.textDisabledDark,
    border: AppColors.borderDark,
    divider: AppColors.dividerDark,
    shimmerBase: AppColors.shimmerBaseDark,
    shimmerHighlight: AppColors.shimmerHighlightDark,
    primarySurface: AppColors.primarySurfaceDark,
    secondarySurface: AppColors.secondarySurfaceDark,
    successSurface: AppColors.successSurfaceDark,
    errorSurface: AppColors.errorSurfaceDark,
    warningSurface: AppColors.warningSurfaceDark,
    infoSurface: AppColors.infoSurfaceDark,
    pendingSurface: AppColors.pendingSurfaceDark,
    completedSurface: AppColors.completedSurfaceDark,
    apologizedSurface: AppColors.apologizedSurfaceDark,
    taskNotStartedSurface: AppColors.taskNotStartedSurfaceDark,
    taskInProgressSurface: AppColors.taskInProgressSurfaceDark,
    taskCompletedSurface: AppColors.taskCompletedSurfaceDark,
    taskPartiallyDoneSurface: AppColors.taskPartiallyDoneSurfaceDark,
    taskNoAssignmentsSurface: AppColors.taskNoAssignmentsSurfaceDark,
    progressPendingSurface: AppColors.progressPendingSurfaceDark,
    progressDoneSurface: AppColors.progressDoneSurfaceDark,
    progressOverdueSurface: AppColors.progressOverdueSurfaceDark,
    roleAdminSurface: AppColors.roleAdminSurfaceDark,
    roleManagerSurface: AppColors.roleManagerSurfaceDark,
    roleEmployeeSurface: AppColors.roleEmployeeSurfaceDark,
  );

  @override
  AppColorsExtension copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? surfaceDisabled,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? border,
    Color? divider,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? primarySurface,
    Color? secondarySurface,
    Color? successSurface,
    Color? errorSurface,
    Color? warningSurface,
    Color? infoSurface,
    Color? pendingSurface,
    Color? completedSurface,
    Color? apologizedSurface,
    Color? taskNotStartedSurface,
    Color? taskInProgressSurface,
    Color? taskCompletedSurface,
    Color? taskPartiallyDoneSurface,
    Color? taskNoAssignmentsSurface,
    Color? progressPendingSurface,
    Color? progressDoneSurface,
    Color? progressOverdueSurface,
    Color? roleAdminSurface,
    Color? roleManagerSurface,
    Color? roleEmployeeSurface,
  }) {
    return AppColorsExtension(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      surfaceDisabled: surfaceDisabled ?? this.surfaceDisabled,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      primarySurface: primarySurface ?? this.primarySurface,
      secondarySurface: secondarySurface ?? this.secondarySurface,
      successSurface: successSurface ?? this.successSurface,
      errorSurface: errorSurface ?? this.errorSurface,
      warningSurface: warningSurface ?? this.warningSurface,
      infoSurface: infoSurface ?? this.infoSurface,
      pendingSurface: pendingSurface ?? this.pendingSurface,
      completedSurface: completedSurface ?? this.completedSurface,
      apologizedSurface: apologizedSurface ?? this.apologizedSurface,
      taskNotStartedSurface: taskNotStartedSurface ?? this.taskNotStartedSurface,
      taskInProgressSurface: taskInProgressSurface ?? this.taskInProgressSurface,
      taskCompletedSurface: taskCompletedSurface ?? this.taskCompletedSurface,
      taskPartiallyDoneSurface: taskPartiallyDoneSurface ?? this.taskPartiallyDoneSurface,
      taskNoAssignmentsSurface: taskNoAssignmentsSurface ?? this.taskNoAssignmentsSurface,
      progressPendingSurface: progressPendingSurface ?? this.progressPendingSurface,
      progressDoneSurface: progressDoneSurface ?? this.progressDoneSurface,
      progressOverdueSurface: progressOverdueSurface ?? this.progressOverdueSurface,
      roleAdminSurface: roleAdminSurface ?? this.roleAdminSurface,
      roleManagerSurface: roleManagerSurface ?? this.roleManagerSurface,
      roleEmployeeSurface: roleEmployeeSurface ?? this.roleEmployeeSurface,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      surfaceDisabled: Color.lerp(surfaceDisabled, other.surfaceDisabled, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      primarySurface: Color.lerp(primarySurface, other.primarySurface, t)!,
      secondarySurface: Color.lerp(secondarySurface, other.secondarySurface, t)!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      errorSurface: Color.lerp(errorSurface, other.errorSurface, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      infoSurface: Color.lerp(infoSurface, other.infoSurface, t)!,
      pendingSurface: Color.lerp(pendingSurface, other.pendingSurface, t)!,
      completedSurface: Color.lerp(completedSurface, other.completedSurface, t)!,
      apologizedSurface: Color.lerp(apologizedSurface, other.apologizedSurface, t)!,
      taskNotStartedSurface: Color.lerp(taskNotStartedSurface, other.taskNotStartedSurface, t)!,
      taskInProgressSurface: Color.lerp(taskInProgressSurface, other.taskInProgressSurface, t)!,
      taskCompletedSurface: Color.lerp(taskCompletedSurface, other.taskCompletedSurface, t)!,
      taskPartiallyDoneSurface: Color.lerp(taskPartiallyDoneSurface, other.taskPartiallyDoneSurface, t)!,
      taskNoAssignmentsSurface: Color.lerp(taskNoAssignmentsSurface, other.taskNoAssignmentsSurface, t)!,
      progressPendingSurface: Color.lerp(progressPendingSurface, other.progressPendingSurface, t)!,
      progressDoneSurface: Color.lerp(progressDoneSurface, other.progressDoneSurface, t)!,
      progressOverdueSurface: Color.lerp(progressOverdueSurface, other.progressOverdueSurface, t)!,
      roleAdminSurface: Color.lerp(roleAdminSurface, other.roleAdminSurface, t)!,
      roleManagerSurface: Color.lerp(roleManagerSurface, other.roleManagerSurface, t)!,
      roleEmployeeSurface: Color.lerp(roleEmployeeSurface, other.roleEmployeeSurface, t)!,
    );
  }
}

/// Extension to easily access custom colors from BuildContext
extension AppColorsExtensionAccess on BuildContext {
  /// Access theme-aware colors: context.colors.background, context.colors.textPrimary, etc.
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>() ?? AppColorsExtension.light;

  /// Check if current theme is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
