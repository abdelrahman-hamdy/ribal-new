import 'package:flutter/material.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/notification_model.dart';
import '../../../../data/repositories/notification_repository.dart';

/// Debug button to create test notifications
/// Only for development/testing purposes
class DebugNotificationButton extends StatelessWidget {
  final String userId;

  const DebugNotificationButton({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _createTestNotifications(context),
      backgroundColor: AppColors.warning,
      icon: const Icon(Icons.bug_report),
      label: const Text('إشعارات تجريبية'),
    );
  }

  Future<void> _createTestNotifications(BuildContext context) async {
    final repository = getIt<NotificationRepository>();

    final testNotifications = [
      (
        type: NotificationType.taskAssigned,
        title: 'مهمة جديدة',
        body: 'تم تعيين مهمة جديدة لك: إعداد التقرير الشهري',
      ),
      (
        type: NotificationType.taskCompleted,
        title: 'تم إكمال المهمة',
        body: 'أكمل أحمد محمد المهمة: مراجعة المستندات',
      ),
      (
        type: NotificationType.taskApologized,
        title: 'اعتذار عن مهمة',
        body: 'اعتذر سعيد أحمد عن المهمة: تحديث البيانات',
      ),
      (
        type: NotificationType.taskReactivated,
        title: 'إعادة تفعيل مهمة',
        body: 'تم إعادة تفعيل المهمة: تنظيم الملفات',
      ),
      (
        type: NotificationType.invitationAccepted,
        title: 'قبول دعوة',
        body: 'قبل خالد العلي دعوة الانضمام للفريق',
      ),
    ];

    try {
      for (final notification in testNotifications) {
        await repository.createTypedNotification(
          userId: userId,
          type: notification.type,
          title: notification.title,
          body: notification.body,
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إنشاء ${testNotifications.length} إشعارات تجريبية'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في إنشاء الإشعارات: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
