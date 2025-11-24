import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/di/injection.dart';
import '../../../../../app/router/routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/avatar/ribal_avatar.dart';
import '../../../../../core/widgets/feedback/empty_state.dart';
import '../../../../../data/models/user_model.dart';
import '../bloc/users_bloc.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<UsersBloc>()..add(const UsersLoadRequested()),
      child: const _UsersPageContent(),
    );
  }
}

class _UsersPageContent extends StatelessWidget {
  const _UsersPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المستخدمين'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: _SearchField(),
          ),
        ),
      ),
      body: BlocConsumer<UsersBloc, UsersState>(
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
          return Column(
            children: [
              // Stats header
              _StatsHeader(
                total: state.users.length,
                admins: state.adminsCount,
                managers: state.managersCount,
                employees: state.employeesCount,
              ),
              // Filter tabs
              _FilterTabs(currentFilter: state.filterRole),
              // Content
              Expanded(
                child: _buildContent(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, UsersState state) {
    if (state.isLoading && state.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.filteredUsers.isEmpty) {
      if (state.searchQuery.isNotEmpty) {
        return EmptyState(
          icon: Icons.search_off,
          title: 'لا توجد نتائج',
          message: 'لم يتم العثور على مستخدم يطابق "${state.searchQuery}"',
        );
      }
      if (state.filterRole != null) {
        return EmptyState(
          icon: Icons.filter_list_off,
          title: 'لا يوجد مستخدمين',
          message: 'لا يوجد مستخدمين بدور ${state.filterRole!.displayNameAr}',
        );
      }
      return const EmptyState(
        icon: Icons.people_outline,
        title: 'لا يوجد مستخدمين',
        message: 'لم يتم تسجيل أي مستخدمين بعد',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<UsersBloc>().add(const UsersLoadRequested());
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: state.filteredUsers.length,
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final user = state.filteredUsers[index];
          return _UserCard(user: user);
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) {
        if (value.isEmpty) {
          context.read<UsersBloc>().add(const UsersSearchCleared());
        } else {
          context.read<UsersBloc>().add(UsersSearchRequested(query: value));
        }
      },
      decoration: InputDecoration(
        hintText: 'البحث بالاسم أو البريد الإلكتروني...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  final int total;
  final int admins;
  final int managers;
  final int employees;

  const _StatsHeader({
    required this.total,
    required this.admins,
    required this.managers,
    required this.employees,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.primarySurface,
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: 'الإجمالي',
              value: total.toString(),
              color: AppColors.primary,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.border),
          Expanded(
            child: _StatItem(
              label: 'مدراء',
              value: admins.toString(),
              color: AppColors.getRoleColor('admin'),
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.border),
          Expanded(
            child: _StatItem(
              label: 'مشرفين',
              value: managers.toString(),
              color: AppColors.getRoleColor('manager'),
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.border),
          Expanded(
            child: _StatItem(
              label: 'موظفين',
              value: employees.toString(),
              color: AppColors.getRoleColor('employee'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final UserRole? currentFilter;

  const _FilterTabs({this.currentFilter});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          _FilterChip(
            label: 'الكل',
            isSelected: currentFilter == null,
            onTap: () => context.read<UsersBloc>().add(
              const UsersFilterByRoleChanged(role: null),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            label: 'مدراء',
            isSelected: currentFilter == UserRole.admin,
            onTap: () => context.read<UsersBloc>().add(
              const UsersFilterByRoleChanged(role: UserRole.admin),
            ),
            color: AppColors.getRoleColor('admin'),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            label: 'مشرفين',
            isSelected: currentFilter == UserRole.manager,
            onTap: () => context.read<UsersBloc>().add(
              const UsersFilterByRoleChanged(role: UserRole.manager),
            ),
            color: AppColors.getRoleColor('manager'),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            label: 'موظفين',
            isSelected: currentFilter == UserRole.employee,
            onTap: () => context.read<UsersBloc>().add(
              const UsersFilterByRoleChanged(role: UserRole.employee),
            ),
            color: AppColors.getRoleColor('employee'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppSpacing.animationFast,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : AppColors.surfaceVariant,
          borderRadius: AppSpacing.borderRadiusFull,
          border: Border.all(
            color: isSelected ? chipColor : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final roleColor = AppColors.getRoleColor(user.role.name);
    final roleSurfaceColor = AppColors.getRoleSurfaceColor(user.role.name);

    return GestureDetector(
      onTap: () => context.push(Routes.adminUserDetailPath(user.id)),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Avatar - using unified RibalAvatar
            RibalAvatar(
              user: user,
              size: RibalAvatarSize.lg,
            ),
            const SizedBox(width: AppSpacing.md),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: AppSpacing.chipPadding,
                    decoration: BoxDecoration(
                      color: roleSurfaceColor,
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getRoleIcon(user.role),
                          size: 14,
                          color: roleColor,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          user.role.displayNameAr,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: roleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            const Icon(
              Icons.chevron_left,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
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
