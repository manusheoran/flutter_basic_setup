# Email Verification Troubleshooting Guide

## 🔍 How Email Verification Works

### **Who Sends the Email?**
**Firebase Authentication** sends the verification email automatically when your app calls:
```dart
await user.sendEmailVerification();
```

### **Flow in Your App:**

1. **User Signs Up** → `AuthService.signUp()`
2. **Firebase creates account** → `createUserWithEmailAndPassword()`
3. **App requests verification email** → `sendEmailVerification()`
4. **Firebase sends email** → User receives email
5. **User clicks link in email** → Email marked as verified
6. **User tries to login** → App checks `user.emailVerified`
7. **If verified** → Allow login ✅
8. **If NOT verified** → Block login and show message ❌

---

## 🧪 How to Check if Email is Sent

### **1. Check Console Logs (Most Important!)**

When you sign up, you should see these logs:

```
📝 Starting signup for: test@example.com
✅ User account created: abc123xyz
📧 Email verified status: false
✅ Verification email sent successfully to test@example.com
📬 Please check your inbox (and spam folder)
```

**If you see errors:**
```
❌ Error sending verification email: [error message]
```
This tells you exactly what's wrong!

### **2. Check Firebase Console**

Go to: [Firebase Console](https://console.firebase.google.com/)
1. Select your project
2. Go to **Authentication** → **Users**
3. Find the newly created user
4. Check if user exists and note the UID

---

## ⚙️ Firebase Configuration Checklist

### **Step 1: Enable Email/Password Authentication**

1. Firebase Console → **Authentication** → **Sign-in method**
2. Find **Email/Password** in the list
3. Make sure it's **ENABLED** (toggle should be on)

### **Step 2: Configure Email Templates**

1. Firebase Console → **Authentication** → **Templates**
2. Click on **Email address verification**
3. You should see a default template like:

```
Subject: Verify your email for %APP_NAME%
Body: Hello,

Follow this link to verify your email address.
%LINK%

If you didn't ask to verify this address, you can ignore this email.

Thanks,
Your %APP_NAME% team
```

4. **Customize if needed** (optional)
5. Make sure **Email verified** action is **enabled**

### **Step 3: Check Sender Email**

1. In the same **Templates** section
2. Look for "From" email address
3. Default: `noreply@your-project-id.firebaseapp.com`
4. This might go to spam! Consider:
   - Adding a custom domain (advanced)
   - Or tell users to check spam folder

---

## 🐛 Common Issues & Solutions

### **Issue 1: "Email not received"**

**Possible Causes:**
- ✅ **Check SPAM folder** (most common!)
- ✅ Email provider blocking `noreply@firebaseapp.com`
- ✅ Incorrect email entered during signup
- ✅ Firebase quota limit reached (free tier: 100 emails/day)

**Solution:**
```dart
// Check logs when signing up - you should see:
✅ Verification email sent successfully to test@example.com

// If you see this, email WAS sent by Firebase
// Check spam folder or try different email provider
```

**Test with different email providers:**
- ✅ Gmail (usually works)
- ✅ Outlook/Hotmail (usually works)
- ⚠️ Custom domains (might block Firebase)
- ⚠️ Corporate emails (often blocked)

---

### **Issue 2: "Error sending verification email"**

**Check console logs for specific error:**

**Error: `too-many-requests`**
```
Solution: Firebase free tier limit reached
- Wait 24 hours, OR
- Upgrade to Blaze plan
```

**Error: `network-request-failed`**
```
Solution: Internet connection issue
- Check your internet
- Try again
```

**Error: `internal-error`**
```
Solution: Firebase service issue
- Check Firebase Status: https://status.firebase.google.com/
- Try again in a few minutes
```

---

### **Issue 3: "How to check if user verified email?"**

**Method 1: In the App**
```dart
// After user clicks email link, they need to:
1. Close the verification browser tab
2. Come back to app
3. Try to login again
4. App will reload user and check: user.emailVerified
```

**Method 2: Firebase Console**
```
1. Go to Firebase Console
2. Authentication → Users
3. Find the user by email
4. Check "Email Verified" column
   - ✓ = Verified
   - (empty) = Not verified
```

**Method 3: Force Reload in App**
```dart
// You can manually check by adding this to your login:
await FirebaseAuth.instance.currentUser?.reload();
final isVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
print('Email verified: $isVerified');
```

---

### **Issue 4: "User clicks link but still can't login"**

**Cause:** App doesn't know email is verified yet

**Solution:**
```dart
// Firebase automatically updates user.emailVerified
// But you need to reload the user:

// In login method:
await _auth.currentUser?.reload(); // Refresh user data
final isVerified = _auth.currentUser?.emailVerified ?? false;

if (!isVerified) {
  return 'Please verify your email first';
}
```

**Already implemented in your app!** ✅  
(Line 223-226 in auth_service.dart)

---

## 🔧 Debug Commands

### **1. Run app and check logs:**
```bash
cd /Users/enrich/CascadeProjects/windsurf-project/sadhana_app

# For Android
flutter run

# Watch for these logs:
# 📝 Starting signup for: ...
# ✅ Verification email sent successfully...
```

### **2. Test with adb logcat (Android):**
```bash
# Terminal 1: Run app
flutter run

# Terminal 2: Watch logs
adb logcat | grep -E "flutter|Firebase|Email"
```

### **3. Check Firebase Console Users:**
```
1. Open: https://console.firebase.google.com/
2. Select your project
3. Authentication → Users
4. Look for newly created user
5. Check "Email Verified" column
```

---

## 📊 Email Sending Status

### **Your App's Implementation:**

✅ **Signup:** Calls `sendEmailVerification()` with ActionCodeSettings  
✅ **Fallback:** Tries without ActionCodeSettings if first fails  
✅ **Logging:** Detailed logs at every step  
✅ **Error Handling:** Catches and reports errors  
✅ **Resend Function:** Available in Settings page  

### **Expected Logs on Successful Signup:**

```
📝 Starting signup for: user@example.com
✅ User account created: xyz123abc
📧 Email verified status: false
✅ Verification email sent successfully to user@example.com
📬 Please check your inbox (and spam folder)
```

---

## 🎯 Quick Test Steps

1. **Sign up with a new email**
   ```
   Use Gmail or Outlook for testing (most reliable)
   ```

2. **Check app logs immediately**
   ```
   Should see: ✅ Verification email sent successfully
   ```

3. **Check email inbox**
   ```
   - Check inbox
   - Check spam/junk folder
   - Check "Promotions" tab (Gmail)
   ```

4. **Email should arrive within 30 seconds**
   ```
   From: noreply@your-project.firebaseapp.com
   Subject: Verify your email for Sadhana
   ```

5. **Click verification link**
   ```
   Opens browser → "Your email has been verified"
   ```

6. **Try to login**
   ```
   Should work now! ✅
   ```

---

## 🚨 Still Not Working?

### **Check These:**

1. **Firebase Project Settings:**
   - Go to Firebase Console
   - Project Settings (gear icon)
   - Scroll to "Your apps"
   - Make sure your Android/iOS app is listed

2. **Check Firebase Quotas:**
   - Firebase Console → Authentication → Usage
   - Free tier: 100 emails/day
   - If exceeded, upgrade or wait 24 hours

3. **Check Firebase Status:**
   - Visit: https://status.firebase.google.com/
   - Make sure no ongoing issues

4. **Try Different Email:**
   - Gmail: ✅ Recommended
   - Outlook: ✅ Works well
   - Yahoo: ⚠️ Sometimes blocks
   - Custom domain: ⚠️ Often blocks

---

## 📝 Manual Email Verification (for Testing)

**If you absolutely need to bypass email verification during development:**

### ⚠️ **WARNING: Only for Development/Testing!**

```dart
// In auth_service.dart, temporarily comment out verification check:

Future<String?> signIn({...}) async {
  // ... sign in code ...
  
  // TEMPORARILY COMMENT THIS OUT FOR TESTING:
  // if (!userCredential.user!.emailVerified) {
  //   await _auth.signOut();
  //   return 'Please verify your email...';
  // }
  
  return null;
}
```

**Remember to uncomment for production!**

---

## ✅ Expected Behavior Summary

| Action | Expected Result |
|--------|----------------|
| User signs up | Account created + Email sent |
| User checks logs | See "✅ Email sent successfully" |
| User checks email | Email received within 30s |
| User clicks link | Browser opens, email verified |
| User tries login (before verify) | ❌ Blocked with message |
| User tries login (after verify) | ✅ Login successful |

---

## 🆘 Still Need Help?

**Share these details:**
1. Console logs during signup
2. Firebase Console screenshot (Users tab)
3. Email provider used (Gmail/Outlook/etc)
4. Any error messages

This will help diagnose the exact issue!
