# Schema Migration Guide

## ✅ Completed Changes

### 1. New Models Created
- ✅ **UserModel** - Updated with new fields:
  - `phoneNumber` (was `phone`)
  - `master` object (was `mentorId` string)
  - `parent` object  
  - `trackingActivities` array (was `displayParameters` map)
  - `displayName`, `sadhanaName`, `dateOfBirth`, `initiatedName`, `address`, `status`
  
- ✅ **DailyActivity** - Replaces old ActivityModel:
  - Flexible activities structure (supports both map and array shapes)
  - Dynamic parameter tracking
  - Analytics computed by cloud functions
  
- ✅ **DiscipleModel** - For users/{uid}/disciples subcollection
- ✅ **DiscipleRequestModel** - For disciple_requests collection
- ✅ **ParameterModel** - For admin-defined scoring rules
- ✅ **ExportJobModel** - For future export jobs

### 2. Services Updated
- ✅ **FirestoreService**:
  - Collection names updated (`daily_activities` instead of `activities`)
  - `saveDailyActivity()` (was `saveActivity()`)
  - Methods updated to use `DailyActivity` instead of `ActivityModel`
  - New methods: `getDisciples()`, `getDiscipleUids()`, `getPendingRequests()`
  
- ✅ **ParameterService** - New service for dynamic scoring:
  - Loads parameters from Firestore
  - Caches for performance
  - Calculates scores dynamically
  
- ✅ **AuthService** - Updated to use new UserModel schema

### 3. Main App
- ✅ ParameterService initialized in `main.dart`

## 🔧 Field Name Mappings

### UserModel Changes
| Old Field | New Field | Type | Notes |
|-----------|-----------|------|-------|
| `phone` | `phoneNumber` | String? | Renamed for consistency |
| `mentorId` | `master` | MasterInfo? | Now an object with uid, name, email |
| `disciples` | (removed) | - | Now in subcollection users/{uid}/disciples |
| `displayParameters` | `trackingActivities` | List<String> | Changed from map to array of parameter keys |

### ActivityModel → DailyActivity Changes
| Old Field | New Field | Notes |
|-----------|-----------|-------|
| `id` | `docId` | Document identifier |
| `userId` | `uid` | User identifier |
| `nindra`, `wakeUp`, etc. | `activities` map | Now dynamic, keyed by parameter key |
| `totalScore` | `analytics.totalPointsAchieved` | Nested in analytics object |
| `percentage` | Computed from analytics | |

## ⚠️ Files That Need Manual Updates

### Controllers
1. **admin_controller.dart** - Replace:
   - `user.mentorId` → `user.master?.uid`
   - `user.disciples` → Call `FirestoreService.getDisciples(uid)`
   - `user.displayParameters` → `user.trackingActivities`

2. **home_controller.dart** - Replace:
   - `ActivityModel` → `DailyActivity`
   - `activity.nindra.score` → `activity.getActivity('nindra')?.analytics?.pointsAchieved`
   - `firestoreService.saveActivity()` → `firestoreService.saveDailyActivity()`

3. **dashboard_controller.dart** - Replace:
   - `ActivityModel` → `DailyActivity`
   - Access activities via `activity.activities` map

4. **settings_controller.dart** - Replace:
   - `user.phone` → `user.phoneNumber`
   - Update requestMentor() parameters

### UI Files
1. **settings_page.dart** - Replace:
   - `user.phone` → `user.phoneNumber`

2. **profile_edit_dialog.dart** - Replace:
   - `user.phone` → `user.phoneNumber`
   - `phone:` parameter → `phoneNumber:`

3. **report_service.dart** - Update to use DailyActivity

## 📋 Migration Strategy

### For Activities
```dart
// OLD
final activity = ActivityModel(
  nindra: ActivityData(time: '22:00', score: 25),
  japa: ActivityData(rounds: 16, score: 25),
  // ...
);

// NEW
final activity = DailyActivity(
  docId: '',
  uid: userId,
  date: '2025-11-10',
  activities: {
    'nindra': ActivityItem(
      id: 'nindra',
      name: 'Night Sleep',
      type: 'time',
      extras: {'value': '22:00'},
      analytics: ActivityAnalytics(pointsAchieved: 25, maxAchievablePoints: 25),
    ),
    'japa': ActivityItem(
      id: 'japa',
      name: 'Japa',
      type: 'count',
      extras: {'rounds': 16},
      analytics: ActivityAnalytics(pointsAchieved: 25, maxAchievablePoints: 25),
    ),
  },
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

### For Scoring
```dart
// OLD - Hardcoded in ScoringService
final score = ScoringService.calculateJapaScore(rounds);

// NEW - Dynamic from ParameterService
final parameterService = Get.find<ParameterService>();
final score = parameterService.calculateScore('japa', rounds);
final maxPoints = parameterService.getMaxPoints('japa');
```

### For Disciples
```dart
// OLD
final discipleIds = user.disciples; // List<String>

// NEW
final firestoreService = Get.find<FirestoreService>();
final disciples = await firestoreService.getDisciples(masterUid); // List<DiscipleModel>
final discipleIds = disciples.map((d) => d.uid).toList();
```

## 🎯 Next Steps

1. Fix all controller files to use new models and field names
2. Update UI files to use new field names (phone → phoneNumber)
3. Update activity tracking UI to work with dynamic DailyActivity model
4. Test all user flows (signup, login, activity tracking, reports)
5. Deploy cloud functions to compute analytics

## 🔄 Backward Compatibility Notes

The new schema is designed to work alongside the old one:
- Cloud functions handle both map and array shapes for activities
- Old `displayParameters` will be migrated to `trackingActivities`
- Empty `trackingActivities` array means "track all parameters"
