import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class ControlPanelPage extends StatelessWidget {
  const ControlPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
      ),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          _buildSection(
            title: 'إدارة المستخدمين',
            items: [
              _MenuItem(
                icon: Icons.people,
                title: 'المستخدمين',
                subtitle: 'إدارة حسابات المستخدمين والأدوار',
                onTap: () => context.push(Routes.adminUsers),
              ),
              _MenuItem(
                icon: Icons.group_work,
                title: 'المجموعات',
                subtitle: 'إدارة مجموعات الموظفين',
                onTap: () => context.push(Routes.adminGroups),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSection(
            title: 'إدارة المهام',
            items: [
              _MenuItem(
                icon: Icons.label,
                title: 'التصنيفات',
                subtitle: 'إدارة تصنيفات المهام',
                onTap: () => context.push(Routes.adminLabels),
              ),
              _MenuItem(
                icon: Icons.archive,
                title: 'الأرشيف',
                subtitle: 'المهام المؤرشفة',
                onTap: () => context.push(Routes.adminArchive),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSection(
            title: 'التسجيل والدعوات',
            items: [
              _MenuItem(
                icon: Icons.verified_user,
                title: 'القائمة البيضاء',
                subtitle: 'إدارة البريد الإلكتروني المعتمد',
                onTap: () => context.push(Routes.adminWhitelist),
              ),
              _MenuItem(
                icon: Icons.card_giftcard,
                title: 'أكواد الدعوة',
                subtitle: 'إنشاء وإدارة أكواد الدعوة',
                onTap: () => context.push(Routes.adminInvitations),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSection(
            title: 'الإعدادات',
            items: [
              _MenuItem(
                icon: Icons.settings,
                title: 'الإعدادات العامة',
                subtitle: 'وقت المهام المتكررة والمواعيد النهائية',
                onTap: () => context.push(Routes.adminSettings),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: AppColors.border),
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
                        color: AppColors.primarySurface,
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: Icon(item.icon, color: AppColors.primary),
                    ),
                    title: Text(item.title),
                    subtitle: Text(
                      item.subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_left),
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
