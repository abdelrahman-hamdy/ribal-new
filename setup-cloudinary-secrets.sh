#!/bin/bash

# Cloudinary Secret Setup Script for Firebase Functions
# This script helps you set up the required secrets for Cloudinary integration

echo "🔐 Cloudinary Secret Setup for Firebase Functions"
echo "=================================================="
echo ""
echo "✅ You are logged in as: abdelrahmanhamdy320@gmail.com"
echo "✅ Firebase Project: ribal-4ac8c"
echo ""
echo "📋 Known Credentials:"
echo "  - Cloud Name: dj16a87b9"
echo "  - API Key: 777665224244565"
echo ""
echo "⚠️  You need to get your API Secret from:"
echo "   https://console.cloudinary.com/console"
echo "   (Click 'Reveal' next to API Secret)"
echo ""
echo "=================================================="
echo ""

# Set API Key
echo "📝 Setting CLOUDINARY_API_KEY..."
echo "777665224244565" | firebase functions:secrets:set CLOUDINARY_API_KEY

if [ $? -eq 0 ]; then
    echo "✅ CLOUDINARY_API_KEY set successfully!"
    echo ""
else
    echo "❌ Failed to set CLOUDINARY_API_KEY"
    exit 1
fi

# Set API Secret
echo "📝 Now setting CLOUDINARY_API_SECRET..."
echo "⚠️  Please paste your Cloudinary API Secret when prompted:"
echo ""

firebase functions:secrets:set CLOUDINARY_API_SECRET

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ CLOUDINARY_API_SECRET set successfully!"
    echo ""
else
    echo "❌ Failed to set CLOUDINARY_API_SECRET"
    exit 1
fi

echo "=================================================="
echo "✅ All secrets configured successfully!"
echo ""
echo "📦 Next step: Deploy your Cloud Functions"
echo "   Run: firebase deploy --only functions"
echo ""
echo "🧪 After deployment, test the profile photo upload"
echo "=================================================="
