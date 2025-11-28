#!/bin/bash
# ============================================================================
# Create Hotfix Branch for Shorebird Patch
# Usage: ./scripts/create_hotfix.sh <hotfix-name>
# Example: ./scripts/create_hotfix.sh fix-notification-crash
# ============================================================================

set -e

if [ -z "$1" ]; then
  echo "❌ Error: Hotfix name required"
  echo ""
  echo "Usage: $0 <hotfix-name>"
  echo "Example: $0 fix-notification-crash"
  echo ""
  echo "Valid hotfix names:"
  echo "  - fix-notification-crash"
  echo "  - fix-task-assignment-bug"
  echo "  - fix-fcm-delivery"
  echo "  - update-arabic-translation"
  exit 1
fi

HOTFIX_NAME=$1
HOTFIX_BRANCH="hotfix/$HOTFIX_NAME"

# Check if git repo is clean
if [[ -n $(git status --porcelain) ]]; then
  echo "⚠️  Warning: You have uncommitted changes"
  echo ""
  git status --short
  echo ""
  read -p "Do you want to continue? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Aborted"
    exit 1
  fi
fi

echo "🔧 Creating hotfix branch: $HOTFIX_BRANCH"
echo ""

# Ensure we're on main and up-to-date
echo "📥 Fetching latest changes from origin..."
git fetch origin

echo "✅ Checking out main branch..."
git checkout main

echo "📥 Pulling latest changes..."
git pull origin main

# Create hotfix branch
echo "🌿 Creating hotfix branch..."
git checkout -b $HOTFIX_BRANCH

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Hotfix branch created: $HOTFIX_BRANCH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 Next steps:"
echo "   1. Make your bug fix changes"
echo "   2. Commit: git add . && git commit -m 'fix: $HOTFIX_NAME'"
echo "   3. Push: git push origin $HOTFIX_BRANCH"
echo "   4. CodeMagic will automatically create a Shorebird patch"
echo ""
echo "⚠️  IMPORTANT:"
echo "   - This will trigger an OTA update to all users!"
echo "   - Test locally first: shorebird preview"
echo "   - Patch will be deployed to beta channel first"
echo "   - Promote to stable after testing: shorebird patch promote"
echo ""
echo "🔍 Current app version:"
grep "version:" pubspec.yaml
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
