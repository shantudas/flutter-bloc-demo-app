# Firebase Configuration Files

Place your Firebase configuration files here:

## Development
Place your development Firebase project's `GoogleService-Info.plist` in:
- `dev/GoogleService-Info.plist`

## Production
Place your production Firebase project's `GoogleService-Info.plist` in:
- `prod/GoogleService-Info.plist`

## How to Get These Files

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project (dev or prod)
3. Go to Project Settings
4. Under "Your apps", select your iOS app
5. Download the `GoogleService-Info.plist` file
6. Place it in the appropriate directory above

## Note
The build script will automatically copy the correct file to `ios/Runner/GoogleService-Info.plist` based on the build configuration.

