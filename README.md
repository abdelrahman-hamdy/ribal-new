# Ribal - Task Management App

A Flutter task management application for mid-size companies with multi-role support (Admin, Manager, Employee).

## Features

- Multi-role user system (Admin, Manager, Employee)
- Smart invitation-based registration (whitelist + invitation codes)
- Task creation with labels and attachments
- Daily recurring tasks with automatic scheduling
- Assignment tracking with completion/apologize workflow
- Real-time notifications with deep linking
- Comprehensive statistics and performance tracking
- Arabic RTL support

## Tech Stack

- **Flutter/Dart** with GoRouter, Bloc, Freezed, Skeletonizer
- **Firebase**: Firestore, Auth, Cloud Functions, FCM, Storage

## Getting Started

### Prerequisites

- Flutter SDK 3.2+
- Firebase CLI
- FlutterFire CLI

### Setup

1. Clone the repository

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
```bash
flutterfire configure
```

4. Download Cairo font family and place in `assets/fonts/`:
   - Cairo-Regular.ttf
   - Cairo-Medium.ttf
   - Cairo-SemiBold.ttf
   - Cairo-Bold.ttf

5. Generate Freezed models:
```bash
dart run build_runner build --delete-conflicting-outputs
```

6. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router/
│   └── di/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── extensions/
│   ├── utils/
│   └── widgets/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
└── features/
    ├── auth/
    ├── admin/
    ├── manager/
    ├── employee/
    ├── notifications/
    └── profile/
```

## Documentation

See [RIBAL_DOCUMENTATION.md](RIBAL_DOCUMENTATION.md) for full project documentation.

## Firebase Setup

### Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }

    // Tasks collection
    match /tasks/{taskId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    // Assignments collection
    match /assignments/{assignmentId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    // Other collections...
  }
}
```

### Cloud Functions (Required)

- `scheduledRecurringTasks`: Daily cron job for recurring tasks
- `onAssignmentCreate`: Send notification on new assignment
- `onAssignmentUpdate`: Notify on status changes

## License

MIT License
