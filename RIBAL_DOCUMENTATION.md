# Ribal - Task Management App Documentation

> **Version**: 1.0.0
> **Last Updated**: 2025-01-23
> **Status**: In Development

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tech Stack](#2-tech-stack)
3. [User Roles & Permissions](#3-user-roles--permissions)
4. [Registration & Authentication](#4-registration--authentication)
5. [Core Concepts](#5-core-concepts)
6. [Features by Role](#6-features-by-role)
7. [Data Models](#7-data-models)
8. [Firebase Structure](#8-firebase-structure)
9. [Notification System](#9-notification-system)
10. [Design System](#10-design-system)
11. [Navigation Structure](#11-navigation-structure)
12. [Business Rules](#12-business-rules)
13. [Cloud Functions](#13-cloud-functions)
14. [Project Structure](#14-project-structure)
15. [Implementation Progress](#15-implementation-progress)

---

## 1. Project Overview

**Ribal** is a task management application designed for mid-size companies. It enables administrators and managers to create, assign, and track tasks for employees with a robust notification system and comprehensive statistics.

### Key Features
- Multi-role user system (Admin, Manager, Employee)
- Smart invitation-based registration
- Task creation with labels and attachments
- Daily recurring tasks with automatic scheduling
- Assignment tracking with completion/apologize workflow
- Real-time notifications with deep linking
- Comprehensive statistics and performance tracking

---

## 2. Tech Stack

### Frontend
| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter | 3.x | Cross-platform framework |
| Dart | 3.2+ | Programming language |
| flutter_bloc | 8.1.6 | State management |
| GoRouter | 14.6.2 | Navigation & deep linking |
| Freezed | 2.5.7 | Immutable models & unions |
| Skeletonizer | 2.1.0 | Loading skeletons |
| fl_chart | 0.69.2 | Charts for statistics |

### Backend (Firebase)
| Service | Purpose |
|---------|---------|
| Firebase Auth | User authentication |
| Cloud Firestore | Database |
| Firebase Storage | File attachments |
| Firebase Cloud Messaging | Push notifications |
| Cloud Functions | Server-side logic & scheduled tasks |

### Key Packages
```yaml
# State Management
flutter_bloc: ^8.1.6
equatable: ^2.0.5

# Navigation
go_router: ^14.6.2

# Code Generation
freezed_annotation: ^2.4.4
json_annotation: ^4.9.0

# Firebase
firebase_core: ^3.8.0
firebase_auth: ^5.3.3
cloud_firestore: ^5.5.0
firebase_storage: ^12.3.6
firebase_messaging: ^15.1.6

# DI
get_it: ^8.0.2
injectable: ^2.5.0

# UI
skeletonizer: ^2.1.0
fl_chart: ^0.69.2
cached_network_image: ^3.4.1
iconsax: ^0.0.8
```

---

## 3. User Roles & Permissions

### Admin
- **Full system access**
- Create/edit/delete tasks
- Assign tasks to ANY user (managers & employees)
- Manage users (change roles, assign to groups)
- Manage groups, labels, whitelist, invitations
- Configure global settings (recurring time, deadline)
- View full statistics
- Access control panel

### Manager
- **Limited task management**
- Receive tasks from admin (acts as employee)
- Create tasks for assigned employees only
- Can assign to: all employees OR specific group(s) (configured by admin)
- Cannot assign tasks to other managers
- View performance of employees they can assign to
- No access to control panel

### Employee
- **Task execution only**
- View assigned tasks
- Mark tasks as done
- Apologize for tasks (with optional message)
- Reactivate apologized tasks (before deadline)
- View own profile

### Role Conversion Rules
- Admin can convert Manager ↔ Employee freely
- System must handle:
  - Manager → Employee: Remove managed groups permissions
  - Employee → Manager: Admin must configure assignable groups

---

## 4. Registration & Authentication

### Registration Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    User Enters Info                          │
│         (firstName, lastName, email, password)               │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │  Check Whitelist      │
              │  (by email)           │
              └───────────┬───────────┘
                          │
            ┌─────────────┴─────────────┐
            │                           │
            ▼                           ▼
   ┌─────────────────┐        ┌─────────────────┐
   │ Email Found     │        │ Email Not Found │
   │ in Whitelist    │        │ in Whitelist    │
   └────────┬────────┘        └────────┬────────┘
            │                          │
            ▼                          ▼
   ┌─────────────────┐        ┌─────────────────┐
   │ Send Email      │        │ Show Invitation │
   │ Verification    │        │ Code Field      │
   │ Code            │        │                 │
   └────────┬────────┘        └────────┬────────┘
            │                          │
            ▼                          ▼
   ┌─────────────────┐        ┌─────────────────┐
   │ User Confirms   │        │ Validate Code   │
   │ Email           │        │ (single-use)    │
   └────────┬────────┘        └────────┬────────┘
            │                          │
            └──────────┬───────────────┘
                       │
                       ▼
              ┌─────────────────┐
              │ Create Account  │
              │ with Role from  │
              │ Whitelist/Code  │
              └─────────────────┘
```

### Whitelist Rules
- Created by admin with email + role
- **Permanent** until manually deleted
- One whitelist entry per email
- Role is assigned automatically on registration

### Invitation Code Rules
- Created by admin with role
- **Single-use** (one code = one registration)
- **No expiration**
- Any user with a manager code registers as manager
- Any user with an employee code registers as employee

---

## 5. Core Concepts

### Task vs Assignment

```
┌─────────────────────────────────────────────────────────────┐
│                         TASK                                 │
│  - Created once by admin/manager                            │
│  - Contains: title, description, labels, attachment         │
│  - Can be recurring or one-time                             │
│  - Has many assignments                                      │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ 1:N relationship
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      ASSIGNMENTS                             │
│  - One per assigned user                                    │
│  - Contains: status, scheduledDate, completedAt, etc.       │
│  - Status: pending → completed OR apologized                │
│  - Apologized can be reactivated (before deadline)          │
└─────────────────────────────────────────────────────────────┘
```

**Example**: Task assigned to 5 users = 1 Task + 5 Assignments

### Assignment Status Flow

```
                    ┌─────────┐
                    │ PENDING │
                    └────┬────┘
                         │
           ┌─────────────┴─────────────┐
           │                           │
           ▼                           ▼
    ┌─────────────┐            ┌─────────────┐
    │ COMPLETED   │            │ APOLOGIZED  │
    │ (by self or │            │ (by self)   │
    │  creator)   │            └──────┬──────┘
    └─────────────┘                   │
                                      │ can reactivate
                                      │ (before deadline)
                                      ▼
                              ┌─────────────┐
                              │  PENDING    │
                              │ (again)     │
                              └─────────────┘
```

### Recurring Tasks

- When `isRecurring: true`, task is automatically re-scheduled daily
- Scheduled at time configured by admin (default: 8:00 AM)
- Creates new assignments for all original assignees each day
- Admin can:
  - **Pause**: Set `isActive: false` (stops scheduling, keeps task)
  - **Archive**: Move to archive (can restore and reschedule later)
  - **Stop permanently**: Delete or archive

### Task Deadline

- Global deadline time configured by admin (default: 8:00 PM)
- Applies to ALL tasks
- After deadline:
  - Employee cannot reactivate apologized assignments
  - Statistics count task as incomplete

### Archive

- Storage for inactive tasks
- Tasks can be copied to archive for future use
- Archived tasks can be restored and rescheduled
- Useful for template tasks

---

## 6. Features by Role

### Admin Features

#### Home Page
- Today's tasks overview (total, completed, pending, apologized)
- Employee performance summary
- Quick stats cards
- Button to full statistics page

#### Control Panel
| Section | Features |
|---------|----------|
| Users | List all users, change roles, assign to groups |
| Groups | Create/edit/delete employee groups |
| Labels | Create/edit/delete/activate labels |
| Whitelist | Add/remove whitelisted emails with roles |
| Invitations | Generate codes, view usage status |
| Settings | Configure recurring time, deadline time |

#### Tasks Management
- Create tasks with:
  - Title, description
  - Multiple labels (from active labels)
  - Optional attachment
  - Recurring toggle
  - Assignees: All users / Groups / Custom selection
- Edit tasks (add/remove assignees)
- View task with all assignments status
- Archive tasks
- Copy tasks to archive

#### Statistics Page
- Time filters: Today, This Week, This Month
- Metrics:
  - Total tasks created
  - Completion rate
  - Apologize rate
  - On-time completion rate
  - Tasks per employee
  - Top performers
  - Performance trends

### Manager Features

#### My Tasks Page (as assignee)
- View tasks assigned by admin
- Mark as done
- Apologize with message
- Reactivate before deadline

#### Team Tasks Page
- Create tasks for assigned employees
- View created tasks with assignment statuses
- Performance of assignable employees

#### Profile Page
- View/edit profile info
- Logout

### Employee Features

#### Today's Tasks Page
- List of today's assignments
- Mark as done
- Apologize with optional message
- Reactivate apologized tasks (before deadline)

#### Profile Page
- View/edit profile info
- Logout

---

## 7. Data Models

### User
```dart
class User {
  String id;
  String firstName;
  String lastName;
  String email;
  UserRole role; // admin, manager, employee
  String? groupId; // single group (for employees)
  List<String> managedGroupIds; // for managers
  bool canAssignToAll; // for managers
  List<String> fcmTokens;
  DateTime createdAt;
  DateTime updatedAt;
}
```

### Task
```dart
class Task {
  String id;
  String title;
  String description;
  List<String> labelIds;
  String? attachmentUrl;
  bool isRecurring;
  bool isActive; // for recurring tasks
  bool isArchived;
  String createdBy;
  AssigneeSelection assigneeSelection; // all, groups, custom
  List<String>? selectedGroupIds;
  List<String>? selectedUserIds;
  DateTime createdAt;
  DateTime updatedAt;
}
```

### Assignment
```dart
class Assignment {
  String id;
  String taskId;
  String userId;
  AssignmentStatus status; // pending, completed, apologized
  String? apologizeMessage;
  DateTime? completedAt;
  DateTime? apologizedAt;
  String? markedDoneBy; // creator or self
  DateTime scheduledDate;
  DateTime createdAt;
}
```

### Group
```dart
class Group {
  String id;
  String name;
  String createdBy;
  DateTime createdAt;
}
```

### Label
```dart
class Label {
  String id;
  String name;
  String color; // hex color
  bool isActive;
  String createdBy;
  DateTime createdAt;
}
```

### WhitelistEntry
```dart
class WhitelistEntry {
  String id;
  String email;
  UserRole role;
  String createdBy;
  DateTime createdAt;
}
```

### Invitation
```dart
class Invitation {
  String code; // also used as document ID
  UserRole role;
  bool used;
  String? usedBy;
  String createdBy;
  DateTime createdAt;
  DateTime? usedAt;
}
```

### AppNotification
```dart
class AppNotification {
  String id;
  String userId;
  NotificationType type;
  String title;
  String body;
  String iconName;
  String iconColor;
  String? deepLink;
  bool isRead;
  DateTime createdAt;
}
```

### AppSettings
```dart
class AppSettings {
  String recurringTaskTime; // "08:00"
  String taskDeadline; // "20:00"
}
```

---

## 8. Firebase Structure

### Collections

```
firestore/
├── users/
│   └── {userId}
│       ├── firstName: string
│       ├── lastName: string
│       ├── email: string
│       ├── role: 'admin' | 'manager' | 'employee'
│       ├── groupId: string?
│       ├── managedGroupIds: string[]
│       ├── canAssignToAll: bool
│       ├── fcmTokens: string[]
│       ├── createdAt: timestamp
│       └── updatedAt: timestamp
│
├── whitelist/
│   └── {id}
│       ├── email: string
│       ├── role: string
│       ├── createdBy: string
│       └── createdAt: timestamp
│
├── invitations/
│   └── {code}
│       ├── code: string
│       ├── role: string
│       ├── used: bool
│       ├── usedBy: string?
│       ├── usedAt: timestamp?
│       ├── createdBy: string
│       └── createdAt: timestamp
│
├── groups/
│   └── {groupId}
│       ├── name: string
│       ├── createdBy: string
│       └── createdAt: timestamp
│
├── labels/
│   └── {labelId}
│       ├── name: string
│       ├── color: string
│       ├── isActive: bool
│       ├── createdBy: string
│       └── createdAt: timestamp
│
├── tasks/
│   └── {taskId}
│       ├── title: string
│       ├── description: string
│       ├── labelIds: string[]
│       ├── attachmentUrl: string?
│       ├── isRecurring: bool
│       ├── isActive: bool
│       ├── isArchived: bool
│       ├── assigneeSelection: 'all' | 'groups' | 'custom'
│       ├── selectedGroupIds: string[]?
│       ├── selectedUserIds: string[]?
│       ├── createdBy: string
│       ├── createdAt: timestamp
│       └── updatedAt: timestamp
│
├── assignments/
│   └── {assignmentId}
│       ├── taskId: string
│       ├── userId: string
│       ├── status: 'pending' | 'completed' | 'apologized'
│       ├── apologizeMessage: string?
│       ├── completedAt: timestamp?
│       ├── apologizedAt: timestamp?
│       ├── markedDoneBy: string?
│       ├── scheduledDate: timestamp
│       └── createdAt: timestamp
│
├── notifications/
│   └── {notificationId}
│       ├── userId: string
│       ├── type: string
│       ├── title: string
│       ├── body: string
│       ├── iconName: string
│       ├── iconColor: string
│       ├── deepLink: string?
│       ├── isRead: bool
│       └── createdAt: timestamp
│
└── settings/
    └── global
        ├── recurringTaskTime: string
        └── taskDeadline: string
```

### Firestore Indexes Required

```
// Assignments by user and date
assignments: userId ASC, scheduledDate DESC

// Assignments by task
assignments: taskId ASC, createdAt DESC

// Notifications by user
notifications: userId ASC, createdAt DESC

// Tasks by creator
tasks: createdBy ASC, createdAt DESC

// Active recurring tasks
tasks: isRecurring ASC, isActive ASC, isArchived ASC
```

---

## 9. Notification System

### Notification Types

| Type | Icon | Color | Trigger |
|------|------|-------|---------|
| `taskAssigned` | task_add | Blue (#2563EB) | New task assigned to user |
| `taskCompleted` | check_circle | Green (#10B981) | Assignee marks task done |
| `taskApologized` | warning | Orange (#F59E0B) | Assignee apologizes for task |
| `taskReactivated` | refresh | Purple (#8B5CF6) | Assignee reactivates task |
| `recurringScheduled` | repeat | Teal (#14B8A6) | Daily recurring task created |
| `invitationAccepted` | person_add | Indigo (#6366F1) | New user joins via invitation |
| `roleChanged` | swap_horiz | Amber (#F59E0B) | User role changed |
| `taskMarkedDone` | done_all | Green (#10B981) | Creator marks assignment done |

### Deep Links

| Notification Type | Deep Link Format |
|-------------------|------------------|
| taskAssigned | `/assignments/{assignmentId}` |
| taskCompleted | `/tasks/{taskId}` |
| taskApologized | `/tasks/{taskId}` |
| taskReactivated | `/tasks/{taskId}` |
| recurringScheduled | `/assignments/{assignmentId}` |
| invitationAccepted | `/users/{userId}` |
| roleChanged | `/profile` |
| taskMarkedDone | `/assignments/{assignmentId}` |

### Push Notification Payload

```json
{
  "notification": {
    "title": "مهمة جديدة",
    "body": "تم تعيين مهمة جديدة لك: تحضير التقرير"
  },
  "data": {
    "type": "taskAssigned",
    "deepLink": "/assignments/abc123",
    "notificationId": "notif123"
  }
}
```

---

## 10. Design System

### Color Palette

```dart
// Primary - Professional Blue
static const primary = Color(0xFF2563EB);
static const primaryLight = Color(0xFF3B82F6);
static const primaryDark = Color(0xFF1D4ED8);

// Secondary - Warm Accent
static const secondary = Color(0xFFF59E0B);
static const secondaryLight = Color(0xFFFBBF24);

// Semantic Colors
static const success = Color(0xFF10B981);
static const error = Color(0xFFEF4444);
static const warning = Color(0xFFF59E0B);
static const info = Color(0xFF3B82F6);

// Status Colors
static const pending = Color(0xFF6B7280);
static const completed = Color(0xFF10B981);
static const apologized = Color(0xFFF59E0B);

// Neutrals
static const background = Color(0xFFF8FAFC);
static const surface = Color(0xFFFFFFFF);
static const surfaceVariant = Color(0xFFF1F5F9);
static const textPrimary = Color(0xFF1E293B);
static const textSecondary = Color(0xFF64748B);
static const textTertiary = Color(0xFF94A3B8);
static const border = Color(0xFFE2E8F0);
static const divider = Color(0xFFF1F5F9);
```

### Typography

**Font Family**: Cairo (Arabic-optimized)

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| displayLarge | 32 | Bold | Page titles |
| displayMedium | 28 | Bold | Section headers |
| headlineLarge | 24 | SemiBold | Card titles |
| headlineMedium | 20 | SemiBold | Subsections |
| titleLarge | 18 | SemiBold | List item titles |
| titleMedium | 16 | Medium | Subtitles |
| bodyLarge | 16 | Regular | Body text |
| bodyMedium | 14 | Regular | Secondary text |
| bodySmall | 12 | Regular | Captions |
| labelLarge | 14 | Medium | Buttons |
| labelMedium | 12 | Medium | Chips, badges |
| labelSmall | 10 | Medium | Tiny labels |

### Spacing Scale

```dart
static const xxs = 2.0;
static const xs = 4.0;
static const sm = 8.0;
static const md = 16.0;
static const lg = 24.0;
static const xl = 32.0;
static const xxl = 48.0;
static const xxxl = 64.0;
```

### Border Radius

```dart
static const radiusXs = 4.0;
static const radiusSm = 8.0;
static const radiusMd = 12.0;
static const radiusLg = 16.0;
static const radiusXl = 24.0;
static const radiusFull = 999.0;
```

### Shadows

```dart
// Subtle shadow for cards
static const shadowSm = BoxShadow(
  color: Color(0x0A000000),
  blurRadius: 4,
  offset: Offset(0, 2),
);

// Medium shadow for elevated elements
static const shadowMd = BoxShadow(
  color: Color(0x14000000),
  blurRadius: 8,
  offset: Offset(0, 4),
);

// Large shadow for modals/dialogs
static const shadowLg = BoxShadow(
  color: Color(0x1F000000),
  blurRadius: 16,
  offset: Offset(0, 8),
);
```

### Reusable Components

| Component | Description |
|-----------|-------------|
| `RibalButton` | Primary, secondary, text, icon variants |
| `RibalTextField` | Standard input with validation |
| `RibalCard` | Consistent card styling |
| `RibalChip` | For labels and tags |
| `RibalAvatar` | User avatars with initials fallback |
| `RibalBadge` | Status badges and counters |
| `RibalBottomSheet` | Consistent bottom sheet |
| `RibalDialog` | Confirmation and input dialogs |
| `TaskCard` | Task list item |
| `AssignmentCard` | Assignment list item |
| `UserTile` | User list item |
| `StatCard` | Statistics card |
| `EmptyState` | Empty list placeholder |
| `ErrorState` | Error display with retry |
| `LoadingState` | Skeletonized loading |

### Floating Action Button Guidelines

**Rule:** All FloatingActionButtons should use **icon-only** style (no labels).

```dart
// CORRECT - Icon only
FloatingActionButton(
  onPressed: () => _showAddDialog(context),
  child: const Icon(Icons.add),
)

// INCORRECT - Do not use extended FAB with labels
FloatingActionButton.extended(
  onPressed: () => _showAddDialog(context),
  icon: const Icon(Icons.add),
  label: const Text('إضافة'),  // ❌ No labels
)
```

**Rationale:**
- Cleaner, more minimal UI
- Consistent appearance across all screens
- Better support for RTL layouts
- Icon-only FABs are universally understood

### Skeletonizer Loading States

**Package**: [skeletonizer](https://pub.dev/packages/skeletonizer) v2.1.0

Skeletonizer automatically converts existing widgets into skeleton loading states with shimmer effects. This provides a consistent loading experience without creating separate skeleton widgets.

#### Core Principle: Use Fake Data

Instead of creating separate skeleton widgets, use **the same widget with fake data**. This ensures the skeleton perfectly matches the actual content layout.

```dart
// ✅ CORRECT: Use real widget with fake data
if (state.isLoading)
  Skeletonizer(
    enabled: true,
    enableSwitchAnimation: true,
    child: ListView.builder(
      itemCount: 3,
      itemBuilder: (_, i) => _ItemCard(item: ItemModel.fake()),
    ),
  )
else
  ListView.builder(
    itemCount: state.items.length,
    itemBuilder: (_, i) => _ItemCard(item: state.items[i]),
  )

// ❌ INCORRECT: Creating separate skeleton widget
if (state.isLoading)
  _ItemCardSkeleton()  // Don't do this!
```

#### Adding Fake Factory to Models

Each model that needs skeleton loading should have a `fake()` factory:

```dart
@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String firstName,
    required String lastName,
    // ... other fields
  }) = _UserModel;

  /// Create fake data for skeleton loading
  factory UserModel.fake() => UserModel(
    id: 'fake-id',
    firstName: 'اسم المستخدم',  // Arabic placeholder
    lastName: 'الكامل',
    email: 'fake@example.com',
    role: UserRole.employee,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}
```

#### Bloc State Pattern for Loading

Always ensure loading state is reset on both success AND error:

```dart
class MyState extends Equatable {
  final bool isLoading;
  final List<Item> items;
  final String? errorMessage;

  // Other fields...
}

// In your bloc handlers:
void _onDataReceived(DataReceived event, Emitter emit) {
  emit(state.copyWith(
    items: event.items,
    isLoading: false,  // ✅ Reset loading
  ));
}

void _onErrorReceived(ErrorReceived event, Emitter emit) {
  emit(state.copyWith(
    isLoading: false,  // ✅ Also reset on error!
    errorMessage: event.message,
  ));
}
```

#### Skeletonizer Configuration Options

```dart
Skeletonizer(
  enabled: true,                    // Toggle skeleton on/off
  enableSwitchAnimation: true,      // Smooth transition when content loads
  ignoreContainers: false,          // Set true to skip container shading
  child: YourWidget(),
)
```

#### Handling Images with Skeleton.replace

If your widget contains `NetworkImage`, use `Skeleton.replace` to avoid URL errors during loading:

```dart
Skeleton.replace(
  replacement: const Bone.square(size: 44),
  child: CircleAvatar(
    backgroundImage: NetworkImage(user.avatarUrl),
  ),
)
```

#### Complete Example: List with Skeleton Loading

```dart
class _AssigneesSection extends StatelessWidget {
  final MyState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return Skeletonizer(
        enabled: true,
        enableSwitchAnimation: true,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,  // Show 3 skeleton items
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, index) => _AssigneeCard(
            assignee: AssigneeWithUser.fake(),  // Use fake data
            isLoading: false,
          ),
        ),
      );
    }

    if (state.items.isEmpty) {
      return const EmptyState(message: 'No items found');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) => _AssigneeCard(
        assignee: state.items[index],
        isLoading: state.loadingItemId == state.items[index].id,
      ),
    );
  }
}
```

#### Best Practices Summary

| Do ✅ | Don't ❌ |
|-------|---------|
| Use `fake()` factory on models | Create separate skeleton widgets |
| Reset loading state on error | Leave loading state stuck forever |
| Use `enableSwitchAnimation: true` | Abrupt content switches |
| Match skeleton count to expected items | Random skeleton counts |
| Use Arabic placeholder text | Use "Lorem ipsum" |
| Handle NetworkImage with Skeleton.replace | Let NetworkImage throw errors |

---

## 11. Navigation Structure

### Routes

```dart
// Auth Routes
/login
/register
/verify-email

// Admin Routes
/admin/home
/admin/statistics
/admin/control-panel
/admin/control-panel/users
/admin/control-panel/users/:userId
/admin/control-panel/groups
/admin/control-panel/labels
/admin/control-panel/whitelist
/admin/control-panel/invitations
/admin/control-panel/settings
/admin/tasks
/admin/tasks/create
/admin/tasks/:taskId
/admin/tasks/:taskId/edit
/admin/archive
/admin/profile

// Manager Routes
/manager/my-tasks
/manager/my-tasks/:assignmentId
/manager/team-tasks
/manager/team-tasks/create
/manager/team-tasks/:taskId
/manager/profile

// Employee Routes
/employee/tasks
/employee/tasks/:assignmentId
/employee/profile

// Shared Routes
/notifications
```

### Bottom Navigation

**Admin**
```
┌─────────────┬─────────────┬─────────────┐
│    الرئيسية   │  لوحة التحكم  │   الملف الشخصي │
│    (Home)   │  (Control)  │  (Profile)  │
└─────────────┴─────────────┴─────────────┘
```

**Manager**
```
┌─────────────┬─────────────┬─────────────┐
│   مهامي      │   إدارة المهام  │   الملف الشخصي │
│  (My Tasks) │ (Team Tasks)│  (Profile)  │
└─────────────┴─────────────┴─────────────┘
```

**Employee**
```
┌─────────────────────┬─────────────────────┐
│       مهام اليوم       │      الملف الشخصي      │
│    (Today Tasks)    │      (Profile)      │
└─────────────────────┴─────────────────────┘
```

---

## 12. Business Rules

### Task Creation Rules
1. Admin can assign to anyone (managers + employees)
2. Manager can only assign to employees they have permission for
3. Task must have at least one assignee
4. Labels are optional (multi-select from active labels)
5. Attachment is optional (single file)
6. Recurring tasks start from creation date

### Assignment Rules
1. Only assigned user can mark their assignment as done
2. Task creator can also mark any assignment as done
3. Only assigned user can apologize
4. Apologize message is optional
5. Can only reactivate before deadline
6. Reactivation resets status to pending

### Recurring Task Rules
1. Runs daily at configured time (default 8:00 AM)
2. Creates new assignments for all original assignees
3. Previous day's assignments remain unchanged
4. Can be paused (isActive: false) without deletion
5. Can be archived for later use

### Group Rules
1. Employee can belong to only ONE group
2. Manager can be assigned multiple groups to manage
3. Manager with `canAssignToAll: true` can assign to all employees
4. Deleting a group removes groupId from all members

### Statistics Calculation
- **Completion Rate**: (completed / total) × 100
- **Apologize Rate**: (apologized / total) × 100
- **On-Time Rate**: (completed before deadline / completed) × 100
- Time filters: Today, This Week (Sunday-Saturday), This Month

---

## 13. Cloud Functions

### Scheduled Functions

#### `scheduledRecurringTasks`
- **Trigger**: Daily at configured time (from settings)
- **Logic**:
  1. Query all tasks where `isRecurring: true`, `isActive: true`, `isArchived: false`
  2. For each task, create new assignments for today
  3. Send notifications to all assignees
  4. Log execution for monitoring

### Trigger Functions

#### `onUserCreate`
- Initialize user document with defaults
- Send welcome notification

#### `onAssignmentCreate`
- Send notification to assigned user
- Update FCM if user has tokens

#### `onAssignmentUpdate`
- On status change to `completed`: Notify task creator
- On status change to `apologized`: Notify task creator
- On status change back to `pending`: Notify task creator

#### `onInvitationUsed`
- Send notification to admin about new user
- Log invitation usage

---

## 14. Project Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase config (generated)
│
├── app/
│   ├── app.dart                 # MaterialApp widget
│   ├── router/
│   │   ├── app_router.dart      # GoRouter configuration
│   │   ├── routes.dart          # Route constants
│   │   └── guards/
│   │       ├── auth_guard.dart
│   │       └── role_guard.dart
│   └── di/
│       ├── injection.dart       # GetIt setup
│       └── injection.config.dart # Generated
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart   # App-wide constants
│   │   └── firebase_constants.dart
│   ├── theme/
│   │   ├── app_theme.dart       # ThemeData
│   │   ├── app_colors.dart      # Color palette
│   │   ├── app_typography.dart  # Text styles
│   │   ├── app_spacing.dart     # Spacing scale
│   │   └── app_shadows.dart     # Shadow definitions
│   ├── extensions/
│   │   ├── context_extensions.dart
│   │   ├── date_extensions.dart
│   │   └── string_extensions.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── date_utils.dart
│   │   └── snackbar_utils.dart
│   ├── l10n/
│   │   ├── app_localizations.dart
│   │   └── arb/
│   │       └── app_ar.arb
│   └── widgets/
│       ├── buttons/
│       │   └── ribal_button.dart
│       ├── inputs/
│       │   └── ribal_text_field.dart
│       ├── cards/
│       │   └── ribal_card.dart
│       ├── feedback/
│       │   ├── empty_state.dart
│       │   ├── error_state.dart
│       │   └── loading_state.dart
│       └── ... (other shared widgets)
│
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── user_model.freezed.dart
│   │   ├── user_model.g.dart
│   │   ├── task_model.dart
│   │   ├── assignment_model.dart
│   │   ├── group_model.dart
│   │   ├── label_model.dart
│   │   ├── notification_model.dart
│   │   ├── whitelist_model.dart
│   │   ├── invitation_model.dart
│   │   └── settings_model.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── user_repository.dart
│   │   ├── task_repository.dart
│   │   ├── assignment_repository.dart
│   │   ├── group_repository.dart
│   │   ├── label_repository.dart
│   │   ├── notification_repository.dart
│   │   ├── whitelist_repository.dart
│   │   ├── invitation_repository.dart
│   │   ├── settings_repository.dart
│   │   └── statistics_repository.dart
│   └── services/
│       ├── firebase_auth_service.dart
│       ├── firestore_service.dart
│       ├── storage_service.dart
│       └── notification_service.dart
│
└── features/
    ├── auth/
    │   ├── bloc/
    │   │   ├── auth_bloc.dart
    │   │   ├── auth_event.dart
    │   │   └── auth_state.dart
    │   └── pages/
    │       ├── login_page.dart
    │       ├── register_page.dart
    │       └── verify_email_page.dart
    │
    ├── admin/
    │   ├── home/
    │   │   ├── bloc/
    │   │   ├── pages/
    │   │   └── widgets/
    │   ├── statistics/
    │   ├── control_panel/
    │   │   ├── users/
    │   │   ├── groups/
    │   │   ├── labels/
    │   │   ├── whitelist/
    │   │   ├── invitations/
    │   │   └── settings/
    │   ├── tasks/
    │   └── archive/
    │
    ├── manager/
    │   ├── my_tasks/
    │   ├── team_tasks/
    │   └── profile/
    │
    ├── employee/
    │   ├── tasks/
    │   └── profile/
    │
    ├── notifications/
    │   ├── bloc/
    │   ├── pages/
    │   └── widgets/
    │
    └── profile/
        ├── bloc/
        ├── pages/
        └── widgets/
```

---

## 15. Implementation Progress

### Phase 1: Foundation ✅ Complete
- [x] Create pubspec.yaml with dependencies
- [x] Create documentation file
- [x] Set up folder structure
- [x] Create design system (colors, typography, spacing, shadows)
- [x] Configure theme (Material 3)
- [x] Set up dependency injection (GetIt + Injectable)
- [x] Configure Firebase options template
- [x] Create Freezed models (User, Task, Assignment, Group, Label, etc.)
- [x] Set up GoRouter with role-based guards

### Phase 2: Authentication ✅ Complete
- [x] Auth repository & service (Firebase Auth)
- [x] AuthBloc with all events and states
- [x] Login page with form validation
- [x] Register page with whitelist/invitation flow
- [x] Email verification page with auto-check
- [x] Splash page with animations

### Phase 3: Core Features - Tasks & Assignments ⏳ Partial (UI Ready)
- [x] Task repository & models
- [x] Assignment repository & models
- [x] Task CRUD pages (create, detail, edit)
- [x] Archive page
- [ ] Connect pages to repositories
- [ ] Assignment list with actions (mark done, apologize, reactivate)
- [ ] Task detail with assignments overview

### Phase 4: Admin Control Panel ⏳ Partial (UI Ready)
- [x] Control panel navigation page
- [x] Users management page (placeholder)
- [x] Groups management page (placeholder)
- [x] Labels management page (placeholder)
- [x] Whitelist management page (placeholder)
- [x] Invitations management page (placeholder)
- [x] Global settings page (time pickers working)
- [ ] Connect pages to repositories with Blocs

### Phase 5: Manager Features ⏳ Partial (UI Ready)
- [x] My tasks page with welcome message
- [x] Team tasks management page
- [x] Task creation page
- [ ] Connect to limited assignee selection

### Phase 6: Notifications ⏳ Partial (UI Ready)
- [x] Notification repository
- [x] Notification service (FCM)
- [x] Notifications page (placeholder)
- [ ] Connect real-time notifications
- [ ] Deep linking implementation

### Phase 7: Statistics ⏳ Partial (UI Ready)
- [x] Statistics repository
- [x] Statistics page with tabs (today/week/month)
- [x] Progress card components
- [ ] Connect real data
- [ ] Charts implementation (fl_chart)

### Phase 8: Polish & UX 🔲 Pending
- [ ] Micro-animations (Hero, AnimatedContainer)
- [ ] Skeletonizer loading states
- [ ] Pull-to-refresh
- [ ] Improved error handling
- [ ] Full Arabic localization (arb files)

### Phase 9: Dark Mode 🔲 Future
- [ ] Dark color palette
- [ ] Theme switching

### Next Steps
1. Run `flutterfire configure` to set up Firebase
2. Download Cairo fonts and place in assets/fonts/
3. Run `dart run build_runner build` to generate Freezed files
4. Create Blocs for each feature and connect to repositories
5. Implement Cloud Functions for recurring tasks

---

## Appendix

### Arabic Translations Reference

| English | Arabic |
|---------|--------|
| Home | الرئيسية |
| Tasks | المهام |
| My Tasks | مهامي |
| Today's Tasks | مهام اليوم |
| Team Tasks | إدارة المهام |
| Control Panel | لوحة التحكم |
| Profile | الملف الشخصي |
| Statistics | الإحصائيات |
| Settings | الإعدادات |
| Users | المستخدمين |
| Groups | المجموعات |
| Labels | التصنيفات |
| Whitelist | القائمة البيضاء |
| Invitations | الدعوات |
| Archive | الأرشيف |
| Notifications | الإشعارات |
| Login | تسجيل الدخول |
| Register | إنشاء حساب |
| Logout | تسجيل الخروج |
| Email | البريد الإلكتروني |
| Password | كلمة المرور |
| Confirm Password | تأكيد كلمة المرور |
| First Name | الاسم الأول |
| Last Name | الاسم الأخير |
| Admin | مدير النظام |
| Manager | مشرف |
| Employee | موظف |
| Pending | قيد الانتظار |
| Completed | مكتملة |
| Apologized | معتذر |
| Mark as Done | تم الإنجاز |
| Apologize | اعتذار |
| Reactivate | إعادة تفعيل |
| Create Task | إنشاء مهمة |
| Edit Task | تعديل المهمة |
| Delete | حذف |
| Cancel | إلغاء |
| Save | حفظ |
| Submit | إرسال |
| Today | اليوم |
| This Week | هذا الأسبوع |
| This Month | هذا الشهر |
| All | الكل |
| Select | اختيار |
| Search | بحث |
| No results | لا توجد نتائج |
| Loading | جاري التحميل |
| Error | خطأ |
| Retry | إعادة المحاولة |
| Success | تم بنجاح |

---

*This documentation will be updated as the project progresses.*
