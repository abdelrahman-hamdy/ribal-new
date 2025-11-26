import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../app/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/buttons/ribal_button.dart';
import '../../../../../core/widgets/feedback/empty_state.dart';
import '../../../../../core/widgets/inputs/ribal_text_field.dart';
import '../../../../../data/models/user_model.dart';
import '../../../../../data/models/whitelist_model.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../auth/bloc/auth_bloc.dart';
import '../bloc/whitelist_bloc.dart';

class WhitelistPage extends StatelessWidget {
  const WhitelistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<WhitelistBloc>()..add(const WhitelistLoadRequested()),
      child: const _WhitelistPageContent(),
    );
  }
}

class _WhitelistPageContent extends StatelessWidget {
  const _WhitelistPageContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.whitelist_title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: _SearchField(),
          ),
        ),
      ),
      body: BlocConsumer<WhitelistBloc, WhitelistState>(
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
          if (state.isLoading && state.entries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.filteredEntries.isEmpty) {
            if (state.searchQuery.isNotEmpty) {
              return EmptyState(
                icon: Icons.search_off,
                title: l10n.common_no_results,
                message: l10n.whitelist_noEntriesMatchingSearch(state.searchQuery),
              );
            }
            return EmptyState(
              icon: Icons.verified_user_outlined,
              title: l10n.whitelist_noEntries,
              message: l10n.whitelist_description,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<WhitelistBloc>().add(const WhitelistLoadRequested());
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: state.filteredEntries.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final entry = state.filteredEntries[index];
                return _WhitelistEntryCard(entry: entry);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<WhitelistBloc>(),
        child: _AddWhitelistDialog(
          onAdd: (email, role) {
            final authState = context.read<AuthBloc>().state;
            final userId = authState is AuthAuthenticated ? authState.user.id : '';

            if (userId.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.common_errorUserNotFound),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }

            context.read<WhitelistBloc>().add(
              WhitelistAddRequested(
                email: email,
                role: role,
                addedBy: userId,
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
          context.read<WhitelistBloc>().add(const WhitelistSearchCleared());
        } else {
          context.read<WhitelistBloc>().add(WhitelistSearchRequested(query: value));
        }
      },
      decoration: InputDecoration(
        hintText: l10n.whitelist_searchHint,
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

class _WhitelistEntryCard extends StatelessWidget {
  final WhitelistModel entry;

  const _WhitelistEntryCard({required this.entry});

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
    final locale = Localizations.localeOf(context).languageCode;
    final roleColor = AppColors.getRoleColor(entry.role.name);
    final roleSurfaceColor = AppColors.getRoleSurfaceColor(entry.role.name);
    final dateFormat = DateFormat('dd/MM/yyyy', locale);

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: roleSurfaceColor,
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Icon(
              Icons.person_outline,
              color: roleColor,
              size: AppSpacing.iconLg,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.email,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Container(
                      padding: AppSpacing.chipPadding,
                      decoration: BoxDecoration(
                        color: roleSurfaceColor,
                        borderRadius: AppSpacing.borderRadiusFull,
                      ),
                      child: Text(
                        _getRoleDisplayName(l10n, entry.role),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: roleColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      dateFormat.format(entry.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: entry.email));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.whitelist_emailCopied),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: l10n.common_copy,
                color: context.colors.textSecondary,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () => _confirmDelete(context),
                tooltip: l10n.common_delete,
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.common_confirmDelete),
        content: Text(l10n.whitelist_deleteConfirmMessage(entry.email)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<WhitelistBloc>().add(
                WhitelistRemoveRequested(entryId: entry.id),
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

class _AddWhitelistDialog extends StatefulWidget {
  final void Function(String email, UserRole role) onAdd;

  const _AddWhitelistDialog({required this.onAdd});

  @override
  State<_AddWhitelistDialog> createState() => _AddWhitelistDialogState();
}

class _AddWhitelistDialogState extends State<_AddWhitelistDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  UserRole _selectedRole = UserRole.employee;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<WhitelistBloc, WhitelistState>(
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
                  l10n.whitelist_addTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                // Email field
                RibalTextField(
                  controller: _emailController,
                  label: l10n.whitelist_emailLabel,
                  hint: l10n.whitelist_emailHint,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.whitelist_emailRequired;
                    }
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return l10n.whitelist_emailInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                // Role selection
                Text(
                  l10n.whitelist_role,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: context.colors.border),
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                  child: Column(
                    children: [
                      _RoleOption(
                        role: UserRole.employee,
                        isSelected: _selectedRole == UserRole.employee,
                        onTap: () => setState(() => _selectedRole = UserRole.employee),
                        isFirst: true,
                      ),
                      const Divider(height: 1),
                      _RoleOption(
                        role: UserRole.manager,
                        isSelected: _selectedRole == UserRole.manager,
                        onTap: () => setState(() => _selectedRole = UserRole.manager),
                      ),
                      const Divider(height: 1),
                      _RoleOption(
                        role: UserRole.admin,
                        isSelected: _selectedRole == UserRole.admin,
                        onTap: () => setState(() => _selectedRole = UserRole.admin),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Submit button
                RibalButton(
                  text: l10n.common_add,
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
      widget.onAdd(_emailController.text.trim(), _selectedRole);
    }
  }
}

class _RoleOption extends StatelessWidget {
  final UserRole role;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const _RoleOption({
    required this.role,
    required this.isSelected,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
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

  String _getRoleDescription(AppLocalizations l10n, UserRole role) {
    switch (role) {
      case UserRole.admin:
        return l10n.whitelist_roleAdminDesc;
      case UserRole.manager:
        return l10n.whitelist_roleManagerDesc;
      case UserRole.employee:
        return l10n.whitelist_roleEmployeeDesc;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final roleColor = AppColors.getRoleColor(role.name);
    final roleSurfaceColor = AppColors.getRoleSurfaceColor(role.name);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(AppSpacing.radiusMd) : Radius.zero,
        bottom: isLast ? const Radius.circular(AppSpacing.radiusMd) : Radius.zero,
      ),
      child: Container(
        padding: AppSpacing.listItemPadding,
        decoration: BoxDecoration(
          color: isSelected ? roleSurfaceColor : null,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(AppSpacing.radiusMd) : Radius.zero,
            bottom: isLast ? const Radius.circular(AppSpacing.radiusMd) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? roleColor : context.colors.surfaceVariant,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Icon(
                _getRoleIcon(),
                color: isSelected ? AppColors.textOnPrimary : context.colors.textSecondary,
                size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getRoleDisplayName(l10n, role),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? roleColor : context.colors.textPrimary,
                    ),
                  ),
                  Text(
                    _getRoleDescription(l10n, role),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: roleColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getRoleIcon() {
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
