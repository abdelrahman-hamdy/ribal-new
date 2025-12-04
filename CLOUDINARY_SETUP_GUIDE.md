# Cloudinary Configuration Guide

## Problem
The profile photo upload feature shows "invalid_api_key" error when users try to change their profile picture. This is caused by missing or incorrectly configured Firebase Secrets for Cloudinary integration.

## Solution

### Step 1: Get Cloudinary Credentials

1. Log in to your [Cloudinary Dashboard](https://cloudinary.com/console)
2. Go to **Dashboard** (home page)
3. You'll see your credentials:
   - **Cloud Name**: `dj16a87b9` (already configured in app)
   - **API Key**: `777665224244565` (copy this)
   - **API Secret**: (click "Reveal" to see it, then copy)

### Step 2: Configure Firebase Secrets

Run the following commands to set up the secrets:

```bash
# Set Cloudinary API Key
firebase functions:secrets:set CLOUDINARY_API_KEY
# When prompted, paste: 777665224244565

# Set Cloudinary API Secret
firebase functions:secrets:set CLOUDINARY_API_SECRET
# When prompted, paste the API Secret from Cloudinary Dashboard
```

### Step 3: Deploy Cloud Functions

After setting the secrets, deploy the functions:

```bash
firebase deploy --only functions
```

### Step 4: Verify Configuration

To verify the secrets are set correctly:

```bash
# Check Firebase Console
# Go to: Firebase Console > Functions > Secrets
# You should see:
# - CLOUDINARY_API_KEY
# - CLOUDINARY_API_SECRET
```

## What Was Fixed

### 1. Cloud Function Error Handling ([functions/src/index.ts](functions/src/index.ts))
- Added validation to check if secrets are configured
- Improved error handling to prevent crashes
- Returns user-friendly errors instead of exposing technical details

### 2. Flutter App Error Messages ([lib/data/services/storage_service.dart](lib/data/services/storage_service.dart))
- Added handling for "invalid_api_key" error
- Improved error messages for all Cloud Function errors
- Never exposes technical error codes to users
- All errors now show user-friendly Arabic messages

## Error Messages Mapping

| Technical Error | User-Friendly Message (Arabic) |
|----------------|-------------------------------|
| invalid_api_key | خدمة الرفع غير متوفرة حالياً. يرجى المحاولة لاحقاً |
| failed-precondition | الخدمة غير جاهزة حالياً. يرجى المحاولة لاحقاً |
| internal | حدث خطأ داخلي. يرجى المحاولة مرة أخرى |
| signature | خطأ في التحقق. حاول مرة أخرى |
| unauthorized | غير مصرح برفع الملفات |
| file size | حجم الملف كبير جداً. الحد الأقصى هو 10 ميجابايت |
| Other errors | حدث خطأ أثناء رفع الملف. يرجى المحاولة مرة أخرى |

## Testing

After deployment, test the profile photo upload:

1. Open the app
2. Go to Profile page
3. Tap on the profile photo
4. Select an image
5. Upload should complete successfully
6. If there's an error, it should show a user-friendly Arabic message

## Troubleshooting

### Still getting "invalid_api_key" error
1. Verify secrets are set: Check Firebase Console > Functions > Secrets
2. Check the API Key value matches your Cloudinary dashboard
3. Redeploy functions: `firebase deploy --only functions`

### Getting "Service not available" error
1. Check Cloud Function logs: Firebase Console > Functions > Logs
2. Look for errors in `getCloudinarySignature` function
3. Verify the API Secret is correct

### Upload fails with network error
1. Check device internet connection
2. Verify Cloudinary account is active
3. Check if file size exceeds 10MB limit
