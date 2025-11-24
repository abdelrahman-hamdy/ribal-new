# Manual Seed Data for Firebase Console

Go to: https://console.firebase.google.com/project/ribal-4ac8c/firestore

---

## 1. Create Groups Collection

Collection: `groups`

### Document 1: (auto-generate ID)
```
name: "فريق التطوير"
createdBy: "A6pMIz5ajQR38nAdYztpXboHYN22"
createdAt: (timestamp - click 'Add field' > Timestamp > now)
```

### Document 2: (auto-generate ID)
```
name: "فريق التسويق"
createdBy: "A6pMIz5ajQR38nAdYztpXboHYN22"
createdAt: (timestamp)
```

### Document 3: (auto-generate ID)
```
name: "فريق الدعم الفني"
createdBy: "A6pMIz5ajQR38nAdYztpXboHYN22"
createdAt: (timestamp)
```

---

## 2. Create Tasks Collection

Collection: `tasks`

### Task 1: (auto-generate ID)
```
title: "مراجعة التقرير الشهري"
description: "مراجعة وتدقيق التقرير الشهري للمبيعات"
isRecurring: false (boolean)
isActive: true (boolean)
isArchived: false (boolean)
assigneeSelection: "all"
selectedGroupIds: [] (array - empty)
selectedUserIds: [] (array - empty)
labelIds: [] (array - empty)
attachmentUrl: null
createdBy: "A6pMIz5ajQR38nAdYztpXboHYN22"
createdAt: (timestamp)
updatedAt: (timestamp)
```

### Task 2: (auto-generate ID)
```
title: "الاجتماع الأسبوعي"
description: "حضور الاجتماع الأسبوعي لمناقشة تقدم المشاريع"
isRecurring: true (boolean)
isActive: true (boolean)
isArchived: false (boolean)
assigneeSelection: "all"
selectedGroupIds: [] (array - empty)
selectedUserIds: [] (array - empty)
labelIds: [] (array - empty)
attachmentUrl: null
createdBy: "A6pMIz5ajQR38nAdYztpXboHYN22"
createdAt: (timestamp)
updatedAt: (timestamp)
```

### Task 3: (auto-generate ID)
```
title: "تحديث الموقع الإلكتروني"
description: "تحديث محتوى الصفحة الرئيسية"
isRecurring: false (boolean)
isActive: true (boolean)
isArchived: false (boolean)
assigneeSelection: "groups"
selectedGroupIds: ["<GROUP_ID_1>"] (array - copy ID from groups)
selectedUserIds: [] (array - empty)
labelIds: [] (array - empty)
attachmentUrl: null
createdBy: "A6pMIz5ajQR38nAdYztpXboHYN22"
createdAt: (timestamp)
updatedAt: (timestamp)
```

---

## 3. Create Labels Collection

Collection: `labels`

### Label 1:
```
name: "عاجل"
color: "#EF4444"
isActive: true (boolean)
createdBy: "A6pMIz5ajQR38nAdYztpXboHYN22"
createdAt: (timestamp)
```

### Label 2:
```
name: "مهم"
color: "#F59E0B"
isActive: true (boolean)
createdBy: "A6pMIz5ajQR38nAdYztpXboHYN22"
createdAt: (timestamp)
```

### Label 3:
```
name: "عادي"
color: "#3B82F6"
isActive: true (boolean)
createdBy: "A6pMIz5ajQR38nAdYztpXboHYN22"
createdAt: (timestamp)
```

---

## Quick Steps in Firebase Console:

1. Go to Firestore Database
2. Click "Start collection"
3. Enter collection name (e.g., "groups")
4. Click "Auto-ID" for document ID
5. Add fields one by one with correct types:
   - String fields: name, description, color, createdBy, assigneeSelection
   - Boolean fields: isRecurring, isActive, isArchived
   - Array fields: selectedGroupIds, selectedUserIds, labelIds
   - Timestamp fields: createdAt, updatedAt
6. Click "Save"
7. Repeat for other documents
