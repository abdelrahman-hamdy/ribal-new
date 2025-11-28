import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../data/models/user_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Avatar size enum
enum RibalAvatarSize {
  /// 24px - Extra small (for compact lists, chips)
  xs,

  /// 32px - Small (for list items, comments)
  sm,

  /// 40px - Medium (for cards, default)
  md,

  /// 48px - Large (for user cards, emphasis)
  lg,

  /// 64px - Extra large (for headers)
  xl,

  /// 96px - Profile size (for profile pages)
  xxl,
}

/// Extension to get size values
extension RibalAvatarSizeX on RibalAvatarSize {
  /// Get the pixel size for this avatar
  double get size {
    switch (this) {
      case RibalAvatarSize.xs:
        return AppSpacing.avatarXs;
      case RibalAvatarSize.sm:
        return AppSpacing.avatarSm;
      case RibalAvatarSize.md:
        return AppSpacing.avatarMd;
      case RibalAvatarSize.lg:
        return AppSpacing.avatarLg;
      case RibalAvatarSize.xl:
        return AppSpacing.avatarXl;
      case RibalAvatarSize.xxl:
        return AppSpacing.avatarXxl;
    }
  }

  /// Get the font size for initials
  double get fontSize {
    switch (this) {
      case RibalAvatarSize.xs:
        return 10;
      case RibalAvatarSize.sm:
        return 12;
      case RibalAvatarSize.md:
        return 14;
      case RibalAvatarSize.lg:
        return 16;
      case RibalAvatarSize.xl:
        return 22;
      case RibalAvatarSize.xxl:
        return 28;
    }
  }

  /// Get the border width
  double get borderWidth {
    switch (this) {
      case RibalAvatarSize.xs:
        return 1;
      case RibalAvatarSize.sm:
        return 1.5;
      case RibalAvatarSize.md:
        return 2;
      case RibalAvatarSize.lg:
        return 2;
      case RibalAvatarSize.xl:
        return 2.5;
      case RibalAvatarSize.xxl:
        return 3;
    }
  }
}

/// Unified avatar widget for displaying user avatars
///
/// Features:
/// - Role-based colors (admin: purple, manager: blue, employee: green)
/// - Fully rounded (circular) style
/// - Multiple sizes via [RibalAvatarSize]
/// - Shows user initials
/// - Optional border
///
/// Usage:
/// ```dart
/// RibalAvatar(user: user, size: RibalAvatarSize.lg)
/// RibalAvatar.fromData(initials: 'AB', role: UserRole.admin)
/// ```
class RibalAvatar extends StatelessWidget {
  /// Create avatar from UserModel
  const RibalAvatar({
    super.key,
    required this.user,
    this.size = RibalAvatarSize.md,
    this.showBorder = false,
    this.onTap,
  })  : _initials = null,
        _role = null,
        _avatarUrl = null;

  /// Create avatar from raw data
  const RibalAvatar.fromData({
    super.key,
    required String initials,
    required UserRole role,
    String? avatarUrl,
    this.size = RibalAvatarSize.md,
    this.showBorder = false,
    this.onTap,
  })  : user = null,
        _initials = initials,
        _role = role,
        _avatarUrl = avatarUrl;

  /// The user to display avatar for
  final UserModel? user;

  /// Manual initials (used with fromData constructor)
  final String? _initials;

  /// Manual role (used with fromData constructor)
  final UserRole? _role;

  /// Manual avatar URL (used with fromData constructor)
  final String? _avatarUrl;

  /// The size of the avatar
  final RibalAvatarSize size;

  /// Whether to show a border
  final bool showBorder;

  /// Optional tap callback (makes avatar tappable)
  final VoidCallback? onTap;

  /// Get initials to display
  String get initials => user?.initials ?? _initials ?? '';

  /// Get the role for color calculation
  UserRole get role => user?.role ?? _role ?? UserRole.employee;

  /// Get avatar URL
  String? get avatarUrl => user?.avatarUrl ?? _avatarUrl;

  /// Get the color based on role
  Color get roleColor => AppColors.getRoleColor(role.name);

  /// Get the surface color based on role
  Color get roleSurfaceColor => AppColors.getRoleSurfaceColor(role.name);

  /// Get the default avatar image path based on role
  String get _defaultAvatarPath {
    switch (role) {
      case UserRole.admin:
        return 'assets/images/admin-avatar.png';
      case UserRole.manager:
        return 'assets/images/manager-avatar.png';
      case UserRole.employee:
        return 'assets/images/employee-avatar.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarSize = size.size;
    final borderWidth = showBorder ? size.borderWidth : 2.0; // Always show border

    Widget avatar;

    // Check if we have an avatar URL
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      avatar = Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: roleSurfaceColor, // Always show subtle background
          border: Border.all(
            color: roleColor,
            width: borderWidth,
          ),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: avatarUrl!,
            width: avatarSize,
            height: avatarSize,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildDefaultAvatar(
              avatarSize: avatarSize,
              showLoading: true,
            ),
            errorWidget: (context, url, error) => _buildDefaultAvatar(
              avatarSize: avatarSize,
            ),
          ),
        ),
      );
    } else {
      // Use role-specific default image instead of initials
      avatar = _buildDefaultAvatar(avatarSize: avatarSize);
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: avatar,
      );
    }

    return avatar;
  }

  /// Build the default avatar using role-specific image
  Widget _buildDefaultAvatar({
    required double avatarSize,
    bool showLoading = false,
  }) {
    final borderWidth = showBorder ? size.borderWidth : 2.0; // Always show border

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: roleSurfaceColor, // Always show subtle background
        border: Border.all(
          color: roleColor,
          width: borderWidth,
        ),
      ),
      child: ClipOval(
        child: showLoading
            ? Container(
                color: roleSurfaceColor,
                child: Center(
                  child: SizedBox(
                    width: avatarSize * 0.4,
                    height: avatarSize * 0.4,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(roleColor),
                    ),
                  ),
                ),
              )
            : Image.asset(
                _defaultAvatarPath,
                width: avatarSize,
                height: avatarSize,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}

/// Avatar with name and optional subtitle
///
/// Commonly used in list items and cards to show user info
class RibalAvatarWithInfo extends StatelessWidget {
  const RibalAvatarWithInfo({
    super.key,
    required this.user,
    this.size = RibalAvatarSize.md,
    this.showBorder = false,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final UserModel user;
  final RibalAvatarSize size;
  final bool showBorder;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        RibalAvatar(
          user: user,
          size: size,
          showBorder: showBorder,
        ),
        const SizedBox(width: AppSpacing.smd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user.fullName,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}
