import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../app/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/avatar/ribal_avatar.dart';
import '../../../../../core/widgets/feedback/empty_state.dart';
import '../../../../../core/widgets/feedback/loading_state.dart';
import '../../../../../data/models/assignment_model.dart';
import '../../../../../data/models/group_model.dart';
import '../../../../../data/models/user_model.dart';
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
    final isCurrentUserAdmin = currentUser?.role == UserRole.admin;

    return BlocProvider(
      create: (context) => getIt<UserProfileBloc>()
        ..add(UserProfileLoadRequested(
          userId: userId,
          currentUserId: currentUserId,
        )),
      child: _UserDetailPageContent(
        isCurrentUserAdmin: isCurrentUserAdmin,
        currentUserId: currentUserId,
      ),
    );
  }
}

class _UserDetailPageContent extends StatelessWidget {
  final bool isCurrentUserAdmin;
  final String currentUserId;

  const _UserDetailPageContent({
    required this.isCurrentUserAdmin,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
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
            return const LoadingState(message: 'جاري تحميل الملف الشخصي...');
          }

          if (state.user == null) {
            return const EmptyState(
              icon: Icons.person_off,
              title: 'المستخدم غير موجود',
              message: 'لم يتم العثور على بيانات المستخدم',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<UserProfileBloc>().add(UserProfileLoadRequested(
                    userId: state.userId!,
                    currentUserId: state.currentUserId!,
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

  @override
  Widget build(BuildContext context) {
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
          style: AppTypography.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),

        // Email
        Text(
          user.email,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
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
                user.role.displayNameAr,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with filter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الإحصائيات',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            _TimeFilterDropdown(currentFilter: timeFilter),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Stats cards
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator(),
            ),
          )
        else
          _StatsGrid(stats: stats),
      ],
    );
  }
}

class _TimeFilterDropdown extends StatelessWidget {
  final TimeFilter currentFilter;

  const _TimeFilterDropdown({required this.currentFilter});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smd,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: AppColors.border),
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
                filter.displayNameAr,
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

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final totalAssignments = stats?.totalAssignments ?? 0;
    final completedAssignments = stats?.completedAssignments ?? 0;
    final apologizedAssignments = stats?.apologizedAssignments ?? 0;
    final completionRate = stats?.completionRate ?? 0.0;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'إجمالي المهام',
                  value: totalAssignments.toString(),
                  color: AppColors.primary,
                  icon: Icons.assignment,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  label: 'المكتملة',
                  value: completedAssignments.toString(),
                  color: AppColors.success,
                  icon: Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'معتذر عنها',
                  value: apologizedAssignments.toString(),
                  color: AppColors.warning,
                  icon: Icons.cancel,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  label: 'نسبة الإنجاز',
                  value: '${completionRate.toStringAsFixed(0)}%',
                  color: AppColors.info,
                  icon: Icons.trending_up,
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
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPaddingSm,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTypography.headlineSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'مهام اليوم',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              child: Text(
                assignments.length.toString(),
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
              color: AppColors.surfaceVariant,
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Row(
              children: [
                Icon(
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
                        'لا توجد مهام اليوم',
                        style: AppTypography.titleMedium,
                      ),
                      Text(
                        'لم يتم تعيين أي مهام لهذا اليوم',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
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

  @override
  Widget build(BuildContext context) {
    final status = assignment.assignment.status;
    final statusColor = AppColors.getStatusColor(status.name);
    final statusSurfaceColor = AppColors.getStatusSurfaceColor(status.name);

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  assignment.taskTitle,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: AppSpacing.chipPadding,
                decoration: BoxDecoration(
                  color: statusSurfaceColor,
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Text(
                  status.displayNameAr,
                  style: AppTypography.labelSmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (assignment.taskDescription.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              assignment.taskDescription,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (status == AssignmentStatus.pending && canMarkDone) ...[
            const SizedBox(height: AppSpacing.smd),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading
                    ? null
                    : () {
                        context.read<UserProfileBloc>().add(
                              UserProfileMarkAssignmentDone(
                                assignmentId: assignment.assignment.id,
                              ),
                            );
                      },
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check, size: 18),
                label: isLoading ? const SizedBox.shrink() : const Text('تم'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.success.withValues(alpha: 0.7),
                  disabledForegroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                ),
              ),
            ),
          ],
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
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجراءات المسؤول',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              // Role conversion action
              _AdminActionButton(
                icon: Icons.swap_horiz,
                iconColor: AppColors.warning,
                title: user.role == UserRole.employee
                    ? 'ترقية إلى مشرف'
                    : 'تحويل إلى موظف',
                subtitle: user.role == UserRole.employee
                    ? 'سيتمكن المستخدم من إنشاء المهام وإدارة الفرق'
                    : 'سيفقد المستخدم صلاحيات الإشراف',
                isLoading: isLoading,
                onTap: () => _showRoleConversionDialog(context),
              ),

              // Group assignment action (only for managers)
              if (user.role == UserRole.manager) ...[
                const Divider(height: AppSpacing.lg),
                _AdminActionButton(
                  icon: Icons.group_work,
                  iconColor: AppColors.info,
                  title: 'إدارة المجموعات',
                  subtitle: user.canAssignToAll
                      ? 'يمكنه التعيين لجميع الموظفين'
                      : user.managedGroupIds.isEmpty
                          ? 'لم يتم تعيين مجموعات بعد'
                          : 'يدير ${user.managedGroupIds.length} مجموعة',
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
    final newRole =
        user.role == UserRole.employee ? UserRole.manager : UserRole.employee;
    final newRoleName = newRole == UserRole.manager ? 'مشرف' : 'موظف';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد تغيير الدور'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل تريد تغيير دور ${user.fullName} إلى $newRoleName؟'),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: AppSpacing.cardPaddingSm,
              decoration: BoxDecoration(
                color: AppColors.warningSurface,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      newRole == UserRole.manager
                          ? 'سيتم إزالة المستخدم من مجموعته الحالية وسيتمكن من إنشاء المهام بعد تعيين مجموعات له.'
                          : 'سيفقد المستخدم صلاحيات الإشراف. المهام التي أنشأها ستبقى كما هي.',
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
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
            ),
            child: const Text('تأكيد'),
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
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
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
                Icons.chevron_left,
                color: AppColors.textSecondary,
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
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                      color: AppColors.border,
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
                            'إدارة مجموعات ${widget.user.fullName}',
                            style: AppTypography.titleLarge.copyWith(
                              fontWeight: FontWeight.w600,
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
                                title: const Text('تعيين لجميع الموظفين'),
                                subtitle: const Text(
                                  'السماح للمشرف بتعيين المهام لجميع الموظفين',
                                ),
                                activeColor: AppColors.primary,
                              ),
                              if (!_canAssignToAll) ...[
                                const Divider(height: AppSpacing.xl),
                                Text(
                                  'اختر المجموعات',
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                if (state.allGroups.isEmpty)
                                  Container(
                                    padding: AppSpacing.cardPadding,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceVariant,
                                      borderRadius: AppSpacing.borderRadiusSm,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        const Expanded(
                                          child: Text('لا توجد مجموعات متاحة'),
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
                      color: Colors.white,
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
                              : const Text('حفظ التغييرات'),
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
