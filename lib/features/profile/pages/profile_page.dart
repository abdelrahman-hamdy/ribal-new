import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/di/injection.dart';
import '../../../app/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/avatar/ribal_avatar.dart';
import '../../../core/widgets/buttons/ribal_button.dart';
import '../../../core/widgets/inputs/ribal_text_field.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/storage_service.dart';
import '../../auth/bloc/auth_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _onRefresh() async {
    // Trigger auth check to reload user data
    context.read<AuthBloc>().add(const AuthCheckRequested());

    // Wait a bit for the state to update
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.user;

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSpacing.pagePadding,
              children: [
                // Avatar - using unified RibalAvatar
                Center(
                  child: RibalAvatar(
                    user: user,
                    size: RibalAvatarSize.xxl,
                    showBorder: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Name
                Center(
                  child: Text(
                    user.fullName,
                    style: AppTypography.headlineMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                // Role badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.smd,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.getRoleSurfaceColor(user.role.name),
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                    child: Text(
                      user.role.displayNameAr,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.getRoleColor(user.role.name),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Info card
                _buildInfoCard(user),
                const SizedBox(height: AppSpacing.lg),

                // Settings section
                _buildSettingsSection(context, user),
                const SizedBox(height: AppSpacing.xl),

                // Logout button
                RibalButton(
                  text: 'تسجيل الخروج',
                  onPressed: () => _handleLogout(context),
                  variant: RibalButtonVariant.danger,
                  icon: Icons.logout,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(UserModel user) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'الاسم الكامل',
            value: user.fullName,
          ),
          const Divider(height: 1),
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'البريد الإلكتروني',
            value: user.email,
          ),
          const Divider(height: 1),
          _buildInfoRow(
            icon: Icons.badge_outlined,
            label: 'الدور',
            value: user.role.displayNameAr,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: AppSpacing.cardPadding,
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: AppSpacing.iconLg),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(value, style: AppTypography.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, UserModel user) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildSettingsButton(
            icon: Icons.dark_mode_outlined,
            label: 'الوضع الداكن',
            onTap: () => _showDarkModeSheet(context),
          ),
          const Divider(height: 1),
          _buildSettingsButton(
            icon: Icons.edit_outlined,
            label: 'تعديل الملف الشخصي',
            onTap: () => _showEditProfileSheet(context, user),
          ),
          const Divider(height: 1),
          _buildSettingsButton(
            icon: Icons.lock_outline,
            label: 'تغيير كلمة المرور',
            onTap: () => _showChangePasswordSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: AppSpacing.iconMd,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.titleMedium,
              ),
            ),
            const Icon(
              Icons.chevron_left,
              color: AppColors.textTertiary,
              size: AppSpacing.iconLg,
            ),
          ],
        ),
      ),
    );
  }

  void _showDarkModeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (sheetContext) => const _DarkModeSheet(),
    );
  }

  void _showEditProfileSheet(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: _EditProfileSheet(user: user),
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: const _ChangePasswordSheet(),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    // Capture the bloc reference before showing dialog
    final authBloc = context.read<AuthBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocListener<AuthBloc, AuthState>(
        bloc: authBloc,
        listener: (_, state) {
          if (state is AuthUnauthenticated) {
            // Close dialog if still open
            if (Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }
            // Navigate to login
            context.go(Routes.login);
          }
        },
        child: AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                // Dispatch sign out event - navigation handled by BlocListener
                authBloc.add(const AuthSignOutRequested());
              },
              child: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dark Mode Bottom Sheet
class _DarkModeSheet extends StatefulWidget {
  const _DarkModeSheet();

  @override
  State<_DarkModeSheet> createState() => _DarkModeSheetState();
}

class _DarkModeSheetState extends State<_DarkModeSheet> {
  int _selectedMode = 0; // 0: System, 1: Light, 2: Dark

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: AppSpacing.dialogPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'الوضع الداكن',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildModeOption(
                icon: Icons.phone_android,
                title: 'حسب النظام',
                subtitle: 'يتبع إعدادات الجهاز',
                value: 0,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildModeOption(
                icon: Icons.light_mode,
                title: 'الوضع الفاتح',
                subtitle: 'دائماً فاتح',
                value: 1,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildModeOption(
                icon: Icons.dark_mode,
                title: 'الوضع الداكن',
                subtitle: 'دائماً داكن',
                value: 2,
              ),
              const SizedBox(height: AppSpacing.lg),
              RibalButton(
                text: 'حفظ',
                onPressed: () {
                  // TODO: Implement theme persistence
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('سيتم دعم الوضع الداكن قريباً'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              RibalButton(
                text: 'إلغاء',
                variant: RibalButtonVariant.outline,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required int value,
  }) {
    final isSelected = _selectedMode == value;
    return InkWell(
      onTap: () => setState(() => _selectedMode = value),
      borderRadius: AppSpacing.borderRadiusMd,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.surface,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: AppSpacing.iconLg,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
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
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: AppSpacing.iconLg,
              ),
          ],
        ),
      ),
    );
  }
}

// Edit Profile Bottom Sheet
class _EditProfileSheet extends StatefulWidget {
  final UserModel user;

  const _EditProfileSheet({required this.user});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  final _storageService = getIt<StorageService>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;

  File? _selectedImage;
  String? _avatarUrl;
  bool _isSubmitting = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
    _avatarUrl = widget.user.avatarUrl;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return _avatarUrl;

    setState(() => _isUploadingImage = true);

    try {
      final url = await _storageService.uploadUserAvatar(
        userId: widget.user.id,
        file: _selectedImage!,
      );
      return url;
    } on StorageException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return _avatarUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل رفع الصورة: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return _avatarUrl;
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthProfileUpdateSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حفظ التغييرات بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is AuthError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
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
                  Text(
                    'تعديل الملف الشخصي',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Avatar picker
                  Center(
                    child: Stack(
                      children: [
                        // Avatar image
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: _selectedImage != null
                                ? Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  )
                                : _avatarUrl != null
                                    ? Image.network(
                                        _avatarUrl!,
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                        errorBuilder: (_, __, ___) =>
                                            _buildAvatarPlaceholder(),
                                      )
                                    : _buildAvatarPlaceholder(),
                          ),
                        ),
                        // Edit button
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: GestureDetector(
                            onTap: _isUploadingImage ? null : _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: _isUploadingImage
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.camera_alt,
                                      color: AppColors.textOnPrimary,
                                      size: 16,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: Text(
                      'اضغط لتغيير الصورة',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  RibalTextField(
                    controller: _firstNameController,
                    label: 'الاسم الأول',
                    hint: 'أدخل الاسم الأول',
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الاسم الأول مطلوب';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  RibalTextField(
                    controller: _lastNameController,
                    label: 'اسم العائلة',
                    hint: 'أدخل اسم العائلة',
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'اسم العائلة مطلوب';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  RibalTextField(
                    controller: _emailController,
                    label: 'البريد الإلكتروني',
                    hint: 'أدخل البريد الإلكتروني',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'البريد الإلكتروني مطلوب';
                      }
                      final emailRegex =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'البريد الإلكتروني غير صالح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  RibalButton(
                    text: 'حفظ التغييرات',
                    isLoading: _isSubmitting || _isUploadingImage,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: AppSpacing.sm),
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

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: AppColors.primarySurface,
      child: Center(
        child: Text(
          widget.user.initials,
          style: AppTypography.headlineLarge.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);

      // Upload image if selected
      final avatarUrl = await _uploadImage();

      if (!mounted) return;

      // Update profile via bloc
      context.read<AuthBloc>().add(
            AuthUpdateProfileRequested(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              email: _emailController.text.trim(),
              avatarUrl: avatarUrl,
            ),
          );
    }
  }
}

// Change Password Bottom Sheet
class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordChangeSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تغيير كلمة المرور بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is AuthError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
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
                  Text(
                    'تغيير كلمة المرور',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  RibalTextField(
                    controller: _currentPasswordController,
                    label: 'كلمة المرور الحالية',
                    hint: 'أدخل كلمة المرور الحالية',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'كلمة المرور الحالية مطلوبة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  RibalTextField(
                    controller: _newPasswordController,
                    label: 'كلمة المرور الجديدة',
                    hint: 'أدخل كلمة المرور الجديدة',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'كلمة المرور الجديدة مطلوبة';
                      }
                      if (value.length < 8) {
                        return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  RibalTextField(
                    controller: _confirmPasswordController,
                    label: 'تأكيد كلمة المرور',
                    hint: 'أعد إدخال كلمة المرور الجديدة',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'تأكيد كلمة المرور مطلوب';
                      }
                      if (value != _newPasswordController.text) {
                        return 'كلمة المرور غير متطابقة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  RibalButton(
                    text: 'تغيير كلمة المرور',
                    isLoading: _isSubmitting,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: AppSpacing.sm),
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
      context.read<AuthBloc>().add(
            AuthChangePasswordRequested(
              currentPassword: _currentPasswordController.text,
              newPassword: _newPasswordController.text,
            ),
          );
    }
  }
}
