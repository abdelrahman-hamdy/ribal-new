import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/note_model.dart';
import '../../../data/models/user_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../utils/ksa_timezone.dart';
import '../avatar/ribal_avatar.dart';

/// A single note bubble in a conversation
class NoteBubble extends StatelessWidget {
  final NoteModel note;
  final bool isCurrentUser;

  const NoteBubble({
    super.key,
    required this.note,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            _buildAvatar(),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Sender name and role (only for other users)
                if (!isCurrentUser) _buildSenderInfo(context),
                // Message bubble
                _buildMessageBubble(context),
                // Timestamp
                _buildTimestamp(context),
              ],
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: AppSpacing.sm),
            _buildAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return RibalAvatar.fromData(
      initials: _getInitials(),
      role: note.senderRole,
      size: RibalAvatarSize.sm,
    );
  }

  /// Get initials from sender name (e.g., "أحمد محمد" -> "أ.م")
  String _getInitials() {
    final parts = note.senderName.trim().split(' ');
    if (parts.isEmpty || note.senderName.isEmpty) return '?';

    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';

    if (first.isEmpty && last.isEmpty) return '?';
    if (first.isEmpty) return last.toUpperCase();
    if (last.isEmpty) return first.toUpperCase();
    return '$first.$last'.toUpperCase();
  }

  Widget _buildSenderInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            note.senderName,
            style: AppTypography.labelSmall.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: _getRoleColor().withValues(alpha: 0.1),
              borderRadius: AppSpacing.borderRadiusXs,
            ),
            child: Text(
              _getRoleLabel(),
              style: AppTypography.labelSmall.copyWith(
                color: _getRoleColor(),
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    final bubbleColor = isCurrentUser
        ? AppColors.primary
        : (note.isApologizeNote
            ? AppColors.warningSurface
            : context.colors.surfaceVariant);

    final textColor = isCurrentUser
        ? AppColors.textOnPrimary
        : (note.isApologizeNote ? AppColors.warningDark : context.colors.textPrimary);

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smd,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppSpacing.radiusMd),
          topRight: const Radius.circular(AppSpacing.radiusMd),
          bottomLeft: Radius.circular(isCurrentUser ? AppSpacing.radiusMd : 4),
          bottomRight: Radius.circular(isCurrentUser ? 4 : AppSpacing.radiusMd),
        ),
        border: note.isApologizeNote && !isCurrentUser
            ? Border.all(color: AppColors.warning.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (note.isApologizeNote && !isCurrentUser)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 14,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'رسالة اعتذار',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          Text(
            note.message,
            style: AppTypography.bodyMedium.copyWith(
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxs),
      child: Text(
        _formatTime(note.createdAt),
        style: AppTypography.labelSmall.copyWith(
          color: context.colors.textTertiary,
          fontSize: 10,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final today = KsaTimezone.today();
    final noteDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (noteDate == today) {
      return DateFormat.jm('ar').format(dateTime);
    } else if (noteDate == today.subtract(const Duration(days: 1))) {
      return 'أمس ${DateFormat.jm('ar').format(dateTime)}';
    } else {
      return DateFormat('d/M', 'ar').format(dateTime);
    }
  }

  Color _getRoleColor() {
    switch (note.senderRole) {
      case UserRole.admin:
        return AppColors.roleAdmin;
      case UserRole.manager:
        return AppColors.roleManager;
      case UserRole.employee:
        return AppColors.roleEmployee;
    }
  }

  String _getRoleLabel() {
    switch (note.senderRole) {
      case UserRole.admin:
        return 'مدير';
      case UserRole.manager:
        return 'مشرف';
      case UserRole.employee:
        return 'موظف';
    }
  }
}
