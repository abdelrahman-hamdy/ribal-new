import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../app/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/avatar/ribal_avatar.dart';
import '../../../../../core/widgets/buttons/ribal_button.dart';
import '../../../../../core/widgets/feedback/empty_state.dart';
import '../../../../../core/widgets/inputs/ribal_text_field.dart';
import '../../../../../data/models/group_model.dart';
import '../../../../../data/models/user_model.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../auth/bloc/auth_bloc.dart';
import '../bloc/groups_bloc.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<GroupsBloc>()..add(const GroupsLoadRequested()),
      child: const _GroupsPageContent(),
    );
  }
}

class _GroupsPageContent extends StatelessWidget {
  const _GroupsPageContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.group_title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: _SearchField(),
          ),
        ),
      ),
      body: BlocConsumer<GroupsBloc, GroupsState>(
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
          if (state.isLoading && state.groups.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.filteredGroups.isEmpty) {
            if (state.searchQuery.isNotEmpty) {
              return EmptyState(
                icon: Icons.search_off,
                title: l10n.common_no_results,
                message: l10n.group_noGroupsMatchingSearch(state.searchQuery),
              );
            }
            return EmptyState(
              icon: Icons.group_work_outlined,
              title: l10n.group_noGroups,
              message: l10n.group_noGroupsSubtitle,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<GroupsBloc>().add(const GroupsLoadRequested());
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: state.filteredGroups.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final group = state.filteredGroups[index];
                final memberCount = state.getMemberCount(group.id);
                return _GroupCard(group: group, memberCount: memberCount);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<GroupsBloc>(),
        child: _GroupFormDialog(
          onSubmit: (name) {
            final authState = context.read<AuthBloc>().state;
            final userId =
                authState is AuthAuthenticated ? authState.user.id : '';

            if (userId.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.common_errorUserNotFound),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }

            context.read<GroupsBloc>().add(
                  GroupCreateRequested(
                    name: name,
                    createdBy: userId,
                  ),
                );
          },
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      onChanged: (value) {
        if (value.isEmpty) {
          context.read<GroupsBloc>().add(const GroupsSearchCleared());
        } else {
          context.read<GroupsBloc>().add(GroupsSearchRequested(query: value));
        }
      },
      decoration: InputDecoration(
        hintText: l10n.group_searchHint,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: context.colors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupModel group;
  final int memberCount;

  const _GroupCard({required this.group, required this.memberCount});

  String _getMemberCountText(AppLocalizations l10n, int count) {
    return '$count ${count == 1 ? l10n.common_member : l10n.common_members}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('yyyy/MM/dd');

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 14,
                      color: context.colors.textTertiary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _getMemberCountText(l10n, memberCount),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: context.colors.textTertiary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      dateFormat.format(group.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.colors.textTertiary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.person_add_outlined, size: 20),
                onPressed: () => _showMembersDialog(context, group),
                tooltip: l10n.group_manageMembers,
                color: AppColors.success,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => _showEditDialog(context, group),
                tooltip: l10n.common_edit,
                color: AppColors.primary,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () => _confirmDelete(context, group, memberCount),
                tooltip: l10n.common_delete,
                color: AppColors.error,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMembersDialog(BuildContext context, GroupModel group) {
    // Load members and all users before showing dialog
    final bloc = context.read<GroupsBloc>();
    bloc.add(GroupMembersLoadRequested(groupId: group.id));
    bloc.add(const AllUsersLoadRequested());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: _GroupMembersDialog(group: group),
      ),
    );
  }

  void _showEditDialog(BuildContext context, GroupModel group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<GroupsBloc>(),
        child: _GroupFormDialog(
          group: group,
          onSubmit: (name) {
            context.read<GroupsBloc>().add(
                  GroupUpdateRequested(
                    group: GroupModel(
                      id: group.id,
                      name: name,
                      createdBy: group.createdBy,
                      createdAt: group.createdAt,
                    ),
                  ),
                );
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, GroupModel group, int memberCount) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.common_confirmDelete),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.group_deleteConfirm} "${group.name}"?'),
            if (memberCount > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: const BoxDecoration(
                  color: AppColors.warningSurface,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_outlined,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.group_deleteMembers(memberCount),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.warningDark,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<GroupsBloc>().add(
                    GroupDeleteRequested(groupId: group.id),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.common_delete),
          ),
        ],
      ),
    );
  }
}

/// Dialog for managing group members
class _GroupMembersDialog extends StatefulWidget {
  final GroupModel group;

  const _GroupMembersDialog({required this.group});

  @override
  State<_GroupMembersDialog> createState() => _GroupMembersDialogState();
}

class _GroupMembersDialogState extends State<_GroupMembersDialog> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<GroupsBloc, GroupsState>(
      builder: (context, state) {
        // Filter out admins - only show employees and managers
        final members = state
            .getMembers(widget.group.id)
            .where((u) => !u.role.isAdmin)
            .toList();
        final memberIds = members.map((m) => m.id).toSet();

        // Get available users (not in this group, not admins)
        final availableUsers = state.allUsers
            .where((u) =>
                !u.role.isAdmin &&
                !memberIds.contains(u.id) &&
                (u.groupId == null || u.groupId!.isEmpty))
            .toList();

        // Filter by search
        final filteredMembers = _searchQuery.isEmpty
            ? members
            : members
                .where((u) =>
                    u.fullName.toLowerCase().contains(_searchQuery) ||
                    u.email.toLowerCase().contains(_searchQuery))
                .toList();

        final filteredAvailable = _searchQuery.isEmpty
            ? availableUsers
            : availableUsers
                .where((u) =>
                    u.fullName.toLowerCase().contains(_searchQuery) ||
                    u.email.toLowerCase().contains(_searchQuery))
                .toList();

        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: AppSpacing.dialogPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                l10n.group_membersOf(widget.group.name),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              // Search field
              TextField(
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase().trim());
                },
                decoration: InputDecoration(
                  hintText: l10n.group_searchUsers,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: context.colors.surfaceVariant,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Content
              Expanded(
                child: state.isLoadingMembers
                    ? const Center(child: CircularProgressIndicator())
                    : DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            TabBar(
                              tabs: [
                                Tab(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.people, size: 18),
                                      const SizedBox(width: 4),
                                      Text('${l10n.group_showMembers} (${filteredMembers.length})'),
                                    ],
                                  ),
                                ),
                                Tab(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.person_add, size: 18),
                                      const SizedBox(width: 4),
                                      Text('${l10n.common_add} (${filteredAvailable.length})'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  // Current members tab
                                  _buildMembersList(
                                    context,
                                    filteredMembers,
                                    isMember: true,
                                  ),
                                  // Available users tab
                                  _buildMembersList(
                                    context,
                                    filteredAvailable,
                                    isMember: false,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Close button
              RibalButton(
                text: l10n.common_close,
                variant: RibalButtonVariant.outline,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMembersList(
    BuildContext context,
    List<UserModel> users, {
    required bool isMember,
  }) {
    final l10n = AppLocalizations.of(context)!;
    if (users.isEmpty) {
      return Center(
        child: Text(
          isMember ? l10n.group_noMembers : l10n.group_noUsersAvailable,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
        ),
      );
    }

    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, index) {
        final user = users[index];
        return _UserTile(
          user: user,
          isMember: isMember,
          groupId: widget.group.id,
        );
      },
    );
  }
}

/// User tile for member management
class _UserTile extends StatelessWidget {
  final UserModel user;
  final bool isMember;
  final String groupId;

  const _UserTile({
    required this.user,
    required this.isMember,
    required this.groupId,
  });

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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        children: [
          // Avatar using unified RibalAvatar
          RibalAvatar(
            user: user,
            size: RibalAvatarSize.sm,
          ),
          const SizedBox(width: AppSpacing.sm),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.getRoleSurfaceColor(user.role.name),
              borderRadius: AppSpacing.borderRadiusFull,
            ),
            child: Text(
              _getRoleDisplayName(l10n, user.role),
              style: TextStyle(
                color: AppColors.getRoleColor(user.role.name),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Action button
          IconButton(
            icon: Icon(
              isMember ? Icons.remove_circle_outline : Icons.add_circle_outline,
              size: 22,
            ),
            color: isMember ? AppColors.error : AppColors.success,
            onPressed: () {
              if (isMember) {
                context.read<GroupsBloc>().add(
                      GroupMemberRemoveRequested(
                        groupId: groupId,
                        userId: user.id,
                      ),
                    );
              } else {
                context.read<GroupsBloc>().add(
                      GroupMemberAddRequested(
                        groupId: groupId,
                        userId: user.id,
                      ),
                    );
              }
            },
            tooltip: isMember ? l10n.group_removeFromGroup : l10n.group_addToGroup,
          ),
        ],
      ),
    );
  }
}

class _GroupFormDialog extends StatefulWidget {
  final GroupModel? group;
  final void Function(String name) onSubmit;

  const _GroupFormDialog({
    this.group,
    required this.onSubmit,
  });

  @override
  State<_GroupFormDialog> createState() => _GroupFormDialogState();
}

class _GroupFormDialogState extends State<_GroupFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isSubmitting = false;

  bool get _isEditing => widget.group != null;

  @override
  void initState() {
    super.initState();
    if (widget.group != null) {
      _nameController.text = widget.group!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<GroupsBloc, GroupsState>(
      listener: (context, state) {
        if (state.successMessage != null && _isSubmitting) {
          Navigator.pop(context);
        }
        if (state.errorMessage != null) {
          setState(() => _isSubmitting = false);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: AppSpacing.dialogPadding,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    _isEditing ? l10n.group_edit : l10n.group_createNew,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Name field
                  RibalTextField(
                    controller: _nameController,
                    label: l10n.group_name,
                    hint: l10n.group_nameHint,
                    prefixIcon: Icons.group_work_outlined,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.group_nameRequired;
                      }
                      if (value.length < 2) {
                        return l10n.group_nameTooShort;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Submit button
                  RibalButton(
                    text: _isEditing ? l10n.common_saveChanges : l10n.group_create,
                    isLoading: _isSubmitting,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Cancel button
                  RibalButton(
                    text: l10n.common_cancel,
                    variant: RibalButtonVariant.outline,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      widget.onSubmit(_nameController.text.trim());
    }
  }
}
