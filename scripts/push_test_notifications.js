/**
 * Push Test Notifications Script
 *
 * Creates test notifications for a user to test the notification system.
 *
 * Usage:
 *   1. First authenticate: gcloud auth application-default login
 *   2. Run: GOOGLE_APPLICATION_CREDENTIALS="" node scripts/push_test_notifications.js <userId>
 *
 * Example:
 *   GOOGLE_APPLICATION_CREDENTIALS="" node scripts/push_test_notifications.js ABC123
 */

const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp({
  projectId: 'ribal-4ac8c',
});

const db = admin.firestore();

const userId = process.argv[2];

// Notification types with their properties
const notificationTypes = [
  {
    type: 'taskAssigned',
    title: 'مهمة جديدة',
    body: 'تم تعيين مهمة جديدة لك: إعداد التقرير الشهري',
    iconName: 'task_add',
    iconColor: '#2563EB',
  },
  {
    type: 'taskCompleted',
    title: 'تم إكمال المهمة',
    body: 'أكمل أحمد محمد المهمة: مراجعة المستندات',
    iconName: 'check_circle',
    iconColor: '#10B981',
  },
  {
    type: 'taskApologized',
    title: 'اعتذار عن مهمة',
    body: 'اعتذر سعيد أحمد عن المهمة: تحديث البيانات',
    iconName: 'warning',
    iconColor: '#F59E0B',
  },
  {
    type: 'taskReactivated',
    title: 'إعادة تفعيل مهمة',
    body: 'تم إعادة تفعيل المهمة: تنظيم الملفات',
    iconName: 'refresh',
    iconColor: '#8B5CF6',
  },
  {
    type: 'taskMarkedDone',
    title: 'تم تسليم مهمة',
    body: 'تم وضع علامة "تم" على المهمة: إعداد العرض التقديمي',
    iconName: 'done_all',
    iconColor: '#10B981',
  },
  {
    type: 'recurringScheduled',
    title: 'مهمة متكررة مجدولة',
    body: 'تم جدولة المهمة المتكررة: الاجتماع الأسبوعي',
    iconName: 'repeat',
    iconColor: '#14B8A6',
  },
  {
    type: 'invitationAccepted',
    title: 'قبول دعوة',
    body: 'قبل خالد العلي دعوة الانضمام للفريق',
    iconName: 'person_add',
    iconColor: '#6366F1',
  },
  {
    type: 'roleChanged',
    title: 'تغيير الدور',
    body: 'تم تغيير دورك من موظف إلى مشرف',
    iconName: 'swap_horiz',
    iconColor: '#F59E0B',
  },
];

async function main() {
  if (!userId) {
    console.log(`
Push Test Notifications Script

Usage: GOOGLE_APPLICATION_CREDENTIALS="" node scripts/push_test_notifications.js <userId>

This script creates sample notifications for testing the notification system.
It will create ${notificationTypes.length} notifications of different types.

To find user IDs, run:
  GOOGLE_APPLICATION_CREDENTIALS="" node scripts/firebase_utils.js read users
    `);
    process.exit(1);
  }

  console.log(`\nCreating ${notificationTypes.length} test notifications for user: ${userId}\n`);

  const batch = db.batch();
  const now = admin.firestore.Timestamp.now();

  for (const notification of notificationTypes) {
    const docRef = db.collection('notifications').doc();

    batch.set(docRef, {
      userId: userId,
      type: notification.type,
      title: notification.title,
      body: notification.body,
      iconName: notification.iconName,
      iconColor: notification.iconColor,
      deepLink: null,
      isSeen: false,
      isRead: false,
      createdAt: now,
    });

    console.log(`  ✓ ${notification.type}: ${notification.title}`);
  }

  await batch.commit();

  console.log(`\n✅ Successfully created ${notificationTypes.length} notifications!`);
  console.log('\nOpen the app to see the notification badge and test the feature.');

  process.exit(0);
}

main().catch(error => {
  console.error('Error:', error.message);
  process.exit(1);
});
