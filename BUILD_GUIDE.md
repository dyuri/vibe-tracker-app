# Build and Deployment Guide

## Prerequisites

1. **Flutter SDK** - Install Flutter from [flutter.dev](https://flutter.dev)
   - Minimum Flutter version: 3.0.0
   - Run `flutter doctor` to verify installation

2. **Android Studio** (for Android development)
   - Android SDK
   - Android SDK Platform-Tools
   - Android SDK Build-Tools

3. **Java Development Kit (JDK)**
   - JDK 11 or higher

## Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/dyuri/vibe-tracker-app.git
   cd vibe-tracker-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Verify setup**
   ```bash
   flutter doctor
   ```

## Building the App

### Debug Build (for testing)

```bash
flutter build apk --debug
```

The APK will be located at: `build/app/outputs/flutter-apk/app-debug.apk`

### Release Build

```bash
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

### App Bundle (for Google Play Store)

```bash
flutter build appbundle --release
```

The bundle will be located at: `build/app/outputs/bundle/release/app-release.aab`

## Running on Device

### Connected Device

1. Enable USB debugging on your Android device
2. Connect device via USB
3. Run:
   ```bash
   flutter devices  # List connected devices
   flutter run      # Run on connected device
   ```

### Emulator

1. Start an Android emulator from Android Studio
2. Run:
   ```bash
   flutter run
   ```

## Installation

### From APK

1. Transfer the APK to your Android device
2. Enable "Install from Unknown Sources" in device settings
3. Open the APK file and install

### From Command Line

```bash
flutter install
```

or

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Configuration

After installing the app:

1. **Open Settings** (gear icon in app)
2. **Configure the following:**
   - Server URL: Your Vibe Tracker server (e.g., `https://your-server.com`)
   - Access Token: Your API token from Vibe Tracker
   - Session Name: A name for your tracking session (e.g., "morning-run")
   - Tracking Interval: How often to send location (in seconds, minimum 10)

3. **Test Connection** - Click the WiFi icon to verify settings

4. **Grant Permissions**
   - Location permission (foreground and background)
   - The app will request these when you start tracking

## Usage

1. Configure settings (see above)
2. Click "Start Tracking" button
3. Grant location permissions if prompted
4. A persistent notification will appear showing tracking status
5. Location data will be sent to your Vibe Tracker server at the configured interval
6. Click "Stop Tracking" to stop

## Troubleshooting

### Location not updating

- Check that location services are enabled on device
- Verify background location permission is granted
- Ensure the app is not battery optimized (Settings > Apps > Vibe Tracker > Battery)

### Failed to send location

- Verify server URL is correct (including http:// or https://)
- Check access token is valid
- Test connection using the WiFi icon in settings
- Check server logs for errors

### Build errors

```bash
flutter clean
flutter pub get
flutter build apk
```

### Permission errors

- Grant all requested permissions in device settings
- For Android 10+, background location requires explicit permission

## Signing the App (for release)

For production releases, you should sign the app:

1. Create a keystore:
   ```bash
   keytool -genkey -v -keystore ~/vibe-tracker-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias vibe-tracker
   ```

2. Create `android/key.properties`:
   ```properties
   storePassword=<your-store-password>
   keyPassword=<your-key-password>
   keyAlias=vibe-tracker
   storeFile=/path/to/vibe-tracker-key.jks
   ```

3. Build signed APK:
   ```bash
   flutter build apk --release
   ```

## Battery Optimization

For reliable background tracking:

1. Go to device Settings > Apps > Vibe Tracker
2. Battery > "Don't optimize" or "Unrestricted"
3. This prevents Android from killing the background service

## Developer Notes

- The app uses a foreground service for persistent location tracking
- Location updates are sent as GeoJSON to `/api/track` endpoint
- Failed uploads are logged (retry logic can be added)
- Minimum Android SDK: 24 (Android 7.0)
- Target Android SDK: 34 (Android 14)
