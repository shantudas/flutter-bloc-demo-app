#!/bin/bash

# Build development APK
# Usage: ./scripts/build_apk_dev.sh

set -e

echo "📦 Building DEVELOPMENT APK..."

# Check if .env.dev exists and load it
if [ -f .env.dev ]; then
    echo "📄 Loading environment variables from .env.dev"
    export $(cat .env.dev | grep -v '^#' | xargs)

    # Build the APK with dart-define flags
    flutter build apk \
        -t lib/main_dev.dart \
        --flavor dev \
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

echo "✅ Development APK built successfully!"
echo "📁 Output: build/app/outputs/flutter-apk/app-dev-debug.apk"

