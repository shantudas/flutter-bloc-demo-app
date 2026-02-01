#!/bin/bash

# Build development iOS app
# Usage: ./scripts/build_ios_dev.sh

set -e

echo "📱 Building DEVELOPMENT iOS app..."

# Check if .env.dev exists and load it
if [ -f .env.dev ]; then
    echo "📄 Loading environment variables from .env.dev"
    export $(cat .env.dev | grep -v '^#' | xargs)

    # Build the iOS app with dart-define flags
    flutter build ios \
        -t lib/main_dev.dart \
        --debug \
        --dart-define=ENV=$ENV \
        --dart-define=API_BASE_URL=$API_BASE_URL \
        --dart-define=FIREBASE_API_KEY=$FIREBASE_API_KEY \
        --dart-define=FIREBASE_APP_ID=$FIREBASE_APP_ID \
        --dart-define=FIREBASE_MESSAGING_SENDER_ID=$FIREBASE_MESSAGING_SENDER_ID \
        --dart-define=FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID \
        --dart-define=ENCRYPTION_KEY=$ENCRYPTION_KEY \
        --dart-define=APP_NAME="$APP_NAME" \
        --dart-define=APPLICATION_ID=$APPLICATION_ID
else
    echo "❌ ERROR: .env.dev file is required for development builds"
    echo "Create it from .env.example: cp .env.example .env.dev"
    exit 1
fi

echo "✅ Development iOS app built successfully!"
echo "📁 Output: build/ios/iphoneos/Runner.app"

