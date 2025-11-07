#!/bin/bash

echo "🔍 Debugging Release APK..."
echo ""

# Build and install
echo "📦 Building release APK..."
flutter build apk --release

echo ""
echo "📱 Installing on device..."
flutter install

echo ""
echo "📋 Watching logs (press Ctrl+C to stop)..."
echo "Look for lines with 'flutter', 'Firebase', 'AuthService'..."
echo ""

adb logcat -s flutter:V FirebaseApp:V
