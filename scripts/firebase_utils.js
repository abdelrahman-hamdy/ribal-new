/**
 * Firebase Utilities for Debugging and Development
 *
 * Usage:
 *   1. First authenticate: gcloud auth application-default login
 *   2. Run scripts: GOOGLE_APPLICATION_CREDENTIALS="" node scripts/firebase_utils.js <command> [args]
 *
 * Commands:
 *   read <collection> [docId]     - Read documents from a collection
 *   write <collection> <docId>    - Write/update a document (data from stdin as JSON)
 *   delete <collection> <docId>   - Delete a document
 *   list-users                    - List all users from Auth
 *   list-collections              - List root collections
 */

const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp({
  projectId: 'ribal-4ac8c',
});

const db = admin.firestore();
const auth = admin.auth();

const command = process.argv[2];
const arg1 = process.argv[3];
const arg2 = process.argv[4];

async function main() {
  try {
    switch (command) {
      case 'read':
        await readCollection(arg1, arg2);
        break;
      case 'write':
        await writeDocument(arg1, arg2);
        break;
      case 'delete':
        await deleteDocument(arg1, arg2);
        break;
      case 'list-users':
        await listAuthUsers();
        break;
      case 'list-collections':
        await listCollections();
        break;
      case 'create-group':
        await createGroup(arg1);
        break;
      case 'create-task':
        await createTask();
        break;
      default:
        printUsage();
    }
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
  process.exit(0);
}

function printUsage() {
  console.log(`
Firebase Utilities for Ribal App

Usage: GOOGLE_APPLICATION_CREDENTIALS="" node scripts/firebase_utils.js <command> [args]

Commands:
  read <collection> [docId]   Read all documents or a specific document
  write <collection> <docId>  Write document (pipe JSON data)
  delete <collection> <docId> Delete a document
  list-users                  List all Firebase Auth users
  list-collections            List root Firestore collections
  create-group <name>         Create a new group
  create-task                 Create a sample task (interactive)

Examples:
  node scripts/firebase_utils.js read users
  node scripts/firebase_utils.js read users ABC123
  echo '{"name":"Test"}' | node scripts/firebase_utils.js write groups group1
  node scripts/firebase_utils.js create-group "فريق التطوير"
  `);
}

async function readCollection(collection, docId) {
  if (!collection) {
    console.error('Collection name required');
    return;
  }

  if (docId) {
    // Read single document
    const doc = await db.collection(collection).doc(docId).get();
    if (!doc.exists) {
      console.log('Document not found');
      return;
    }
    console.log('\n📄 Document:', docId);
    console.log(JSON.stringify({ id: doc.id, ...doc.data() }, null, 2));
  } else {
    // Read all documents
    const snapshot = await db.collection(collection).get();
    console.log(`\n📚 Collection: ${collection} (${snapshot.size} documents)\n`);
    snapshot.forEach(doc => {
      console.log('---');
      console.log('ID:', doc.id);
      console.log(JSON.stringify(doc.data(), null, 2));
    });
  }
}

async function writeDocument(collection, docId) {
  if (!collection || !docId) {
    console.error('Collection and document ID required');
    return;
  }

  // Read JSON from stdin
  const chunks = [];
  for await (const chunk of process.stdin) {
    chunks.push(chunk);
  }
  const input = Buffer.concat(chunks).toString().trim();

  if (!input) {
    console.error('No JSON data provided. Pipe JSON to stdin.');
    return;
  }

  const data = JSON.parse(input);

  // Add timestamps
  data.updatedAt = admin.firestore.Timestamp.now();
  if (!data.createdAt) {
    data.createdAt = admin.firestore.Timestamp.now();
  }

  await db.collection(collection).doc(docId).set(data, { merge: true });
  console.log(`✅ Document written: ${collection}/${docId}`);
}

async function deleteDocument(collection, docId) {
  if (!collection || !docId) {
    console.error('Collection and document ID required');
    return;
  }

  await db.collection(collection).doc(docId).delete();
  console.log(`✅ Document deleted: ${collection}/${docId}`);
}

async function listAuthUsers() {
  const result = await auth.listUsers(100);
  console.log(`\n👥 Firebase Auth Users (${result.users.length}):\n`);
  result.users.forEach(user => {
    console.log('---');
    console.log('UID:', user.uid);
    console.log('Email:', user.email);
    console.log('Display Name:', user.displayName || 'N/A');
    console.log('Email Verified:', user.emailVerified);
    console.log('Created:', user.metadata.creationTime);
  });
}

async function listCollections() {
  const collections = await db.listCollections();
  console.log('\n📁 Root Collections:\n');
  collections.forEach(col => {
    console.log('  -', col.id);
  });
}

async function createGroup(name) {
  if (!name) {
    console.error('Group name required');
    return;
  }

  const groupRef = db.collection('groups').doc();
  const now = admin.firestore.Timestamp.now();

  await groupRef.set({
    name: name,
    createdBy: 'system',
    createdAt: now,
  });

  console.log(`✅ Group created: ${groupRef.id}`);
  console.log('Name:', name);
}

async function createTask() {
  const taskRef = db.collection('tasks').doc();
  const now = admin.firestore.Timestamp.now();

  const task = {
    title: 'مهمة تجريبية',
    description: 'هذه مهمة تجريبية للاختبار',
    createdBy: 'system',
    assignToAll: true,
    groupIds: [],
    isRecurring: false,
    status: 'active',
    createdAt: now,
    updatedAt: now,
  };

  await taskRef.set(task);
  console.log(`✅ Task created: ${taskRef.id}`);
  console.log(JSON.stringify(task, null, 2));
}

main();
