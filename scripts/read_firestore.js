/**
 * Quick Firestore Reader
 *
 * Usage:
 *   GOOGLE_APPLICATION_CREDENTIALS="" node scripts/read_firestore.js [collection] [docId]
 *
 * Examples:
 *   node scripts/read_firestore.js                    # List all collections
 *   node scripts/read_firestore.js users              # Read all users
 *   node scripts/read_firestore.js users ABC123       # Read specific user
 *   node scripts/read_firestore.js tasks              # Read all tasks
 *   node scripts/read_firestore.js groups             # Read all groups
 */

const admin = require('firebase-admin');

admin.initializeApp({
  projectId: 'ribal-4ac8c',
});

const db = admin.firestore();

async function main() {
  const collection = process.argv[2];
  const docId = process.argv[3];

  try {
    if (!collection) {
      // List all collections
      const collections = await db.listCollections();
      console.log('\n📁 Available Collections:\n');
      for (const col of collections) {
        const snapshot = await col.limit(1).get();
        const count = (await col.count().get()).data().count;
        console.log(`  • ${col.id} (${count} docs)`);
      }
      console.log('\nUsage: node scripts/read_firestore.js <collection> [docId]');
      return;
    }

    if (docId) {
      // Read single document
      const doc = await db.collection(collection).doc(docId).get();
      if (!doc.exists) {
        console.log('❌ Document not found:', `${collection}/${docId}`);
        return;
      }
      console.log(`\n📄 ${collection}/${docId}:\n`);
      console.log(JSON.stringify({ id: doc.id, ...doc.data() }, null, 2));
    } else {
      // Read all documents in collection
      const snapshot = await db.collection(collection).limit(50).get();
      console.log(`\n📚 ${collection} (${snapshot.size} documents):\n`);

      if (snapshot.empty) {
        console.log('  (empty collection)');
        return;
      }

      snapshot.forEach((doc, index) => {
        const data = doc.data();
        console.log(`\n--- [${index + 1}] ID: ${doc.id} ---`);
        console.log(JSON.stringify(data, null, 2));
      });
    }
  } catch (error) {
    console.error('❌ Error:', error.message);
  }

  process.exit(0);
}

main();
