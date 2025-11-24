/**
 * Seed Firestore using REST API with Firebase CLI authentication
 */

const { execSync } = require('child_process');
const https = require('https');

const PROJECT_ID = 'ribal-4ac8c';
const ADMIN_USER_ID = 'A6pMIz5ajQR38nAdYztpXboHYN22';

// Command line args
const args = process.argv.slice(2);
const SEED_EMPLOYEES = args.includes('--employees') || args.includes('--all');
const SEED_ALL = args.includes('--all');

// Get access token from Firebase CLI
function getAccessToken() {
  try {
    // Read the firebase config file
    const fs = require('fs');
    const configPath = `${process.env.HOME}/.config/configstore/firebase-tools.json`;
    const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));

    // Get refresh token and exchange for access token
    const tokens = config.tokens;
    if (tokens && tokens.access_token) {
      return tokens.access_token;
    }
    throw new Error('No access token found');
  } catch (e) {
    console.error('Error getting token:', e.message);
    console.log('\nTrying firebase CLI directly...');

    // Alternative: use firebase CLI to get token
    try {
      const result = execSync('firebase login:ci --interactive 2>/dev/null || echo ""', { encoding: 'utf8' });
      return result.trim();
    } catch (e2) {
      return null;
    }
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

function createDocument(collectionId, fields) {
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

async function seedData() {
  console.log('🌱 Seeding Firestore with dummy data...\n');

  const token = getAccessToken();
  if (!token) {
    console.error('❌ Could not get Firebase access token.');
    console.log('\nPlease run: firebase login:ci');
    console.log('Then set FIREBASE_TOKEN environment variable');
    process.exit(1);
  }

  console.log('✅ Got access token\n');

  try {
    // Create groups
    console.log('📁 Creating groups...');
    const groups = [
      { name: 'فريق التطوير', createdBy: ADMIN_USER_ID, createdAt: '' },
      { name: 'فريق التسويق', createdBy: ADMIN_USER_ID, createdAt: '' },
      { name: 'فريق الدعم الفني', createdBy: ADMIN_USER_ID, createdAt: '' },
    ];

    const groupIds = [];
    for (const group of groups) {
      const doc = createDocument('groups', group);
      const result = await makeRequest('POST', '/groups', doc, token);
      const id = result.name?.split('/').pop();
      groupIds.push(id);
      console.log(`  ✅ Created: ${group.name}`);
    }

    // Create tasks
    console.log('\n📋 Creating tasks...');
    const tasks = [
      {
        title: 'مراجعة التقرير الشهري',
        description: 'مراجعة وتدقيق التقرير الشهري للمبيعات',
        isRecurring: false,
        isActive: true,
        isArchived: false,
        assigneeSelection: 'all',
        selectedGroupIds: [],
        selectedUserIds: [],
        labelIds: [],
        attachmentUrl: null,
        createdBy: ADMIN_USER_ID,
        createdAt: '',
        updatedAt: '',
      },
      {
        title: 'الاجتماع الأسبوعي',
        description: 'حضور الاجتماع الأسبوعي لمناقشة المشاريع',
        isRecurring: true,
        isActive: true,
        isArchived: false,
        assigneeSelection: 'all',
        selectedGroupIds: [],
        selectedUserIds: [],
        labelIds: [],
        attachmentUrl: null,
        createdBy: ADMIN_USER_ID,
        createdAt: '',
        updatedAt: '',
      },
      {
        title: 'تحديث الموقع الإلكتروني',
        description: 'تحديث محتوى الصفحة الرئيسية',
        isRecurring: false,
        isActive: true,
        isArchived: false,
        assigneeSelection: 'groups',
        selectedGroupIds: groupIds.slice(0, 1),
        selectedUserIds: [],
        labelIds: [],
        attachmentUrl: null,
        createdBy: ADMIN_USER_ID,
        createdAt: '',
        updatedAt: '',
      },
    ];

    for (const task of tasks) {
      const doc = createDocument('tasks', task);
      await makeRequest('POST', '/tasks', doc, token);
      console.log(`  ✅ Created: ${task.title}`);
    }

    // Create labels
    console.log('\n🏷️  Creating labels...');
    const labels = [
      { name: 'عاجل', color: '#EF4444', isActive: true, createdBy: ADMIN_USER_ID, createdAt: '' },
      { name: 'مهم', color: '#F59E0B', isActive: true, createdBy: ADMIN_USER_ID, createdAt: '' },
      { name: 'عادي', color: '#3B82F6', isActive: true, createdBy: ADMIN_USER_ID, createdAt: '' },
    ];

    for (const label of labels) {
      const doc = createDocument('labels', label);
      await makeRequest('POST', '/labels', doc, token);
      console.log(`  ✅ Created: ${label.name}`);
    }

    console.log('\n✨ Seeding complete!');
    console.log('🔄 Hot restart your Flutter app to see the data!');

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

seedData();
