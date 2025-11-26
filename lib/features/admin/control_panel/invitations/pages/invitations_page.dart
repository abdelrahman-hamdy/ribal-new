import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../app/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/buttons/ribal_button.dart';
import '../../../../../core/widgets/feedback/empty_state.dart';
import '../../../../../data/models/invitation_model.dart';
import '../../../../../data/models/user_model.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../auth/bloc/auth_bloc.dart';
import '../bloc/invitations_bloc.dart';

class InvitationsPage extends StatelessWidget {
  const InvitationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<InvitationsBloc>()..add(const InvitationsLoadRequested()),
      child: const _InvitationsPageContent(),
    );
  }
}

class _InvitationsPageContent extends StatelessWidget {
  const _InvitationsPageContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.invitation_title),
      ),
      body: BlocConsumer<InvitationsBloc, InvitationsState>(
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
          if (state.isLoading && state.invitations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Stats header
              _StatsHeader(
                total: state.invitations.length,
                used: state.usedCount,
                unused: state.unusedCount,
              ),
              // Filter tabs
              _FilterTabs(currentFilter: state.showUsedOnly),
              // Content
              Expanded(
                child: state.filteredInvitations.isEmpty
                    ? _buildEmptyState(context, state)
                    : RefreshIndicator(
                        onRefresh: () async {
                          context.read<InvitationsBloc>().add(const InvitationsLoadRequested());
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: state.filteredInvitations.length,
                          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final invitation = state.filteredInvitations[index];
                            return _InvitationCard(invitation: invitation);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGenerateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, InvitationsState state) {
    final l10n = AppLocalizations.of(context)!;
    if (state.showUsedOnly == true) {
      return EmptyState(
        icon: Icons.check_circle_outline,
        title: l10n.invitation_noCodesUsed,
        message: l10n.invitation_noCodesUsedSubtitle,
      );
    } else if (state.showUsedOnly == false) {
      return EmptyState(
        icon: Icons.card_giftcard_outlined,
        title: l10n.invitation_noCodesAvailable,
        message: l10n.invitation_noCodesAvailableSubtitle,
      );
    }
    return EmptyState(
      icon: Icons.card_giftcard_outlined,
      title: l10n.invitation_noCodes,
      message: l10n.invitation_noCodesSubtitle,
    );
  }

  void _showGenerateDialog(BuildContext context) {
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
        value: context.read<InvitationsBloc>(),
        child: _GenerateInvitationDialog(
          onGenerate: (role) {
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

            context.read<InvitationsBloc>().add(
              InvitationCreateRequested(
                role: role,
                createdBy: userId,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  final int total;
  final int used;
  final int unused;

  const _StatsHeader({
    required this.total,
    required this.used,
    required this.unused,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: context.colors.primarySurface,
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: l10n.common_total,
              value: total.toString(),
              color: AppColors.primary,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: context.colors.border,
          ),
          Expanded(
            child: _StatItem(
              label: l10n.invitation_statusUsed,
              value: used.toString(),
              color: AppColors.success,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: context.colors.border,
          ),
          Expanded(
            child: _StatItem(
              label: l10n.invitation_statusAvailable,
              value: unused.toString(),
              color: AppColors.warning,
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
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final bool? currentFilter;

  const _FilterTabs({this.currentFilter});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          _FilterChip(
            label: l10n.common_all,
            isSelected: currentFilter == null,
            onTap: () => context.read<InvitationsBloc>().add(
              const InvitationsFilterChanged(showUsedOnly: null),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            label: l10n.invitation_tabAvailable,
            isSelected: currentFilter == false,
            onTap: () => context.read<InvitationsBloc>().add(
              const InvitationsFilterChanged(showUsedOnly: false),
            ),
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            label: l10n.invitation_tabUsed,
            isSelected: currentFilter == true,
            onTap: () => context.read<InvitationsBloc>().add(
              const InvitationsFilterChanged(showUsedOnly: true),
            ),
            color: AppColors.success,
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
          color: isSelected ? chipColor : context.colors.surfaceVariant,
          borderRadius: AppSpacing.borderRadiusFull,
          border: Border.all(
            color: isSelected ? chipColor : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected ? AppColors.textOnPrimary : context.colors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  final InvitationModel invitation;

  const _InvitationCard({required this.invitation});

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
    final roleColor = AppColors.getRoleColor(invitation.role.name);
    final roleSurfaceColor = AppColors.getRoleSurfaceColor(invitation.role.name);
    final dateFormat = DateFormat('dd/MM/yyyy', locale);
    final statusColor = invitation.used ? AppColors.success : AppColors.warning;
    final statusSurfaceColor = invitation.used ? AppColors.successSurface : AppColors.warningSurface;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Code and copy button
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceVariant,
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.vpn_key,
                        size: 18,
                        color: context.colors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          invitation.code,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: invitation.code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.invitation_codeCopied),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        tooltip: l10n.invitation_copyCode,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Details row
          Row(
            children: [
              // Role chip
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
                      _getRoleIcon(),
                      size: 14,
                      color: roleColor,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _getRoleDisplayName(l10n, invitation.role),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: roleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Status chip
              Container(
                padding: AppSpacing.chipPadding,
                decoration: BoxDecoration(
                  color: statusSurfaceColor,
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      invitation.used ? Icons.check_circle : Icons.hourglass_empty,
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      invitation.used ? l10n.invitation_statusUsed : l10n.invitation_statusAvailable,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Date
              Text(
                dateFormat.format(invitation.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.colors.textTertiary,
                ),
              ),
              // Delete button (only for unused)
              if (!invitation.used) ...[
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => _confirmDelete(context),
                  tooltip: l10n.common_delete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: AppColors.error,
                ),
              ],
            ],
          ),
          // Used by info (if used)
          if (invitation.used && invitation.usedAt != null) ...[
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: context.colors.textTertiary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  l10n.invitation_usedOn(dateFormat.format(invitation.usedAt!)),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _getRoleIcon() {
    switch (invitation.role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.manager:
        return Icons.manage_accounts;
      case UserRole.employee:
        return Icons.person;
    }
  }

  void _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.common_confirmDelete),
        content: Text(l10n.invitation_deleteConfirmMessage(invitation.code)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<InvitationsBloc>().add(
                InvitationDeleteRequested(code: invitation.code),
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

class _GenerateInvitationDialog extends StatefulWidget {
  final void Function(UserRole role) onGenerate;

  const _GenerateInvitationDialog({required this.onGenerate});

  @override
  State<_GenerateInvitationDialog> createState() => _GenerateInvitationDialogState();
}

class _GenerateInvitationDialogState extends State<_GenerateInvitationDialog> {
  UserRole _selectedRole = UserRole.employee;
  bool _isSubmitting = false;
  String? _generatedCode;

  @override
  Widget build(BuildContext context) {
    return BlocListener<InvitationsBloc, InvitationsState>(
      listener: (context, state) {
        if (state.lastCreatedCode != null && _isSubmitting && state.lastCreatedCode != _generatedCode) {
          setState(() {
            _generatedCode = state.lastCreatedCode;
            _isSubmitting = false;
          });
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
            child: _generatedCode != null
                ? _buildSuccessContent(context)
                : _buildFormContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Text(
          l10n.invitation_create,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.invitation_createCodeSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        // Role selection
        Text(
          l10n.invitation_role,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
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
        // Generate button
        RibalButton(
          text: l10n.invitation_createCode,
          isLoading: _isSubmitting,
          onPressed: () {
            setState(() => _isSubmitting = true);
            widget.onGenerate(_selectedRole);
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        // Cancel button
        RibalButton(
          text: l10n.common_cancel,
          variant: RibalButtonVariant.outline,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildSuccessContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success icon
        Container(
          width: 64,
          height: 64,
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.successSurface,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: AppColors.success,
            size: 32,
          ),
        ),
        // Title
        Text(
          l10n.invitation_successTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        // Code display
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.colors.surfaceVariant,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Column(
            children: [
              Text(
                l10n.invitation_invitationCode,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SelectableText(
                _generatedCode!,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  letterSpacing: 4,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Role info
        Container(
          padding: AppSpacing.chipPadding,
          decoration: BoxDecoration(
            color: AppColors.getRoleSurfaceColor(_selectedRole.name),
            borderRadius: AppSpacing.borderRadiusFull,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getRoleIcon(_selectedRole),
                size: 16,
                color: AppColors.getRoleColor(_selectedRole.name),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                l10n.invitation_roleLabel(_getRoleDisplayName(l10n, _selectedRole)),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.getRoleColor(_selectedRole.name),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Copy button
        RibalButton(
          text: l10n.invitation_copyCodeButton,
          icon: Icons.copy,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: _generatedCode!));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.invitation_codeCopied),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        // Close button
        RibalButton(
          text: l10n.common_close,
          variant: RibalButtonVariant.outline,
          onPressed: () => Navigator.pop(context),
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
