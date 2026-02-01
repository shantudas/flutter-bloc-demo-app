#!/bin/bash

# Build production APK with obfuscation
# Usage: ./scripts/build_apk_prod.sh

set -e

echo "📦 Building PRODUCTION APK..."

# Check if .env.prod exists and load it
if [ -f .env.prod ]; then
    echo "📄 Loading environment variables from .env.prod"
    export $(cat .env.prod | grep -v '^#' | xargs)

    # Validate required variables
    if [ -z "$API_BASE_URL" ] || [ -z "$FIREBASE_API_KEY" ] || [ -z "$ENCRYPTION_KEY" ]; then
        echo "❌ ERROR: Required environment variables missing in .env.prod"
        echo "Required: API_BASE_URL, FIREBASE_API_KEY, FIREBASE_APP_ID, FIREBASE_MESSAGING_SENDER_ID, FIREBASE_PROJECT_ID, ENCRYPTION_KEY"
        exit 1
    fi

    # Build the APK with obfuscation and dart-define flags
    flutter build apk \
        -t lib/main_prod.dart \
        --flavor prod \
        --release \
        --obfuscate \
        --split-debug-info=build/symbols \
        --dart-define=ENV=prod \
        --dart-define=API_BASE_URL=$API_BASE_URL \
        --dart-define=FIREBASE_API_KEY=$FIREBASE_API_KEY \
        --dart-define=FIREBASE_APP_ID=$FIREBASE_APP_ID \
        --dart-define=FIREBASE_MESSAGING_SENDER_ID=$FIREBASE_MESSAGING_SENDER_ID \
        --dart-define=FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID \
        --dart-define=ENCRYPTION_KEY=$ENCRYPTION_KEY
else
    echo "❌ ERROR: .env.prod file is required for production builds"
    echo "Create .env.prod from .env.example and fill in production values"
    exit 1
fi

echo "✅ Production APK built successfully!"
echo "📁 Output: build/app/outputs/flutter-apk/app-prod-release.apk"
echo "🔐 Debug symbols: build/symbols"

