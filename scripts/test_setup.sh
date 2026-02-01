#!/bin/bash

# Test Environment Setup Implementation
# This script tests if all environment setup components are correctly implemented

echo "🧪 Testing Environment Setup Implementation"
echo "=========================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TOTAL=0
PASSED=0
FAILED=0

# Test function
test_file() {
    TOTAL=$((TOTAL + 1))
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗${NC} $2"
        echo -e "  ${YELLOW}Missing: $1${NC}"
        FAILED=$((FAILED + 1))
    fi
}

# Test directory
test_dir() {
    TOTAL=$((TOTAL + 1))
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗${NC} $2"
        echo -e "  ${YELLOW}Missing: $1${NC}"
        FAILED=$((FAILED + 1))
    fi
}

echo "📋 Testing Core Configuration Files"
echo "-----------------------------------"
test_file "lib/config/environment.dart" "Environment enum"
test_file "lib/config/app_config.dart" "AppConfig model"
test_file "lib/config/env/dev_config.dart" "Development config"
test_file "lib/config/env/prod_config.dart" "Production config"
echo ""

echo "📋 Testing Entry Points"
echo "----------------------"
test_file "lib/main.dart" "Generic entry point"
test_file "lib/main_dev.dart" "Development entry point"
test_file "lib/main_prod.dart" "Production entry point"
echo ""

echo "📋 Testing Dependency Injection"
echo "-------------------------------"
test_file "lib/core/di/injection_container.dart" "DI container"
echo ""

echo "📋 Testing Services"
echo "------------------"
test_file "lib/core/services/firebase_service.dart" "Firebase service"
echo ""

echo "📋 Testing Android Configuration"
echo "--------------------------------"
test_file "android/app/build.gradle.kts" "Android build config (flavors)"
test_dir "android/app/src/dev" "Dev flavor directory"
test_dir "android/app/src/prod" "Prod flavor directory"
test_file "android/app/src/README.md" "Android Firebase instructions"
echo ""

echo "📋 Testing iOS Configuration"
echo "----------------------------"
test_file "ios/Runner/Dev.xcconfig" "iOS dev config"
test_file "ios/Runner/Prod.xcconfig" "iOS prod config"
test_dir "ios/Runner/Firebase/dev" "iOS dev Firebase directory"
test_dir "ios/Runner/Firebase/prod" "iOS prod Firebase directory"
test_file "ios/Runner/Firebase/README.md" "iOS Firebase instructions"
echo ""

echo "📋 Testing Build Scripts"
echo "------------------------"
test_file "Makefile" "Makefile"
test_file "scripts/run_dev.sh" "Run dev script"
test_file "scripts/run_prod.sh" "Run prod script"
test_file "scripts/build_apk_dev.sh" "Build dev APK script"
test_file "scripts/build_apk_prod.sh" "Build prod APK script"
test_file "scripts/build_appbundle_prod.sh" "Build prod AAB script"
test_file "scripts/build_ios_dev.sh" "Build dev iOS script"
test_file "scripts/build_ios_prod.sh" "Build prod iOS script"
test_file "scripts/generate.sh" "Code generation script"
echo ""

echo "📋 Testing Documentation"
echo "-----------------------"
test_file ".env.example" "Environment variables example"
test_file "BUILD_GUIDE.md" "Build guide"
test_file "QUICK_REFERENCE.md" "Quick reference"
test_file "ENVIRONMENT_SETUP_SUMMARY.md" "Setup summary"
test_file "README.md" "README"
test_file ".gitignore" "Gitignore"
echo ""

echo "📋 Testing CI/CD"
echo "---------------"
test_file ".github/workflows/build.yml" "GitHub Actions workflow"
echo ""

echo "=========================================="
echo "📊 Test Results"
echo "=========================================="
echo -e "Total tests: $TOTAL"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo -e "${GREEN}Environment setup is complete and ready to use.${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠ Some tests failed.${NC}"
    echo -e "${YELLOW}Please review the missing files above.${NC}"
    exit 1
fi

