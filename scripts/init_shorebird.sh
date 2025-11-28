#!/bin/bash
# ============================================================================
# Initialize Shorebird for Ribal App
# Usage: ./scripts/init_shorebird.sh
# ============================================================================

set -e

echo "🚀 Initializing Shorebird for Ribal..."
echo ""

# Check if Shorebird is installed
if ! command -v shorebird &> /dev/null; then
    echo "❌ Shorebird CLI not found. Installing..."
    curl --proto '=https' --tlsv1.2 \
      https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash
    export PATH="$HOME/.shorebird/bin:$PATH"
    echo "✅ Shorebird CLI installed successfully"
else
    echo "✅ Shorebird CLI already installed"
fi

# Verify Shorebird version
echo ""
echo "📦 Shorebird version:"
shorebird --version

# Login to Shorebird (interactive)
echo ""
echo "🔐 Logging in to Shorebird..."
echo "⚠️  This will open your browser for authentication"
shorebird login

# Initialize Shorebird in project
echo ""
echo "📦 Initializing Shorebird in project..."
shorebird init

# Verify configuration
if [ -f "shorebird.yaml" ]; then
    echo ""
    echo "✅ Shorebird initialized successfully!"
    echo "📝 shorebird.yaml created"

    # Display app ID
    SHOREBIRD_APP_ID=$(grep 'app_id:' shorebird.yaml | awk '{print $2}')
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔑 Your Shorebird App ID: $SHOREBIRD_APP_ID"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "⚠️  IMPORTANT: Add these to CodeMagic environment variables:"
    echo "   SHOREBIRD_APP_ID=$SHOREBIRD_APP_ID"
    echo ""
    echo "   Get SHOREBIRD_TOKEN by running:"
    echo "   shorebird login:ci"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
    echo "❌ Error: shorebird.yaml not created"
    exit 1
fi

# Run doctor to check setup
echo ""
echo "🔍 Running Shorebird doctor..."
shorebird doctor

echo ""
echo "✅ Shorebird setup complete!"
echo ""
echo "📚 Next steps:"
echo "   1. Get CI token: shorebird login:ci"
echo "   2. Add environment variables to CodeMagic"
echo "   3. Update ProGuard rules (already done)"
echo "   4. Create first release: shorebird release android"
echo ""
