# Release History

All notable releases and patches for the Ribal Flutter app are documented in this file.

## Format

- **Release**: Full app store submission (version bump in pubspec.yaml)
- **Patch**: Over-the-air update via Shorebird (build number bump only)

---

## Releases

### v2.0.0+13 (2025-01-XX) - Major Release

**Type**: Major Version Release with Shorebird Code Push

**Platform**: Android (Google Play), iOS (App Store)

**Features**:
- Complete Shorebird Code Push integration for OTA updates
- Enhanced task management system
- Improved Firebase integration and notifications
- ProGuard optimization for Android
- Production-ready FCM background handler
- Automated CI/CD with CodeMagic

**Technical**:
- Flutter SDK: 3.19.0
- Shorebird Code Push enabled
- ProGuard rules optimized for Shorebird compatibility
- iOS entitlements configured for push notifications
- CodeMagic automation for releases and patches

**Status**: 🚀 Ready for submission
**Shorebird Track**: stable

---

### v1.0.10+12 (2025-XX-XX) - Store Release

**Type**: Initial Release with Shorebird Integration

**Platform**: Android (Google Play), iOS (App Store)

**Features**:
- Task management system for Admin, Manager, and Employee roles
- Firebase integration (Auth, Firestore, Cloud Messaging)
- Push notifications with FCM background handler
- Arabic/English localization
- Cloudinary image uploads
- Hive local storage with offline support
- Shorebird Code Push integration

**Technical**:
- Flutter SDK: 3.19.0
- ProGuard optimization enabled (Android)
- Firebase Cloud Messaging background handler with `@pragma('vm:entry-point')`
- Shorebird baseline release for future OTA updates

**Status**: ✅ Submitted to stores
**Shorebird Track**: stable
**App Bundle Size**: ~XX MB (Android), ~XX MB (iOS)

---

## Patches

Patches will be listed here after deployment. Each patch entry should include:

- **Version**: Build number (e.g., v1.0.10+13)
- **Type**: Hotfix / Update
- **Patch for**: Base release version
- **Fixed/Changed**: Description of changes
- **Platform**: Android / iOS / Both
- **Deployment Date**: YYYY-MM-DD
- **Patch ID**: [from Shorebird console]
- **Install Rate**: XX% within 24/48/72 hours
- **Status**: ✅ Success / ❌ Rolled back / ⚠️ Issues detected

### Example Patch Entry Template

```markdown
### v1.0.10+13 (2025-XX-XX) - Patch

**Type**: Hotfix

**Patch for**: v1.0.10+12

**Fixed**:
- Resolved notification crash on Android 14 when app is terminated
- Added null check for RemoteMessage.notification
- Improved error handling in FCM background handler

**Platform**: Android + iOS

**Deployment**:
- Date: 2025-XX-XX HH:MM UTC
- Branch: hotfix/fix-notification-crash
- Commit: abc1234
- Patch ID: [shorebird-patch-id]

**Rollout**:
- Beta channel: 24 hours (10 internal testers)
- Stable channel: Phased (5% → 25% → 50% → 100%)
- Full rollout completed: 72 hours

**Metrics**:
- Install Rate (24h): 65%
- Install Rate (48h): 82%
- Install Rate (72h): 91%
- Crash Rate Change: +0.0% (no increase)
- User Reports: 0 issues

**Status**: ✅ Deployed successfully

**Notes**:
- Monitored FCM delivery for 48 hours post-deployment
- No rollback required
- Merged to main on 2025-XX-XX
```

---

## Release Statistics

### Summary (Updated Monthly)

- **Total Releases**: 1
- **Total Patches**: 0
- **Average Patch Adoption (72h)**: N/A
- **Successful Patches**: 0
- **Rolled Back Patches**: 0
- **Average Time to Hotfix**: N/A

### Upcoming Releases

List planned releases here:

- **v1.1.0**: [Description of major features]
  - Estimated: Q1 2026
  - Type: Store Release (minor version bump)

---

## Versioning Strategy

```
version: MAJOR.MINOR.PATCH+BUILD
         │     │     │      │
         │     │     │      └─ Build number (increments with every release/patch)
         │     │     └──────── Patch version (for Shorebird patches)
         │     └────────────── Minor version (store releases with new features)
         └──────────────────── Major version (breaking changes)
```

**Examples**:
- `1.0.10+12` → `1.0.10+13`: Shorebird patch applied
- `1.0.10+13` → `1.1.0+14`: Store release with new features
- `1.1.0+14` → `2.0.0+15`: Major release with breaking changes

---

## Notes

- All timestamps are in UTC
- Patch IDs can be found in [Shorebird console](https://console.shorebird.dev)
- Build logs available in [CodeMagic](https://codemagic.io)
- Firebase Crashlytics dashboard: [Firebase Console](https://console.firebase.google.com)

---

**Last Updated**: 2025-11-28
**Maintained By**: Ribal Development Team
