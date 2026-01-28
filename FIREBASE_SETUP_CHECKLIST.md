# Firebase Setup Checklist

Use this checklist to complete the Firebase Crashlytics setup for your app.

---

## ✅ Prerequisites Completed

- [x] Firebase dependencies installed (`firebase_core`, `firebase_crashlytics`)
- [x] Firebase service implemented
- [x] Android build configuration updated
- [x] Product flavors configured (dev/prod)
- [x] Entry points updated with Firebase initialization
- [x] Logger integrated with Crashlytics
- [x] Helper utilities created
- [x] Test screen implemented
- [x] Documentation completed

---

## 📋 Setup Steps (To Do)

### Step 1: Create Firebase Projects

- [ ] Go to [Firebase Console](https://console.firebase.google.com/)
- [ ] Create **Development Project**:
  - [ ] Project name: `your-app-dev` (or your choice)
  - [ ] Project ID: Note this down
  - [ ] Enable Google Analytics (optional)
- [ ] Create **Production Project**:
  - [ ] Project name: `your-app-prod` (or your choice)
  - [ ] Project ID: Note this down
  - [ ] Enable Google Analytics (recommended)

### Step 2: Register Android Apps

**For Development Project:**
- [ ] Click "Add app" → Android
- [ ] Package name: `com.example.flutter_bloc.dev`
- [ ] App nickname: "Social App Dev" (optional)
- [ ] Download `google-services.json`
- [ ] Save to: `android/app/src/dev/google-services.json`
- [ ] ⚠️ Replace the placeholder file

**For Production Project:**
- [ ] Click "Add app" → Android
- [ ] Package name: `com.example.flutter_bloc`
- [ ] App nickname: "Social App" (optional)
- [ ] Download `google-services.json`
- [ ] Save to: `android/app/src/prod/google-services.json`
- [ ] ⚠️ Replace the placeholder file

### Step 3: Enable Crashlytics

**For Development Project:**
- [ ] In Firebase Console, go to **Crashlytics**
- [ ] Click "Get Started" or "Enable Crashlytics"
- [ ] Follow any additional setup steps

**For Production Project:**
- [ ] In Firebase Console, go to **Crashlytics**
- [ ] Click "Get Started" or "Enable Crashlytics"
- [ ] Follow any additional setup steps

### Step 4: Update App Configuration

- [ ] Open `lib/config/env/dev_config.dart`
- [ ] Update these values from your Dev Firebase project:
  ```dart
  firebaseApiKey: 'YOUR_DEV_API_KEY',
  firebaseAppId: 'YOUR_DEV_APP_ID',
  firebaseMessagingSenderId: 'YOUR_DEV_SENDER_ID',
  firebaseProjectId: 'your-app-dev',
  ```

- [ ] Open `lib/config/env/prod_config.dart`
- [ ] Update these values from your Prod Firebase project:
  ```dart
  firebaseApiKey: 'YOUR_PROD_API_KEY',
  firebaseAppId: 'YOUR_PROD_APP_ID',
  firebaseMessagingSenderId: 'YOUR_PROD_SENDER_ID',
  firebaseProjectId: 'your-app-prod',
  ```

**Where to find these values:**
1. Firebase Console → Project Settings (⚙️ icon)
2. Scroll to "Your apps" section
3. Click on your Android app
4. All values are displayed there

### Step 5: Build and Test

**Development Build:**
- [ ] Run: `flutter clean`
- [ ] Run: `flutter pub get`
- [ ] Run: `flutter run -t lib/main_dev.dart --flavor dev`
- [ ] Check console for "✅ Firebase initialized successfully"
- [ ] Check console for "✅ Crashlytics initialized successfully"

**Production Build:**
- [ ] Build: `flutter build apk -t lib/main_prod.dart --flavor prod --release`
- [ ] Install on device
- [ ] Run and check for initialization messages

### Step 6: Test Crashlytics

**Using Test Screen (Dev Only):**
- [ ] Navigate to Crashlytics Test Screen
- [ ] Click "Test Non-Fatal Exception"
- [ ] See success message
- [ ] Wait 1-2 minutes
- [ ] Check Dev Firebase Console → Crashlytics
- [ ] Verify exception appears

**Manual Testing:**
- [ ] Add this code temporarily in your app:
  ```dart
  import 'package:social_app/core/services/firebase_service.dart';
  
  // In a button press or similar
  await FirebaseService.instance.sendTestException();
  ```
- [ ] Run the app and trigger the test
- [ ] Wait 1-2 minutes
- [ ] Check Firebase Console → Crashlytics
- [ ] Remove test code

**Verify Symbolication:**
- [ ] Check that stack traces are readable (not obfuscated)
- [ ] Verify file names and line numbers are correct
- [ ] Check that custom keys are attached
- [ ] Verify breadcrumbs are present

### Step 7: Test Real Scenarios

- [ ] Trigger a real error in your app
- [ ] Check it appears in Crashlytics
- [ ] Verify user identifier is set (if logged in)
- [ ] Check custom keys are meaningful
- [ ] Verify breadcrumbs show user journey

### Step 8: Production Verification

- [ ] Deploy production build to testers
- [ ] Monitor Crashlytics dashboard
- [ ] Verify crashes are reported
- [ ] Check crash-free users metric
- [ ] Set up email alerts in Firebase Console

---

## 🔍 Verification Points

### Development Environment
- [ ] `google-services.json` in `android/app/src/dev/`
- [ ] Dev Firebase credentials in `dev_config.dart`
- [ ] Can build with: `flutter run -t lib/main_dev.dart --flavor dev`
- [ ] Test screen accessible
- [ ] Crashes appear in Dev Firebase Console
- [ ] App ID suffix: `.dev`
- [ ] App name: "Social App Dev"

### Production Environment
- [ ] `google-services.json` in `android/app/src/prod/`
- [ ] Prod Firebase credentials in `prod_config.dart`
- [ ] Can build with: `flutter build apk -t lib/main_prod.dart --flavor prod --release`
- [ ] Crashes appear in Prod Firebase Console
- [ ] App ID: No suffix
- [ ] App name: "Social App"

### Code Quality
- [ ] No compilation errors: `flutter analyze`
- [ ] All tests pass: `flutter test`
- [ ] No warnings in console output
- [ ] Logger shows appropriate messages
- [ ] Firebase initialization succeeds

---

## 🐛 Troubleshooting

### Crashes Not Appearing

**Issue:** Sent test exception but nothing in Firebase Console

**Solutions:**
- [ ] Wait 2-5 minutes (normal delay)
- [ ] Check internet connectivity
- [ ] Verify `enable_crashlytics` feature flag is `true`
- [ ] Ensure correct `google-services.json` file
- [ ] Check Firebase project matches your build
- [ ] Restart app and try again
- [ ] Check Firebase Console → Project Settings → Service Accounts

### Build Errors

**Issue:** Build fails with Firebase or Crashlytics errors

**Solutions:**
- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Delete `build` folder
- [ ] Sync Android project: `cd android && ./gradlew clean`
- [ ] Verify Firebase plugin versions in `android/build.gradle.kts`
- [ ] Check `google-services.json` is valid JSON
- [ ] Ensure package name matches in Firebase Console

### Wrong Firebase Project

**Issue:** Crashes appearing in wrong Firebase project

**Solutions:**
- [ ] Check which flavor you're building: `--flavor dev` or `--flavor prod`
- [ ] Verify `google-services.json` in correct directory
- [ ] Check package name in Firebase Console
- [ ] Rebuild with correct flavor

### Symbolication Not Working

**Issue:** Stack traces show obfuscated code

**Solutions:**
- [ ] Ensure Crashlytics Gradle plugin is applied
- [ ] Check `android/app/build.gradle.kts` has both plugins
- [ ] For release builds, verify mapping files uploaded
- [ ] Run clean build: `flutter clean && flutter build`
- [ ] Check ProGuard rules (if custom rules added)

---

## 📚 Reference Documents

- **Setup Guide:** `android/app/src/README.md`
- **Quick Reference:** `CRASHLYTICS_GUIDE.md`
- **Implementation Details:** `ENVIRONMENT_IMPLEMENTATION.md` (Section 3)
- **Architecture:** `ENVIRONMENT_SETUP.md` (Section 3)
- **Summary:** `CRASHLYTICS_IMPLEMENTATION_SUMMARY.md`

---

## 🎯 Success Criteria

You've successfully set up Firebase Crashlytics when:

- ✅ Both dev and prod Firebase projects created
- ✅ Android apps registered with correct package names
- ✅ `google-services.json` files in correct locations
- ✅ Configuration files updated with real credentials
- ✅ App builds successfully for both flavors
- ✅ Test exceptions appear in Firebase Console
- ✅ Stack traces are readable (symbolicated)
- ✅ Custom keys and breadcrumbs are attached
- ✅ No console errors related to Firebase
- ✅ Production build tested on real device

---

## 🚀 Next Steps After Setup

Once Firebase Crashlytics is working:

1. **Monitor Dashboard**
   - Check Crashlytics daily during development
   - Set up email alerts for new crashes
   - Review crash-free users percentage

2. **Integrate Throughout App**
   - Set user ID after login: `CrashlyticsHelper.setUser()`
   - Track screens: `CrashlyticsHelper.setCurrentScreen()`
   - Log important actions: `AppLogger.logUserAction()`
   - Handle exceptions: `CrashlyticsHelper.recordHandledException()`

3. **Production Best Practices**
   - Test thoroughly before release
   - Monitor for first 24 hours after release
   - Fix critical crashes immediately
   - Review weekly crash reports
   - Track crash-free users trend

4. **Advanced Features**
   - Add custom keys for important state
   - Track feature usage with breadcrumbs
   - Log business logic errors
   - Monitor network failures
   - Track session duration

---

**Last Updated:** January 29, 2026  
**Status:** Ready for Firebase setup  
**Estimated Time:** 30-45 minutes for complete setup

