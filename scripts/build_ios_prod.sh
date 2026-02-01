#!/bin/bash

# Build production iOS app with obfuscation
# Usage: ./scripts/build_ios_prod.sh

set -e

echo "📱 Building PRODUCTION iOS app..."

# Check if .env.prod exists and load it
if [ -f .env.prod ]; then
    echo "📄 Loading environment variables from .env.prod"
    export $(cat .env.prod | grep -v '^#' | xargs)
fi

# Build the iOS app with obfuscation
flutter build ios \
    -t lib/main_prod.dart \
    --release \
    --obfuscate \
    --split-debug-info=build/symbols

echo "✅ Production iOS app built successfully!"
echo "📁 Output: build/ios/iphoneos/Runner.app"
echo "🔐 Debug symbols: build/symbols"
echo ""
echo "📤 Open Xcode to archive and upload to App Store"

