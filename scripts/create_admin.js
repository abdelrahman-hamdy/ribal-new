const admin = require('firebase-admin');

// Initialize with default credentials (uses gcloud auth)
admin.initializeApp({
  projectId: 'ribal-4ac8c',
});

const auth = admin.auth();
const db = admin.firestore();

async function createAdminUser() {
  const email = 'admin@ribal.app';
  const password = 'Admin@123';
  const firstName = 'مدير';
  const lastName = 'النظام';

  try {
    // Create user in Firebase Auth
    let userRecord;
    try {
      userRecord = await auth.createUser({
        email: email,
        password: password,
        emailVerified: true,
        displayName: `${firstName} ${lastName}`,
      });
      console.log('✅ Created Auth user:', userRecord.uid);
    } catch (error) {
      if (error.code === 'auth/email-already-exists') {
        userRecord = await auth.getUserByEmail(email);
        console.log('ℹ️  Auth user already exists:', userRecord.uid);
      } else {
        throw error;
      }
    }

    // Create user document in Firestore
    const now = admin.firestore.Timestamp.now();
    const userData = {
      firstName: firstName,
      lastName: lastName,
      email: email,
      role: 'admin',
      groupId: null,
      managedGroupIds: [],
      canAssignToAll: true,
      fcmTokens: [],
      createdAt: now,
      updatedAt: now,
    };

    await db.collection('users').doc(userRecord.uid).set(userData, { merge: true });
    console.log('✅ Created Firestore user document');

    console.log('\n========================================');
    console.log('🎉 Admin account created successfully!');
    console.log('========================================');
    console.log('Email:', email);
    console.log('Password:', password);
    console.log('Role: Admin (مدير النظام)');
    console.log('========================================\n');

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }

  process.exit(0);
}

createAdminUser();
