# Shorebird Setup Guide for Ribal Developers

## Overview

This guide will help you set up Shorebird Code Push for the Ribal Flutter app. Shorebird enables instant over-the-air (OTA) updates for bug fixes and improvements without requiring app store submissions.

## Prerequisites

- **Flutter SDK**: 3.19.0 or higher
- **Git**: For version control
- **Shorebird account**: Create at [console.shorebird.dev](https://console.shorebird.dev)
- **Android/iOS development environment**: Android Studio and/or Xcode
- **Access to CodeMagic**: For CI/CD automation

## Installation

### 1. Install Shorebird CLI

**Mac/Linux:**
```bash
curl --proto '=https' --tlsv1.2 \
  https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash
```

**Add to PATH** (add to `~/.zshrc` or `~/.bash_profile`):
```bash
export PATH="$HOME/.shorebird/bin:$PATH"
```

**Reload shell:**
```bash
source ~/.zshrc  # or source ~/.bash_profile
```

### 2. Verify Installation

```bash
shorebird --version
shorebird doctor
```

Expected output:
```
Shorebird <version>
Flutter <version> • Dart <version>
```

### 3. Authenticate with Shorebird

```bash
shorebird login
```

This will open your browser for authentication. Sign in with your Shorebird account.

## Project Initialization

### Quick Setup (Automated)

Run the provided initialization script:

```bash
cd /path/to/ribal-new
./scripts/init_shorebird.sh
```

This script will:
- Install Shorebird CLI (if not already installed)
- Authenticate with Shorebird
- Initialize the project
- Display your app ID for CodeMagic configuration

### Manual Setup

If you prefer manual setup:

```bash
cd /path/to/ribal-new
shorebird init
```

Answer the prompts:
- **App name**: ribal
- **Organization**: (your organization)

This creates `shorebird.yaml` in the project root.

## Configuration

### Shorebird Configuration (shorebird.yaml)

After initialization, you'll have a `shorebird.yaml` file:

```yaml
# Shorebird configuration
app_id: <YOUR_APP_ID>
flavors: {}
```

**Important**: Commit this file to version control. It contains only the non-sensitive app ID.

### ProGuard Rules (Android)

The ProGuard rules have already been updated in [`android/app/proguard-rules.pro`](../android/app/proguard-rules.pro) to include Shorebird-specific keep rules. These rules ensure:

- Shorebird updater classes are not stripped
- FCM background handler is preserved
- @pragma annotations are maintained

### iOS Entitlements

The iOS entitlements file ([`ios/Runner/Runner.entitlements`](../ios/Runner/Runner.entitlements)) has been configured with comments:

- Use `development` for TestFlight testing
- Change to `production` before App Store submission

## Building for Development

### Android

**Debug build** (standard Flutter, no Shorebird):
```bash
flutter run
```

**Release build with Shorebird**:
```bash
shorebird release android --flutter-version=3.19.0
```

This creates a Shorebird-enabled release build that can receive OTA patches.

### iOS

**Debug build** (standard Flutter, no Shorebird):
```bash
flutter run
```

**Release build with Shorebird**:
```bash
shorebird release ios --flutter-version=3.19.0
```

**Note**: iOS release builds require proper signing configuration in Xcode.

## Testing Patches Locally

### Preview Patches Before Deployment

```bash
# Make your code changes (Dart code only)
# Then test the patch locally:

shorebird preview
```

This:
1. Creates a temporary patch
2. Runs it on a connected device/emulator
3. Allows you to test changes before deploying

## Creating Your First Patch

### Step 1: Make Changes

Edit Dart code only. For example, fix a bug in a repository or update a UI text:

```dart
// lib/features/admin/home/pages/admin_home_page.dart
// Change: "المهام" → "المهام اليومية"
```

### Step 2: Test Locally

```bash
shorebird preview
```

### Step 3: Commit Changes

```bash
git add .
git commit -m "fix: update task list title"
```

### Step 4: Deploy Patch

```bash
# Get current version from pubspec.yaml
VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}')

# Create patch for Android
shorebird patch android --release-version=$VERSION

# Create patch for iOS
shorebird patch ios --release-version=$VERSION
```

### Step 5: Verify Deployment

Check the Shorebird console:
```bash
open https://console.shorebird.dev
```

View your app → Patches → See install count and status

## Common Issues & Solutions

### Issue 1: "shorebird: command not found"

**Solution**: Ensure Shorebird is in your PATH:
```bash
export PATH="$HOME/.shorebird/bin:$PATH"
source ~/.zshrc
```

### Issue 2: "No release found for version X.X.X"

**Solution**: Create a release first before creating patches:
```bash
shorebird release android --flutter-version=3.19.0
```

### Issue 3: ProGuard breaks Shorebird on Android

**Solution**:
- Verify [`android/app/proguard-rules.pro`](../android/app/proguard-rules.pro) includes Shorebird keep rules
- Test with a release build: `flutter build appbundle --release`
- Check ProGuard mapping files in `build/app/outputs/mapping/release/`

### Issue 4: FCM background handler not working after patch

**Solution**:
- Ensure `@pragma('vm:entry-point')` annotation exists on the handler in [`lib/main.dart`](../lib/main.dart)
- ProGuard rules preserve this annotation (already configured)
- Test by sending a notification when the app is **terminated** (not just background)

### Issue 5: Patch not downloading on device

**Solution**:
- Check network connectivity
- Verify device can reach shorebird.dev
- App checks for updates on startup - restart the app
- Wait 30 seconds for the update check to complete

## CodeMagic Integration

### Environment Variables

Add these to CodeMagic project settings:

```bash
SHOREBIRD_TOKEN                    # Get via: shorebird login:ci
SHOREBIRD_APP_ID                   # From shorebird.yaml
```

**Get CI token**:
```bash
shorebird login:ci
```

Copy the token and add to CodeMagic.

### Automated Workflows

The [`codemagic.yaml`](../codemagic.yaml) file defines three workflows:

1. **shorebird-release**: Full releases (triggered by push to `main`)
2. **shorebird-patch**: OTA patches (triggered by push to `hotfix/*` branches)
3. **shorebird-preview**: Development builds (triggered by push to `develop`)

## Best Practices

### ✅ DO:

- **Test patches locally** before deploying (`shorebird preview`)
- **Use hotfix branches** for patches (`git checkout -b hotfix/fix-name`)
- **Keep patches small** - single bug fix or minor improvement
- **Monitor patch adoption** via Shorebird console
- **Commit `shorebird.yaml`** to version control

### ❌ DON'T:

- **Don't patch native code** - requires store release
- **Don't patch asset files** (images, fonts) - not supported
- **Don't skip testing** - always preview patches first
- **Don't patch breaking changes** - use store releases for major updates
- **Don't ignore ProGuard rules** - can break Shorebird on Android

## Release vs Patch Decision Matrix

| Change Type | Method |
|-------------|--------|
| Bug fix in Dart code | Shorebird Patch |
| UI text change | Shorebird Patch |
| Business logic fix | Shorebird Patch |
| Add new Dart dependency | Shorebird Patch (no native code) |
| Update Firebase plugin | Store Release |
| Add new permissions | Store Release |
| Change app icon/assets | Store Release |
| Update Flutter SDK | Store Release |

## Quick Reference Commands

```bash
# Install Shorebird
curl --proto '=https' --tlsv1.2 \
  https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash

# Initialize project
shorebird init

# Create release
shorebird release android --flutter-version=3.19.0
shorebird release ios --flutter-version=3.19.0

# Create patch
shorebird patch android --release-version=1.0.10+12
shorebird patch ios --release-version=1.0.10+12

# Test locally
shorebird preview

# List releases
shorebird releases list

# List patches
shorebird patches list

# Check environment
shorebird doctor
```

## Additional Resources

- **Shorebird Documentation**: https://docs.shorebird.dev
- **Shorebird Console**: https://console.shorebird.dev
- **Discord Community**: https://discord.gg/shorebird
- **Ribal Patch Workflow**: [PATCH_RELEASE_WORKFLOW.md](PATCH_RELEASE_WORKFLOW.md)

## Support

For Shorebird-related issues:
- Check [Common Issues](#common-issues--solutions) above
- Consult [Shorebird docs](https://docs.shorebird.dev)
- Ask in Shorebird Discord
- Contact team lead for CodeMagic access issues
