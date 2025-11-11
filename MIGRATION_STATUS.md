# Schema Migration Status

## ✅ Completed (100%)

### Models
All new models have been created in `/lib/data/models/`:
- ✅ `user_model.dart` - Updated with new comprehensive schema
- ✅ `activity_model.dart` - New `DailyActivity` model with flexible structure
- ✅ `disciple_model.dart` - For disciples subcollection
- ✅ `disciple_request_model.dart` - For disciple requests
- ✅ `parameter_model.dart` - For dynamic scoring parameters
- ✅ `export_job_model.dart` - For future export jobs

### Services  
- ✅ `firestore_service.dart` - Updated to use new collections and models
  - Collection: `daily_activities` (was `activities`)
  - Methods updated to use `DailyActivity` instead of `ActivityModel`
  - Added disciples and request management methods
  
- ✅ `parameter_service.dart` - New service for dynamic scoring
  - Loads parameters from Firestore
  - Caches for performance
  - Calculates scores dynamically
  
- ✅ `auth_service.dart` - Updated to use new UserModel fields
  - Uses `trackingActivities` instead of `displayParameters`
  - Removed `disciples` field (now subcollection)

### App Initialization
- ✅ `main.dart` - ParameterService initialized and parameters loaded

### UI Files (Partial)
- ✅ `profile_edit_dialog.dart` - Fixed to use `phoneNumber` instead of `phone`
- ✅ `settings_page.dart` - Fixed to use `phoneNumber` instead of `phone`

## ⚠️ Remaining Work

### High Priority - Compilation Errors

#### 1. admin_controller.dart
**Lines 92-94** - Update user copyWith:
```dart
// Current (BROKEN):
mentorId: user.mentorId,
disciples: user.disciples,  
displayParameters: user.displayParameters,

// Fix to:
// Remove these lines OR update to:
// master: user.master, 
// trackingActivities: user.trackingActivities,
// (disciples is now fetched from subcollection, not stored in user doc)
```

#### 2. settings_controller.dart  
**Line 77** - Update requestMentor call:
```dart
// Current (BROKEN):
firestoreService.requestMentor(userId, mentorId, mentorName)

// Fix to (6 parameters now):
firestoreService.requestMentor(
  discipleUid,
  discipleName,
  discipleEmail,
  masterUid,
  masterName,
  masterEmail,
)
```

#### 3. home_controller.dart
Multiple changes needed:
- Replace `ActivityModel` with `DailyActivity`
- Update activity field access from hardcoded fields to dynamic map
- Change `saveActivity()` to `saveDailyActivity()`

**Example transformation:**
```dart
// OLD:
activity.nindra.score
activity.japa.rounds

// NEW:
activity.getActivity('nindra')?.analytics?.pointsAchieved ?? 0
activity.getActivity('japa')?.extras['rounds'] ?? 0
```

#### 4. dashboard_controller.dart
- Replace `ActivityModel` with `DailyActivity`
- Update activity access patterns
- Fix `.date` access (use `.dateString` instead)

#### 5. report_service.dart
- Replace `ActivityModel` with `DailyActivity`
- Update all activity field accessors
- Fix scoring calculations

#### 6. report_page.dart
- Replace `ActivityModel` with `DailyActivity`
- Update activity display logic

### Medium Priority - Refactoring

#### 7. scoring_service.dart
Can be simplified or removed since scoring is now handled by:
- `ParameterService` for score calculations
- Cloud Functions for analytics computation

### Low Priority - Enhancements

#### 8. Create admin UI for parameter management
- Allow admins to edit scoring rules
- Add/remove/enable/disable parameters

#### 9. Add disciple request management UI
- Show pending requests for masters
- Approve/reject UI

## 📝 Quick Fix Guide

### For each controller/UI file with errors:

1. **Replace old imports:**
```dart
import '../../data/models/activity_model.dart';
// TO:
import '../../data/models/activity_model.dart'; // Still valid, contains DailyActivity
```

2. **Replace ActivityModel with DailyActivity:**
```dart
List<ActivityModel> activities = ...
// TO:
List<DailyActivity> activities = ...
```

3. **Update activity data access:**
```dart
// OLD hardcoded fields:
activity.nindra, activity.japa, etc.

// NEW dynamic access:
activity.getActivity('nindra')
activity.getActivity('japa')
activity.activities['nindra']
```

4. **Update score access:**
```dart
// OLD:
activity.totalScore
activity.percentage

// NEW:
activity.totalPoints
activity.percentage
// OR:
activity.analytics?.totalPointsAchieved ?? 0
activity.analytics?.percentage ?? 0
```

5. **Update save methods:**
```dart
firestoreService.saveActivity(activity)
// TO:
firestoreService.saveDailyActivity(activity)
```

## 🎯 Next Steps

1. Fix `admin_controller.dart` - Remove invalid copyWith parameters
2. Fix `settings_controller.dart` - Update requestMentor call
3. Fix `home_controller.dart` - Complete ActivityModel → DailyActivity migration
4. Fix `dashboard_controller.dart` - Update activity accessors
5. Fix `report_service.dart` - Update all activity handling
6. Run `flutter pub get` and test compilation
7. Test all user flows (signup, login, activity tracking, reports)

## 🔧 Testing Checklist

After fixes:
- [ ] App compiles without errors
- [ ] User can sign up and login
- [ ] User can track daily activities
- [ ] Activities save to Firestore correctly
- [ ] Reports display correctly
- [ ] Master-disciple requests work
- [ ] Admin functions work
- [ ] Parameter management works

## 📚 Reference

See `SCHEMA_MIGRATION_GUIDE.md` for detailed schema changes and migration patterns.
