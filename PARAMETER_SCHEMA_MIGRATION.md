# Parameter Schema Migration to Firestore

## Overview
Parameters are now stored in Firestore instead of being hardcoded in the app. This document explains the implementation and migration process.

## JSON Schema Definition
All parameters follow this schema:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Parameter",
  "type": "object",
  "properties": {
    "key": { 
      "type": "string", 
      "description": "unique key used in activities (e.g., 'japa','wake_up')" 
    },
    "name": { "type": "string" },
    "type": { 
      "type": "string", 
      "enum": ["duration","count","time"], 
      "description": "duration: minutes | count: numeric | time: clock time-of-day" 
    },
    "enabled": { "type": "boolean", "default": true },
    "maxPoints": { 
      "type": "number", 
      "description": "maximum points achievable for this parameter" 
    },
    "scoring": {
      "type": "object",
      "description": "bucket->points mapping. Examples: '0':0, '1-15':5, '31-9999':25, or '05:00-06:30':10 for time",
      "additionalProperties": { "type": "number" }
    },
    "description": { "type": "string" },
    "createdAt": { "type": ["string","object","number"] },
    "updatedAt": { "type": ["string","object","number"] }
  },
  "required": ["key","name","type","scoring"],
  "additionalProperties": false
}
```

## Firestore Collection Structure

**Collection:** `parameters`
**Document ID:** Parameter key (e.g., `japa`, `wake_up`, `nindra`)

### Defined Parameters (7 total)

1. **nindra** - Night sleep time (PM)
   - Type: time
   - Max Points: 25
   - Scoring: Time-based ranges from 21:45 to 23:59

2. **wake_up** - Morning wake up time
   - Type: time
   - Max Points: 25
   - Scoring: Time-based ranges from 03:45 to 05:15

3. **day_sleep** - Day sleep duration
   - Type: duration
   - Max Points: 25
   - Scoring: Duration-based (0-9999 minutes)

4. **japa** - Japa chanting completion time
   - Type: time
   - Max Points: 25
   - Scoring: Time-based ranges throughout the day

5. **pathan** - Reading duration
   - Type: duration
   - Max Points: 30
   - Scoring: Duration-based (0-9999 minutes)

6. **sravan** - Listening duration
   - Type: duration
   - Max Points: 30
   - Scoring: Duration-based (0-9999 minutes)

7. **seva** - Service duration
   - Type: duration
   - Max Points: 100
   - Scoring: Duration-based (0-9999 minutes)

## Implementation Details

### Changes Made

#### 1. **ParameterService** (`lib/data/services/parameter_service.dart`)
   - **Removed:** Hardcoded fallback mechanism (`_loadHardcodedDefaults()`)
   - **Enhanced:** `loadParameters()` now auto-initializes from defaults if Firestore is empty
   - **Added:** Timestamps (`createdAt`, `updatedAt`) to all default parameters
   - **Improved:** `initializeDefaultParameters()` uses batch write for better performance
   - **Result:** Parameters are ONLY loaded from Firestore (no in-memory hardcoded fallback)

#### 2. **Automatic Initialization Flow**
```
App Start (main.dart)
    ↓
Firebase.initializeApp()
    ↓
ParameterService.loadParameters()
    ↓
Is Firestore empty?
    ├─ YES → initializeDefaultParameters() → Upload to Firestore → Reload
    └─ NO → Load from Firestore
```

### How It Works

1. **First Run:**
   - When the app starts, `main.dart` calls `parameterService.loadParameters()`
   - If no parameters exist in Firestore, `initializeDefaultParameters()` is called automatically
   - All 7 parameters are uploaded to Firestore using batch write
   - Parameters are then loaded from Firestore into memory cache

2. **Subsequent Runs:**
   - Parameters are loaded directly from Firestore
   - No hardcoded defaults are used
   - All scoring calculations use the Firestore data

### Benefits

✅ **Centralized Configuration:** All parameters stored in Firestore
✅ **Real-time Updates:** Admin can modify parameters without app updates
✅ **Scalability:** Easy to add/modify parameters through admin interface
✅ **Consistency:** All users see the same parameters
✅ **Audit Trail:** `createdAt` and `updatedAt` timestamps track changes

### Future Enhancements

1. **Admin Interface:** UI to manage parameters (add, edit, disable)
2. **Version Control:** Track parameter changes over time
3. **User-specific Parameters:** Allow customization per user if needed
4. **Parameter History:** Store historical scoring rules for data analysis

## Testing

To verify the migration:

1. **Fresh Install:**
   - Install the app on a fresh device/emulator
   - Check console logs for: `🚀 Initializing default parameters in Firestore...`
   - Verify all 7 parameters are created in Firestore

2. **Existing Installation:**
   - Parameters should load from Firestore
   - Console shows: `✅ Loaded 7 parameters from Firestore`

3. **Firestore Console:**
   - Navigate to Firestore → `parameters` collection
   - Verify 7 documents exist with keys: nindra, wake_up, day_sleep, japa, pathan, sravan, seva

## Migration Cleanup (Future)

Once confirmed working in production, we can:
- Remove `_getDefaultParametersList()` method (keep for reference/backup)
- Remove default parameter definitions from code
- Keep only `initializeDefaultParameters()` for new installations

## Notes

- ✅ No changes to `ParameterModel` - schema remains compatible
- ✅ No changes to scoring logic - calculations work the same way
- ✅ Backward compatible - existing activities continue to work
- ✅ One-time operation - initialization only happens when Firestore is empty
