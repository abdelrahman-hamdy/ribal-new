import 'package:flutter/material.dart';

import '../../../app/di/injection.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// A notification icon button with real-time badge count
///
/// Shows the unseen notification count (isSeen = false) in real-time.
/// When user opens notifications panel, the count resets but individual
/// notifications remain highlighted until clicked.
class NotificationBadge extends StatelessWidget {
  final String userId;
  final VoidCallback onTap;

  const NotificationBadge({
    super.key,
    required this.userId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final notificationRepository = getIt<NotificationRepository>();

    return StreamBuilder<int>(
      stream: notificationRepository.streamUnseenCount(userId),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined),
                if (count > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        count > 99 ? '99+' : count.toString(),
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: onTap,
          ),
        );
      },
    );
  }
}
