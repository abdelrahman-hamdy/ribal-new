# Patch Release Workflow for Ribal

## Overview

This document outlines the standard workflow for creating and deploying Shorebird patches (OTA updates) for the Ribal Flutter app. Follow these procedures to ensure safe, tested, and monitored patch deployments.

## When to Create a Patch

### ✅ Patch is Appropriate For:

- **Bug fixes in Dart code** - Crashes, logic errors, calculation bugs
- **UI text corrections** - Typos, translation updates
- **Business logic improvements** - Task sorting, filtering, validation rules
- **FCM notification handler updates** - Notification handling logic
- **Minor feature tweaks** - UI adjustments that don't require new permissions

### ❌ Store Release Required For:

- **New Firebase plugins** - firebase_auth update, new Firebase services
- **Native dependency updates** - Cloudinary, Hive, or other native plugins
- **Permission changes** - New AndroidManifest.xml or Info.plist permissions
- **Flutter SDK updates** - Upgrading Flutter version
- **Major new features** - Significant functionality additions
- **Asset changes** - New images, fonts, or other assets

---

## Pre-Release Checklist

Before creating a patch, ensure:

- [ ] Code has been **reviewed and approved** by at least one team member
- [ ] **Unit tests are passing** (`flutter test`)
- [ ] **No native code changes** (Java, Kotlin, Swift, Objective-C)
- [ ] **No new permissions** required in AndroidManifest.xml or Info.plist
- [ ] **Tested on physical device** (Android and iOS)
- [ ] **RELEASE_HISTORY.md** updated with patch details
- [ ] **Git repository is clean** (`git status` shows no uncommitted changes)

---

## Patch Creation Steps

### Step 1: Create Hotfix Branch

Use the provided script:

```bash
./scripts/create_hotfix.sh <hotfix-name>
```

Example:
```bash
./scripts/create_hotfix.sh fix-notification-crash
```

This creates a branch named `hotfix/fix-notification-crash` from `main`.

**Manual alternative:**
```bash
git checkout main
git pull origin main
git checkout -b hotfix/fix-notification-crash
```

### Step 2: Make Bug Fix Changes

Edit the necessary Dart files. For example:

```dart
// lib/data/services/fcm_notification_service.dart
// Fix the notification crash on Android 14
Future<void> handleNotification(RemoteMessage message) async {
  // Add null check
  if (message.notification == null) return;

  // Rest of the logic...
}
```

### Step 3: Test Locally (CRITICAL)

**3a. Test with Shorebird Preview:**

```bash
shorebird preview
```

This runs the patch on a connected device/emulator.

**3b. Manual Testing Checklist:**

For the specific bug being fixed:
- [ ] Bug is reproducible **before** the fix
- [ ] Bug is **resolved** after the fix
- [ ] No new bugs introduced

For FCM-related patches specifically:
- [ ] Send FCM notification while app is in **foreground**
- [ ] Send FCM notification while app is in **background**
- [ ] Send FCM notification while app is **terminated** (critical!)
- [ ] Tap notification → verify correct navigation

For task-related patches:
- [ ] Test as Admin (create/edit/delete tasks)
- [ ] Test as Manager (assign tasks)
- [ ] Test as Employee (view assignments, add notes)

### Step 4: Commit Changes

```bash
git add .
git commit -m "fix: resolve notification crash on Android 14"
```

**Commit message format:**
- `fix:` - Bug fixes
- `update:` - UI/text updates
- `improve:` - Logic improvements

### Step 5: Push to Trigger Automated Patch

```bash
git push origin hotfix/fix-notification-crash
```

**What happens next:**
1. CodeMagic detects push to `hotfix/*` branch
2. Automatically runs `shorebird-patch` workflow
3. Creates patches for Android and iOS
4. Deploys to Shorebird (users receive on next app restart)
5. Sends Slack notification (if configured)

### Step 6: Monitor Deployment

**6a. Check CodeMagic Build:**

Visit [CodeMagic dashboard](https://codemagic.io) → Ribal → Builds

Verify:
- [ ] Build succeeded
- [ ] Android patch created
- [ ] iOS patch created
- [ ] No errors in logs

**6b. Check Shorebird Console:**

Visit [Shorebird console](https://console.shorebird.dev) → Your App → Patches

Monitor:
- [ ] Patch appears in list
- [ ] Install count increasing
- [ ] No error reports

**6c. Monitor App Stability:**

Check Firebase Crashlytics for 24 hours:
- [ ] Crash rate does not increase
- [ ] No new crashes related to the patch

### Step 7: Merge Hotfix Branch

After verifying patch is successful:

```bash
git checkout main
git merge hotfix/fix-notification-crash
git push origin main

# Delete hotfix branch
git branch -d hotfix/fix-notification-crash
git push origin --delete hotfix/fix-notification-crash
```

### Step 8: Update RELEASE_HISTORY.md

Document the patch:

```markdown
### v1.0.10+13 (2025-XX-XX) - Patch

- **Type**: Hotfix
- **Patch for**: v1.0.10+12
- **Fixed**: Notification crash on Android 14
- **Affected**: All users on v1.0.10+12
- **Patch ID**: [from Shorebird console]
- **Install Rate**: XX% within 24 hours
- **Status**: ✅ Deployed successfully
```

---

## Rollback Procedures

### When to Rollback

Immediate rollback if:
- Crash rate increases > 1%
- Critical functionality broken (login, task assignment, FCM)
- Data corruption reported
- Multiple user complaints

### How to Rollback

**Option 1: Patch Forward (Recommended)**

```bash
# Revert to last good commit
git checkout <last-good-commit>

# Create emergency patch
VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}')
shorebird patch android --release-version=$VERSION
shorebird patch ios --release-version=$VERSION
```

**Option 2: Revert and Patch**

```bash
# Revert the bad commit
git revert <bad-commit-hash>

# Create new patch with reverted code
shorebird patch android --release-version=1.0.10+12
shorebird patch ios --release-version=1.0.10+12
```

**Option 3: Use Shorebird Console**

Visit Shorebird console:
1. Select your app
2. Go to Patches
3. Find the problematic patch
4. Click "Rollback" to revert to previous patch

**Emergency Communication:**

```bash
# Notify users via FCM (if patch is critical)
# Send push notification explaining the rollback
"We detected an issue and have reverted to the previous version.
Please restart the app if you experience any issues."
```

---

## Post-Deployment Monitoring

### 24 Hours After Patch

Monitor these metrics:

**Patch Adoption Rate:**
- Target: > 80% of active users within 72 hours
- Source: Shorebird console

**App Stability:**
- Target: Crash-free sessions > 99.5%
- Source: Firebase Crashlytics

**FCM Delivery (if FCM-related patch):**
- Target: Notification delivery rate > 95%
- Source: Firebase Cloud Messaging reports

**User Reports:**
- Monitor support channels for bug reports
- Check app store reviews for complaints

### Weekly Review

Every Monday, review:
- Total patches deployed last week
- Average patch adoption time
- Any rollbacks or issues
- Lessons learned

---

## Emergency Hotfix (Critical Bugs)

For **critical** bugs (app crashes on launch, data loss, security vulnerability):

### Fast-Track Process

**1. Skip branch creation** (work directly on main if necessary):

```bash
git checkout main
# Make urgent fix
git commit -m "fix(critical): resolve app crash on startup"
git push origin main
```

**2. Manual patch deployment** (bypass CI/CD):

```bash
# Get current version
VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}')

# Create patches immediately
shorebird patch android --release-version=$VERSION
shorebird patch ios --release-version=$VERSION
```

**3. Monitor in real-time:**

- Stay online for 2 hours
- Watch Crashlytics live
- Monitor Shorebird console
- Be ready to rollback

**4. Notify stakeholders:**

```
Subject: [CRITICAL] Emergency Patch Deployed

A critical bug was detected and an emergency patch has been deployed:

- Bug: [description]
- Impact: [affected users/functionality]
- Fix: [what was changed]
- Deployment time: [timestamp]
- Expected rollout: 90% within 2 hours

Monitoring: [your name] will monitor for next 2 hours
Rollback plan: [describe if needed]
```

---

## Testing Checklist Templates

### General Patch Testing

```
[ ] App launches successfully
[ ] No crashes during basic navigation
[ ] Authentication flow works (login/logout)
[ ] Core features functional:
    [ ] Admin: Task creation
    [ ] Manager: Task assignment
    [ ] Employee: View assignments
[ ] Firebase services working:
    [ ] Firestore read/write
    [ ] FCM notifications (foreground + background + terminated)
    [ ] Firebase Auth token refresh
[ ] Offline mode (Hive cache)
[ ] Arabic/English localization
```

### FCM-Specific Patch Testing

```
[ ] FCM token generation on app start
[ ] Foreground notifications:
    [ ] Notification appears
    [ ] Tap → correct navigation
[ ] Background notifications:
    [ ] App in background → notification appears
    [ ] Tap → app opens to correct screen
[ ] Terminated state notifications (CRITICAL):
    [ ] App completely closed (swiped away)
    [ ] Send notification via Firebase Console
    [ ] Notification appears in system tray
    [ ] Background handler executes
    [ ] Tap → app launches to correct screen
[ ] Deep link navigation works
[ ] Notification data payload accessible
```

### Task Management Patch Testing

```
[ ] Admin role:
    [ ] Create new task
    [ ] Edit existing task
    [ ] Delete task
    [ ] Assign to manager
[ ] Manager role:
    [ ] View assigned tasks
    [ ] Assign task to employee
    [ ] Track task progress
    [ ] View team statistics
[ ] Employee role:
    [ ] View my assignments
    [ ] Add notes to tasks
    [ ] Upload attachments (Cloudinary)
    [ ] Mark tasks complete
```

---

## Branch Strategy

```
main                           → Production (triggers full release)
├── hotfix/fix-notification-crash  → Triggers patch
├── hotfix/fix-task-sorting        → Triggers patch
└── hotfix/update-arabic-text      → Triggers patch

develop                        → Development (preview builds)
```

**Rules:**
- `main` = production releases
- `hotfix/*` = patches (OTA updates)
- `develop` = development builds
- Never merge `hotfix/*` to `develop` (merge to `main` only)

---

## Slack Notification Format

CodeMagic sends these notifications automatically:

**Patch Deployed:**
```
🚀 Shorebird Patch Deployed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Patch Name: 1.0.10+12-fix-notification-crash
Version: 1.0.10+12
Platform: Android + iOS
Commit: a4853f1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Patch Failed:**
```
❌ Ribal Build FAILED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Workflow: shorebird-patch
Build: #43
Branch: hotfix/fix-notification-crash
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
View logs: https://codemagic.io/...
```

---

## FAQ

**Q: How long does it take for users to receive a patch?**

A: Users receive patches on their next app restart. 80% of active users typically install patches within 72 hours.

**Q: Can I rollback a patch after deployment?**

A: Yes, either by patching forward to the previous version or using the Shorebird console rollback feature.

**Q: What happens if users don't restart their app?**

A: They will continue using the old version until they restart. Patches are applied on the next app launch.

**Q: Can I force users to update?**

A: Shorebird applies patches automatically on restart. You cannot force an immediate update while the app is running. To force users to update, you would need to implement version checking logic that blocks app usage until they restart.

**Q: What if Shorebird servers are down?**

A: The app continues functioning normally. Users won't receive the patch until Shorebird servers are back online. In an emergency, push a store update instead.

**Q: Can I patch Flutter SDK changes?**

A: No. Flutter SDK updates require a full store release because they involve engine changes.

---

## Additional Resources

- [Shorebird Setup Guide](SHOREBIRD_SETUP.md)
- [Shorebird Documentation](https://docs.shorebird.dev)
- [Shorebird Console](https://console.shorebird.dev)
- [CodeMagic Configuration](../codemagic.yaml)
- [Release History](../RELEASE_HISTORY.md)

---

**Last Updated**: 2025-11-28
**Maintained By**: Ribal Development Team
