# Dashboard Improvements - Negative Values & Auto-Refresh

## Overview
Enhanced dashboard with support for negative scores, auto-refresh on open, and default 30-day view.

---

## 1. ✅ Dashboard Auto-Refresh & 30 Days Default

### Changes Made

#### A. Changed Default Range to 30 Days
**File**: `lib/features/dashboard/dashboard_controller.dart`

```dart
// Before: Last 7 Days
Rx<DateTime> startDate = DateTime.now().subtract(const Duration(days: 6)).obs;
RxString selectedRangeLabel = 'Last 7 Days'.obs;

// After: Last 30 Days
Rx<DateTime> startDate = DateTime.now().subtract(const Duration(days: 29)).obs;
RxString selectedRangeLabel = 'Last 30 Days'.obs;
```

#### B. Added Auto-Refresh on Dashboard Open
**File**: `lib/features/dashboard/dashboard_controller.dart`

```dart
@override
void onReady() {
  super.onReady();
  // Reload data when dashboard is opened (in case data changed)
  refreshData();
}

// Refresh all data
Future<void> refreshData() async {
  print('🔄 Refreshing dashboard data...');
  await loadFirstActivityDate();
  await loadActivitiesForDateRange();
}
```

### Why This Matters

**Before:**
- Dashboard shows last 7 days by default
- Data only loads once when controller initializes
- If user updates data elsewhere, dashboard doesn't refresh

**After:**
- Dashboard shows last 30 days by default (more comprehensive view)
- Every time user navigates to dashboard, data refreshes automatically
- Always shows latest data even if changed in settings or home page

### Use Cases

1. **User updates activity tracking in settings** → Opens dashboard → Sees updated data immediately
2. **User adds/edits activities on home page** → Switches to dashboard → Charts reflect new data
3. **Multiple devices** → Update on device A → Open dashboard on device B → Shows latest data

---

## 2. ✅ Negative Values Support in All Visualizations

### Problem
Some activities can have negative scores:
- **Nindra**: If bedtime is after 11:15 PM → -5 points
- **Wake Up**: If wake time is after certain hours → -5 points

Charts couldn't display negative values properly because:
- `minY` was 0 or not set
- Bars would disappear or show incorrectly
- Negative values were not visually distinguished

### Solution Overview

| Chart Type | Solution |
|------------|----------|
| **Line Chart** | Set `minY: -20` to accommodate negative total scores |
| **Bar Chart** | Set `minY: -10` + Show negative bars in RED color |
| **Radar Chart** | Normalize negative values (can't show negative in radar) |

---

## 3. Line Chart - Negative Total Scores

### Changes
**File**: `lib/features/dashboard/dashboard_page.dart`

```dart
LineChartData(
  minY: -20, // Allow negative scores (was 0)
  maxY: AppConstants.maxTotalScore.toDouble(), // 260
  // ... rest of config
)
```

### Dynamic Title
```dart
// Now shows: "Score Trend (Last 30 Days)" - updates based on selection
Obx(() => Text(
  'Score Trend (${controller.selectedRangeLabel.value})',
  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
))
```

### How It Works

**Example Day with Negative Total:**
```
Nindra: -5 (went to bed at 11:30 PM)
Wake Up: -5 (woke up at 8:00 AM)
Day Sleep: 0 (didn't sleep during day)
Japa: 20 (completed at 7:15 AM)
Pathan: 0
Sravan: 0
Seva: 50

Total: -5 + (-5) + 0 + 20 + 0 + 0 + 50 = 60 points
```

**On Line Chart:**
- Y-axis now ranges from -20 to 260
- Can display scores from -20 to 260
- Negative scores visible below the 0 line
- Orange line and shaded area still show the trend

---

## 4. Bar Chart - Color-Coded Negative Values

### Changes
**File**: `lib/features/dashboard/dashboard_page.dart`

#### A. Added minY
```dart
BarChartData(
  minY: -10, // Allow negative individual scores
  maxY: 105, // Max is 100 for Seva
)
```

#### B. Dynamic Color Based on Value
```dart
// Each bar now checks if value is negative
BarChartGroupData(x: 0, barRods: [BarChartRodData(
  toY: controller.avgNindra.value, 
  color: controller.avgNindra.value < 0 ? Colors.red : AppColors.primaryOrange,
  width: 16
)])
```

**Color Logic:**
- **Positive value** → Original color (Orange, Blue, Purple, etc.)
- **Negative value** → RED (universal negative indicator)

#### C. Enhanced Tooltip
```dart
touchTooltipData: BarTouchTooltipData(
  getTooltipItem: (group, groupIndex, rod, rodIndex) {
    final activities = ['Nindra', 'Wake', 'Sleep', 'Japa', 'Pathan', 'Sravan', 'Seva'];
    return BarTooltipItem(
      '${activities[group.x.toInt()]}\n${rod.toY.toStringAsFixed(1)} pts',
      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
  },
)
```

#### D. Legend Added
```dart
Row(
  children: [
    Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
    const SizedBox(width: 4),
    Text(
      'Red = Negative score (below target)',
      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
    ),
  ],
)
```

### Visual Examples

**Scenario 1: All Positive Scores**
```
Nindra: 20 (Orange bar)
Wake Up: 25 (Blue bar)
Day Sleep: 15 (Purple bar)
Japa: 25 (Green bar)
Pathan: 25 (Teal bar)
Sravan: 30 (Indigo bar)
Seva: 80 (Dark Red bar)
```

**Scenario 2: Some Negative Scores**
```
Nindra: -5 (RED bar going downward)
Wake Up: -5 (RED bar going downward)
Day Sleep: 20 (Purple bar going upward)
Japa: 25 (Green bar going upward)
Pathan: 0 (Teal bar at baseline)
Sravan: 15 (Indigo bar going upward)
Seva: 50 (Dark Red bar going upward)
```

### User Experience
1. **Hover over bar** → Tooltip shows exact score
2. **See red bar** → Immediately know performance is below target
3. **Compare heights** → See which activities need attention

---

## 5. Radar Chart - Normalized Negative Handling

### Problem
Radar charts can't display negative values (geometric limitation).

### Solution
Normalize negative values by:
1. Clamping to min possible (-5 for some activities)
2. Shifting scale to make all values positive
3. Normalizing to 0-5 range for visualization

### Changes
**File**: `lib/features/dashboard/dashboard_page.dart`

```dart
dataEntries: [
  // Nindra: Range -5 to 25, normalize to 0-5 scale
  RadarEntry(value: ((controller.avgNindra.value.clamp(-5, 25) + 5) / 30) * 5),
  
  // Wake Up: Range -5 to 25, normalize to 0-5 scale
  RadarEntry(value: ((controller.avgWakeUp.value.clamp(-5, 25) + 5) / 30) * 5),
  
  // Day Sleep: Range -5 to 25, normalize to 0-5 scale
  RadarEntry(value: ((controller.avgDaySleep.value.clamp(-5, 25) + 5) / 30) * 5),
  
  // Japa: Range 0 to 25, normalize to 0-5 scale
  RadarEntry(value: ((controller.avgJapa.value.clamp(0, 25)) / 25) * 5),
  
  // Pathan: Range 0 to 30, normalize to 0-5 scale
  RadarEntry(value: ((controller.avgPathan.value.clamp(0, 30)) / 30) * 5),
  
  // Sravan: Range 0 to 30, normalize to 0-5 scale
  RadarEntry(value: ((controller.avgSravan.value.clamp(0, 30)) / 30) * 5),
  
  // Seva: Range 0 to 100, normalize to 0-5 scale
  RadarEntry(value: ((controller.avgSeva.value.clamp(0, 100)) / 100) * 5),
],
```

### Normalization Formula

**For activities that can be negative (Nindra, Wake Up, Day Sleep):**
```
normalized = ((actualValue.clamp(-5, 25) + 5) / 30) * 5

Examples:
- actualValue = -5 → ((-5 + 5) / 30) * 5 = 0.0 (minimum on radar)
- actualValue = 0  → ((0 + 5) / 30) * 5 = 0.83
- actualValue = 10 → ((10 + 5) / 30) * 5 = 2.5 (middle)
- actualValue = 25 → ((25 + 5) / 30) * 5 = 5.0 (maximum on radar)
```

**For activities that are always positive (Japa, Pathan, Sravan, Seva):**
```
normalized = (actualValue.clamp(0, maxPoints) / maxPoints) * 5

Examples for Japa (max 25):
- actualValue = 0  → (0 / 25) * 5 = 0.0
- actualValue = 12 → (12 / 25) * 5 = 2.4
- actualValue = 25 → (25 / 25) * 5 = 5.0
```

### Updated Description
```dart
Text(
  'Visual representation of activity balance (negative scores normalized to 0)',
  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
)
```

### Why This Approach?

**Pros:**
- Keeps radar chart functional
- Shows relative performance across all activities
- -5 score shows as 0 on radar (still visible as low performance)
- Users can see overall balance at a glance

**Note for Users:**
- Check **bar chart** for exact values including negatives
- Radar shows **relative balance**, not exact scores
- Red bars in bar chart indicate actual negative performance

---

## Complete Visual System for Negative Values

### Summary Table

| Visualization | Negative Handling | Visual Indicator |
|---------------|-------------------|------------------|
| **Line Chart** | Shows below 0 line | Orange line dips below baseline |
| **Bar Chart** | Red bars going downward | RED color + negative Y value |
| **Radar Chart** | Normalized to 0-5 scale | Appears closer to center (smaller area) |
| **Score Cards** | Shows exact value | Can display negative numbers with minus sign |

### User Journey: Seeing Negative Scores

1. **Home Page**: User enters late bedtime (11:30 PM)
   - Saves activity
   - Sees score: -5 for Nindra

2. **Dashboard Opens**: Auto-refresh loads latest data
   - **Line Chart**: Shows total score dip (if day total is negative)
   - **Bar Chart**: Nindra bar is RED and goes downward to -5
   - **Radar Chart**: Nindra slice is smaller (normalized to near 0)
   - **Legend**: Shows "Red = Negative score (below target)"

3. **Tooltip Interaction**: User hovers over Nindra red bar
   - Shows: "Nindra\n-5.0 pts"
   - Clear indication of negative performance

4. **Understanding**: User sees:
   - Red color = Below target
   - Exact negative value in tooltip
   - Overall impact on total score in line chart
   - Relative balance in radar chart

---

## Technical Implementation Details

### Dart Extensions Used
```dart
controller.avgNindra.value.clamp(-5, 25) // Clamps value between -5 and 25
rod.toY.toStringAsFixed(1)               // Formats to 1 decimal place
Colors.red.shade400                      // Color variant
```

### Observable Updates
All charts use `Obx()` wrapper:
```dart
Obx(() {
  if (controller.activities.isEmpty) {
    return const SizedBox.shrink();
  }
  return Card(/* ... chart ... */);
})
```

This ensures:
- Charts rebuild when data changes
- Colors update dynamically based on values
- Tooltips show current values
- Auto-refresh triggers UI update

---

## Files Modified

1. ✅ `lib/features/dashboard/dashboard_controller.dart`
   - Changed default to 30 days
   - Added `onReady()` for auto-refresh
   - Added `refreshData()` method

2. ✅ `lib/features/dashboard/dashboard_page.dart`
   - Line chart: Added `minY: -20`
   - Line chart: Made title dynamic
   - Bar chart: Added `minY: -10`
   - Bar chart: Added color logic for negative values
   - Bar chart: Added tooltip with activity name
   - Bar chart: Added legend for red color
   - Radar chart: Updated normalization for negative values
   - Radar chart: Updated description

---

## Testing Checklist

### Test 1: Auto-Refresh
- [ ] Add activity on home page
- [ ] Navigate to dashboard
- [ ] Verify new activity appears in charts
- [ ] Go to settings, disable an activity
- [ ] Return to dashboard
- [ ] Verify chart updates with recalculated data

### Test 2: Negative Values - Line Chart
- [ ] Create activity with negative total (e.g., late bed + late wake)
- [ ] Open dashboard
- [ ] Verify line chart shows point below 0
- [ ] Y-axis should show negative values (-20, -10, 0, 10, ...)

### Test 3: Negative Values - Bar Chart
- [ ] Open dashboard with negative activity score
- [ ] Verify bar is RED color
- [ ] Verify bar extends downward (negative direction)
- [ ] Hover over red bar
- [ ] Verify tooltip shows negative value (e.g., "Nindra\n-5.0 pts")
- [ ] Check legend shows red = negative explanation

### Test 4: Negative Values - Radar Chart
- [ ] Open dashboard with negative scores
- [ ] Verify radar chart still displays (no errors)
- [ ] Activities with negative scores should be closer to center
- [ ] Check description mentions "negative scores normalized to 0"

### Test 5: Default 30 Days
- [ ] First time opening dashboard
- [ ] Verify shows "Last 30 Days" by default
- [ ] Verify date range selector shows 30 days selected
- [ ] Verify line chart title says "Score Trend (Last 30 Days)"

### Test 6: Color Transitions
- [ ] Start with positive score (e.g., Nindra = 20, Orange bar)
- [ ] Edit to make it negative (e.g., Nindra = -5)
- [ ] Open dashboard
- [ ] Verify bar color changes from Orange to RED
- [ ] Edit back to positive
- [ ] Verify bar color changes back to Orange

---

## Edge Cases Handled

1. **All Negative Day**: Total = -10
   - Line chart shows point at -10
   - All bars in bar chart are red
   - Radar chart shows very small polygon near center

2. **Mixed Scores**: Some positive, some negative
   - Line chart shows net total
   - Bar chart shows red for negative, normal colors for positive
   - Radar chart balances both

3. **Zero Score**: Activity = 0
   - Line chart shows at 0 baseline
   - Bar chart shows bar at 0 (neither up nor down)
   - Radar chart shows slice at normalized 0.83 position (for -5 to 25 range)

4. **Extreme Negative**: -20 total
   - Line chart minY = -20, so still visible
   - Multiple activities must be negative
   - Clear visual indicator that performance is very poor

---

## Benefits

### For Users
- ✅ **Always see latest data** - Auto-refresh on dashboard open
- ✅ **More comprehensive view** - 30 days default instead of 7
- ✅ **Clear negative indicators** - Red color for below-target performance
- ✅ **Accurate visualization** - All scores (positive and negative) displayed correctly
- ✅ **Better insights** - Can identify which activities drag down overall score

### For Development
- ✅ **Robust charting** - Handles full range of possible values
- ✅ **Consistent UX** - All charts handle negatives appropriately
- ✅ **Real-time updates** - Observable pattern ensures UI stays in sync
- ✅ **Maintainable** - Clear normalization formulas for future adjustments

---

## Future Enhancements

1. **Configurable Default Range**: Let users set their preferred default (7, 15, 30, or 90 days)
2. **Negative Score Alerts**: Push notification when score goes negative
3. **Trend Analysis**: Show if negative scores are improving or worsening over time
4. **Goal Setting**: Set target to avoid negative scores, track progress
5. **Custom Colors**: Let users customize negative score color in settings

---

## Conclusion

Dashboard now provides:
- ✅ **30-day default view** for comprehensive overview
- ✅ **Auto-refresh** to always show latest data
- ✅ **Full negative value support** across all visualizations
- ✅ **Clear visual indicators** (red color) for below-target performance
- ✅ **Proper scaling** (minY values) to display full range
- ✅ **Enhanced tooltips** with activity names and exact values
- ✅ **User-friendly legends** explaining color meanings

Users can now accurately track their performance including when they fall below targets, and the dashboard always reflects the most current data! 🎉
