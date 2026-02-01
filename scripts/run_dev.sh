#!/bin/bash

# Run Flutter app in development mode
# Usage: ./scripts/run_dev.sh

set -e

echo "🚀 Starting app in DEVELOPMENT mode..."

# Check if .env.dev exists and load it
if [ -f .env.dev ]; then
    echo "📄 Loading environment variables from .env.dev"
    export $(cat .env.dev | grep -v '^#' | xargs)

    # Run the app with dart-define flags
    flutter run \
        -t lib/main_dev.dart \
        --flavor dev \
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

echo "✅ Development app started"

