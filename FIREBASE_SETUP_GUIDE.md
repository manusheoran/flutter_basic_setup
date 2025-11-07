# 🔥 Firebase Setup Guide

## ✅ Current Status

Your app is **successfully running** in **Preview Mode**! You can see and interact with the UI, but authentication won't work until Firebase is configured.

---

## 📱 What's Working Now

✅ **App launches successfully**  
✅ **Login page UI is displayed**  
✅ **All navigation routes configured**  
✅ **Theme system working (Light/Dark modes)**  
✅ **No crashes or compilation errors**  

🟡 **Preview Mode**: Click "Log In" or "Sign Up" and you'll see:
> "Preview Mode: Firebase is not configured. Please run: flutterfire configure"

---

## 🔥 To Enable Full Firebase Functionality

### **Option 1: Using FlutterFire CLI (Recommended)**

#### Step 1: Add Dart to PATH
```bash
# Add to your ~/.zshrc or ~/.bashrc
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Reload shell
source ~/.zshrc
```

#### Step 2: Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

#### Step 3: Login to Firebase
```bash
firebase login
# Or if you don't have Firebase CLI:
npm install -g firebase-tools
firebase login
```

#### Step 4: Configure Your Project
```bash
cd /Users/enrich/CascadeProjects/windsurf-project/sadhana_app
flutterfire configure
```

**Follow the prompts:**
1. Select or create a Firebase project
2. Choose platforms (Android, iOS, Web)
3. This will generate `lib/firebase_options.dart`

#### Step 5: Enable Services in Firebase Console

Go to https://console.firebase.google.com

**Enable Authentication:**
1. Select your project
2. Click **Authentication** → **Get Started**
3. Click **Sign-in method** tab
4. Enable **Email/Password**
5. Click **Save**

**Create Firestore Database:**
1. Click **Firestore Database** → **Create database**
2. Choose **Test mode** (for development) or **Production mode**
3. Select your region (closest to you)
4. Click **Enable**

**Add Security Rules (Production Mode):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId || 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Activities collection
    match /activities/{activityId} {
      allow read: if request.auth != null &&
        (resource.data.userId == request.auth.uid ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.disciples.hasAny([resource.data.userId]) ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }
  }
}
```

#### Step 6: Run Your App
```bash
flutter run
```

🎉 **Firebase is now fully configured!**

---

### **Option 2: Manual Configuration (If CLI Doesn't Work)**

#### For Android:

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project or select existing
3. Click **Add app** → **Android**
4. Package name: `com.example.sadhana_app`
5. Download `google-services.json`
6. Place it in: `/Users/enrich/CascadeProjects/windsurf-project/sadhana_app/android/app/`

#### For iOS:

1. In same project, click **Add app** → **iOS**
2. Bundle ID: `com.example.sadhanaApp`
3. Download `GoogleService-Info.plist`
4. Place it in: `/Users/enrich/CascadeProjects/windsurf-project/sadhana_app/ios/Runner/`

#### Create firebase_options.dart manually:

Create `lib/firebase_options.dart` with your Firebase config:

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.sadhanaApp',
  );
}
```

Then update `lib/main.dart` to use it:

```dart
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // ... rest of initialization
  } catch (e) {
    // ... error handling
  }
  
  runApp(const MyApp());
}
```

---

## 🧪 Testing Firebase Setup

### 1. Check the App Logs

After running `flutter run`, you should see:
```
✅ Firebase initialized successfully
```

Instead of:
```
⚠️ Firebase initialization failed
📱 Running app without Firebase (UI preview mode)
```

### 2. Test Sign Up

1. Open the app
2. Click "Sign Up"
3. Enter:
   - Name: Test User
   - Email: test@example.com
   - Password: password123
4. Click "Sign Up"
5. Should navigate to Home page!

### 3. Verify in Firebase Console

1. Go to **Authentication** → **Users**
2. You should see your new user listed!

3. Go to **Firestore Database**
4. Check the `users` collection
5. You should see a document with your user data!

---

## 🐛 Troubleshooting

### Issue: "command not found: flutterfire"
**Solution**: Add Dart pub cache to PATH:
```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
source ~/.zshrc
```

### Issue: "Failed to load FirebaseOptions"
**Solution**: The `firebase_options.dart` file wasn't generated. Run:
```bash
flutterfire configure
```

### Issue: "Permission denied" errors
**Solution**: Check Firebase security rules in Firestore Console

### Issue: App crashes on login
**Solution**: 
1. Check Firebase Authentication is enabled
2. Check internet connection
3. Check console logs for specific errors

---

## 📚 Next Steps After Firebase Setup

Once Firebase is configured and working:

1. **Build Home Page UI** - Implement daily activity tracker
2. **Add Dashboard Charts** - Use FL Chart for analytics
3. **Create Settings Page** - Theme toggle, language selector
4. **Build Admin Portal** - User management features

---

## 📋 Quick Reference

### Important Files:
- `lib/main.dart` - App entry point
- `lib/firebase_options.dart` - Firebase config (generated)
- `android/app/google-services.json` - Android Firebase config
- `ios/Runner/GoogleService-Info.plist` - iOS Firebase config

### Firebase Collections:
- `users` - User profiles and settings
- `activities` - Daily activity tracking data

### Commands:
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure

# Run app
flutter run

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

---

## 🎯 Current App Features

### ✅ Fully Implemented:
- Login/Sign up UI
- Theme system (light/dark)
- Navigation routing
- Data models (User, Activity)
- Services (Auth, Firestore, Scoring)
- 175-point scoring logic

### 🟡 UI Stubs (Need Implementation):
- Home page (daily tracker)
- Dashboard (charts)
- Settings page
- Admin portal

---

## 💡 Pro Tips

1. **Start with Test Mode** in Firestore for easier development
2. **Switch to Production Mode** with security rules before deploying
3. **Test on real device** for better Firebase performance
4. **Monitor Firebase Console** for user activity and errors
5. **Use Firebase Analytics** to track app usage (optional)

---

**Need help? Check the console logs - they provide clear error messages!**

Good luck! 🚀
