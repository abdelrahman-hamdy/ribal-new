const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');

// Initialize Firebase Admin with project ID
initializeApp({
  credential: applicationDefault(),
  projectId: 'ribal-4ac8c'
});

async function verifyEmail(email) {
  try {
    console.log(`Verifying email: ${email}...`);

    // Get user by email
    const user = await getAuth().getUserByEmail(email);
    console.log(`Found user with UID: ${user.uid}`);
    console.log(`Current emailVerified status: ${user.emailVerified}`);

    // Update user to set emailVerified to true
    await getAuth().updateUser(user.uid, {
      emailVerified: true
    });

    console.log(`✅ Email verified successfully for ${email}`);

    // Verify the change
    const updatedUser = await getAuth().getUserByEmail(email);
    console.log(`New emailVerified status: ${updatedUser.emailVerified}`);

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

verifyEmail('admin@ribal.com');
