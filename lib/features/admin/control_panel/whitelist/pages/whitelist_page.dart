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
    return Scaffold(
      appBar: AppBar(
        title: const Text('القائمة البيضاء'),
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
                title: 'لا توجد نتائج',
                message: 'لم يتم العثور على بريد إلكتروني يطابق "${state.searchQuery}"',
              );
            }
            return const EmptyState(
              icon: Icons.verified_user_outlined,
              title: 'لا توجد عناصر',
              message: 'أضف عناوين البريد الإلكتروني المعتمدة للتسجيل المباشر',
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
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
                const SnackBar(
                  content: Text('خطأ: لم يتم العثور على المستخدم'),
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
    return TextField(
      onChanged: (value) {
        if (value.isEmpty) {
          context.read<WhitelistBloc>().add(const WhitelistSearchCleared());
        } else {
          context.read<WhitelistBloc>().add(WhitelistSearchRequested(query: value));
        }
      },
      decoration: InputDecoration(
        hintText: 'البحث بالبريد الإلكتروني...',
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

class _WhitelistEntryCard extends StatelessWidget {
  final WhitelistModel entry;

  const _WhitelistEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final roleColor = AppColors.getRoleColor(entry.role.name);
    final roleSurfaceColor = AppColors.getRoleSurfaceColor(entry.role.name);
    final dateFormat = DateFormat('dd/MM/yyyy', 'ar');

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
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
                        entry.role.displayNameAr,
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
                        color: AppColors.textTertiary,
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
                    const SnackBar(
                      content: Text('تم نسخ البريد الإلكتروني'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: 'نسخ',
                color: AppColors.textSecondary,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () => _confirmDelete(context),
                tooltip: 'حذف',
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${entry.email}" من القائمة البيضاء؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<WhitelistBloc>().add(
                WhitelistRemoveRequested(entryId: entry.id),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف'),
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
                  'إضافة إلى القائمة البيضاء',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                // Email field
                RibalTextField(
                  controller: _emailController,
                  label: 'البريد الإلكتروني',
                  hint: 'أدخل البريد الإلكتروني',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'البريد الإلكتروني مطلوب';
                    }
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'البريد الإلكتروني غير صالح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                // Role selection
                Text(
                  'الدور',
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
                // Submit button
                RibalButton(
                  text: 'إضافة',
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.sm),
                // Cancel button
                RibalButton(
                  text: 'إلغاء',
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

  @override
  Widget build(BuildContext context) {
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
                color: isSelected ? roleColor : AppColors.surfaceVariant,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Icon(
                _getRoleIcon(),
                color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.displayNameAr,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? roleColor : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    _getRoleDescription(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
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

  String _getRoleDescription() {
    switch (role) {
      case UserRole.admin:
        return 'صلاحيات كاملة لإدارة النظام';
      case UserRole.manager:
        return 'إدارة المهام والموظفين المعينين';
      case UserRole.employee:
        return 'تنفيذ المهام المسندة';
    }
  }
}
