import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/di/injection.dart';
import '../../../app/router/routes.dart';
import '../../../core/locale/bloc/locale_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/bloc/theme_bloc.dart';
import '../../../core/widgets/avatar/ribal_avatar.dart';
import '../../../core/widgets/buttons/ribal_button.dart';
import '../../../core/widgets/inputs/ribal_text_field.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/storage_service.dart';
import '../../../l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile_title),
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
            backgroundColor: context.colors.surface,
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
                    style: AppTypography.headlineMedium.copyWith(
                      color: context.colors.textPrimary,
                    ),
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
                      color: AppColors.getRoleSurfaceColor(user.role.name, isDark: context.isDarkMode),
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                    child: Text(
                      _getRoleDisplayName(context, user.role),
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.getRoleColor(user.role.name),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Info card
                _buildInfoCard(context, user),
                const SizedBox(height: AppSpacing.lg),

                // Settings section
                _buildSettingsSection(context, user),
                const SizedBox(height: AppSpacing.xl),

                // Logout button
                RibalButton(
                  text: l10n.profile_logout,
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

  String _getRoleDisplayName(BuildContext context, UserRole role) {
    final l10n = AppLocalizations.of(context)!;
    switch (role) {
      case UserRole.admin:
        return l10n.user_roleAdmin;
      case UserRole.manager:
        return l10n.user_roleManager;
      case UserRole.employee:
        return l10n.user_roleEmployee;
    }
  }

  Widget _buildInfoCard(BuildContext context, UserModel user) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            context: context,
            icon: Icons.person_outline,
            label: l10n.profile_fullName,
            value: user.fullName,
          ),
          Divider(height: 1, color: context.colors.divider),
          _buildInfoRow(
            context: context,
            icon: Icons.email_outlined,
            label: l10n.profile_email,
            value: user.email,
          ),
          Divider(height: 1, color: context.colors.divider),
          _buildInfoRow(
            context: context,
            icon: Icons.badge_outlined,
            label: l10n.profile_role,
            value: _getRoleDisplayName(context, user.role),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: AppSpacing.cardPadding,
      child: Row(
        children: [
          Icon(icon, color: context.colors.textSecondary, size: AppSpacing.iconLg),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.titleMedium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, UserModel user) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          _buildSettingsButton(
            context: context,
            icon: Icons.dark_mode_outlined,
            label: l10n.profile_darkMode,
            onTap: () => _showDarkModeSheet(context),
          ),
          Divider(height: 1, color: context.colors.divider),
          _buildSettingsButton(
            context: context,
            icon: Icons.language_outlined,
            label: l10n.profile_language,
            onTap: () => _showLanguageSheet(context),
          ),
          Divider(height: 1, color: context.colors.divider),
          _buildSettingsButton(
            context: context,
            icon: Icons.edit_outlined,
            label: l10n.profile_editProfile,
            onTap: () => _showEditProfileSheet(context, user),
          ),
          Divider(height: 1, color: context.colors.divider),
          _buildSettingsButton(
            context: context,
            icon: Icons.lock_outline,
            label: l10n.profile_changePassword,
            onTap: () => _showChangePasswordSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton({
    required BuildContext context,
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
              decoration: BoxDecoration(
                color: context.colors.primarySurface,
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
                style: AppTypography.titleMedium.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: context.colors.textTertiary,
              size: 16,
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
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<ThemeBloc>(),
        child: const _DarkModeSheet(),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
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
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<LocaleBloc>(),
        child: const _LanguageSheet(),
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, UserModel user) {
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
      backgroundColor: context.colors.surface,
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
    final l10n = AppLocalizations.of(context)!;
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
          title: Text(l10n.profile_logout),
          content: Text(l10n.profile_logoutConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.common_cancel),
            ),
            TextButton(
              onPressed: () {
                // Dispatch sign out event - navigation handled by BlocListener
                authBloc.add(const AuthSignOutRequested());
              },
              child: Text(
                l10n.profile_logout,
                style: const TextStyle(color: AppColors.error),
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
  late AppThemeMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = context.read<ThemeBloc>().state.mode;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                l10n.theme_title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildModeOption(
                icon: Icons.phone_android,
                title: l10n.theme_system,
                subtitle: l10n.theme_systemSubtitle,
                value: AppThemeMode.system,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildModeOption(
                icon: Icons.light_mode,
                title: l10n.theme_light,
                subtitle: l10n.theme_lightSubtitle,
                value: AppThemeMode.light,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildModeOption(
                icon: Icons.dark_mode,
                title: l10n.theme_dark,
                subtitle: l10n.theme_darkSubtitle,
                value: AppThemeMode.dark,
              ),
              const SizedBox(height: AppSpacing.lg),
              RibalButton(
                text: l10n.common_save,
                onPressed: () {
                  context.read<ThemeBloc>().add(ThemeModeChanged(_selectedMode));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              RibalButton(
                text: l10n.common_cancel,
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
    required AppThemeMode value,
  }) {
    final isSelected = _selectedMode == value;
    return InkWell(
      onTap: () => setState(() => _selectedMode = value),
      borderRadius: AppSpacing.borderRadiusMd,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primarySurface : context.colors.surface,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(
            color: isSelected ? AppColors.primary : context.colors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : context.colors.textSecondary,
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
                          : context.colors.textPrimary,
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

// Language Bottom Sheet
class _LanguageSheet extends StatefulWidget {
  const _LanguageSheet();

  @override
  State<_LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<_LanguageSheet> {
  late AppLocale _selectedLocale;

  @override
  void initState() {
    super.initState();
    _selectedLocale = context.read<LocaleBloc>().state.appLocale;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                l10n.language_title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildLocaleOption(
                title: l10n.language_arabic,
                subtitle: l10n.language_arabicSubtitle,
                value: AppLocale.arabic,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildLocaleOption(
                title: l10n.language_english,
                subtitle: l10n.language_englishSubtitle,
                value: AppLocale.english,
              ),
              const SizedBox(height: AppSpacing.lg),
              RibalButton(
                text: l10n.common_save,
                onPressed: () {
                  context.read<LocaleBloc>().add(LocaleChanged(_selectedLocale));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              RibalButton(
                text: l10n.common_cancel,
                variant: RibalButtonVariant.outline,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocaleOption({
    required String title,
    required String subtitle,
    required AppLocale value,
  }) {
    final isSelected = _selectedLocale == value;
    return InkWell(
      onTap: () => setState(() => _selectedLocale = value),
      borderRadius: AppSpacing.borderRadiusMd,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primarySurface : context.colors.surface,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(
            color: isSelected ? AppColors.primary : context.colors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.language,
              color: isSelected ? AppColors.primary : context.colors.textSecondary,
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
                          : context.colors.textPrimary,
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
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthProfileUpdateSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.profile_changesSaved),
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
                    l10n.profile_editProfile,
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
                      l10n.profile_tapToChangePhoto,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  RibalTextField(
                    controller: _firstNameController,
                    label: l10n.auth_firstName,
                    hint: l10n.auth_firstNameHint,
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.auth_firstNameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  RibalTextField(
                    controller: _lastNameController,
                    label: l10n.auth_lastName,
                    hint: l10n.auth_lastNameHint,
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.auth_lastNameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  RibalTextField(
                    controller: _emailController,
                    label: l10n.auth_email,
                    hint: l10n.auth_emailHint,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.auth_emailRequired;
                      }
                      final emailRegex =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return l10n.auth_emailInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  RibalButton(
                    text: l10n.common_saveChanges,
                    isLoading: _isSubmitting || _isUploadingImage,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: AppSpacing.sm),
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

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: context.colors.primarySurface,
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
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordChangeSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.auth_passwordChanged),
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
                    l10n.profile_changePassword,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  RibalTextField(
                    controller: _currentPasswordController,
                    label: l10n.auth_passwordCurrent,
                    hint: l10n.auth_passwordCurrentHint,
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.auth_passwordCurrentRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  RibalTextField(
                    controller: _newPasswordController,
                    label: l10n.auth_passwordNew,
                    hint: l10n.auth_passwordNewHint,
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.auth_passwordNewRequired;
                      }
                      if (value.length < 8) {
                        return l10n.auth_passwordMinLength;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  RibalTextField(
                    controller: _confirmPasswordController,
                    label: l10n.auth_passwordConfirm,
                    hint: l10n.auth_passwordConfirmHint,
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.auth_passwordConfirmRequired;
                      }
                      if (value != _newPasswordController.text) {
                        return l10n.auth_passwordMismatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  RibalButton(
                    text: l10n.profile_changePassword,
                    isLoading: _isSubmitting,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: AppSpacing.sm),
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
      context.read<AuthBloc>().add(
            AuthChangePasswordRequested(
              currentPassword: _currentPasswordController.text,
              newPassword: _newPasswordController.text,
            ),
          );
    }
  }
}
