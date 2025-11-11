# 🕉️ Sādhana Tracking Scoring System - Final Implementation

## Overview

Total Maximum Points: **230 points**
- 4 Timestamp-based activities: 100 points (25 each)
- 3 Duration-based activities: 130 points (30+30+70 or 100 split)

## Activity Types

### Timestamp Activities (Time Input)
User selects specific time (HH:mm with AM/PM):
- **NINDRA (To Bed)** - Minimum: 09:45 PM
- **WAKE UP** - Minimum: 03:45 AM  
- **JAPA** - Completion time (also stores rounds as extra info)

### Duration Activities (Minutes Input)
User enters duration in hours and minutes:
- **DAY SLEEP** - Sleep duration during day
- **PATHAN** - Reading/Study duration
- **SRAVAN** - Listening/Discourse duration
- **SEVA** - Service duration

## Exact Scoring Rules

### 1. NINDRA (To Bed) - 25 max points
| Time Range | Points |
|------------|--------|
| 09:45 – 10:00 PM | 25 |
| 10:00 – 10:15 PM | 20 |
| 10:15 – 10:30 PM | 15 |
| 10:30 – 10:45 PM | 10 |
| 10:45 – 11:00 PM | 5 |
| 11:00 – 11:15 PM | 0 |
| After 11:15 PM | -5 |

### 2. WAKE UP - 25 max points
| Time Range | Points |
|------------|--------|
| 03:45 – 04:00 AM | 25 |
| 04:00 – 04:15 AM | 20 |
| 04:15 – 04:30 AM | 15 |
| 04:30 – 04:45 AM | 10 |
| 04:45 – 05:00 AM | 5 |
| 05:00 – 05:15 AM | 0 |
| After 05:15 AM | -5 |

### 3. DAY SLEEP - 25 max points
| Duration | Points |
|----------|--------|
| ≤ 60 min (1 hr or less) | 25 |
| 61 – 75 min (1 – 1:15 hr) | 20 |
| 76 – 90 min (1:15 – 1:30 hr) | 15 |
| 91 – 105 min (1:30 – 1:45 hr) | 10 |
| 106 – 120 min (1:45 – 2:00 hr) | 5 |
| 121 – 135 min (2:00 – 2:15 hr) | 0 |
| > 135 min (After 2:15 hr) | -5 |

### 4. JAPA (Completion Time) - 25 max points
| Time Range | Points |
|------------|--------|
| Before 07:15 AM | 25 |
| 07:15 – 09:30 AM | 20 |
| 09:30 AM – 01:00 PM | 15 |
| 01:00 – 07:00 PM | 10 |
| 07:00 – 09:00 PM | 5 |
| 09:00 – 11:00 PM | 0 |
| After 11:00 PM | -5 |

**Note**: Japa also stores "rounds" (number of chants) as extra info - not used in scoring

### 5. PATHAN (Reading/Study) - 30 max points
| Duration | Points |
|----------|--------|
| > 60 min (> 1 hr) | 30 |
| 45 – 60 min (1 hr to 45 min) | 25 |
| 35 – 44 min (45 – 35 min) | 20 |
| 25 – 34 min (35 – 25 min) | 15 |
| 15 – 24 min (25 – 15 min) | 10 |
| 5 – 14 min (15 – 5 min) | 5 |
| < 5 min (Below 5 min) | 0 |

### 6. SRAVAN (Listening/Discourse) - 30 max points
| Duration | Points |
|----------|--------|
| > 60 min (> 1 hr) | 30 |
| 45 – 60 min (1 hr to 45 min) | 25 |
| 35 – 44 min (45 – 35 min) | 20 |
| 25 – 34 min (35 – 25 min) | 15 |
| 15 – 24 min (25 – 15 min) | 10 |
| 5 – 14 min (15 – 5 min) | 5 |
| < 5 min (Below 5 min) | 0 |

### 7. SEVA (Service) - 100 max points
| Duration | Points |
|----------|--------|
| > 210 min (> 3.5 hrs) | 100 |
| 181 – 210 min (3 – 3.5 hrs) | 80 |
| 151 – 180 min (2.5 – 3 hrs) | 60 |
| 121 – 150 min (2 – 2.5 hrs) | 40 |
| 91 – 120 min (1.5 – 2 hrs) | 20 |
| 0 – 90 min (≤ 1.5 hrs) | 0 |

## Analytics Structure

Each activity stores the following in `analytics`:

```json
{
  "type": "timestamp" | "duration",
  "timestamp": "2024-01-01T10:00:00Z",  // For timestamp-based
  "duration": 60,  // For duration-based (minutes)
  "pointsAchieved": 25,
  "maxAchievablePoints": 25,
  "default": 0,
  "status": "active"
}
```

## Data Storage

### Timestamp Activities (NINDRA, WAKE UP, JAPA)
```dart
extras: {
  'value': '22:00',  // HH:mm format
  'rounds': 16,  // JAPA only - extra info
}
analytics: ActivityAnalytics(
  timestamp: DateTime(...),  // Parsed from value
  pointsAchieved: 20.0,
  maxAchievablePoints: 25.0,
  defaultValue: 0.0,
  status: 'active',
)
```

### Duration Activities (DAY SLEEP, PATHAN, SRAVAN, SEVA)
```dart
extras: {
  'duration': 60,  // minutes
}
analytics: ActivityAnalytics(
  duration: 60.0,  // minutes
  pointsAchieved: 25.0,
  maxAchievablePoints: 30.0,
  defaultValue: 0.0,
  status: 'active',
)
```

## UI Input Requirements

### Timestamp Input
- Time Picker with Hours, Minutes, AM/PM
- **NINDRA**: Default 09:45 PM, can't go before this
- **WAKE UP**: Default 03:45 AM, can't go before this
- **JAPA**: Any time, but scored based on table

### Duration Input  
- Hours and Minutes selection
- Starts from 0
- Converted to total minutes for storage and scoring

## Percentage Calculation

```dart
percentage = (totalPointsAchieved / 230) * 100
```

Example:
- Total points achieved: 180
- Percentage: (180 / 230) * 100 = 78.26%

## First-Time User Setup

When creating a new user:
1. Add all 7 parameters as active in user document
2. Add to `trackingActivities` array in user doc
3. Create activity document for current day with default values:
   - All timestamp activities: null/empty
   - All duration activities: 0 minutes
   - All scores: 0 points

## Implementation Files

### Models
- **activity_model.dart**: DailyActivity, ActivityItem, ActivityAnalytics, DailyAnalytics
- **parameter_model.dart**: ParameterModel with scoring logic

### Services
- **parameter_service.dart**: Loads parameters, calculates scores
- **firestore_service.dart**: CRUD operations for activities
- **auth_service.dart**: User management

### Controllers
- **home_controller.dart**: Activity input and score calculation
- **dashboard_controller.dart**: Activity display and analytics

## Testing Examples

### Perfect Day (230 points, 100%)
- NINDRA: 09:50 PM → 25 points
- WAKE UP: 03:50 AM → 25 points
- DAY SLEEP: 30 min → 25 points
- JAPA: 07:00 AM → 25 points
- PATHAN: 65 min → 30 points
- SRAVAN: 70 min → 30 points
- SEVA: 250 min → 100 points
- **Total: 230 / 230 = 100%**

### Good Day (160 points, 69.57%)
- NINDRA: 10:30 PM → 10 points
- WAKE UP: 04:20 AM → 15 points
- DAY SLEEP: 80 min → 15 points
- JAPA: 08:00 AM → 20 points
- PATHAN: 40 min → 20 points
- SRAVAN: 30 min → 15 points
- SEVA: 180 min → 60 points
- **Total: 155 / 230 = 67.39%**

## Notes
- Negative scores are possible for very late activities
- System is precise to the minute for duration-based activities
- System is precise to 15-minute intervals for timestamp-based activities
- Japa rounds are stored but not used in scoring - scoring is purely time-based
