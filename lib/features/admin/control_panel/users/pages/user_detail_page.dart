import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../app/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/animated/animated_count.dart';
import '../../../../../core/widgets/avatar/ribal_avatar.dart';
import '../../../../../core/widgets/feedback/empty_state.dart';
import '../../../../../core/widgets/feedback/loading_state.dart';
import '../../../../../data/models/assignment_model.dart';
import '../../../../../data/models/group_model.dart';
import '../../../../../data/models/user_model.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../auth/bloc/auth_bloc.dart';
import '../bloc/user_profile_bloc.dart';

class UserDetailPage extends StatelessWidget {
  final String userId;

  const UserDetailPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final currentUser = authState is AuthAuthenticated ? authState.user : null;
    final currentUserId = currentUser?.id ?? '';
    final currentUserRole = currentUser?.role ?? UserRole.employee;
    final isCurrentUserAdmin = currentUser?.role == UserRole.admin;

    return BlocProvider(
      create: (context) => getIt<UserProfileBloc>()
        ..add(UserProfileLoadRequested(
          userId: userId,
          currentUserId: currentUserId,
          currentUserRole: currentUserRole,
        )),
      child: _UserDetailPageContent(
        isCurrentUserAdmin: isCurrentUserAdmin,
        currentUserId: currentUserId,
        currentUserRole: currentUserRole,
      ),
    );
  }
}

class _UserDetailPageContent extends StatelessWidget {
  final bool isCurrentUserAdmin;
  final String currentUserId;
  final UserRole currentUserRole;

  const _UserDetailPageContent({
    required this.isCurrentUserAdmin,
    required this.currentUserId,
    required this.currentUserRole,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile_title),
      ),
      body: BlocConsumer<UserProfileBloc, UserProfileState>(
        listenWhen: (previous, current) {
          // Only trigger listener when messages change from null to a value
          return (previous.errorMessage == null && current.errorMessage != null) ||
              (previous.successMessage == null && current.successMessage != null);
        },
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.user == null) {
            return LoadingState(message: l10n.user_loadingProfile);
          }

          if (state.user == null) {
            return EmptyState(
              icon: Icons.person_off,
              title: l10n.user_notFound,
              message: l10n.user_notFoundMessage,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<UserProfileBloc>().add(UserProfileLoadRequested(
                    userId: state.userId!,
                    currentUserId: state.currentUserId!,
                    currentUserRole: currentUserRole,
                  ));
            },
            child: ListView(
              padding: AppSpacing.pagePadding,
              children: [
                // User header with avatar
                _UserHeader(user: state.user!),
                const SizedBox(height: AppSpacing.xl),

                // Admin actions (only shown for admins viewing non-admin users)
                if (isCurrentUserAdmin &&
                    state.user!.role != UserRole.admin &&
                    state.user!.id != currentUserId)
                  _AdminActionsSection(
                    user: state.user!,
                    isLoading: state.isRoleConversionLoading,
                    allGroups: state.allGroups,
                    isGroupsLoading: state.isGroupsLoading,
                  ),
                if (isCurrentUserAdmin &&
                    state.user!.role != UserRole.admin &&
                    state.user!.id != currentUserId)
                  const SizedBox(height: AppSpacing.xl),

                // Stats section with time filter
                _StatsSection(
                  stats: state.stats,
                  timeFilter: state.timeFilter,
                  isLoading: state.isLoadingStats,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Today's assignments
                _TodayAssignmentsSection(
                  assignments: state.todayAssignments,
                  isLoading: state.isLoadingAssignments,
                  canMarkDone: state.canMarkDone,
                  loadingAssignmentId: state.loadingAssignmentId,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  final UserModel user;

  const _UserHeader({required this.user});

  String _getRoleDisplayName(AppLocalizations l10n, UserRole role) {
    switch (role) {
      case UserRole.admin:
        return l10n.user_roleAdmin;
      case UserRole.manager:
        return l10n.user_roleManager;
      case UserRole.employee:
        return l10n.user_roleEmployee;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Avatar
        RibalAvatar(
          user: user,
          size: RibalAvatarSize.xxl,
          showBorder: true,
        ),
        const SizedBox(height: AppSpacing.md),

        // Name
        Text(
          user.fullName,
          style: AppTypography.headlineMedium.copyWith(
            color: context.colors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),

        // Email
        Text(
          user.email,
          style: AppTypography.bodyMedium.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Role badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.smd,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.getRoleSurfaceColor(user.role.name),
            borderRadius: AppSpacing.borderRadiusFull,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getRoleIcon(user.role),
                size: 16,
                color: AppColors.getRoleColor(user.role.name),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                _getRoleDisplayName(l10n, user.role),
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.getRoleColor(user.role.name),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.manager:
        return Icons.manage_accounts;
      case UserRole.employee:
        return Icons.person;
    }
  }
}

class _StatsSection extends StatelessWidget {
  final dynamic stats;
  final TimeFilter timeFilter;
  final bool isLoading;

  const _StatsSection({
    required this.stats,
    required this.timeFilter,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with filter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.stats_statistics,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            _TimeFilterDropdown(currentFilter: timeFilter),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Stats cards - always show with animated counts
        _StatsGrid(stats: stats, isLoading: isLoading),
      ],
    );
  }
}

class _TimeFilterDropdown extends StatelessWidget {
  final TimeFilter currentFilter;

  const _TimeFilterDropdown({required this.currentFilter});

  String _getFilterDisplayName(AppLocalizations l10n, TimeFilter filter) {
    switch (filter) {
      case TimeFilter.today:
        return l10n.timeFilter_today;
      case TimeFilter.week:
        return l10n.timeFilter_thisWeek;
      case TimeFilter.month:
        return l10n.timeFilter_thisMonth;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smd,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: context.colors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TimeFilter>(
          value: currentFilter,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          items: TimeFilter.values.map((filter) {
            return DropdownMenuItem(
              value: filter,
              child: Text(
                _getFilterDisplayName(l10n, filter),
                style: AppTypography.labelMedium,
              ),
            );
          }).toList(),
          onChanged: (filter) {
            if (filter != null) {
              context.read<UserProfileBloc>().add(
                    UserProfileTimeFilterChanged(filter: filter),
                  );
            }
          },
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final dynamic stats;
  final bool isLoading;

  const _StatsGrid({required this.stats, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalAssignments = stats?.totalAssignments ?? 0;
    final completedAssignments = stats?.completedAssignments ?? 0;
    final apologizedAssignments = stats?.apologizedAssignments ?? 0;
    final completionRate = (stats?.completionRate ?? 0.0) as double;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: l10n.stats_totalTasks,
                  count: totalAssignments,
                  color: AppColors.primary,
                  icon: Icons.assignment,
                  isLoading: isLoading,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  label: l10n.stats_completed,
                  count: completedAssignments,
                  color: AppColors.success,
                  icon: Icons.check_circle,
                  isLoading: isLoading,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: l10n.stats_apologized,
                  count: apologizedAssignments,
                  color: AppColors.error,
                  icon: Icons.cancel,
                  isLoading: isLoading,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  label: l10n.stats_completionRate,
                  count: completionRate.toInt(),
                  suffix: '%',
                  color: AppColors.info,
                  icon: Icons.trending_up,
                  isLoading: isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final bool isLoading;
  final String? suffix;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    required this.isLoading,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final valueStyle = AppTypography.headlineSmall.copyWith(
      color: color,
      fontWeight: FontWeight.bold,
    );

    return Container(
      padding: AppSpacing.cardPaddingSm,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedStatCount(
                  isLoading: isLoading,
                  count: count,
                  style: valueStyle,
                  suffix: suffix,
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

class _TodayAssignmentsSection extends StatelessWidget {
  final List<AssignmentWithTask> assignments;
  final bool isLoading;
  final bool Function(AssignmentWithTask) canMarkDone;
  final String? loadingAssignmentId;

  const _TodayAssignmentsSection({
    required this.assignments,
    required this.isLoading,
    required this.canMarkDone,
    this.loadingAssignmentId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.task_todayAssignments,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: context.colors.primarySurface,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              child: AnimatedStatCount(
                isLoading: isLoading,
                count: assignments.length,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        if (isLoading)
          Skeletonizer(
            enabled: true,
            enableSwitchAnimation: true,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) => const _AssignmentCardSkeleton(),
            ),
          )
        else if (assignments.isEmpty)
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: context.colors.surfaceVariant,
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                  size: 32,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.task_noTasksToday,
                        style: AppTypography.titleMedium.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                      Text(
                        l10n.task_noTasksTodaySubtitle,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assignments.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final assignment = assignments[index];
              return _AssignmentCard(
                assignment: assignment,
                canMarkDone: canMarkDone(assignment),
                isLoading: loadingAssignmentId == assignment.assignment.id,
              );
            },
          ),
      ],
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final AssignmentWithTask assignment;
  final bool canMarkDone;
  final bool isLoading;

  const _AssignmentCard({
    required this.assignment,
    required this.canMarkDone,
    this.isLoading = false,
  });

  Color _getStatusColor(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.completed:
        return AppColors.success;
      case AssignmentStatus.pending:
        return AppColors.warning;
      case AssignmentStatus.apologized:
      case AssignmentStatus.overdue:
        return AppColors.error;
    }
  }

  String _getStatusDisplayName(AppLocalizations l10n, AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.pending:
        return l10n.assignment_statusPending;
      case AssignmentStatus.completed:
        return l10n.assignment_statusCompleted;
      case AssignmentStatus.apologized:
        return l10n.assignment_statusApologized;
      case AssignmentStatus.overdue:
        return l10n.assignment_statusOverdue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = assignment.assignment.status;
    final statusColor = _getStatusColor(status);
    final isCompleted = status == AssignmentStatus.completed;
    final canShowMarkDone = !isCompleted && canMarkDone;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          // Main row: Task info and mark done button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge (moved to top)
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          _getStatusDisplayName(l10n, status),
                          style: AppTypography.bodySmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (assignment.assignment.isCompletedByCreator) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            l10n.assignment_byAdmin,
                            style: AppTypography.bodySmall.copyWith(
                              color: context.colors.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    // Task title
                    Text(
                      assignment.taskTitle,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Task description
                    if (assignment.taskDescription.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        assignment.taskDescription,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.colors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    // Task creator (moved to bottom)
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: context.colors.textTertiary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          assignment.taskCreatorName,
                          style: AppTypography.bodySmall.copyWith(
                            color: context.colors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Mark done button (inline with task info)
              if (canShowMarkDone) ...[
                const SizedBox(width: AppSpacing.md),
                GestureDetector(
                  onTap: isLoading
                      ? null
                      : () {
                          context.read<UserProfileBloc>().add(
                                UserProfileMarkAssignmentDone(
                                  assignmentId: assignment.assignment.id,
                                ),
                              );
                        },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.smd,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check, size: 16, color: Colors.white),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                l10n.common_done,
                                style: AppTypography.labelMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton template for assignment card
class _AssignmentCardSkeleton extends StatelessWidget {
  const _AssignmentCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: context.colors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Bone.text(words: 3)),
              SizedBox(width: AppSpacing.sm),
              Bone(width: 60, height: 24),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Bone.text(words: 6, fontSize: 12),
          SizedBox(height: AppSpacing.smd),
          Bone(width: double.infinity, height: 40),
        ],
      ),
    );
  }
}

/// Admin actions section for role conversion and group assignment
class _AdminActionsSection extends StatelessWidget {
  final UserModel user;
  final bool isLoading;
  final List<GroupModel> allGroups;
  final bool isGroupsLoading;

  const _AdminActionsSection({
    required this.user,
    required this.isLoading,
    required this.allGroups,
    required this.isGroupsLoading,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.admin_adminActions,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            children: [
              // Role conversion action
              _AdminActionButton(
                icon: Icons.swap_horiz,
                iconColor: AppColors.warning,
                title: user.role == UserRole.employee
                    ? l10n.user_promoteToManager
                    : l10n.user_demoteToEmployee,
                subtitle: user.role == UserRole.employee
                    ? l10n.user_promoteDescription
                    : l10n.user_demoteDescription,
                isLoading: isLoading,
                onTap: () => _showRoleConversionDialog(context),
              ),

              // Group assignment action (only for managers)
              if (user.role == UserRole.manager) ...[
                const Divider(height: AppSpacing.lg),
                _AdminActionButton(
                  icon: Icons.group_work,
                  iconColor: AppColors.info,
                  title: l10n.user_manageGroups,
                  subtitle: user.canAssignToAll
                      ? l10n.user_canAssignAll
                      : user.managedGroupIds.isEmpty
                          ? l10n.user_noManagedGroups
                          : l10n.user_managesGroups(user.managedGroupIds.length),
                  isLoading: isGroupsLoading,
                  onTap: () => _showGroupAssignmentDialog(context),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showRoleConversionDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final newRole =
        user.role == UserRole.employee ? UserRole.manager : UserRole.employee;
    final newRoleName = newRole == UserRole.manager
        ? l10n.user_roleManager
        : l10n.user_roleEmployee;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.user_changeRoleTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.user_changeRoleConfirm(user.fullName, newRoleName)),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: AppSpacing.cardPaddingSm,
              decoration: BoxDecoration(
                color: AppColors.warningSurface,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      newRole == UserRole.manager
                          ? l10n.user_promoteWarning
                          : l10n.user_demoteWarning,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<UserProfileBloc>().add(
                        UserProfileRoleConversionRequested(
                          userId: user.id,
                          newRole: newRole,
                        ),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.smd),
                ),
                child: Text(l10n.common_confirm),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.smd),
                  ),
                  child: Text(l10n.common_cancel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showGroupAssignmentDialog(BuildContext context) {
    // Load groups if not already loaded
    if (allGroups.isEmpty && !isGroupsLoading) {
      context.read<UserProfileBloc>().add(const UserProfileGroupsLoadRequested());
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: context.read<UserProfileBloc>(),
        child: _GroupAssignmentBottomSheet(user: user),
      ),
    );
  }
}

/// Admin action button widget
class _AdminActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isLoading;
  final VoidCallback onTap;

  const _AdminActionButton({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: AppSpacing.borderRadiusSm,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.smd),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                color: context.colors.textSecondary,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}

/// Group assignment bottom sheet
class _GroupAssignmentBottomSheet extends StatefulWidget {
  final UserModel user;

  const _GroupAssignmentBottomSheet({required this.user});

  @override
  State<_GroupAssignmentBottomSheet> createState() =>
      _GroupAssignmentBottomSheetState();
}

class _GroupAssignmentBottomSheetState
    extends State<_GroupAssignmentBottomSheet> {
  late List<String> _selectedGroupIds;
  late bool _canAssignToAll;

  @override
  void initState() {
    super.initState();
    _selectedGroupIds = List.from(widget.user.managedGroupIds);
    _canAssignToAll = widget.user.canAssignToAll;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: AppSpacing.smd),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.user_manageGroupsFor(widget.user.fullName),
                            style: AppTypography.titleLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Content
                  Expanded(
                    child: state.isGroupsLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            children: [
                              // Can assign to all toggle
                              SwitchListTile(
                                value: _canAssignToAll,
                                onChanged: (value) {
                                  setState(() {
                                    _canAssignToAll = value;
                                    if (value) {
                                      _selectedGroupIds.clear();
                                    }
                                  });
                                },
                                title: Text(l10n.user_assignToAllEmployees),
                                subtitle: Text(l10n.user_assignToAllDescription),
                                activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                                activeColor: AppColors.primary,
                              ),
                              if (!_canAssignToAll) ...[
                                const Divider(height: AppSpacing.xl),
                                Text(
                                  l10n.user_selectGroups,
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: context.colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                if (state.allGroups.isEmpty)
                                  Container(
                                    padding: AppSpacing.cardPadding,
                                    decoration: BoxDecoration(
                                      color: context.colors.surfaceVariant,
                                      borderRadius: AppSpacing.borderRadiusSm,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: context.colors.textSecondary,
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Text(l10n.user_noGroupsAvailable),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  ...state.allGroups.map((group) {
                                    final isSelected =
                                        _selectedGroupIds.contains(group.id);
                                    return CheckboxListTile(
                                      value: isSelected,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedGroupIds.add(group.id);
                                          } else {
                                            _selectedGroupIds.remove(group.id);
                                          }
                                        });
                                      },
                                      title: Text(group.name),
                                      activeColor: AppColors.primary,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    );
                                  }),
                              ],
                            ],
                          ),
                  ),
                  // Save button
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.isRoleConversionLoading
                              ? null
                              : () {
                                  context.read<UserProfileBloc>().add(
                                        UserProfileManagerGroupsUpdated(
                                          userId: widget.user.id,
                                          groupIds: _selectedGroupIds,
                                          canAssignToAll: _canAssignToAll,
                                        ),
                                      );
                                  Navigator.pop(context);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppSpacing.borderRadiusSm,
                            ),
                          ),
                          child: state.isRoleConversionLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(l10n.common_saveChanges),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
