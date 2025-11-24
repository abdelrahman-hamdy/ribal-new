/**
 * Seed Firestore with dummy data for testing
 *
 * Run: GOOGLE_APPLICATION_CREDENTIALS="" node scripts/seed_data.js
 */

const admin = require('firebase-admin');

admin.initializeApp({
  projectId: 'ribal-4ac8c',
});

const db = admin.firestore();
const auth = admin.auth();

async function seedData() {
  console.log('🌱 Seeding Firestore with dummy data...\n');

  const now = admin.firestore.Timestamp.now();
  const adminUserId = 'A6pMIz5ajQR38nAdYztpXboHYN22'; // Your admin user ID

  // ============================================
  // CREATE GROUPS
  // ============================================
  console.log('📁 Creating groups...');

  const groups = [
    { name: 'فريق التطوير', createdBy: adminUserId },
    { name: 'فريق التسويق', createdBy: adminUserId },
    { name: 'فريق الدعم الفني', createdBy: adminUserId },
  ];

  const groupIds = [];
  for (const group of groups) {
    const ref = db.collection('groups').doc();
    await ref.set({
      ...group,
      createdAt: now,
    });
    groupIds.push(ref.id);
    console.log(`  ✅ Created group: ${group.name} (${ref.id})`);
  }

  // ============================================
  // CREATE TASKS
  // ============================================
  console.log('\n📋 Creating tasks...');

  const tasks = [
    {
      title: 'مراجعة التقرير الشهري',
      description: 'مراجعة وتدقيق التقرير الشهري للمبيعات وإرساله للإدارة',
      isRecurring: false,
      assigneeSelection: 'all',
      selectedGroupIds: [],
      selectedUserIds: [],
    },
    {
      title: 'الاجتماع الأسبوعي',
      description: 'حضور الاجتماع الأسبوعي لمناقشة تقدم المشاريع',
      isRecurring: true,
      assigneeSelection: 'all',
      selectedGroupIds: [],
      selectedUserIds: [],
    },
    {
      title: 'تحديث الموقع الإلكتروني',
      description: 'تحديث محتوى الصفحة الرئيسية وإضافة المنتجات الجديدة',
      isRecurring: false,
      assigneeSelection: 'groups',
      selectedGroupIds: [groupIds[0]], // فريق التطوير
      selectedUserIds: [],
    },
    {
      title: 'الرد على استفسارات العملاء',
      description: 'متابعة والرد على جميع استفسارات العملاء في نظام الدعم',
      isRecurring: true,
      assigneeSelection: 'groups',
      selectedGroupIds: [groupIds[2]], // فريق الدعم الفني
      selectedUserIds: [],
    },
    {
      title: 'إعداد الحملة الإعلانية',
      description: 'تصميم وإعداد الحملة الإعلانية للمنتج الجديد',
      isRecurring: false,
      assigneeSelection: 'groups',
      selectedGroupIds: [groupIds[1]], // فريق التسويق
      selectedUserIds: [],
    },
  ];

  for (const task of tasks) {
    const ref = db.collection('tasks').doc();
    await ref.set({
      ...task,
      labelIds: [],
      attachmentUrl: null,
      isActive: true,
      isArchived: false,
      createdBy: adminUserId,
      createdAt: now,
      updatedAt: now,
    });
    console.log(`  ✅ Created task: ${task.title} (${ref.id})`);
  }

  // ============================================
  // CREATE LABELS
  // ============================================
  console.log('\n🏷️  Creating labels...');

  const labels = [
    { name: 'عاجل', color: '#EF4444', isActive: true },
    { name: 'مهم', color: '#F59E0B', isActive: true },
    { name: 'عادي', color: '#3B82F6', isActive: true },
    { name: 'مؤجل', color: '#6B7280', isActive: true },
  ];

  for (const label of labels) {
    const ref = db.collection('labels').doc();
    await ref.set({
      ...label,
      createdBy: adminUserId,
      createdAt: now,
    });
    console.log(`  ✅ Created label: ${label.name} (${ref.id})`);
  }

  // ============================================
  // SUMMARY
  // ============================================
  console.log('\n✨ Seeding complete!');
  console.log(`   - ${groups.length} groups created`);
  console.log(`   - ${tasks.length} tasks created`);
  console.log(`   - ${labels.length} labels created`);
  console.log('\n🔄 Hot restart your Flutter app to see the data!');
}

seedData()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('❌ Error seeding data:', error);
    process.exit(1);
  });
