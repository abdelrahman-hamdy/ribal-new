# Push Notifications Testing Guide

**Project:** Ribal Task Management App
**Date:** November 28, 2025
**Firebase Project:** ribal-4ac8c

---

## Overview

This guide provides step-by-step instructions for testing push notifications on both Android and iOS platforms. The app uses Firebase Cloud Messaging (FCM) with local notifications support.

---

## Prerequisites

### General Requirements
- ✅ Flutter SDK installed
- ✅ Android Studio / Xcode installed
- ✅ Physical devices (recommended) or emulators
- ✅ Firebase Console access to `ribal-4ac8c` project
- ✅ Internet connection

### Android-Specific
- Android device running API 33+ (for POST_NOTIFICATIONS permission)
- USB debugging enabled
- Google Play Services installed on device

### iOS-Specific
- iOS device (physical device required for push notifications)
- Apple Developer Account with push notification certificates
- APNs authentication key uploaded to Firebase Console

---

## Setup Steps

### 1. Build and Install the App

#### Android
```bash
cd /Users/abdelrahmanhamdy/projects/ribal-new

# Clean previous builds
flutter clean
flutter pub get

# Build and install debug APK
flutter run --debug

# Or build release APK for testing
flutter build apk --release
# Install manually: adb install build/app/outputs/flutter-apk/app-release.apk
```

#### iOS
```bash
cd /Users/abdelrahmanhamdy/projects/ribal-new

# Clean previous builds
flutter clean
flutter pub get

# Open Xcode workspace
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select your development team
# 2. Ensure Bundle ID is: com.ribal.tasks
# 3. Enable "Push Notifications" capability
# 4. Select Runner.entitlements file
# 5. Build and run on physical device
```

### 2. Grant Notification Permissions

When the app launches for the first time:

**Android:**
- A system dialog will appear requesting notification permission
- Tap "Allow" to grant permission

**iOS:**
- A system dialog will appear requesting notification permission
- Tap "Allow" to grant permission

### 3. Capture FCM Token

The app automatically prints the FCM token to the console on startup:

```
🔔 FCM Token received: <YOUR_DEVICE_TOKEN>
```

**How to find the token:**

**Android (via logcat):**
```bash
adb logcat | grep "FCM Token"
```

**iOS (via Xcode console):**
- Look for the line with "🔔 FCM Token received:" in the Xcode console

**Save this token** - you'll need it for sending test notifications.

---

## Testing Scenarios

### Test 1: Foreground Notifications

**Objective:** Verify notifications are displayed when the app is open.

**Steps:**
1. Keep the app open and in the foreground
2. Send a test notification from Firebase Console (see "Sending Test Notifications" below)
3. Expected: A local notification should appear at the top of the screen with sound and vibration

**Success Criteria:**
- ✅ Notification banner appears
- ✅ Notification sound plays
- ✅ Notification icon shows correctly
- ✅ Title and body text are displayed correctly
- ✅ Console shows: `🔔 Foreground message received: <messageId>`
- ✅ Console shows: `🔔 Local notification shown: <title>`

### Test 2: Background Notifications

**Objective:** Verify notifications work when app is in background.

**Steps:**
1. Open the app
2. Press home button (minimize app, don't close it)
3. Send a test notification from Firebase Console
4. Expected: System notification appears in notification tray

**Success Criteria:**
- ✅ Notification appears in notification tray
- ✅ Notification sound/vibration occurs
- ✅ Tapping notification opens the app

### Test 3: Terminated State Notifications

**Objective:** Verify notifications work when app is completely closed.

**Steps:**
1. Open the app
2. Completely close the app (swipe away from recent apps)
3. Send a test notification from Firebase Console
4. Expected: System notification appears in notification tray

**Success Criteria:**
- ✅ Notification appears in notification tray
- ✅ Tapping notification launches the app
- ✅ Console shows: `🔔 Initial message found: <messageId>` (when app is opened)

### Test 4: Notification Tap Handling

**Objective:** Verify notification tap callback works correctly.

**Steps:**
1. Send a notification with custom data payload
2. Tap the notification
3. Expected: App opens and payload is logged

**Success Criteria:**
- ✅ App opens when notification is tapped
- ✅ Console shows: `🔔 Notification tapped with payload: <payload>`
- ✅ Payload data is correctly parsed

### Test 5: Token Refresh

**Objective:** Verify FCM token refresh handling.

**Steps:**
1. Clear app data (Android) or reinstall (iOS)
2. Open the app
3. Expected: New token is generated and logged

**Success Criteria:**
- ✅ Console shows: `🔔 FCM Token received: <new_token>`
- ✅ New token is different from previous token

---

## Sending Test Notifications

### Method 1: Firebase Console (Recommended for Initial Testing)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **ribal-4ac8c**
3. Navigate to: **Engage** → **Messaging**
4. Click "Create your first campaign" or "New campaign"
5. Select "Firebase Notification messages"
6. Fill in the form:
   - **Notification title:** "Test Notification"
   - **Notification text:** "This is a test notification from Firebase"
   - **Notification image (optional):** Leave blank
7. Click "Next"
8. **Target:**
   - Select "Send test message"
   - Paste your FCM token from step 3 above
   - Click "Test"
9. Check your device for the notification

### Method 2: Using Firebase Cloud Functions

Create a Cloud Function to send notifications:

```javascript
// functions/index.js
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendTestNotification = functions.https.onRequest(async (req, res) => {
  const token = req.body.token; // FCM token

  const message = {
    notification: {
      title: 'Test Notification',
      body: 'This is a test from Cloud Functions',
    },
    data: {
      type: 'test',
      taskId: '123',
    },
    token: token,
  };

  try {
    const response = await admin.messaging().send(message);
    res.json({ success: true, messageId: response });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

Deploy and call:
```bash
firebase deploy --only functions
curl -X POST https://YOUR_REGION-ribal-4ac8c.cloudfunctions.net/sendTestNotification \
  -H "Content-Type: application/json" \
  -d '{"token": "YOUR_FCM_TOKEN"}'
```

### Method 3: Using REST API (Advanced)

```bash
# Get your Server Key from Firebase Console → Project Settings → Cloud Messaging
SERVER_KEY="YOUR_SERVER_KEY"
FCM_TOKEN="YOUR_DEVICE_TOKEN"

curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=$SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "'$FCM_TOKEN'",
    "notification": {
      "title": "REST API Test",
      "body": "Notification sent via REST API"
    },
    "data": {
      "type": "test",
      "custom_field": "custom_value"
    }
  }'
```

---

## Troubleshooting

### Android Issues

#### Issue: Notifications not appearing
**Solutions:**
1. Check notification permission is granted:
   ```bash
   adb shell dumpsys notification_listener
   ```
2. Verify notification channel is created:
   ```bash
   adb shell cmd notification list_channels com.ribal.tasks
   ```
3. Check Do Not Disturb mode is disabled
4. Verify Google Play Services is installed and up-to-date

#### Issue: No FCM token generated
**Solutions:**
1. Verify `google-services.json` is in `android/app/`
2. Check package name matches: `com.ribal.tasks`
3. Run: `flutter clean && flutter pub get && flutter run`
4. Check internet connection

#### Issue: Background handler not working
**Solutions:**
1. Verify `@pragma('vm:entry-point')` is present on background handler
2. Check Firebase is initialized in background handler
3. Restart the app completely (kill and relaunch)

### iOS Issues

#### Issue: Notifications not appearing
**Solutions:**
1. Verify you're testing on a **physical device** (not simulator)
2. Check notification permission is granted in iOS Settings → Ribal
3. Ensure APNs certificate is uploaded to Firebase Console
4. Verify `aps-environment` is set to "development" in entitlements

#### Issue: No FCM token generated
**Solutions:**
1. Verify `GoogleService-Info.plist` is in `ios/Runner/`
2. Check Bundle ID matches: `com.ribal.tasks`
3. Ensure "Push Notifications" capability is enabled in Xcode
4. Run: `flutter clean && flutter pub get && flutter run`

#### Issue: APNs token not available
**Solutions:**
1. Restart device
2. Check Apple Developer account has push notification certificates
3. Verify provisioning profile includes push notifications
4. Try: `flutter clean && cd ios && pod install && cd .. && flutter run`

### General Issues

#### Issue: Token refresh not working
**Solution:**
- Clear app data/reinstall app
- Check internet connection
- Verify Firebase SDK is up-to-date

#### Issue: Notification tap not working
**Solution:**
- Verify payload is valid JSON
- Check `onNotificationTapped` callback in main.dart
- Review console logs for errors

---

## Verification Checklist

### Android
- [ ] Notification permission granted
- [ ] FCM token generated and logged
- [ ] Foreground notifications display correctly
- [ ] Background notifications display correctly
- [ ] Terminated state notifications display correctly
- [ ] Notification tap opens app
- [ ] Notification payload is parsed correctly
- [ ] Notification sound plays
- [ ] Notification icon displays correctly
- [ ] Token refresh works after app reinstall

### iOS
- [ ] Notification permission granted
- [ ] FCM token generated and logged
- [ ] APNs token generated
- [ ] Foreground notifications display correctly
- [ ] Background notifications display correctly
- [ ] Terminated state notifications display correctly
- [ ] Notification tap opens app
- [ ] Notification payload is parsed correctly
- [ ] Notification sound plays
- [ ] Token refresh works after app reinstall

---

## Firebase Console Setup

### Required Configurations

#### Android SHA Fingerprints
Add your app's SHA-1 and SHA-256 fingerprints to Firebase Console:

```bash
# Debug keystore (for development)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Release keystore
keytool -list -v -keystore android/app/ribal-release-key.jks -alias ribal-key -storepass ribal123456 -keypass ribal123456
```

Current SHA-1 (from migration): `84:DE:DC:25:D6:AB:0A:FB:2F:2F:6C:91:02:74:63:55:26:C2:D3:32`

**Add to Firebase Console:**
1. Go to Project Settings → Your apps → Android app
2. Scroll to "SHA certificate fingerprints"
3. Click "Add fingerprint"
4. Paste SHA-1 and SHA-256

#### iOS APNs Certificate
Upload APNs authentication key to Firebase Console:

1. Get APNs key from [Apple Developer Portal](https://developer.apple.com/account/resources/authkeys/list)
2. Go to Firebase Console → Project Settings → Cloud Messaging → iOS app configuration
3. Upload APNs authentication key (.p8 file)
4. Enter Key ID and Team ID

---

## Production Checklist

Before deploying to production:

### Android
- [ ] Change `aps-environment` to "production" (if applicable)
- [ ] Add release SHA fingerprints to Firebase
- [ ] Test with release build (`flutter build apk --release`)
- [ ] Verify ProGuard doesn't strip FCM classes

### iOS
- [ ] Change entitlements `aps-environment` to "production"
- [ ] Upload production APNs certificate to Firebase
- [ ] Test with release build (`flutter build ios --release`)
- [ ] Test via TestFlight before App Store submission

### General
- [ ] Implement proper token storage (save to backend)
- [ ] Implement notification tap navigation logic
- [ ] Add notification categories/actions if needed
- [ ] Set up notification analytics tracking
- [ ] Create notification templates for different event types
- [ ] Document notification payload structure for backend team

---

## Next Steps

1. **Token Management:**
   - Save FCM tokens to your backend (Firestore or REST API)
   - Associate tokens with user accounts
   - Handle token refresh events

2. **Navigation:**
   - Implement proper deep linking for notification taps
   - Navigate to specific screens based on payload data
   - Example: If `payload['type'] == 'task'`, navigate to task detail page

3. **Notification Types:**
   - Create different notification types (task assigned, task completed, reminder, etc.)
   - Use different notification channels for Android
   - Implement notification actions (Accept, Decline, etc.)

4. **Backend Integration:**
   - Create Cloud Functions to send notifications on specific events
   - Implement notification triggers (task created, deadline approaching, etc.)
   - Set up notification scheduling for reminders

---

## Support

If you encounter issues not covered in this guide:

1. Check Firebase Console logs for delivery errors
2. Review Android logcat / iOS console for error messages
3. Verify Firebase SDK versions are compatible
4. Check Firebase Status page: https://status.firebase.google.com/

---

**Testing completed successfully!** 🎉
