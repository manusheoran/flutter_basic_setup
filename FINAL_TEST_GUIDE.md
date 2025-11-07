# 🧪 Final Test Guide - Profile & Export

## 🔥 Run the App

```bash
flutter run
```

---

## ✅ Test 1: Profile Edit (1 minute)

### Steps:
1. **Go to Settings** (bottom nav)
2. **See your profile card** at the top
3. **Click the pencil (Edit) icon** in top-right of card
4. **Dialog should open** with:
   - Your name (pre-filled)
   - Email (read-only, grayed out)
   - Phone number field
   - Gender dropdown
   - Occupation dropdown

5. **Fill in details:**
   - Phone: `9876543210`
   - Gender: Select any option
   - Occupation: Select any option

6. **Click "Save Changes"**

### Expected Results:
✅ Green success message appears
✅ Dialog closes
✅ Settings page shows updated info
✅ Phone, Gender, Occupation appear below your name

### If It Doesn't Work:
**Check Console For:**
```
Error: [details]
```

**Common Issues:**
- Firestore rules might block updates
- User not logged in
- Network error

---

## ✅ Test 2: Export Reports (2 minutes)

### Steps:
1. **Go to Home page**
2. **Save at least ONE activity** (fill any values, click Save)
3. **Go to Dashboard**
4. **Verify activities loaded:**
   - Should see "✅ Found X activities" in console
   - Dashboard shows charts and averages

5. **Click "Export Reports"**
6. **Report page opens**
7. **Click "Download Excel Report"**

### Expected Console Output:
```
📄 Report Page: Loading data for user: [userId]
📄 Loading user data from Firestore...
📄 Current user: [YourName]
✅ Report Page: Loaded 1 activities
📊 Excel export button clicked
📊 Exporting 1 activities for [YourName]
📊 Starting Excel export...
📊 Storage permission status: granted
✅ Permission granted!
📊 Android device detected
📊 Writing XXXX bytes to file...
✅ Excel file saved successfully!
```

### Expected Results:
✅ Green success message
✅ File saved to Downloads folder
✅ File name: `Sadhana_Report_YourName_timestamp.xlsx`

### If Console Shows:
```
❌ No current user
```

**FIX:** The currentUser is not loading. Try:
1. Log out
2. Log back in
3. Try export again

---

## 🐛 Troubleshooting

### Issue 1: Profile Edit Dialog Doesn't Open

**Symptom:** Clicking edit button does nothing

**Check:**
```dart
// In console, should see no errors when clicking
```

**Fix:**
- Make sure user is logged in
- Restart app: Press `R` in terminal

---

### Issue 2: "No Current User" Error

**Symptom:** Console shows:
```
❌ No current user
```

**Root Cause:** `currentUser.value` is null

**Fix Option 1: Quick Fix**
Log out and log back in

**Fix Option 2: Check Auth Loading**
After login, console should show:
```
Loading user data from Firestore...
Current user loaded: [YourName]
```

If not shown, auth service isn't loading user properly.

---

### Issue 3: Export Buttons Don't Work

**Symptom:** Clicking export button does nothing

**Check Console:**
If you see:
```
📊 Excel export button clicked
❌ No current user
```

Then user is not loaded.

If you see NOTHING when clicking button:
- Button might be disabled (grayed out)
- Need to have activities first
- Check if `activities.isEmpty`

---

### Issue 4: Permission Denied (Android)

**Console shows:**
```
❌ All permissions denied
```

**Fix:**
1. Go to phone Settings
2. Apps → Sadhana App
3. Permissions → Storage
4. Allow

---

### Issue 5: Dropdowns Don't Show Selected Value

**Symptom:** Gender/Occupation dropdowns look empty even after selection

**This is expected!** - Using hint text instead of value
When you click dropdown, you'll see the list and can select

To see current value, check Settings page after saving

---

## 📱 Where to Find Exported Files

### Android:
```
/storage/emulated/0/Download/Sadhana_Report_*.xlsx
```

Or use File Manager → Downloads folder

### iOS:
```
Files app → On My iPhone → Sadhana App
```

---

## 🎯 Quick Checklist

Before reporting "not working":

- [ ] App is running (`flutter run`)
- [ ] Logged in with valid account
- [ ] At least one activity saved (Home page)
- [ ] Console visible to see errors
- [ ] Storage permission granted (Android)
- [ ] Tried logging out and back in
- [ ] Checked Downloads folder for files

---

## 📊 Console Logs to Look For

### Good Signs ✅:
```
📄 Current user: [YourName]
✅ Found 3 activities
📊 Exporting 3 activities for [YourName]
✅ Excel file saved successfully!
```

### Bad Signs ❌:
```
❌ No current user
❌ No activities to export
❌ All permissions denied
❌ Export error: [details]
```

---

## 🔧 Emergency Fixes

### Fix 1: Clear and Restart
```bash
flutter clean
flutter pub get
flutter run
```

### Fix 2: Log Out/In
1. Go to Settings
2. Click Logout
3. Log back in
4. Try again

### Fix 3: Check Firestore Console
1. Open Firebase Console
2. Go to Firestore Database
3. Check `users` collection
4. Find your user document
5. Verify it has:
   - name
   - email
   - phone (after edit)
   - occupation (after edit)
   - gender (after edit)

---

## 🎬 Complete Test Flow

```
1. flutter run
   ↓
2. Login
   ↓
3. Home page → Save activity
   ↓
4. Settings → Click Edit icon
   ↓
5. Fill profile → Save
   ↓
6. Verify profile shows on Settings
   ↓
7. Dashboard → Check data loaded
   ↓
8. Export Reports
   ↓
9. Download Excel
   ↓
10. Check Downloads folder
   ↓
SUCCESS! 🎉
```

---

## 📝 Report Format

If still not working, provide:

1. **Which step fails?**
   - Profile edit? or Export?

2. **Console output** (copy-paste)

3. **What you see on screen**

4. **Any error messages**

---

**Test now and share your console output!** 📊
