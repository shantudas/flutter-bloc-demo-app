#!/bin/bash

# Run code generation with build_runner
# Usage: ./scripts/generate.sh

set -e

echo "⚙️  Running code generation..."

flutter pub run build_runner build --delete-conflicting-outputs

echo "✅ Code generation complete!"

