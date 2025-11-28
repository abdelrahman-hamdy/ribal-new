// Simple script to verify email using UID directly
const admin = require('firebase-admin');

// Initialize without credentials (will use the function's environment)
admin.initializeApp({
  projectId: 'ribal-4ac8c'
});

const uid = 'A6pMIz5ajQR38nAdYztpXboHYN22'; // admin@ribal.com

admin.auth().updateUser(uid, {
  emailVerified: true
})
.then(() => {
  console.log('✅ Email verified successfully for UID:', uid);
  return admin.auth().getUser(uid);
})
.then((user) => {
  console.log('Updated emailVerified status:', user.emailVerified);
  process.exit(0);
})
.catch((error) => {
  console.error('Error:', error);
  process.exit(1);
});
