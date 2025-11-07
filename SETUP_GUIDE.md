# Sadhana Tracker - Complete Setup & Implementation Guide

## ✅ What's Been Completed

### 1. **Project Infrastructure**
- ✅ Flutter project with GetX state management
- ✅ Firebase dependencies configured
- ✅ Material 3 theme system (Light/Dark modes)
- ✅ Color palette matching UI mockup
- ✅ Google Fonts integration (Inter font family)
- ✅ Complete navigation routing system

### 2. **Theme System**
- ✅ `app_colors.dart` - Complete color palette with score-based colors
- ✅ `app_text_styles.dart` - Typography with Google Fonts
- ✅ `app_theme.dart` - Light and dark themes
- ✅ `app_constants.dart` - App-wide constants

### 3. **Data Layer**
- ✅ **Models**:
  - `user_model.dart` - User with roles (user/mentor/admin)
  - `activity_model.dart` - Daily activity tracking
  
- ✅ **Services**:
  - `auth_service.dart` - Firebase Authentication with auto-routing
  - `firestore_service.dart` - Complete Firestore operations
  - `scoring_service.dart` - Points calculation logic (175 total points)

### 4. **Features Implemented**
- ✅ **Login Page** - Email/password auth with sign up

### 5. **Remaining Pages (Need Implementation)**
You'll need to create these files following the same pattern:

#### Home Page Files Needed:
```
lib/features/home/
  ├── home_page.dart
  └── home_controller.dart
```

#### Dashboard Page Files Needed:
```
lib/features/dashboard/
  ├── dashboard_page.dart
  └── dashboard_controller.dart
```

#### Settings Page Files Needed:
```
lib/features/settings/
  ├── settings_page.dart
  └── settings_controller.dart
```

#### Admin Page Files Needed:
```
lib/features/admin/
  ├── admin_page.dart
  └── admin_controller.dart
```

---

## 🔥 Firebase Setup Instructions

### Step 1: Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### Step 2: Configure Firebase
```bash
cd /Users/enrich/CascadeProjects/windsurf-project/sadhana_app
flutterfire configure
```

This will:
- Create a Firebase project or connect to existing one
- Generate `firebase_options.dart`
- Configure Android and iOS apps

### Step 3: Enable Firebase Authentication
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to **Authentication** → **Sign-in method**
4. Enable **Email/Password**

### Step 4: Create Firestore Database
1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Choose **Production mode**
4. Select your region
5. Add these security rules:

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

---

## 📊 Firebase Schema

### Users Collection (`users`)
```json
{
  "uid": "auto-generated",
  "email": "user@example.com",
  "name": "User Name",
  "role": "user" | "mentor" | "admin",
  "mentorId": "optional_mentor_uid",
  "disciples": ["uid1", "uid2"],
  "displayParameters": {
    "nindra": true,
    "wakeUp": true,
    "daySleep": true,
    "japa": true,
    "pathan": true,
    "sravan": true,
    "seva": true
  },
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Activities Collection (`activities`)
```json
{
  "id": "auto-generated",
  "userId": "user_uid",
  "date": "2024-01-15",
  "nindra": {"time": "22:00", "score": 25},
  "wakeUp": {"time": "04:30", "score": 20},
  "daySleep": {"minutes": 0, "score": 25},
  "japa": {"rounds": 16, "score": 25},
  "pathan": {"minutes": 60, "score": 25},
  "sravan": {"minutes": 45, "score": 20},
  "seva": {"hours": 4, "score": 25},
  "totalScore": 165,
  "percentage": 94.3,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

## 🎯 Scoring System (Total: 175 Points)

### Nindra (Sleep Time) - 25 pts max
| Time Range | Points |
|------------|--------|
| 21:45 - 22:00 | 25 |
| 22:01 - 22:30 | 20 |
| 22:31 - 23:00 | 15 |
| 23:01 - 23:30 | 10 |
| After 23:30 | 5 |

### Wake Up - 25 pts max
| Time Range | Points |
|------------|--------|
| Before 04:00 | 25 |
| 04:01 - 04:30 | 20 |
| 04:31 - 05:00 | 15 |
| 05:01 - 05:30 | 10 |
| After 05:30 | 5 |

### Day Sleep - 25 pts max
| Minutes | Points |
|---------|--------|
| 0 | 25 |
| 1-30 | 15 |
| 31-60 | 10 |
| 61-90 | 5 |
| 90+ | 0 |

### Japa (Chanting Rounds) - 25 pts max
| Rounds | Points |
|--------|--------|
| 16+ | 25 |
| 14-15 | 20 |
| 12-13 | 15 |
| 10-11 | 10 |
| <10 | 5 |

### Pathan (Reading Minutes) - 25 pts max
| Minutes | Points |
|---------|--------|
| 60+ | 25 |
| 45-59 | 20 |
| 30-44 | 15 |
| 15-29 | 10 |
| <15 | 5 |

### Sravan (Listening Minutes) - 25 pts max
| Minutes | Points |
|---------|--------|
| 60+ | 25 |
| 45-59 | 20 |
| 30-44 | 15 |
| 15-29 | 10 |
| <15 | 5 |

### Seva (Service Hours) - 25 pts max
| Hours | Points |
|-------|--------|
| 4+ | 25 |
| 3-4 | 20 |
| 2-3 | 15 |
| 1-2 | 10 |
| <1 | 5 |

---

## 🚀 Running the App

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run on Device/Simulator
```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Or just
flutter run
```

---

## 📱 Page Specifications

### Home Page (To Build)
**Purpose**: Daily activity tracking

**Features**:
- Date selector (today, yesterday, 2/3 days ago)
- Activity input cards with icons
- Live score calculation
- Save button at bottom
- Auto-calculation of points

### Dashboard Page (To Build)
**Purpose**: Analytics and progress tracking

**Features**:
- Two tabs: "My Dashboard" and "Mentor View"
- Charts showing 7/30/custom day trends
- Parameter breakdown
- Color-coded performance (Green >80%, Orange 60-80%, Yellow 40-60%, Maroon <40%)

### Settings Page (To Build)
**Purpose**: App configuration

**Features**:
- Toggle activity parameter visibility
- Theme switcher (Light/Dark)
- Language selector
- Mentor request system
- Logout button

### Admin Page (To Build)
**Purpose**: User management

**Features**:
- Search users
- View/Edit/Delete users
- View user activities
- Export to Excel

---

## 🎨 Design System

### Colors
- **Primary**: Orange `#FFA726`
- **Success** (>80%): Green `#4CAF50`
- **Warning** (60-80%): Orange `#FF9800`
- **Caution** (40-60%): Yellow `#FDD835`
- **Danger** (<40%): Maroon `#880E4F`

### Spacing
- XS: 4px
- S: 8px
- M: 16px
- L: 24px
- XL: 32px

### Border Radius
- S: 8px
- M: 12px
- L: 16px

---

## 🧪 Testing

### Create Test Users in Firebase Console
1. Go to **Authentication** → **Users**
2. Add users manually:
   ```
   user@test.com (role: user)
   mentor@test.com (role: mentor)
   admin@test.com (role: admin)
   ```
3. Add role field in **Firestore** → **users** collection

---

## 📚 Next Steps

1. ✅ Run `flutterfire configure`
2. ✅ Enable Firebase Authentication
3. ✅ Create Firestore database with security rules
4. 📝 Build Home Page for activity tracking
5. 📝 Build Dashboard Page with charts (use FL Chart)
6. 📝 Build Settings Page
7. 📝 Build Admin Page
8. 🧪 Test all features
9. 🚀 Deploy to App Store / Play Store

---

## 💡 Code Examples for Remaining Pages

### Home Controller Pattern
```dart
class HomeController extends GetxController {
  final FirestoreService _firestoreService = Get.find();
  final AuthService _authService = Get.find();
  
  Rx<ActivityModel?> todayActivity = Rx<ActivityModel?>(null);
  Rx<DateTime> selectedDate = DateTime.now().obs;
  
  @override
  void onInit() {
    super.onInit();
    loadActivityForDate(selectedDate.value);
  }
  
  Future<void> loadActivityForDate(DateTime date) async {
    // Load activity from Firestore
  }
  
  Future<void> saveActivity() async {
    // Calculate scores and save to Firestore
  }
}
```

---

## 🐛 Troubleshooting

### Issue: Firebase not initialized
**Solution**: Make sure you ran `flutterfire configure`

### Issue: Build errors
**Solution**: Run `flutter clean` then `flutter pub get`

### Issue: Can't login
**Solution**: Check Firebase Authentication is enabled

---

## 📞 Support
For implementation questions, check:
- GetX Documentation: https://pub.dev/packages/get
- Firebase Documentation: https://firebase.google.com/docs/flutter
- FL Chart Examples: https://pub.dev/packages/fl_chart

---

**Happy Coding! 🎉**
