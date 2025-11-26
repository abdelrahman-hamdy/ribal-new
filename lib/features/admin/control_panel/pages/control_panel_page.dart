import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ControlPanelPage extends StatelessWidget {
  const ControlPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.controlPanel_title),
      ),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          _buildSection(
            context: context,
            title: l10n.controlPanel_userManagement,
            items: [
              _MenuItem(
                icon: Icons.people,
                title: l10n.user_title,
                subtitle: l10n.user_subtitle,
                onTap: () => context.push(Routes.adminUsers),
              ),
              _MenuItem(
                icon: Icons.group_work,
                title: l10n.group_title,
                subtitle: l10n.group_manageSubtitle,
                onTap: () => context.push(Routes.adminGroups),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSection(
            context: context,
            title: l10n.controlPanel_taskManagement,
            items: [
              _MenuItem(
                icon: Icons.label,
                title: l10n.label_title,
                subtitle: l10n.label_manageSubtitle,
                onTap: () => context.push(Routes.adminLabels),
              ),
              _MenuItem(
                icon: Icons.archive,
                title: l10n.archive_title,
                subtitle: l10n.archive_subtitle,
                onTap: () => context.push(Routes.adminArchive),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSection(
            context: context,
            title: l10n.controlPanel_registration,
            items: [
              _MenuItem(
                icon: Icons.verified_user,
                title: l10n.whitelist_title,
                subtitle: l10n.whitelist_subtitle,
                onTap: () => context.push(Routes.adminWhitelist),
              ),
              _MenuItem(
                icon: Icons.card_giftcard,
                title: l10n.invitation_title,
                subtitle: l10n.invitation_subtitle,
                onTap: () => context.push(Routes.adminInvitations),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSection(
            context: context,
            title: l10n.controlPanel_settings,
            items: [
              _MenuItem(
                icon: Icons.settings,
                title: l10n.settings_general,
                subtitle: l10n.settings_subtitle,
                onTap: () => context.push(Routes.adminSettings),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: context.colors.primarySurface,
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: Icon(item.icon, color: AppColors.primary),
                    ),
                    title: Text(item.title),
                    subtitle: Text(
                      item.subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: context.colors.textTertiary,
                    ),
                    onTap: item.onTap,
                  ),
                  if (index < items.length - 1)
                    const Divider(height: 1, indent: 72),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
