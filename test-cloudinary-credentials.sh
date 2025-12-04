#!/bin/bash

# Test Cloudinary credentials
# This script tests if your Cloudinary API key and secret are valid

echo "🔍 Testing Cloudinary Credentials"
echo "=================================="
echo ""

# Known values
CLOUD_NAME="dj16a87b9"
API_KEY="777665224244565"

echo "Cloud Name: $CLOUD_NAME"
echo "API Key: $API_KEY"
echo ""
echo "⚠️  You need to paste your API Secret from Cloudinary dashboard"
echo "   Visit: https://console.cloudinary.com/console"
echo "   Click 'Reveal' next to API Secret"
echo ""
read -p "Paste your Cloudinary API Secret: " API_SECRET
echo ""

# Test authentication by making a simple API call
echo "📡 Testing credentials with Cloudinary API..."
echo ""

response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
  "https://api.cloudinary.com/v1_1/$CLOUD_NAME/resources/image" \
  -u "$API_KEY:$API_SECRET")

http_status=$(echo "$response" | grep "HTTP_STATUS" | cut -d':' -f2)
response_body=$(echo "$response" | sed '/HTTP_STATUS/d')

echo "HTTP Status: $http_status"
echo ""

if [ "$http_status" = "200" ]; then
    echo "✅ SUCCESS! Your credentials are VALID"
    echo ""
    echo "Response from Cloudinary:"
    echo "$response_body" | python3 -m json.tool 2>/dev/null || echo "$response_body"
    echo ""
    echo "=================================="
    echo "✅ Your credentials work!"
    echo ""
    echo "📝 Now update Firebase secrets:"
    echo "   1. echo \"$API_KEY\" | firebase functions:secrets:set CLOUDINARY_API_KEY"
    echo "   2. echo \"YOUR_SECRET\" | firebase functions:secrets:set CLOUDINARY_API_SECRET"
    echo "   3. firebase deploy --only functions:getCloudinarySignature --force"
    echo ""
elif [ "$http_status" = "401" ]; then
    echo "❌ AUTHENTICATION FAILED!"
    echo ""
    echo "Your API Key or Secret is INCORRECT."
    echo ""
    echo "Error from Cloudinary:"
    echo "$response_body"
    echo ""
    echo "=================================="
    echo "⚠️  Please double-check your credentials at:"
    echo "   https://console.cloudinary.com/console"
    echo ""
    echo "Current values you're using:"
    echo "  - Cloud Name: $CLOUD_NAME"
    echo "  - API Key: $API_KEY"
    echo "  - API Secret: [the value you just pasted]"
    echo ""
else
    echo "⚠️  Unexpected response: HTTP $http_status"
    echo ""
    echo "Response:"
    echo "$response_body"
fi
