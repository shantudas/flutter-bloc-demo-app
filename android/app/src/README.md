# Firebase Configuration Files

Place your Firebase configuration files here:

## Development
Place your development Firebase project's `google-services.json` in:
- `android/app/src/dev/google-services.json`

## Production
Place your production Firebase project's `google-services.json` in:
- `android/app/src/prod/google-services.json`

## How to Get These Files

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project (dev or prod)
3. Go to Project Settings
4. Under "Your apps", select your Android app
5. Download the `google-services.json` file
6. Place it in the appropriate directory above

## Current Status
- Dev: The current dev configuration is already in place
- Prod: You need to add your production `google-services.json` file

## Note
The Android build system automatically uses the correct file based on the flavor (dev/prod).

