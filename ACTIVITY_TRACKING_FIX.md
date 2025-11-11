# Activity Tracking Fixes - Total Score & Display Logic

## Overview
Fixed two critical issues with activity tracking:
1. Total score not updating when activities are removed
2. Home page display logic for tracked activities

---

## Issue 1: ✅ Total Score Not Updating When Activity Removed

### Problem
When user turned off activity tracking in settings:
- Activity was removed from `daily_activities/{date}/activities` map ✅
- But `analytics.totalPointsAchieved`, `totalMaxAchievablePoints`, and `percentage` were NOT recalculated ❌
- This showed wrong total score on home page and dashboard

### Solution
**File**: `lib/data/services/firestore_service.dart` → `updateDailyActivitiesForTracking()`

Added score recalculation after modifying activities:

```dart
// Recalculate total points and percentage
double totalPointsAchieved = 0;
double totalMaxPoints = 0;

activities.forEach((key, value) {
  final analytics = value['analytics'] as Map<String, dynamic>?;
  if (analytics != null) {
    totalPointsAchieved += (analytics['pointsAchieved'] as num?)?.toDouble() ?? 0;
    totalMaxPoints += (analytics['maxPoints'] as num?)?.toDouble() ?? 0;
  }
});

final percentage = totalMaxPoints > 0 ? (totalPointsAchieved / totalMaxPoints) * 100 : 0;

// Update document with recalculated analytics
await _dailyActivities.doc(docId).update({
  'activities': activities,
  'analytics': {
    'totalPointsAchieved': totalPointsAchieved,
    'totalMaxAchievablePoints': totalMaxPoints,
    'percentage': percentage,
  },
  'updatedAt': Timestamp.now(),
});
```

### How It Works Now

**Before:**
```
User disables "Japa" (25 points achieved out of 25)
→ Japa removed from activities map
→ Total: Still shows 150/230 (wrong!)
```

**After:**
```
User disables "Japa" (25 points achieved out of 25)
→ Japa removed from activities map
→ Total recalculated: 125/205 (correct!)
→ Percentage updated: 60.97%
```

### Console Output
```
➖ Removed japa from activities
✅ Updated daily_activities for 2024-11-11
   Total Points: 125.0 / 205.0 (60.97%)
```

---

## Issue 2: ✅ Home Page Activity Display Logic

### Problem
User wanted to know which activities are being tracked:
- If activity tracking is OFF for an activity, it shouldn't show on home page
- But if no document exists yet, all activities should show (so user can create data)

### Solution

#### A. Added Logic to Controller
**File**: `lib/features/home/home_controller.dart`

```dart
// Check if activity should be shown in UI
// Logic: If no document exists -> show all activities
//        If document exists -> show only activities in the activities map
bool shouldShowActivity(String key) {
  if (currentActivity.value == null) {
    // No document - show all activities so user can fill them
    return true;
  } else {
    // Document exists - show only activities that are being tracked
    // (present in the activities map)
    return currentActivity.value!.activities.containsKey(key);
  }
}
```

#### B. Updated Home Page UI
**File**: `lib/features/home/home_page.dart`

Wrapped each activity card with conditional check:

```dart
Widget _buildActivityCards(HomeController controller, BuildContext context) {
  return Obx(() => Column(
    children: [
      // Only show if shouldShowActivity returns true
      if (controller.shouldShowActivity('nindra')) ...[
        _buildActivityWithScore(/* ... */),
        const SizedBox(height: AppConstants.kSpacingM),
      ],
      
      if (controller.shouldShowActivity('wake_up')) ...[
        _buildActivityWithScore(/* ... */),
        const SizedBox(height: AppConstants.kSpacingM),
      ],
      
      // ... other activities with same pattern
    ],
  ));
}
```

### How It Works Now

#### Scenario 1: No Document Exists (New Day or First Time)
```
currentActivity = null
→ shouldShowActivity('nindra') = true
→ shouldShowActivity('japa') = true
→ shouldShowActivity('seva') = true
→ ALL 7 activities shown
→ User can fill in data for any activity
```

#### Scenario 2: Document Exists with All Activities
```
currentActivity.activities = {
  'nindra': {...},
  'wake_up': {...},
  'day_sleep': {...},
  'japa': {...},
  'pathan': {...},
  'sravan': {...},
  'seva': {...}
}
→ ALL 7 activities shown
→ All are being tracked
```

#### Scenario 3: Document Exists, Some Activities Disabled
```
User disabled "japa" and "sravan" in settings

currentActivity.activities = {
  'nindra': {...},
  'wake_up': {...},
  'day_sleep': {...},
  // 'japa' missing (disabled)
  'pathan': {...},
  // 'sravan' missing (disabled)
  'seva': {...}
}
→ shouldShowActivity('japa') = false (not in map)
→ shouldShowActivity('sravan') = false (not in map)
→ ONLY 5 activities shown
→ User KNOWS japa and sravan tracking is OFF (they're not visible)
```

### Benefits

1. **Clear Visual Feedback**
   - Missing activity = tracking is disabled
   - Present activity = tracking is enabled

2. **Prevents Confusion**
   - User won't wonder "where did japa go?"
   - They'll know it's disabled in settings

3. **Smart Default**
   - New day without document = show all (let user create)
   - Existing document = show only tracked (respect settings)

4. **Real-Time Updates**
   - Since we're using streams, when settings change:
   - Activities appear/disappear immediately
   - No page refresh needed

---

## Complete Flow: Disabling Activity Tracking

### Step-by-Step Example: User Disables "Japa"

**1. Initial State**
```
Settings: All activities enabled
Home Page: All 7 activities visible
Daily Activity Document: Has all 7 activities
Total Score: 150/230 (65.2%)
```

**2. User Goes to Settings → Parameter Tracking**
```
Opens parameter tracking page
Sees all 7 activities with toggles ON
```

**3. User Toggles "Japa" OFF and Clicks Save**
```
ParameterTrackingController.saveConfiguration() called
  ↓
Updates users/{uid}:
  - activityTracking: {"japa": false, ...}
  - trackingActivities: ["nindra", "wake_up", ...] (no japa)
  ↓
Updates daily_activities/{uid_2024-11-11}:
  - Removes "japa" from activities map
  - Recalculates totalPointsAchieved: 125 (was 150)
  - Recalculates totalMaxAchievablePoints: 205 (was 230)
  - Recalculates percentage: 60.97% (was 65.2%)
```

**4. User Sees Changes Immediately**
```
Home Page (via stream):
  - Japa input field disappears
  - Score card updates: 125/205 (60.97%)
  
Dashboard (via stream if open):
  - Total score updates: 125/205
  - Percentage updates: 60.97%
  - Charts recalculate without japa data
```

**5. Next Day (New Document)**
```
User opens home page for tomorrow
currentActivity = null (no document yet)
→ shouldShowActivity('japa') = true (show all for new day)
→ User can still see japa field
→ But when they try to save, japa won't be included (disabled in tracking)
```

---

## Database State After Changes

### Before Disabling "Japa"
```javascript
// Users collection
users/{uid} = {
  activityTracking: {
    "japa": true,  // <-- enabled
    // ... other activities
  },
  trackingActivities: ["nindra", "wake_up", "japa", "pathan", ...]
}

// Daily activities collection
daily_activities/{uid_2024-11-11} = {
  activities: {
    "japa": {  // <-- present
      extras: { rounds: 16, time: "06:00" },
      analytics: { pointsAchieved: 25, maxPoints: 25 }
    },
    // ... other activities
  },
  analytics: {
    totalPointsAchieved: 150,
    totalMaxAchievablePoints: 230,
    percentage: 65.2
  }
}
```

### After Disabling "Japa"
```javascript
// Users collection
users/{uid} = {
  activityTracking: {
    "japa": false,  // <-- disabled
    // ... other activities
  },
  trackingActivities: ["nindra", "wake_up", "pathan", ...]  // no japa
}

// Daily activities collection
daily_activities/{uid_2024-11-11} = {
  activities: {
    // "japa" removed completely
    "nindra": {...},
    "wake_up": {...},
    // ... other activities
  },
  analytics: {
    totalPointsAchieved: 125,  // recalculated!
    totalMaxAchievablePoints: 205,  // recalculated!
    percentage: 60.97  // recalculated!
  }
}
```

---

## Edge Cases Handled

### 1. Activity With 0 Points
```
User has japa with 0 points achieved
Disables japa
→ Total: 100/230 → 100/205
→ Percentage: 43.48% → 48.78% (improved!)
```

### 2. Re-enabling Activity
```
User re-enables japa
→ Japa added back with default values (0 points)
→ Total: 125/205 → 125/230
→ Percentage: 60.97% → 54.35%
→ Home page shows japa field again
```

### 3. Multiple Activities
```
Disable 3 activities at once
→ All 3 removed from map
→ Single recalculation for all changes
→ Efficient batch update
```

### 4. All Activities Disabled (Edge Case)
```
User disables all 7 activities (unlikely but possible)
→ activities map = {} (empty)
→ Total: 0/0
→ Percentage: 0%
→ Home page shows no activities
```

---

## Files Modified

1. ✅ `lib/data/services/firestore_service.dart`
   - Updated `updateDailyActivitiesForTracking()` to recalculate analytics

2. ✅ `lib/features/home/home_controller.dart`
   - Added `shouldShowActivity()` method

3. ✅ `lib/features/home/home_page.dart`
   - Wrapped each activity card with conditional display

---

## Testing Checklist

### Test 1: Score Recalculation
- [x] Open home page with existing data
- [x] Note current total score (e.g., 150/230)
- [x] Go to Settings → Parameter Tracking
- [x] Disable one activity (e.g., Japa with 25 points)
- [x] Save configuration
- [x] Return to home page
- [x] Verify total score updated (should be 125/205)
- [x] Verify percentage updated correctly

### Test 2: Activity Display Logic
- [x] **No Document Scenario:**
  - Select a future date (no document)
  - Verify all 7 activities show
- [x] **All Activities Enabled:**
  - Select date with existing document
  - All activities enabled in settings
  - Verify all 7 activities show
- [x] **Some Activities Disabled:**
  - Disable 2 activities in settings
  - Verify only 5 activities show on home page
  - Missing activities = disabled ones

### Test 3: Real-Time Updates
- [x] Open home page
- [x] In another tab/device, disable an activity
- [x] Verify activity disappears from home page immediately
- [x] Verify score updates immediately

### Test 4: Re-enabling
- [x] Disable activity (disappears from home)
- [x] Re-enable activity in settings
- [x] Verify activity reappears on home page
- [x] Verify it shows default values

---

## Conclusion

Both issues fixed successfully:

1. ✅ **Score Updates** - Total score recalculates when activities removed/added
2. ✅ **Smart Display** - Shows all activities if no document, shows only tracked if document exists

The app now provides:
- Accurate score calculations at all times
- Clear visual feedback on which activities are tracked
- Real-time updates across all screens
- Proper handling of edge cases

Users can now confidently manage their activity tracking knowing the data is always correct! 🎉
