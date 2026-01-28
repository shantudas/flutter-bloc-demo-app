# Flutter Production-Grade Setup Guide

## Overview
This guide provides a complete implementation strategy for setting up a production-ready Flutter application with two environments (development and production), secure configuration management, industry-standard logging, Firebase Crashlytics integration, and automated CI/CD using Fastlane and GitHub Actions.

---

## Table of Contents
1. [Environment Configuration](#1-environment-configuration)
2. [Logging System](#2-logging-system)
3. [Firebase Crashlytics Integration](#3-firebase-crashlytics-integration)
4. [Fastlane Setup](#4-fastlane-setup)
5. [GitHub Actions CI/CD](#5-github-actions-cicd)
6. [Project Structure](#6-project-structure)
7. [Secrets Management](#7-secrets-management)
8. [Testing Strategy](#8-testing-strategy)

---

## 1. Environment Configuration

### 1.1 Environment Architecture

**Objective**: Separate development and production configurations completely, including API endpoints, Firebase projects, and third-party service tokens.

**Approach**: Use multiple entry points with compile-time environment injection.

### 1.2 File Structure
```
lib/
├── main_dev.dart           # Development entry point
├── main_prod.dart          # Production entry point
├── config/
│   ├── environment.dart    # Environment enum and current config
│   ├── app_config.dart     # Configuration model class
│   └── env/
│       ├── dev_config.dart # Development configuration
│       └── prod_config.dart # Production configuration
```

### 1.3 Configuration Parameters

**Development Environment**:
- API Base URL: Development/staging API endpoint
- Firebase Project: Separate dev Firebase project
- API Keys: Development keys (limited scope)
- Feature Flags: All features enabled for testing
- Debug Mode: Enabled
- Log Level: DEBUG/VERBOSE

**Production Environment**:
- API Base URL: Production API endpoint
- Firebase Project: Production Firebase project
- API Keys: Production keys (full access)
- Feature Flags: Controlled rollout
- Debug Mode: Disabled
- Log Level: INFO/WARNING/ERROR only

### 1.4 Secrets to Configure

**Required Secrets**:
- API_BASE_URL
- FIREBASE_API_KEY
- FIREBASE_APP_ID
- FIREBASE_MESSAGING_SENDER_ID
- FIREBASE_PROJECT_ID
- GOOGLE_MAPS_API_KEY (if using maps)
- STRIPE_PUBLISHABLE_KEY (if using payments)
- SENTRY_DSN (optional, for additional error tracking)
- APP_ENCRYPTION_KEY (for secure storage)

### 1.5 Build Flavors

**Android (android/app/build.gradle)**:
- Development flavor: `dev`
    - Application ID: `com.yourapp.dev`
    - App name: "YourApp Dev"
    - Version name suffix: `-dev`
    - Different icon/colors

- Production flavor: `prod`
    - Application ID: `com.yourapp`
    - App name: "YourApp"
    - Standard versioning

**iOS (Xcode Schemes)**:
- Development scheme: `dev`
    - Bundle ID: `com.yourapp.dev`
    - Display name: "YourApp Dev"
    - Different icon

- Production scheme: `prod`
    - Bundle ID: `com.yourapp`
    - Display name: "YourApp"

### 1.6 Environment Loading Strategy

**At App Startup**:
1. Entry point (main_dev.dart or main_prod.dart) sets the environment
2. Load environment-specific configuration
3. Initialize services with environment config
4. Configure logger with environment-appropriate settings
5. Initialize Firebase with correct project
6. Start the app

---

## 2. Logging System

### 2.1 Logging Architecture

**Multi-Layer Approach**:
- **Console Logger**: Development debugging
- **File Logger**: Persistent local logs
- **Remote Logger**: Production error tracking
- **Analytics Logger**: User behavior and events

### 2.2 Log Levels

**Standard Log Levels** (RFC 5424 compliant):
1. **DEBUG** (Development only): Detailed diagnostic information
2. **INFO**: General informational messages
3. **WARNING**: Warning messages for potentially harmful situations
4. **ERROR**: Error events that might still allow the app to continue
5. **FATAL**: Very severe error events that might cause termination

**Environment-Based Filtering**:
- **Development**: All levels (DEBUG through FATAL)
- **Production**: INFO, WARNING, ERROR, FATAL only (no DEBUG)

### 2.3 Logger Features

**Core Capabilities**:
- Automatic context injection (timestamp, environment, app version, device info)
- Stack trace capture on errors
- Breadcrumb trail (last N actions before error)
- PII scrubbing (emails, phone numbers, tokens)
- Network request/response logging (sanitized)
- Performance monitoring integration
- Structured logging (JSON format for remote logs)
- Log rotation (file size limits)
- Crash-safe logging (buffered writes)

### 2.4 Logger Interface

**Key Methods**:
- `debug(message, {context})`
- `info(message, {context})`
- `warning(message, {context, error, stackTrace})`
- `error(message, {context, error, stackTrace})`
- `fatal(message, {context, error, stackTrace})`
- `logNetworkRequest(request, response, duration)`
- `logUserAction(action, metadata)`
- `logPerformanceMetric(metric, value)`

### 2.5 Structured Logging Format

**Standard Log Entry Structure**:
```json
{
  "timestamp": "ISO-8601 format",
  "level": "ERROR",
  "environment": "production",
  "message": "Human-readable message",
  "context": {
    "userId": "user_123",
    "sessionId": "session_456",
    "screenName": "ProfileScreen",
    "appVersion": "1.2.3",
    "buildNumber": "42"
  },
  "device": {
    "platform": "android",
    "osVersion": "13",
    "model": "Pixel 7",
    "locale": "en_US"
  },
  "error": {
    "type": "NetworkException",
    "message": "Connection timeout",
    "stackTrace": "..."
  },
  "breadcrumbs": [
    {"action": "login_success", "timestamp": "..."},
    {"action": "navigate_to_profile", "timestamp": "..."}
  ]
}
```

### 2.6 PII Scrubbing Strategy

**Sensitive Data to Remove**:
- Email addresses (regex pattern matching)
- Phone numbers (international format detection)
- Credit card numbers
- Authentication tokens
- Passwords
- Social security numbers
- Personal names (when possible)

**Scrubbing Approach**:
- Replace with masked values: `email@example.com` → `***@***.com`
- Use placeholders: `<REDACTED_EMAIL>`
- Hash non-reversibly for tracking purposes when needed

### 2.7 Dependencies

**Primary Packages**:
- `logger`: Base logging functionality
- `firebase_crashlytics`: Crash reporting
- `sentry_flutter`: (Optional) Additional error tracking
- `path_provider`: File storage for logs

---

## 3. Firebase Crashlytics Integration

### 3.1 Setup Strategy

**Dual Firebase Projects**:
- Development Firebase project (separate console project)
- Production Firebase project
- Each environment uses its own `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

### 3.2 Configuration Files Location

**Android**:
- Dev: `android/app/src/dev/google-services.json`
- Prod: `android/app/src/prod/google-services.json`

**iOS**:
- Dev: `ios/Runner/Firebase/Dev/GoogleService-Info.plist`
- Prod: `ios/Runner/Firebase/Prod/GoogleService-Info.plist`
- Xcode build phases copy the correct file based on scheme

### 3.3 Crashlytics Features to Implement

**Core Features**:
1. **Automatic Crash Reporting**: Native crashes and Flutter errors
2. **Custom Keys**: Add context to crashes (user ID, feature flags, etc.)
3. **Custom Logs**: Breadcrumb trail leading to crash
4. **Non-Fatal Exceptions**: Log caught exceptions
5. **User Identifiers**: Associate crashes with users (anonymized in dev)
6. **Crash-Free Users Tracking**: Percentage of users without crashes

### 3.4 Crashlytics Integration Points

**Initialization**:
- Initialize after Firebase initialization
- Enable/disable based on environment (optional disable in dev)
- Set user identifiers after authentication
- Configure custom keys for important app state

**Error Handling**:
- Wrap main app in error boundary
- Catch and report Flutter framework errors
- Report platform channel errors
- Handle isolate errors

**Custom Logging**:
- Log important user actions as breadcrumbs
- Log app state changes
- Log feature flag evaluations
- Log network failures

### 3.5 Crashlytics Custom Keys

**Recommended Keys**:
- `environment`: "dev" or "production"
- `user_id`: Anonymized user identifier
- `user_type`: User role or subscription level
- `feature_flags`: Active feature flags JSON
- `last_screen`: Screen user was on
- `session_duration`: Time since app start
- `network_status`: Online/offline
- `app_state`: Foreground/background

### 3.6 ProGuard/R8 Configuration (Android)

**Requirements**:
- Keep Crashlytics classes from obfuscation
- Upload mapping files to Firebase
- Automated upload via Gradle plugin

**Symbol Upload**:
- Android: Automatic via Gradle plugin
- iOS: Automatic via Firebase Crashlytics run script build phase

### 3.7 Testing Crashlytics

**Verification Steps**:
1. Force a test crash in development
2. Verify crash appears in Firebase console
3. Check symbolication is working (readable stack traces)
4. Verify custom keys are attached
5. Verify breadcrumbs are present
6. Test non-fatal exception logging

---

## 4. Fastlane Setup

### 4.1 Fastlane Structure

**Directory Layout**:
```
android/
└── fastlane/
    ├── Fastfile          # Main lanes definition
    ├── Appfile           # App identifiers
    ├── .env.dev          # Dev environment variables
    ├── .env.prod         # Production environment variables
    └── .env.secret       # Sensitive credentials (gitignored)

ios/
└── fastlane/
    ├── Fastfile          # Main lanes definition
    ├── Appfile           # App identifiers
    ├── Matchfile         # Code signing (if using Match)
    ├── .env.dev          # Dev environment variables
    ├── .env.prod         # Production environment variables
    └── .env.secret       # Sensitive credentials (gitignored)
```

### 4.2 Android Fastlane Implementation

**Key Lanes**:

**build_dev**:
- Clean build directory
- Flutter build with dev environment
- Build APK/AAB for dev flavor
- Generate version metadata
- Save artifacts

**build_prod**:
- Clean build directory
- Run tests
- Flutter build with prod environment
- Build signed AAB for production flavor
- Generate version metadata
- Save artifacts

**deploy_internal_dev**:
- Build dev APK/AAB
- Upload to Firebase App Distribution
- Notify team via Slack/Discord

**deploy_internal_prod**:
- Build production AAB
- Upload to Play Store internal track
- Send notification

**deploy_beta**:
- Build production AAB
- Run tests
- Upload to Play Store beta track
- Update release notes
- Send notification

**deploy_production**:
- Verify version number
- Build production AAB
- Upload to Play Store production track
- Rollout percentage configuration
- Update release notes
- Create Git tag
- Send success notification

**version_bump**:
- Increment version code
- Update version name (semantic versioning)
- Commit changes
- Push to repository

### 4.3 iOS Fastlane Implementation

**Key Lanes**:

**certificates_dev**:
- Match development certificates and profiles
- Update Xcode project settings

**certificates_prod**:
- Match app store certificates and profiles
- Update Xcode project settings

**build_dev**:
- Clean build directory
- Flutter build with dev environment
- Build IPA for dev scheme
- Generate version metadata
- Save artifacts

**build_prod**:
- Clean build directory
- Run tests
- Flutter build with prod environment
- Build signed IPA for production scheme
- Generate version metadata
- Save artifacts

**deploy_internal_dev**:
- Get dev certificates
- Build dev IPA
- Upload to Firebase App Distribution
- Notify team

**deploy_testflight_prod**:
- Get production certificates
- Build production IPA
- Upload to TestFlight
- Manage beta testers
- Update release notes
- Send notification

**deploy_appstore**:
- Verify version number
- Get production certificates
- Build production IPA
- Upload to App Store Connect
- Submit for review (optional)
- Update metadata
- Create Git tag
- Send success notification

**version_bump**:
- Increment build number
- Update version string
- Commit changes
- Push to repository

### 4.4 Common Lanes (Both Platforms)

**tests**:
- Run Flutter unit tests
- Run widget tests
- Generate coverage report
- Fail on test failures

**lint**:
- Run Flutter analyze
- Check code formatting
- Run custom linters

**screenshots**:
- Generate app screenshots for store listings
- Multiple device sizes
- Multiple locales

**changelog**:
- Generate changelog from Git commits
- Format for store submissions

### 4.5 Fastlane Environment Variables

**Development (.env.dev)**:
- ENVIRONMENT=dev
- FIREBASE_APP_ID_ANDROID=dev_android_id
- FIREBASE_APP_ID_IOS=dev_ios_id
- FIREBASE_DISTRIBUTION_GROUPS=dev-team,qa-team
- SLACK_WEBHOOK_URL=dev_slack_url

**Production (.env.prod)**:
- ENVIRONMENT=prod
- FIREBASE_APP_ID_ANDROID=prod_android_id
- FIREBASE_APP_ID_IOS=prod_ios_id
- SLACK_WEBHOOK_URL=prod_slack_url

**Secrets (.env.secret) - Gitignored**:
- PLAY_STORE_JSON_KEY_PATH=path/to/service_account.json
- MATCH_PASSWORD=match_repository_password
- FASTLANE_APPLE_ID=apple_id@email.com
- FASTLANE_APPLE_APP_SPECIFIC_PASSWORD=app_specific_password
- FIREBASE_TOKEN=firebase_ci_token
- SLACK_WEBHOOK_URL=webhook_url

### 4.6 Fastlane Plugins

**Recommended Plugins**:
- `fastlane-plugin-firebase_app_distribution`: Firebase distribution
- `fastlane-plugin-flutter`: Flutter integration (if not using direct commands)
- `fastlane-plugin-versioning`: Version management
- `fastlane-plugin-changelog`: Changelog generation

### 4.7 Code Signing

**Android**:
- Store keystore in secure location (not in Git)
- Use environment variables for keystore credentials
- Separate dev and prod keystores
- Upload to CI/CD secrets

**iOS**:
- **Option 1: Match** (Recommended)
    - Store certificates in private Git repository
    - Automated certificate management
    - Team synchronization

- **Option 2: Manual**
    - Store certificates in CI/CD secrets
    - Manual renewal process

---

## 5. GitHub Actions CI/CD

### 5.1 Workflow Strategy

**Workflow Files**:
```
.github/
└── workflows/
    ├── dev_android.yml          # Dev Android builds
    ├── dev_ios.yml              # Dev iOS builds
    ├── prod_android.yml         # Prod Android builds
    ├── prod_ios.yml             # Prod iOS builds
    ├── test.yml                 # Tests on PR
    └── release.yml              # Full release process
```

### 5.2 Trigger Configuration

**Development Workflows**:
- Trigger: Push to `develop` branch
- Trigger: Manual dispatch
- Action: Build and deploy to Firebase App Distribution

**Production Workflows**:
- Trigger: Push to `main` branch with tag (e.g., `v1.2.3`)
- Trigger: Manual dispatch with version input
- Action: Build, test, and deploy to stores

**Test Workflow**:
- Trigger: Pull request to `develop` or `main`
- Action: Run tests, linting, code analysis

**Release Workflow**:
- Trigger: Manual dispatch with version number
- Action: Version bump, tag, build both platforms, deploy

### 5.3 GitHub Actions Jobs Structure

**Android Development Workflow Jobs**:

1. **test_and_lint**:
    - Checkout code
    - Setup Flutter
    - Get dependencies
    - Run tests with coverage
    - Run Flutter analyze
    - Upload coverage reports

2. **build_dev_android**:
    - Depends on: test_and_lint
    - Checkout code
    - Setup Flutter
    - Setup Java
    - Decode and setup keystore from secrets
    - Setup Fastlane
    - Run Fastlane build_dev lane
    - Upload APK/AAB as artifact

3. **deploy_dev_android**:
    - Depends on: build_dev_android
    - Download build artifacts
    - Setup Fastlane
    - Run Fastlane deploy_internal_dev lane
    - Send notification (Slack/Discord)

**Android Production Workflow Jobs**:

1. **test_and_validate**:
    - Full test suite
    - Code quality checks
    - Version validation

2. **build_prod_android**:
    - Setup signing
    - Build production AAB
    - Run Fastlane build_prod lane

3. **deploy_internal**:
    - Deploy to Play Store internal track
    - Automated testing gate

4. **deploy_beta** (manual approval):
    - Promote to beta track
    - Notify beta testers

5. **deploy_production** (manual approval):
    - Promote to production
    - Staged rollout configuration
    - Create GitHub release
    - Tag version

**iOS Workflows** (similar structure):
- Additional certificate/provisioning setup
- Match integration
- TestFlight deployment
- App Store submission

### 5.4 GitHub Secrets Configuration

**Required Secrets**:

**Flutter/Firebase**:
- FIREBASE_TOKEN
- FIREBASE_DEV_GOOGLE_SERVICES_ANDROID (base64 encoded)
- FIREBASE_PROD_GOOGLE_SERVICES_ANDROID (base64 encoded)
- FIREBASE_DEV_GOOGLE_SERVICES_IOS (base64 encoded)
- FIREBASE_PROD_GOOGLE_SERVICES_IOS (base64 encoded)

**Android**:
- ANDROID_KEYSTORE_DEV (base64 encoded)
- ANDROID_KEYSTORE_PROD (base64 encoded)
- ANDROID_KEY_ALIAS_DEV
- ANDROID_KEY_ALIAS_PROD
- ANDROID_KEYSTORE_PASSWORD_DEV
- ANDROID_KEY_PASSWORD_DEV
- ANDROID_KEYSTORE_PASSWORD_PROD
- ANDROID_KEY_PASSWORD_PROD
- PLAY_STORE_SERVICE_ACCOUNT_JSON (base64 encoded)

**iOS**:
- MATCH_PASSWORD
- MATCH_GIT_URL
- APP_STORE_CONNECT_API_KEY_ID
- APP_STORE_CONNECT_API_ISSUER_ID
- APP_STORE_CONNECT_API_KEY_CONTENT (base64 encoded)
- FASTLANE_APPLE_ID
- FASTLANE_APPLE_APP_SPECIFIC_PASSWORD
- CERTIFICATES_GIT_PRIVATE_KEY (if using Match with SSH)

**Notifications**:
- SLACK_WEBHOOK_URL_DEV
- SLACK_WEBHOOK_URL_PROD

**Environment Variables** (Non-sensitive, can be in repository variables):
- DEV_API_BASE_URL
- PROD_API_BASE_URL
- FIREBASE_DEV_PROJECT_ID
- FIREBASE_PROD_PROJECT_ID

### 5.5 Workflow Best Practices

**Caching**:
- Cache Flutter SDK
- Cache Gradle dependencies (.gradle, build cache)
- Cache Pods (iOS dependencies)
- Cache pub dependencies

**Concurrency**:
- Cancel in-progress runs on new push (for dev)
- Don't cancel for production builds
- Queue production deployments

**Artifacts**:
- Upload build artifacts (APK, AAB, IPA)
- Retention: 7 days for dev, 30 days for production
- Include version info and changelog

**Notifications**:
- Notify on build success/failure
- Include build number, version, and download link
- Different channels for dev vs production

**Security**:
- Never log secrets
- Use environment files for Fastlane
- Validate signatures before deployment
- Scan dependencies for vulnerabilities

### 5.6 Deployment Gates and Approvals

**Development**:
- Automatic deployment to Firebase App Distribution
- No manual approval required

**Production Internal**:
- Automatic after successful build and tests
- Internal testing track on Play Store

**Production Beta**:
- Manual approval required (GitHub Environments)
- Notify QA team
- Wait for approval before promoting

**Production Release**:
- Manual approval required (GitHub Environments)
- Multiple approvers if needed
- Staged rollout (e.g., 10% → 50% → 100%)
- Ability to halt and rollback

### 5.7 Rollback Strategy

**Process**:
1. Detect issue via Crashlytics/monitoring
2. Halt staged rollout in store console
3. Trigger rollback workflow (deploys previous version)
4. Automated notification
5. Incident post-mortem

**Rollback Workflow**:
- Accepts version number to rollback to
- Retrieves artifacts from previous successful build
- Deploys to store
- Creates incident ticket automatically

---

## 6. Project Structure

### 6.1 Complete Directory Layout

```
project_root/
├── .github/
│   └── workflows/              # CI/CD workflows
│       ├── dev_android.yml
│       ├── dev_ios.yml
│       ├── prod_android.yml
│       ├── prod_ios.yml
│       ├── test.yml
│       └── release.yml
│
├── android/
│   ├── app/
│   │   ├── src/
│   │   │   ├── dev/           # Dev flavor specific files
│   │   │   │   ├── google-services.json
│   │   │   │   └── res/       # Dev icons, strings
│   │   │   ├── prod/          # Prod flavor specific files
│   │   │   │   ├── google-services.json
│   │   │   │   └── res/       # Prod icons, strings
│   │   │   └── main/          # Shared code
│   │   └── build.gradle       # Flavor configuration
│   └── fastlane/
│       ├── Fastfile
│       ├── Appfile
│       ├── .env.dev
│       ├── .env.prod
│       └── .env.secret        # Gitignored
│
├── ios/
│   ├── Runner/
│   │   ├── Firebase/
│   │   │   ├── Dev/
│   │   │   │   └── GoogleService-Info.plist
│   │   │   └── Prod/
│   │   │       └── GoogleService-Info.plist
│   │   └── Info.plist
│   ├── Runner.xcodeproj/      # Schemes: dev, prod
│   └── fastlane/
│       ├── Fastfile
│       ├── Appfile
│       ├── Matchfile
│       ├── .env.dev
│       ├── .env.prod
│       └── .env.secret        # Gitignored
│
├── lib/
│   ├── main_dev.dart          # Dev entry point
│   ├── main_prod.dart         # Prod entry point
│   ├── app.dart               # Main app widget
│   │
│   ├── config/
│   │   ├── environment.dart   # Environment enum
│   │   ├── app_config.dart    # Config model
│   │   └── env/
│   │       ├── dev_config.dart
│   │       └── prod_config.dart
│   │
│   ├── core/
│   │   ├── logging/
│   │   │   ├── logger.dart    # Main logger interface
│   │   │   ├── console_logger.dart
│   │   │   ├── file_logger.dart
│   │   │   ├── remote_logger.dart
│   │   │   ├── crashlytics_logger.dart
│   │   │   └── log_filters.dart
│   │   │
│   │   ├── error_handling/
│   │   │   ├── error_handler.dart
│   │   │   └── app_error.dart
│   │   │
│   │   └── network/
│   │       ├── api_client.dart
│   │       └── network_logger_interceptor.dart
│   │
│   ├── features/              # Feature modules
│   ├── shared/                # Shared widgets, utils
│   └── services/              # Business services
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── .gitignore                 # Excludes secrets
├── pubspec.yaml
└── README.md
```

### 6.2 .gitignore Configuration

**Critical Entries**:
```
# Environment secrets
**/.env.secret
**/google-services.json
**/GoogleService-Info.plist

# Android signing
*.jks
*.keystore
key.properties

# iOS signing
*.p12
*.mobileprovision
*.certSigningRequest

# Fastlane
**/fastlane/report.xml
**/fastlane/Preview.html
**/fastlane/screenshots
**/fastlane/test_output

# CI/CD
.env.local
secrets/
```

---

## 7. Secrets Management

### 7.1 Secret Storage Strategy

**Local Development**:
- `.env.secret` files (gitignored)
- Developers receive encrypted copy via secure channel
- Instructions document for decryption

**CI/CD**:
- GitHub Secrets for all sensitive values
- Base64 encode files before storing
- Environment-specific secret prefixes

**Runtime**:
- Flutter Secure Storage for user tokens
- Environment variables for app configuration
- Never hardcode secrets

### 7.2 Secret Rotation Process

**Regular Rotation** (Quarterly):
1. Generate new credentials
2. Update GitHub Secrets
3. Update local developer environments
4. Test in dev environment
5. Deploy to production
6. Revoke old credentials after validation

**Emergency Rotation** (Security Breach):
1. Immediately revoke compromised secrets
2. Generate new credentials
3. Emergency update to GitHub Secrets
4. Expedited deployment
5. Incident report

### 7.3 Access Control

**Principle of Least Privilege**:
- Separate dev and prod secrets
- Different Firebase projects with limited permissions
- API keys with scope restrictions
- Service accounts with minimal permissions
- Regular access audits

**Team Access**:
- Only lead developers have GitHub Secrets access
- Production credentials on need-to-know basis
- Audit log monitoring
- Offboarding checklist includes secret rotation

---

## 8. Testing Strategy

### 8.1 Test Pyramid

**Unit Tests** (70%):
- Business logic
- Utilities
- Data models
- Service classes
- Logger functionality

**Widget Tests** (20%):
- UI components
- User interactions
- Widget behavior
- State management

**Integration Tests** (10%):
- End-to-end flows
- API integration
- Navigation flows
- Critical user journeys

### 8.2 Environment-Specific Testing

**Development**:
- Run all tests locally
- Mock external dependencies
- Test logger output
- Verify configuration loading

**CI/CD Pipeline**:
- Automated test execution
- Code coverage requirements (minimum 80%)
- Test reports and artifacts
- Fail builds on test failures

**Pre-Production**:
- Integration tests against staging APIs
- Smoke tests on actual devices
- Performance testing
- Security scanning

### 8.3 Testing Checklist for Each Environment

**Before Dev Deployment**:
- [ ] Unit tests pass
- [ ] Widget tests pass
- [ ] Linting passes
- [ ] Dev configuration loads correctly
- [ ] Logger outputs to console

**Before Prod Deployment**:
- [ ] All tests pass (unit, widget, integration)
- [ ] Code coverage meets threshold
- [ ] No critical security vulnerabilities
- [ ] Production configuration validated
- [ ] Logger sends to remote services
- [ ] Crashlytics integration verified
- [ ] Performance benchmarks met
- [ ] Manual QA approval

---

## 9. Monitoring and Alerting

### 9.1 Metrics to Monitor

**Application Health**:
- Crash-free users percentage (target: >99%)
- App launch time (target: <3 seconds)
- Screen load times
- API response times
- Error rate per endpoint

**Business Metrics**:
- Daily active users
- Session duration
- Feature adoption rates
- Conversion funnels

**Infrastructure**:
- API availability
- CDN performance
- Third-party service status

### 9.2 Alert Configuration

**Critical Alerts** (Immediate Response):
- Crash rate spike (>1% in 1 hour)
- API complete failure
- Payment processing failure
- Security breach indicators

**Warning Alerts** (Review within 24h):
- Crash rate increase (>0.5%)
- Performance degradation (>20% slower)
- Error rate increase on specific endpoints
- High memory usage patterns

**Info Alerts** (Weekly Review):
- Deprecation warnings
- New error types
- Unusual usage patterns

### 9.3 Alert Channels

**Slack/Discord Integration**:
- Separate channels for dev and prod
- Different alert severities
- Build status notifications
- Deployment confirmations

**Email**:
- Critical production issues
- Weekly summary reports
- Deployment confirmations

**PagerDuty** (Optional for 24/7 Support):
- Critical production incidents
- Escalation policies
- On-call rotations

---

## 10. Deployment Checklist

### 10.1 Pre-Deployment

**Code Quality**:
- [ ] All tests passing
- [ ] Code review approved
- [ ] No merge conflicts
- [ ] Changelog updated

**Configuration**:
- [ ] Environment variables verified
- [ ] Firebase configuration files updated
- [ ] Feature flags configured
- [ ] Version numbers bumped

**Security**:
- [ ] No secrets in code
- [ ] Dependencies scanned for vulnerabilities
- [ ] ProGuard/R8 rules tested (Android)
- [ ] Code obfuscation verified

### 10.2 Deployment Process

**Development**:
1. Merge to develop branch
2. Automated CI/CD triggers
3. Build and test
4. Deploy to Firebase App Distribution
5. Team notification

**Production**:
1. Create release branch from main
2. Final QA testing
3. Merge to main with version tag
4. Automated CI/CD triggers
5. Build and test
6. Deploy to internal track (auto)
7. Manual approval for beta
8. Deploy to beta (50% rollout)
9. Monitor for 24-48 hours
10. Manual approval for production
11. Deploy to production (10% → 25% → 50% → 100% rollout)
12. Monitor continuously

### 10.3 Post-Deployment

**Immediate** (0-2 hours):
- [ ] Monitor crash rate
- [ ] Check error logs
- [ ] Verify critical paths working
- [ ] Review user feedback

**Short-term** (2-24 hours):
- [ ] Monitor performance metrics
- [ ] Check analytics events
- [ ] Review Crashlytics dashboard
- [ ] Verify rollout percentage

**Long-term** (24-48 hours):
- [ ] Full rollout completion
- [ ] Compare metrics to baseline
- [ ] User feedback analysis
- [ ] Document any issues

---

## 11. Rollback Procedures

### 11.1 Rollback Triggers

**Automatic Rollback**:
- Crash rate exceeds threshold (>5% within 1 hour)
- Critical security vulnerability discovered
- Complete feature failure

**Manual Rollback**:
- Business decision
- Unexpected user behavior
- Performance issues
- Customer reports

### 11.2 Rollback Process

**Play Store (Android)**:
1. Halt staged rollout
2. Promote previous version to production
3. Update release notes with known issues
4. Notify users (if necessary)

**App Store (iOS)**:
1. Submit expedited review with previous version
2. Remove current version from sale (if critical)
3. Communicate timeline to users

**Firebase App Distribution**:
1. Upload previous version
2. Notify testers
3. Immediate availability

### 11.3 Post-Rollback

**Immediate Actions**:
1. Create incident ticket
2. Notify stakeholders
3. Begin root cause analysis
4. Update status page (if public-facing)

**Follow-up**:
1. Fix identified issues
2. Add regression tests
3. Enhanced monitoring for affected areas
4. Post-mortem documentation
5. Process improvements

---

## 12. Maintenance and Updates

### 12.1 Dependency Updates

**Regular Updates** (Monthly):
- Flutter SDK
- Dart packages
- Native dependencies (CocoaPods, Gradle)
- CI/CD actions versions

**Security Updates** (Immediate):
- Critical vulnerability patches
- Security advisories from pub.dev
- Platform security updates

### 12.2 Flutter Version Updates

**Process**:
1. Test in dev environment
2. Run full test suite
3. Check for deprecations
4. Update CI/CD configuration
5. Update team documentation
6. Deploy to dev
7. Thorough testing period
8. Deploy to production

### 12.3 Firebase SDK Updates

**Coordination**:
- Update both platforms simultaneously
- Test Crashlytics reporting
- Verify analytics events
- Check remote config
- Validate authentication flows

---

## 13. Best Practices Summary

### 13.1 Security

✅ **Do**:
- Use separate Firebase projects for dev and prod
- Rotate secrets regularly
- Encrypt sensitive data at rest
- Use HTTPS for all API calls
- Implement certificate pinning
- Enable ProGuard/R8 obfuscation
- Use biometric authentication where appropriate

❌ **Don't**:
- Commit secrets to Git
- Use production credentials in development
- Log sensitive user data
- Store API keys in client code
- Skip security testing
- Use debug mode in production builds

### 13.2 Logging

✅ **Do**:
- Log all errors with context
- Implement log level filtering
- Scrub PII before logging
- Use structured logging
- Rotate log files
- Monitor log volumes
- Set up alerts for error spikes

❌ **Don't**:
- Log passwords or tokens
- Log excessive debug info in production
- Ignore log file size limits
- Skip error context
- Log unhandled exceptions without reporting

### 13.3 CI/CD

✅ **Do**:
- Automate everything possible
- Use staged rollouts
- Implement manual approval gates for production
- Cache dependencies
- Run tests before deployment
- Version all releases
- Keep CI/CD configuration in code

❌ **Don't**:
- Deploy without testing
- Skip version tagging
- Use same pipeline for dev and prod without gates
- Ignore failed builds
- Deploy Friday afternoons (production)

### 13.4 Monitoring

✅ **Do**:
- Set up comprehensive dashboards
- Monitor crash rates continuously
- Track performance metrics
- Set meaningful alert thresholds
- Review analytics regularly
- Track deployment metrics

❌ **Don't**:
- Ignore warning signs
- Set alerts too aggressively (alert fatigue)
- Skip post-deployment monitoring
- Forget about user feedback

---

## 14. Team Workflow

### 14.1 Development Workflow

**Feature Development**:
1. Create feature branch from `develop`
2. Implement feature with tests
3. Test locally with dev environment
4. Create pull request
5. Code review
6. CI/CD runs tests automatically
7. Merge to `develop`
8. Automatic deployment to dev environment
9. QA testing

**Release Workflow**:
1. Create release branch from `develop`
2. Version bump
3. Final testing
4. Merge to `main`
5. Tag release
6. CI/CD builds production release
7. Internal testing
8. Beta release (with approval)
9. Production release (with approval)
10. Monitor deployment

### 14.2 Branching Strategy

**Branch Types**:
- `main`: Production-ready code
- `develop`: Development integration branch
- `feature/*`: Feature branches
- `bugfix/*`: Bug fix branches
- `hotfix/*`: Emergency production fixes
- `release/*`: Release preparation branches

**Branch Protection**:
- Require PR reviews
- Require status checks to pass
- Require branches to be up to date
- Restrict direct pushes to main/develop

---

## 15. Documentation Requirements

### 15.1 Required Documentation

**Technical Documentation**:
- Architecture overview
- API integration guide
- Environment setup instructions
- Build and deployment guide
- Troubleshooting guide

**Process Documentation**:
- Development workflow
- Code review guidelines
- Testing strategy
- Deployment procedures
- Incident response playbook

**Runbooks**:
- How to deploy to each environment
- How to roll back a release
- How to rotate secrets
- How to debug common issues
- How to add new team members

### 15.2 Documentation Maintenance

**Regular Updates** (Quarterly):
- Review and update all documentation
- Remove outdated information
- Add new procedures
- Update screenshots and examples
- Verify all links work

---

## 16. Cost Optimization

### 16.1 Firebase Costs

**Monitoring**:
- Track Firebase usage regularly
- Set up billing alerts
- Review Crashlytics quota usage
- Optimize analytics event volume

**Optimization**:
- Limit Crashlytics custom keys
- Reduce log verbosity in production
- Batch analytics events
- Use appropriate Firebase plans

### 16.2 CI/CD Costs

**GitHub Actions**:
- Use caching effectively
- Cancel redundant builds
- Optimize workflow concurrency
- Schedule heavy jobs during off-peak hours

**Third-party Services**:
- Review Firebase App Distribution usage
- Monitor storage costs for artifacts
- Optimize build times
- Use free tiers where possible

---

## 17. Compliance and Privacy

### 17.1 Data Privacy

**User Data Handling**:
- GDPR compliance (if EU users)
- CCPA compliance (if California users)
- Clear privacy policy
- User consent for tracking
- Data retention policies
- Right to deletion implementation

**Logging Compliance**:
- No PII in logs
- Anonymize user identifiers
- Secure log storage
- Limited log retention
- Audit log access

### 17.2 Store Compliance

**Google Play Store**:
- Data safety form completion
- Privacy policy URL
- Permissions justification
- Target API level requirements

**Apple App Store**:
- Privacy nutrition labels
- App privacy details
- Data collection disclosure
- Third-party SDK disclosures

---

## 18. Success Metrics

### 18.1 Development Metrics

**Code Quality**:
- Test coverage >80%
- Zero critical security vulnerabilities
- <10 linting warnings
- Code review turnaround <24 hours

**Deployment Metrics**:
- Build success rate >95%
- Deployment frequency: Daily (dev), Weekly (prod)
- Lead time: <4 hours (dev), <1 day (prod)
- Rollback rate <5%

### 18.2 Application Metrics

**Stability**:
- Crash-free users >99.5%
- ANR rate <0.5%
- App launch time <3 seconds
- API success rate >99%

**Performance**:
- Screen load time <1 second
- Memory usage <200MB
- Battery usage <5% per hour active use
- APK/IPA size <50MB

---

## Conclusion

This comprehensive setup provides a production-grade foundation for Flutter applications with:

✅ **Secure Environment Management**: Separate dev and production configurations with proper secrets handling

✅ **Industry-Standard Logging**: Multi-layered logging system with PII protection and environment-aware filtering

✅ **Robust Error Tracking**: Firebase Crashlytics integration with custom keys and breadcrumbs

✅ **Automated CI/CD**: Complete Fastlane and GitHub Actions pipelines for both platforms

✅ **Staged Deployments**: Controlled rollout with manual approval gates

✅ **Comprehensive Monitoring**: Real-time alerting and metrics tracking

✅ **Rollback Capabilities**: Quick rollback procedures for emergency situations

✅ **Team Collaboration**: Clear workflows and documentation for team efficiency

The implementation of this setup will result in a reliable, maintainable, and scalable Flutter application with professional-grade deployment and monitoring capabilities.