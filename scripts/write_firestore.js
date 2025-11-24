/**
 * Quick Firestore Writer
 *
 * Usage:
 *   GOOGLE_APPLICATION_CREDENTIALS="" node scripts/write_firestore.js <collection> <docId> '<json>'
 *
 * Examples:
 *   # Create a group
 *   node scripts/write_firestore.js groups group1 '{"name":"فريق التطوير"}'
 *
 *   # Create a task
 *   node scripts/write_firestore.js tasks task1 '{"title":"مهمة جديدة","description":"وصف المهمة","assignToAll":true}'
 *
 *   # Update user
 *   node scripts/write_firestore.js users USER_ID '{"canAssignToAll":true}'
 */

const admin = require('firebase-admin');

admin.initializeApp({
  projectId: 'ribal-4ac8c',
});

const db = admin.firestore();

async function main() {
  const collection = process.argv[2];
  const docId = process.argv[3];
  const jsonData = process.argv[4];

  if (!collection || !docId || !jsonData) {
    console.log(`
Firestore Writer - Quick document creation/update

Usage:
  node scripts/write_firestore.js <collection> <docId> '<json>'

Arguments:
  collection  - Firestore collection name (users, tasks, groups, etc.)
  docId       - Document ID (use 'auto' to generate)
  json        - JSON data to write

Examples:
  # Create a group
  node scripts/write_firestore.js groups auto '{"name":"فريق التطوير"}'

  # Create a task
  node scripts/write_firestore.js tasks auto '{"title":"مهمة تجريبية","description":"وصف","assignToAll":true}'

  # Update existing document
  node scripts/write_firestore.js users ABC123 '{"canAssignToAll":true}'
    `);
    process.exit(1);
  }

  try {
    let data = JSON.parse(jsonData);

    // Add timestamps
    const now = admin.firestore.Timestamp.now();
    data.updatedAt = now;

    // Determine document reference
    let docRef;
    if (docId === 'auto') {
      docRef = db.collection(collection).doc();
      data.createdAt = now;
    } else {
      docRef = db.collection(collection).doc(docId);
      // Check if document exists to preserve createdAt
      const existing = await docRef.get();
      if (!existing.exists) {
        data.createdAt = now;
      }
    }

    // Write with merge to preserve existing fields
    await docRef.set(data, { merge: true });

    console.log(`\n✅ Document written successfully!`);
    console.log(`   Collection: ${collection}`);
    console.log(`   Document ID: ${docRef.id}`);
    console.log(`\n📄 Data written:`);
    console.log(JSON.stringify(data, null, 2));

    // Read back to confirm
    const written = await docRef.get();
    console.log(`\n📄 Full document after write:`);
    console.log(JSON.stringify(written.data(), null, 2));

  } catch (error) {
    if (error instanceof SyntaxError) {
      console.error('❌ Invalid JSON:', error.message);
      console.log('\nMake sure to wrap JSON in single quotes and use double quotes inside:');
      console.log("  '{ \"key\": \"value\" }'");
    } else {
      console.error('❌ Error:', error.message);
    }
    process.exit(1);
  }

  process.exit(0);
}

main();
