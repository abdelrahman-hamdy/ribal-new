/**
 * Create Firebase Auth Users
 * Run: node scripts/create_auth_users.js
 */

const https = require('https');
const fs = require('fs');

const PROJECT_ID = 'ribal-4ac8c';

// Employees to create with their Firestore document IDs
const EMPLOYEES = [
  {
    firestoreId: 'P3QSjUIpNGl2CtsJT3WGGriyLGj3',
    email: 'ahmed@ribal.com',
    password: 'Test123456',
    displayName: 'أحمد محمد',
  },
  {
    firestoreId: 'Vvm9n5KReYE5LMYdJhVMIHnniEkx',
    email: 'fatima@ribal.com',
    password: 'Test123456',
    displayName: 'فاطمة علي',
  },
  {
    firestoreId: 'mgkcbBuZeymYsvTOyhJYkLc4p6Gs',
    email: 'mahmoud@ribal.com',
    password: 'Test123456',
    displayName: 'محمود حسن',
  },
  {
    firestoreId: 'H4eQ6B2WeKSXmnoLuOGkGM0hUAaH',
    email: 'noura@ribal.com',
    password: 'Test123456',
    displayName: 'نورا أحمد',
  },
  {
    firestoreId: '7bxq3B9QzZNZJVVntMOa8OglriYL',
    email: 'khaled@ribal.com',
    password: 'Test123456',
    displayName: 'خالد سعيد',
  },
];

function getAccessToken() {
  try {
    const configPath = `${process.env.HOME}/.config/configstore/firebase-tools.json`;
    const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    if (config.tokens && config.tokens.access_token) {
      return config.tokens.access_token;
    }
    throw new Error('No access token found');
  } catch (e) {
    console.error('Error getting token:', e.message);
    return null;
  }
}

async function createAuthUser(email, password, displayName, localId, token) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify({
      localId: localId,
      email: email,
      password: password,
      displayName: displayName,
      emailVerified: true, // Pre-verify for testing
    });

    const options = {
      hostname: 'identitytoolkit.googleapis.com',
      port: 443,
      path: `/v1/projects/${PROJECT_ID}/accounts`,
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData),
      },
    };

    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(JSON.parse(body || '{}'));
        } else {
          reject(new Error(`HTTP ${res.statusCode}: ${body}`));
        }
      });
    });

    req.on('error', reject);
    req.write(postData);
    req.end();
  });
}

async function updateFirestoreUserId(oldId, newId, token) {
  // This updates the Firestore document ID by copying data to new doc and deleting old
  return new Promise(async (resolve, reject) => {
    try {
      // First, get the existing document
      const getOptions = {
        hostname: 'firestore.googleapis.com',
        port: 443,
        path: `/v1/projects/${PROJECT_ID}/databases/(default)/documents/users/${oldId}`,
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
        },
      };

      const docData = await new Promise((res, rej) => {
        const req = https.request(getOptions, (response) => {
          let body = '';
          response.on('data', (chunk) => body += chunk);
          response.on('end', () => {
            if (response.statusCode >= 200 && response.statusCode < 300) {
              res(JSON.parse(body));
            } else {
              rej(new Error(`GET failed: ${body}`));
            }
          });
        });
        req.on('error', rej);
        req.end();
      });

      // Create new document with new ID
      const createOptions = {
        hostname: 'firestore.googleapis.com',
        port: 443,
        path: `/v1/projects/${PROJECT_ID}/databases/(default)/documents/users?documentId=${newId}`,
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      };

      const createData = JSON.stringify({ fields: docData.fields });

      await new Promise((res, rej) => {
        const req = https.request(createOptions, (response) => {
          let body = '';
          response.on('data', (chunk) => body += chunk);
          response.on('end', () => {
            if (response.statusCode >= 200 && response.statusCode < 300) {
              res(JSON.parse(body || '{}'));
            } else {
              rej(new Error(`CREATE failed: ${body}`));
            }
          });
        });
        req.on('error', rej);
        req.write(createData);
        req.end();
      });

      // Delete old document
      const deleteOptions = {
        hostname: 'firestore.googleapis.com',
        port: 443,
        path: `/v1/projects/${PROJECT_ID}/databases/(default)/documents/users/${oldId}`,
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`,
        },
      };

      await new Promise((res, rej) => {
        const req = https.request(deleteOptions, (response) => {
          let body = '';
          response.on('data', (chunk) => body += chunk);
          response.on('end', () => {
            if (response.statusCode >= 200 && response.statusCode < 300) {
              res(true);
            } else {
              rej(new Error(`DELETE failed: ${body}`));
            }
          });
        });
        req.on('error', rej);
        req.end();
      });

      resolve(true);
    } catch (e) {
      reject(e);
    }
  });
}

async function main() {
  console.log('🔐 Creating Firebase Auth Users...\n');

  const token = getAccessToken();
  if (!token) {
    console.error('❌ Could not get Firebase access token.');
    console.log('\nPlease run: firebase login');
    process.exit(1);
  }

  console.log('✅ Got access token\n');

  for (const emp of EMPLOYEES) {
    try {
      console.log(`Creating auth user: ${emp.email}...`);

      const result = await createAuthUser(
        emp.email,
        emp.password,
        emp.displayName,
        null, // Let Firebase generate the UID
        token
      );

      const newUid = result.localId;
      console.log(`  ✅ Auth user created with UID: ${newUid}`);

      // Update Firestore document to match the new UID
      if (newUid !== emp.firestoreId) {
        console.log(`  📝 Updating Firestore document ID...`);
        await updateFirestoreUserId(emp.firestoreId, newUid, token);
        console.log(`  ✅ Firestore document updated`);
      }

    } catch (error) {
      if (error.message.includes('EMAIL_EXISTS')) {
        console.log(`  ⚠️  User ${emp.email} already exists in Auth`);
      } else {
        console.error(`  ❌ Error creating ${emp.email}:`, error.message);
      }
    }
  }

  console.log('\n✨ Auth user creation complete!');
  console.log('\n📋 Test Credentials (all passwords: Test123456):');
  EMPLOYEES.forEach(emp => {
    console.log(`   • ${emp.email}`);
  });
}

main();
