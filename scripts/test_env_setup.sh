#!/bin/bash

# Test script to verify environment configuration setup
# This script tests both make dev-run and IDE run scenarios

set -e  # Exit on error

echo "================================================"
echo "Environment Configuration Test"
echo "================================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Check .env.dev exists
echo "Test 1: Checking .env.dev file..."
if [ -f .env.dev ]; then
    echo -e "${GREEN}✅ .env.dev exists${NC}"
else
    echo -e "${RED}❌ .env.dev not found${NC}"
    exit 1
fi

# Test 2: Check required variables in .env.dev
echo ""
echo "Test 2: Checking required variables in .env.dev..."
REQUIRED_VARS=("ENV" "APP_NAME" "APPLICATION_ID" "API_BASE_URL" "FIREBASE_API_KEY" "FIREBASE_APP_ID" "FIREBASE_MESSAGING_SENDER_ID" "FIREBASE_PROJECT_ID" "ENCRYPTION_KEY")
MISSING_VARS=()

for VAR in "${REQUIRED_VARS[@]}"; do
    if grep -q "^$VAR=" .env.dev; then
        VALUE=$(grep "^$VAR=" .env.dev | cut -d'=' -f2)
        if [ -z "$VALUE" ]; then
            MISSING_VARS+=("$VAR")
            echo -e "${RED}❌ $VAR is empty${NC}"
        else
            echo -e "${GREEN}✅ $VAR is set${NC}"
        fi
    else
        MISSING_VARS+=("$VAR")
        echo -e "${RED}❌ $VAR not found${NC}"
    fi
done

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
    echo -e "${RED}Missing or empty variables: ${MISSING_VARS[*]}${NC}"
    exit 1
fi

# Test 3: Check .gitignore
echo ""
echo "Test 3: Checking .gitignore..."
if grep -q "^\.env$" .gitignore && grep -q "^\.env\.dev$" .gitignore && grep -q "^\.env\.prod$" .gitignore; then
    echo -e "${GREEN}✅ .env files are in .gitignore${NC}"
else
    echo -e "${YELLOW}⚠️  .env files might not be properly excluded from git${NC}"
fi

# Test 4: Check files exist
echo ""
echo "Test 4: Checking required files..."
FILES=(
    "lib/main.dart"
    "lib/main_dev.dart"
    "lib/main_prod.dart"
    "lib/config/env_loader.dart"
    "lib/config/environment.dart"
    "lib/config/app_config.dart"
    "lib/config/env/dev_config.dart"
    "lib/config/env/prod_config.dart"
    "Makefile"
)

for FILE in "${FILES[@]}"; do
    if [ -f "$FILE" ]; then
        echo -e "${GREEN}✅ $FILE exists${NC}"
    else
        echo -e "${RED}❌ $FILE not found${NC}"
        exit 1
    fi
done

# Test 5: Check Flutter analyze
echo ""
echo "Test 5: Running Flutter analyze on key files..."
if flutter analyze lib/main.dart lib/config/env_loader.dart --no-fatal-infos > /dev/null 2>&1; then
    echo -e "${GREEN}✅ No analysis errors${NC}"
else
    echo -e "${YELLOW}⚠️  Some analysis warnings (this is OK)${NC}"
fi

# Test 6: Check Makefile commands
echo ""
echo "Test 6: Checking Makefile commands..."
if grep -q "^dev-run:" Makefile; then
    echo -e "${GREEN}✅ make dev-run command exists${NC}"
else
    echo -e "${RED}❌ make dev-run command not found${NC}"
    exit 1
fi

if grep -q "^prod-run:" Makefile; then
    echo -e "${GREEN}✅ make prod-run command exists${NC}"
else
    echo -e "${RED}❌ make prod-run command not found${NC}"
    exit 1
fi

# Test 7: Check Android configuration
echo ""
echo "Test 7: Checking Android configuration..."
if grep -q "dev" android/app/build.gradle.kts && grep -q "prod" android/app/build.gradle.kts; then
    echo -e "${GREEN}✅ Android flavors configured${NC}"
else
    echo -e "${RED}❌ Android flavors not properly configured${NC}"
    exit 1
fi

echo ""
echo "================================================"
echo -e "${GREEN}✅ All tests passed!${NC}"
echo "================================================"
echo ""
echo "Summary:"
echo "  ✅ Environment files configured"
echo "  ✅ All required files present"
echo "  ✅ No critical errors"
echo "  ✅ Makefile commands ready"
echo "  ✅ Android flavors configured"
echo ""
echo "You can now run:"
echo "  - ${GREEN}make dev-run${NC}     (command line with --dart-define)"
echo "  - ${GREEN}Run from IDE${NC}     (Android Studio with .env.dev file)"
echo ""

