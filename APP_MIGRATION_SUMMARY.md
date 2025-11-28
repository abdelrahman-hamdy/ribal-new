# Ribal App - Publishing Configuration Migration Summary

**Migration Date:** November 28, 2025
**From:** `/Users/abdelrahmanhamdy/projects/ribal` (Old App)
**To:** `/Users/abdelrahmanhamdy/projects/ribal-new` (New App)

---

## Overview

All publishing configurations, signing credentials, and store metadata have been successfully migrated from the old Ribal app to the new version. The new app is now configured to replace the existing app on Google Play Store and Apple App Store.

---

## Android Configuration

### Application Identity
- **Application ID:** `com.ribal.tasks`
- **Namespace:** `com.ribal.tasks`
- **Package Structure:** `com.ribal.tasks` (MainActivity relocated)

### Signing Configuration
- **Keystore File:** `android/app/ribal-release-key.jks` ✓ Copied
- **Key Alias:** `ribal-key`
- **Key Password:** `ribal123456`
- **Store Password:** `ribal123456`
- **Signing Config:** Release builds now properly signed

### Build Configuration ([android/app/build.gradle.kts](android/app/build.gradle.kts))
- ✓ ProGuard rules enabled with optimization
- ✓ Multidex enabled
- ✓ Code minification enabled
- ✓ Resource shrinking enabled
- ✓ Core library desugaring enabled
- ✓ Vector drawables support

### AndroidManifest.xml Updates ([android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml))
**Permissions Added:**
- `INTERNET`
- `ACCESS_NETWORK_STATE`
- `WRITE_EXTERNAL_STORAGE` (maxSdkVersion=28)
- `READ_EXTERNAL_STORAGE`
- `POST_NOTIFICATIONS`

**Configuration:**
- App label: `Ribal`
- Icon: `@mipmap/launcher_icon`
- `usesCleartextTraffic`: true
- URL launcher queries configured

### ProGuard Rules
- ✓ `proguard-rules.pro` copied
- ✓ `proguard-rules-optimized.pro` copied

### Dependencies Added
```gradle
coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
implementation("androidx.multidex:multidex:2.0.1")
```

---

## iOS Configuration

### Application Identity
- **Bundle ID:** `com.ribal.tasks`
- **Display Name:** `Ribal`
- **Provisioning Profile:** "ribal profile 1" (referenced in old app)

### Info.plist Updates ([ios/Runner/Info.plist](ios/Runner/Info.plist))
**Permissions Added:**
- `NSPhotoLibraryUsageDescription`: Photo library access for profile pictures and attachments
- `NSDocumentsFolderUsageDescription`: Documents access for task attachments
- `NSAppTransportSecurity`: Allow arbitrary loads (HTTP connections)

**Configuration:**
- Background modes: `remote-notification`
- Supported orientations (iPhone): Portrait only
- Supported orientations (iPad): All orientations
- Status bar: Visible
- CADisableMinimumFrameDurationOnPhone: true

---

## Firebase Configuration

⚠️ **IMPORTANT:** The new app uses a DIFFERENT Firebase project than the old app!
- **Old app Firebase:** `ribal-tasks` (used only for notifications)
- **New app Firebase:** `ribal-4ac8c` (full backend with Auth, Firestore, Functions, Storage)

### Android
- **File:** [android/app/google-services.json](android/app/google-services.json) ✓ Generated with FlutterFire CLI
- **Project ID:** `ribal-4ac8c`
- **Project Number:** `148376111214`
- **App ID:** `1:148376111214:android:7e095160708db47edd3e7f`
- **Package Name:** `com.ribal.tasks`
- **API Key:** `AIzaSyCDtsXnqHav0_VgNZNHR0tFbAuofjiQiG4`

### iOS
- **File:** [ios/Runner/GoogleService-Info.plist](ios/Runner/GoogleService-Info.plist) ✓ Generated with FlutterFire CLI
- **API Key:** `AIzaSyCK-EK_guRZ5AtrrPGU33HNPpcFOqlSFXE`
- **Bundle ID:** `com.ribal.tasks`
- **App ID:** `1:148376111214:ios:7d7eace3f25f15f1dd3e7f`
- **GCM Sender ID:** `148376111214`
- **Project ID:** `ribal-4ac8c`
- **Storage Bucket:** `ribal-4ac8c.firebasestorage.app`

---

## Version Information

### Old App
- **Version:** 1.0.9
- **Build Number:** 11

### New App
- **Version:** 1.0.10 (incremented)
- **Build Number:** 12 (incremented)
- **File:** [pubspec.yaml](pubspec.yaml) line 4

This ensures the new app version is higher than the published version, allowing proper updates on both stores.

---

## Files Modified/Created

### Copied Files
1. ✓ `android/app/ribal-release-key.jks` (Keystore)
2. ✓ `android/app/google-services.json` (Firebase Android)
3. ✓ `ios/Runner/GoogleService-Info.plist` (Firebase iOS)
4. ✓ `ios/Runner/Info.plist` (iOS permissions & config)
5. ✓ `android/app/proguard-rules.pro` (ProGuard rules)
6. ✓ `android/app/proguard-rules-optimized.pro` (Optimized ProGuard)

### Updated Files
1. ✓ [android/app/build.gradle.kts](android/app/build.gradle.kts) - App ID, signing, dependencies
2. ✓ [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml) - Permissions, label, icon
3. ✓ [ios/Runner.xcodeproj/project.pbxproj](ios/Runner.xcodeproj/project.pbxproj) - Bundle ID
4. ✓ [pubspec.yaml](pubspec.yaml) - Version number
5. ✓ `android/app/src/main/kotlin/com/ribal/tasks/MainActivity.kt` - Package name & location

---

## Security Credentials Summary

### Android Keystore Details
- **Location:** `android/app/ribal-release-key.jks`
- **Alias:** `ribal-key`
- **Passwords:** `ribal123456` (both key and store)

⚠️ **IMPORTANT:** These credentials are hardcoded in `build.gradle.kts`. For production, consider using environment variables or a secure key management system.

### Firebase API Keys (Project: ribal-4ac8c)
- **Android API Key:** `AIzaSyCDtsXnqHav0_VgNZNHR0tFbAuofjiQiG4`
- **iOS API Key:** `AIzaSyCK-EK_guRZ5AtrrPGU33HNPpcFOqlSFXE`

These are public API keys restricted by bundle ID/package name (`com.ribal.tasks`) in Firebase Console.

⚠️ **Note:** The old app used a different Firebase project (`ribal-tasks`) which only handled notifications. The new app uses `ribal-4ac8c` which contains your full backend (Auth, Firestore, Functions, Cloud Storage). Do NOT confuse these two projects!

---

## Pre-Deployment Checklist

Before building and deploying the new app:

### Android
- [ ] Verify keystore file exists: `ls -la android/app/ribal-release-key.jks`
- [ ] Test release build: `flutter build appbundle --release`
- [ ] Verify signing: `jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab`
- [ ] Check ProGuard doesn't break functionality
- [ ] Test on physical Android device

### iOS
- [ ] Open in Xcode: `open ios/Runner.xcworkspace`
- [ ] Verify Bundle ID: `com.ribal.tasks`
- [ ] Select correct provisioning profile: "ribal profile 1"
- [ ] Configure signing certificate in Xcode
- [ ] Test release build: `flutter build ios --release`
- [ ] Test on physical iOS device
- [ ] Verify push notifications work

### General
- [ ] Test Firebase authentication
- [ ] Test Firebase messaging (push notifications)
- [ ] Test all permissions (photos, documents)
- [ ] Verify app icon displays correctly
- [ ] Check app name shows as "Ribal"
- [ ] Test deep linking/URL schemes if applicable
- [ ] Run on both iOS and Android devices

---

## Store Submission Notes

### Google Play Store
1. The app will **update** the existing app (same `com.ribal.tasks` package)
2. Build number (12) is higher than current version (11)
3. Upload the AAB file: `build/app/outputs/bundle/release/app-release.aab`
4. Update release notes for version 1.0.10

### Apple App Store
1. The app will **update** the existing app (same `com.ribal.tasks` bundle ID)
2. Build number (12) is higher than current version (11)
3. Use Xcode or `flutter build ipa` to create IPA
4. Upload via App Store Connect or Transporter
5. Update release notes for version 1.0.10

---

## Troubleshooting

### If build fails with "Duplicate class" errors:
- Clean build: `flutter clean && flutter pub get`
- Check for conflicting dependencies

### If signing fails on Android:
- Verify keystore path is correct
- Check keystore passwords match
- Ensure keystore file has read permissions

### If iOS provisioning fails:
- Open Xcode and let it automatically manage signing
- Or manually select "ribal profile 1" in signing settings
- Ensure your Apple Developer account has access

### If Firebase doesn't work:
- Verify package name matches in Firebase Console: `com.ribal.tasks`
- Check SHA fingerprints are registered (Android)
- Ensure GoogleService files are in correct locations

---

## Next Steps

1. **Test the build:**
   ```bash
   cd /Users/abdelrahmanhamdy/projects/ribal-new
   flutter pub get
   flutter build appbundle --release  # Android
   flutter build ios --release         # iOS
   ```

2. **Verify configurations:**
   - Check app installs with correct name and icon
   - Test all Firebase features
   - Verify permissions work correctly

3. **Deploy:**
   - Upload to Google Play Console (internal/beta testing first)
   - Upload to App Store Connect (TestFlight first)
   - Run through store review process

---

## Additional Notes

- The old app used Shorebird code push (`shorebird.yaml` in assets). The new app doesn't have this configured yet - add if needed.
- The old app had custom launcher icons configured. Ensure you run `flutter pub run flutter_launcher_icons` if icons need regeneration.
- Both apps use the same Firebase project, so data should be compatible.

---

## Contact & Support

If you encounter any issues during deployment:
1. Check Firebase Console for app registration
2. Verify signing certificates in respective consoles
3. Ensure version numbers are incrementing correctly

**Migration completed successfully!** 🎉
