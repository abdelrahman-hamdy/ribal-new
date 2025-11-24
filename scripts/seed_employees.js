/**
 * Seed Employee Users to Firestore
 * Run: node scripts/seed_employees.js
 */

const https = require('https');
const fs = require('fs');

const PROJECT_ID = 'ribal-4ac8c';
const ADMIN_USER_ID = 'A6pMIz5ajQR38nAdYztpXboHYN22';

// Existing group IDs from Firestore
const GROUP_IDS = {
  development: 'hnluJiTVDvXpoj0En2e4',  // فريق التطوير
  marketing: 'KCBuJxdJ5DIJhvksacBj',     // فريق التسويق
  support: 'fMIh3ariQxyhCKZ0UvuK',       // فريق الدعم الفني
};

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

async function makeRequest(method, path, data, token) {
  return new Promise((resolve, reject) => {
    const postData = data ? JSON.stringify(data) : '';
    const options = {
      hostname: 'firestore.googleapis.com',
      port: 443,
      path: `/v1/projects/${PROJECT_ID}/databases/(default)/documents${path}`,
      method: method,
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
    if (postData) req.write(postData);
    req.end();
  });
}

function createDocument(fields) {
  const now = new Date().toISOString();
  return {
    fields: Object.entries(fields).reduce((acc, [key, value]) => {
      if (value === null) {
        acc[key] = { nullValue: null };
      } else if (typeof value === 'boolean') {
        acc[key] = { booleanValue: value };
      } else if (typeof value === 'number') {
        acc[key] = { integerValue: String(value) };
      } else if (Array.isArray(value)) {
        acc[key] = {
          arrayValue: {
            values: value.map(v => ({ stringValue: v }))
          }
        };
      } else if (key.includes('At')) {
        acc[key] = { timestampValue: now };
      } else {
        acc[key] = { stringValue: String(value) };
      }
      return acc;
    }, {}),
  };
}

// Generate a fake user ID (in real app, this would be Firebase Auth UID)
function generateFakeUserId() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  for (let i = 0; i < 28; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

async function seedEmployees() {
  console.log('👥 Seeding Employee Users...\n');

  const token = getAccessToken();
  if (!token) {
    console.error('❌ Could not get Firebase access token.');
    console.log('\nPlease run: firebase login');
    process.exit(1);
  }

  console.log('✅ Got access token\n');

  // Employee data - these are Firestore user documents
  // In production, the ID would match their Firebase Auth UID
  const employees = [
    {
      id: generateFakeUserId(),
      firstName: 'أحمد',
      lastName: 'محمد',
      email: 'ahmed@ribal.com',
      role: 'employee',
      groupId: GROUP_IDS.development,
      managedGroupIds: [],
      canAssignToAll: false,
      fcmTokens: [],
    },
    {
      id: generateFakeUserId(),
      firstName: 'فاطمة',
      lastName: 'علي',
      email: 'fatima@ribal.com',
      role: 'employee',
      groupId: GROUP_IDS.development,
      managedGroupIds: [],
      canAssignToAll: false,
      fcmTokens: [],
    },
    {
      id: generateFakeUserId(),
      firstName: 'محمود',
      lastName: 'حسن',
      email: 'mahmoud@ribal.com',
      role: 'employee',
      groupId: GROUP_IDS.marketing,
      managedGroupIds: [],
      canAssignToAll: false,
      fcmTokens: [],
    },
    {
      id: generateFakeUserId(),
      firstName: 'نورا',
      lastName: 'أحمد',
      email: 'noura@ribal.com',
      role: 'employee',
      groupId: GROUP_IDS.support,
      managedGroupIds: [],
      canAssignToAll: false,
      fcmTokens: [],
    },
    {
      id: generateFakeUserId(),
      firstName: 'خالد',
      lastName: 'سعيد',
      email: 'khaled@ribal.com',
      role: 'manager',
      groupId: null,
      managedGroupIds: [GROUP_IDS.development, GROUP_IDS.marketing],
      canAssignToAll: false,
      fcmTokens: [],
    },
  ];

  try {
    console.log('👤 Creating employee users...');
    const createdUserIds = [];

    for (const emp of employees) {
      const userId = emp.id;
      const userData = {
        firstName: emp.firstName,
        lastName: emp.lastName,
        email: emp.email,
        role: emp.role,
        groupId: emp.groupId,
        managedGroupIds: emp.managedGroupIds,
        canAssignToAll: emp.canAssignToAll,
        fcmTokens: emp.fcmTokens,
        createdAt: '',
        updatedAt: '',
      };

      const doc = createDocument(userData);
      // Create document with specific ID
      await makeRequest('PATCH', `/users/${userId}?updateMask.fieldPaths=firstName&updateMask.fieldPaths=lastName&updateMask.fieldPaths=email&updateMask.fieldPaths=role&updateMask.fieldPaths=groupId&updateMask.fieldPaths=managedGroupIds&updateMask.fieldPaths=canAssignToAll&updateMask.fieldPaths=fcmTokens&updateMask.fieldPaths=createdAt&updateMask.fieldPaths=updatedAt`, doc, token);

      createdUserIds.push(userId);
      console.log(`  ✅ Created ${emp.role}: ${emp.firstName} ${emp.lastName} (${emp.email})`);
    }

    // Create some task completions for employees
    console.log('\n📝 Creating task completions...');

    // Get existing tasks
    const tasksResponse = await makeRequest('GET', '/tasks?pageSize=10', null, token);
    const tasks = tasksResponse.documents || [];

    if (tasks.length > 0) {
      for (let i = 0; i < Math.min(3, tasks.length); i++) {
        const task = tasks[i];
        const taskId = task.name.split('/').pop();
        const userId = createdUserIds[i % createdUserIds.length];

        const completion = {
          taskId: taskId,
          userId: userId,
          status: i === 0 ? 'completed' : 'pending',
          notes: i === 0 ? 'تم إنجاز المهمة بنجاح' : '',
          completedAt: i === 0 ? '' : null,
          createdAt: '',
          updatedAt: '',
        };

        const doc = createDocument(completion);
        await makeRequest('POST', '/task_completions', doc, token);
        console.log(`  ✅ Created completion for task: ${taskId}`);
      }
    }

    console.log('\n✨ Employee seeding complete!');
    console.log(`   - ${employees.length} users created`);
    console.log('   - Task completions created');
    console.log('\n📋 Created Users:');
    employees.forEach(emp => {
      console.log(`   • ${emp.firstName} ${emp.lastName} (${emp.email}) - ${emp.role}`);
    });
    console.log('\n🔄 Hot restart your Flutter app to see the data!');

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

seedEmployees();
