import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import '../models/user_model.dart';
import 'parameter_service.dart';
import '../../core/constants/app_constants.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final LocalAuthentication _localAuth = LocalAuthentication();

  Rx<User?> firebaseUser = Rx<User?>(null);
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  // Biometric settings
  RxBool canCheckBiometrics = false.obs;
  RxBool canUseDeviceCredentials = false.obs;
  bool _biometricValidated = false;

  bool get isBiometricRequired => AppConstants.requireBiometricAuthentication;
  bool get shouldPromptBiometric =>
      isBiometricRequired &&
      (canCheckBiometrics.value || canUseDeviceCredentials.value);

  // Flag to prevent auth listener interference during signup
  bool _isSigningUp = false;

  @override
  void onInit() async {
    super.onInit();
    try {
      print('🔥 AuthService initializing...');
      firebaseUser.bindStream(_auth.authStateChanges());
      ever(firebaseUser, (user) => _setInitialScreen(user, fromAuthChange: true));
      print('✅ Auth state listener registered');

      // Check biometric availability
      await _checkBiometricAvailability();

      // Warm up parameters so first navigation has data ready
      await _ensureParametersLoaded();

      // Fallback: If auth state doesn't fire within 3 seconds, navigate manually
      Future.delayed(const Duration(seconds: 3), () async {
        if (Get.currentRoute == '/splash') {
          print('⚠️ Auth state timeout - navigating from splash');
          final user = _auth.currentUser;
          if (user != null) {
            print('📱 User found in cache: ${user.uid}');
            _setInitialScreen(user);
          } else {
            print('📱 No user found - going to login');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.offAllNamed('/login');
            });
          }

          await _ensureParametersLoaded();
        }
      });
    } catch (e) {
      print('❌ AuthService: Firebase not available - $e');
      // Navigate to login page in preview mode
      Future.delayed(const Duration(milliseconds: 500), () {
        print('🔀 Navigating to login (Firebase unavailable)');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed('/login');
        });
      });
    }
  }

  Future<void> _ensureParametersLoaded() async {
    try {
      final parameterService = Get.isRegistered<ParameterService>()
          ? Get.find<ParameterService>()
          : Get.put(ParameterService());

      if (!parameterService.isLoaded) {
        print('📊 Loading parameters after authentication...');
        await parameterService.ensureLoaded();
      }
    } catch (e) {
      print('❌ Failed to load parameters after authentication: $e');
    }
  }

  void _setInitialScreen(User? user, {bool fromAuthChange = false}) async {
    print(
        '🔄 Auth state changed: ${user != null ? "Logged in (${user.uid})" : "Logged out"}');

    // Skip if we're in the middle of signing up
    if (_isSigningUp) {
      print('⏭️ Skipping auth state handler - signup in progress');
      return;
    }

    final currentRoute = Get.currentRoute;
    print('📍 Current route: $currentRoute');

    if (user == null) {
      _biometricValidated = false;
      // User is logged out - go to login
      if (currentRoute != '/login') {
        print('🔀 Navigating to login page');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed('/login');
        });
      }
    } else {
      if (fromAuthChange) {
        _biometricValidated = false;
      }

      await _ensureParametersLoaded();
      if (shouldPromptBiometric && !_biometricValidated) {
        print('⏳ Awaiting biometric authentication before navigation');
        return;
      }
      // Check if email is verified (only for email/password users)
      final isEmailProvider =
          user.providerData.any((p) => p.providerId == 'password');

      if (isEmailProvider && !user.emailVerified) {
        print('⚠️ Email not verified - signing out');
        await _auth.signOut();

        // Show message on login page
        Future.delayed(const Duration(milliseconds: 500), () {
          if (Get.currentRoute == '/login') {
            Get.snackbar(
              'Verify Email',
              'Please verify your email before signing in. Check your inbox and spam folder.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              duration: const Duration(seconds: 5),
            );
          }
        });
        return; // Don't navigate to home
      }

      // User is logged in and verified - load data and navigate
      await loadCurrentUser(user.uid);

      // Determine target route based on role
      final targetRoute =
          currentUser.value?.role == 'admin' ? '/admin' : '/home';

      // Navigate if on splash or login or different target
      if (currentRoute == '/splash' ||
          currentRoute == '/login' ||
          currentRoute != targetRoute) {
        print('🔀 Navigating to $targetRoute');
        
        // Wait a frame to ensure GetMaterialApp is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.key.currentContext != null) {
            Get.offAllNamed(targetRoute);
          } else {
            // If still not ready, try again after a short delay
            Future.delayed(const Duration(milliseconds: 100), () {
              Get.offAllNamed(targetRoute);
            });
          }
        });
      } else {
        print('✅ Already on correct route: $targetRoute');
      }
    }
  }

  Future<void> loadCurrentUser(String uid) async {
    try {
      print('👤 Loading user from Firestore: $uid');
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        currentUser.value = UserModel.fromFirestore(doc);
        print('✅ User loaded: ${currentUser.value?.name}');
      } else {
        print('❌ User document not found in Firestore');
        print('🔧 Creating user document...');

        // Get email from Firebase Auth
        final firebaseUser = _auth.currentUser;
        if (firebaseUser != null) {
          // Create a basic user document
          final newUser = UserModel(
            uid: uid,
            email: firebaseUser.email ?? 'user@example.com',
            name: firebaseUser.displayName ??
                firebaseUser.email?.split('@')[0] ??
                'User',
            role: 'user',
            trackingActivities: [], // Empty means track all
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          // Save to Firestore
          await _firestore
              .collection('users')
              .doc(uid)
              .set(newUser.toFirestore());
          currentUser.value = newUser;
          print('✅ User document created: ${newUser.name}');
        } else {
          print('❌ Firebase user is null, cannot create document');
        }
      }
    } catch (e) {
      print('❌ Error loading user: $e');
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    String role = 'user',
  }) async {
    _isSigningUp = true; // Set flag to prevent auth listener interference

    try {
      print('📝 Starting signup for: $email');

      print('🔹 Step 1: Creating Firebase user account...');
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print(
          '✅ Step 1 complete: User account created: ${userCredential.user?.uid}');

      print('🔹 Step 2: Sending verification email...');
      if (userCredential.user != null) {
        try {
          // Wait a moment for user creation to complete
          await Future.delayed(const Duration(milliseconds: 500));

          // Send verification email WITHOUT ActionCodeSettings (to avoid plugin bug)
          await userCredential.user!.sendEmailVerification();

          print('✅ Step 2 complete: Verification email sent to $email');
          print('📧 IMPORTANT: Check SPAM/JUNK folder!');
          print('📧 Sender: noreply@[your-project-id].firebaseapp.com');
        } catch (emailError) {
          print('⚠️ Email sending error: $emailError');
          print('📧 User can request resend from login page');
          // Don't fail signup - user created successfully
        }
      }

      print('🔹 Step 3: Creating Firestore user document...');
      final userData = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        role: role,
        trackingActivities: [], // Empty means track all parameters
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData.toFirestore());
      print('✅ Step 3 complete: Firestore document created');

      print('🔹 Step 4: Signing out user until email verified...');
      await _auth.signOut();
      print('✅ Step 4 complete: User signed out');

      print('✅ Signup completed successfully!');
      print('📧 Verification email sent to: $email');
      print('⚠️ CHECK SPAM FOLDER if not received in 5 minutes!');

      _isSigningUp = false; // Clear flag
      return null; // Success
    } on FirebaseAuthException catch (e) {
      _isSigningUp = false; // Clear flag on error
      print('❌ Signup Firebase error: ${e.code} - ${e.message}');
      return getFirebaseErrorMessage(e);
    } catch (e) {
      _isSigningUp = false; // Clear flag on error
      print('❌ Signup error: $e');
      return 'An error occurred during sign up. Please try again.';
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Attempting login for: $email');

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Firebase authentication successful');

      // Check email verification
      if (!userCredential.user!.emailVerified) {
        print('⚠️ Email not verified');

        // Sign out immediately
        await _auth.signOut();

        print('❌ Login blocked - email not verified');
        return 'Please verify your email before signing in.\n\n'
            'Check your inbox (and spam folder) for the verification link.\n\n'
            'Didn\'t receive it? Try signing up again to resend the email.';
      }

      print('✅ Email verified - login successful!');
      return null; // Success
    } on FirebaseAuthException catch (e) {
      print('❌ Login Firebase error: ${e.code} - ${e.message}');
      return getFirebaseErrorMessage(e);
    } catch (e) {
      print('❌ Login error: $e');
      return 'An error occurred during login. Please try again.';
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut(); // Sign out from Google too
    await _auth.signOut();
    currentUser.value = null;
    _biometricValidated = false;
    print('👋 User signed out');
  }

  // Google Sign-In with Account Linking Detection
  Future<String?> signInWithGoogle() async {
    try {
      print('🔐 Starting Google Sign-In...');

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('❌ Google Sign-In cancelled by user');
        return 'Sign in cancelled';
      }

      print('✅ Google account selected: ${googleUser.email}');

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Try to sign in with the Google credential
      UserCredential userCredential;

      try {
        userCredential = await _auth.signInWithCredential(credential);
        print('✅ Google Sign-In successful: ${userCredential.user?.email}');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          print('⚠️ Account exists with different credential');

          final email = googleUser.email;

          // Assuming the user must have used 'password' if this specific error is returned:
          // You can modify the message to guide the user based on the certainty of the error.
          return 'An account already exists with ${email}.\n\n'
              'Please:\n'
              '1. Login with your email and password\n'
              '2. Go to Profile settings\n'
              '3. Link your Google account\n\n'
              'Then you can use either method to login.';
        }

        // Re-throw other errors
        throw e;
      }

      // Check if user document exists, create if not
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        print('📝 Creating user document for Google user');
        final userData = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          name: userCredential.user!.displayName ?? 'User',
          role: 'user',
          trackingActivities: [], // Empty means track all parameters
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userData.toFirestore());
        print('✅ User document created');
      }

      return null; // Success
    } on FirebaseAuthException catch (e) {
      print('❌ Google Sign-In Firebase error: ${e.code} - ${e.message}');
      return getFirebaseErrorMessage(e);
    } catch (e) {
      print('❌ Google Sign-In error: $e');
      return 'An error occurred during Google sign in. Please try again.';
    }
  }

  // Link Google Account (for Profile page)
  Future<String?> linkGoogleAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return 'No user logged in';
      }

      print('🔗 Linking Google account...');

      // Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return 'Sign in cancelled';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Link the credential
      await user.linkWithCredential(credential);
      print('✅ Google account linked successfully');

      return null; // Success
    } on FirebaseAuthException catch (e) {
      print('❌ Link error: ${e.code}');

      if (e.code == 'provider-already-linked') {
        return 'Google account is already linked.';
      } else if (e.code == 'credential-already-in-use') {
        return 'This Google account is already linked to another user.';
      }

      return getFirebaseErrorMessage(e);
    } catch (e) {
      print('❌ Link error: $e');
      return 'An error occurred. Please try again.';
    }
  }

  // Unlink Google Account
  Future<String?> unlinkGoogleAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return 'No user logged in';
      }

      await user.unlink('google.com');
      print('✅ Google account unlinked');

      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'no-such-provider') {
        return 'Google account is not linked.';
      }
      return getFirebaseErrorMessage(e);
    }
  }

  // Get linked providers
  List<String> getLinkedProviders() {
    final user = _auth.currentUser;
    if (user == null) return [];

    return user.providerData.map((info) => info.providerId).toList();
  }

  // Forgot Password
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('📧 Password reset email sent to $email');
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return getFirebaseErrorMessage(e);
    } catch (e) {
      return 'An error occurred. Please try again.';
    }
  }

  // Reset Password (for logged-in users)
  Future<String?> resetPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return 'No user logged in';
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
      print('✅ Password updated successfully');

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return getFirebaseErrorMessage(e);
    } catch (e) {
      return 'An error occurred. Please try again.';
    }
  }

  // Resend verification email
  Future<String?> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return 'No user logged in';
      }

      if (user.emailVerified) {
        return 'Email already verified';
      }

      // Reload user data
      await user.reload();
      final refreshedUser = _auth.currentUser;

      if (refreshedUser == null) {
        return 'User session expired';
      }

      if (refreshedUser.emailVerified) {
        return 'Email already verified';
      }

      print('📧 Resending verification email to: ${refreshedUser.email}');

      final projectId = _auth.app.options.projectId;

      await refreshedUser.sendEmailVerification(
        ActionCodeSettings(
          url: 'https://$projectId.firebaseapp.com',
          handleCodeInApp: false,
          androidInstallApp: false,
          androidMinimumVersion: '21',
        ),
      );

      print('✅ Verification email resent successfully');
      print('📧 Check spam folder!');

      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        return 'Too many requests. Please wait a few minutes before trying again.';
      }
      return getFirebaseErrorMessage(e);
    } catch (e) {
      print('❌ Resend error: $e');
      return 'An error occurred. Please try again.';
    }
  }

  // Biometric Authentication
  Future<void> _checkBiometricAvailability() async {
    try {
      final biometricsAvailable = await _localAuth.canCheckBiometrics;
      final deviceSupported = await _localAuth.isDeviceSupported();

      canCheckBiometrics.value = biometricsAvailable;
      canUseDeviceCredentials.value = deviceSupported;

      print(
          '🔐 Secure auth availability -> biometrics: $biometricsAvailable, device credentials: $deviceSupported');
    } catch (e) {
      print('❌ Error checking biometrics: $e');
      canCheckBiometrics.value = false;
      canUseDeviceCredentials.value = false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final deviceSupported = await _localAuth.isDeviceSupported();
      if (!deviceSupported) {
        print('❌ Secure authentication not supported on this device');
        return false;
      }

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      print(
          '🔐 Secure auth result: ${authenticated ? "success" : "failed"} (biometrics found: $availableBiometrics)');
      return authenticated;
    } catch (e) {
      print('❌ Biometric authentication error: $e');
      return false;
    }
  }

  bool get isLoggedIn => firebaseUser.value != null;

  String? get currentUserId => firebaseUser.value?.uid;

  void markBiometricValidated() {
    _biometricValidated = true;
    final user = firebaseUser.value;
    if (user != null) {
      _setInitialScreen(user);
    }
  }

  void resetBiometricValidation() {
    _biometricValidated = false;
  }

  // Centralized error message helper
  String getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials.';
      case 'invalid-credential':
        return 'The supplied credential is invalid or has expired.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/user_model.dart';

// class AuthService extends GetxService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   final LocalAuthentication _localAuth = LocalAuthentication();

//   Rx<User?> firebaseUser = Rx<User?>(null);
//   Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  
//   // Biometric settings
//   RxBool isBiometricEnabled = false.obs;
//   RxBool canCheckBiometrics = false.obs;
  
//   // Flag to prevent auth listener interference during signup
//   bool _isSigningUp = false;

//   @override
//   void onInit() async {
//     super.onInit();
//     try {
//       print('🔥 AuthService initializing...');
//       firebaseUser.bindStream(_auth.authStateChanges());
//       ever(firebaseUser, _setInitialScreen);
//       print('✅ Auth state listener registered');
      
//       // Check biometric availability
//       await _checkBiometricAvailability();
//       await _loadBiometricPreference();
      
//       // Fallback: If auth state doesn't fire within 3 seconds, navigate manually
//       Future.delayed(const Duration(seconds: 3), () {
//         if (Get.currentRoute == '/splash') {
//           print('⚠️ Auth state timeout - navigating from splash');
//           final user = _auth.currentUser;
//           if (user != null) {
//             print('📱 User found in cache: ${user.uid}');
//             _setInitialScreen(user);
//           } else {
//             print('📱 No user found - going to login');
//             Get.offAllNamed('/login');
//           }
//         }
//       });
//     } catch (e) {
//       print('❌ AuthService: Firebase not available - $e');
//       // Navigate to login page in preview mode
//       Future.delayed(const Duration(milliseconds: 500), () {
//         print('🔀 Navigating to login (Firebase unavailable)');
//         Get.offAllNamed('/login');
//       });
//     }
//   }

//   void _setInitialScreen(User? user) async {
//     print('🔄 Auth state changed: ${user != null ? "Logged in (${user.uid})" : "Logged out"}');
    
//     // Skip if we're in the middle of signing up
//     if (_isSigningUp) {
//       print('⏭️ Skipping auth state handler - signup in progress');
//       return;
//     }
    
//     final currentRoute = Get.currentRoute;
//     print('📍 Current route: $currentRoute');
    
//     if (user == null) {
//       // User is logged out - go to login
//       if (currentRoute != '/login') {
//         print('🔀 Navigating to login page');
//         Get.offAllNamed('/login');
//       }
//     } else {
//       // Check if email is verified (only for email/password users)
//       final isEmailProvider = user.providerData.any((p) => p.providerId == 'password');
      
//       if (isEmailProvider && !user.emailVerified) {
//         print('⚠️ Email not verified - signing out');
//         await _auth.signOut();
        
//         // Show message on login page
//         Future.delayed(const Duration(milliseconds: 500), () {
//           if (Get.currentRoute == '/login') {
//             Get.snackbar(
//               'Verify Email',
//               'Please verify your email before signing in. Check your inbox.',
//               snackPosition: SnackPosition.BOTTOM,
//               backgroundColor: Colors.orange,
//               colorText: Colors.white,
//               duration: const Duration(seconds: 5),
//             );
//           }
//         });
//         return; // Don't navigate to home
//       }
      
//       // User is logged in and verified - load data and navigate
//       await loadCurrentUser(user.uid);
      
//       // Determine target route based on role
//       final targetRoute = currentUser.value?.role == 'admin' ? '/admin' : '/home';
      
//       // Navigate if on splash or login or different target
//       if (currentRoute == '/splash' || currentRoute == '/login' || currentRoute != targetRoute) {
//         print('🔀 Navigating to $targetRoute');
//         Get.offAllNamed(targetRoute);
//       } else {
//         print('✅ Already on correct route: $targetRoute');
//       }
//     }
//   }

//   Future<void> loadCurrentUser(String uid) async {
//     try {
//       print('👤 Loading user from Firestore: $uid');
//       final doc = await _firestore.collection('users').doc(uid).get();
      
//       if (doc.exists) {
//         currentUser.value = UserModel.fromFirestore(doc);
//         print('✅ User loaded: ${currentUser.value?.name}');
//       } else {
//         print('❌ User document not found in Firestore');
//         print('🔧 Creating user document...');
        
//         // Get email from Firebase Auth
//         final firebaseUser = _auth.currentUser;
//         if (firebaseUser != null) {
//           // Create a basic user document
//           final newUser = UserModel(
//             uid: uid,
//             email: firebaseUser.email ?? 'user@example.com',
//             name: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
//             role: 'user',
//             disciples: [],
//             displayParameters: {
//               'nindra': true,
//               'wakeUp': true,
//               'daySleep': true,
//               'japa': true,
//               'pathan': true,
//               'sravan': true,
//               'seva': true,
//             },
//             createdAt: DateTime.now(),
//             updatedAt: DateTime.now(),
//           );
          
//           // Save to Firestore
//           await _firestore.collection('users').doc(uid).set(newUser.toFirestore());
//           currentUser.value = newUser;
//           print('✅ User document created: ${newUser.name}');
//         } else {
//           print('❌ Firebase user is null, cannot create document');
//         }
//       }
//     } catch (e) {
//       print('❌ Error loading user: $e');
//     }
//   }

//   Future<String?> signUp({
//     required String email,
//     required String password,
//     required String name,
//     String role = 'user',
//   }) async {
//     _isSigningUp = true; // Set flag to prevent auth listener interference
    
//     try {
//       print('📝 Starting signup for: $email');
      
//       print('🔹 Step 1: Creating Firebase user account...');
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       print('✅ Step 1 complete: User account created: ${userCredential.user?.uid}');
      
//       print('🔹 Step 2: Checking email verified status...');
//       print('📧 Email verified status: ${userCredential.user?.emailVerified}');

//       print('🔹 Step 3: Skipping automatic email send (will send on login attempt)...');
//       print('✅ Step 3 complete');

//       print('🔹 Step 4: Creating Firestore user document...');
//       final userData = UserModel(
//         uid: userCredential.user!.uid,
//         email: email,
//         name: name,
//         role: role,
//         disciples: [],
//         displayParameters: {
//           'nindra': true,
//           'wakeUp': true,
//           'daySleep': true,
//           'japa': true,
//           'pathan': true,
//           'sravan': true,
//           'seva': true,
//         },
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       );

//       await _firestore
//           .collection('users')
//           .doc(userCredential.user!.uid)
//           .set(userData.toFirestore());
//       print('✅ Step 4 complete: Firestore document created');

//       print('🔹 Step 5: Signing out user until email verified...');
//       await _auth.signOut();
//       print('✅ Step 5 complete: User signed out');
      
//       print('✅ Signup completed successfully - check your email!');
//       _isSigningUp = false; // Clear flag
//       return null; // Success
//     } on FirebaseAuthException catch (e) {
//       _isSigningUp = false; // Clear flag on error
//       return getFirebaseErrorMessage(e);
//     } catch (e) {
//       _isSigningUp = false; // Clear flag on error
//       print('❌ Signup error: $e');
//       return 'An error occurred during sign up. Please try again.';
//     }
//   }

//   Future<String?> signIn({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
      
//       // Check email verification
//       if (!userCredential.user!.emailVerified) {
//         // Send verification email if not sent yet (avoiding await to prevent platform bug)
//         print('📧 User email not verified, triggering verification email...');
//         userCredential.user!.sendEmailVerification().then((_) {
//           print('✅ Verification email sent to $email');
//         }).catchError((e) {
//           print('⚠️ Could not send verification email: $e');
//         });
        
//         await _auth.signOut();
//         return 'Email not verified. We\'ve sent a verification link to $email. Please check your inbox (and spam folder) and try again after verifying.';
//       }
      
//       return null; // Success
//     } on FirebaseAuthException catch (e) {
//       return getFirebaseErrorMessage(e);
//     } catch (e) {
//       return 'An error occurred during login. Please try again.';
//     }
//   }

//   Future<void> signOut() async {
//     await _auth.signOut();
//     currentUser.value = null;
//   }

//   // Google Sign-In
//   Future<String?> signInWithGoogle() async {
//     try {
//       print('🔐 Starting Google Sign-In...');
      
//       // Trigger Google Sign-In flow
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
//       if (googleUser == null) {
//         print('❌ Google Sign-In cancelled by user');
//         return 'Sign in cancelled';
//       }

//       // Obtain auth details from request
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//       // Create a new credential
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       // Sign in to Firebase with the Google credential
//       UserCredential userCredential = await _auth.signInWithCredential(credential);
      
//       print('✅ Google Sign-In successful: ${userCredential.user?.email}');

//       // Check if user document exists, create if not
//       final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      
//       if (!userDoc.exists) {
//         print('📝 Creating user document for Google user');
//         final userData = UserModel(
//           uid: userCredential.user!.uid,
//           email: userCredential.user!.email ?? '',
//           name: userCredential.user!.displayName ?? 'User',
//           role: 'user',
//           disciples: [],
//           displayParameters: {
//             'nindra': true,
//             'wakeUp': true,
//             'daySleep': true,
//             'japa': true,
//             'pathan': true,
//             'sravan': true,
//             'seva': true,
//           },
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         );
        
//         await _firestore
//             .collection('users')
//             .doc(userCredential.user!.uid)
//             .set(userData.toFirestore());
//       }

//       return null; // Success
//     } on FirebaseAuthException catch (e) {
//       print('❌ Google Sign-In Firebase error: ${e.message}');
//       return e.message ?? 'Google sign in failed';
//     } catch (e) {
//       print('❌ Google Sign-In error: $e');
//       return 'An error occurred during Google sign in. Please try again.';
//     }
//   }

//   // Forgot Password
//   Future<String?> sendPasswordResetEmail(String email) async {
//     try {
//       await _auth.sendPasswordResetEmail(email: email);
//       print('📧 Password reset email sent to $email');
//       return null; // Success
//     } on FirebaseAuthException catch (e) {
//       return getFirebaseErrorMessage(e);
//     } catch (e) {
//       return 'An error occurred. Please try again.';
//     }
//   }

//   // Reset Password (for logged-in users)
//   Future<String?> resetPassword({
//     required String currentPassword,
//     required String newPassword,
//   }) async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null || user.email == null) {
//         return 'No user logged in';
//       }

//       // Re-authenticate user
//       final credential = EmailAuthProvider.credential(
//         email: user.email!,
//         password: currentPassword,
//       );

//       await user.reauthenticateWithCredential(credential);
      
//       // Update password
//       await user.updatePassword(newPassword);
//       print('✅ Password updated successfully');
      
//       return null; // Success
//     } on FirebaseAuthException catch (e) {
//       return getFirebaseErrorMessage(e);
//     } catch (e) {
//       return 'An error occurred. Please try again.';
//     }
//   }

//   // Resend verification email
//   Future<String?> resendVerificationEmail() async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) {
//         return 'No user logged in';
//       }

//       if (user.emailVerified) {
//         return 'Email already verified';
//       }

//       print('📧 Resending verification email to: ${user.email}');
//       await user.sendEmailVerification();
//       print('✅ Verification email resent successfully');
      
//       return null; // Success
//     } on FirebaseAuthException catch (e) {
//       return getFirebaseErrorMessage(e);
//     } catch (e) {
//       return 'An error occurred. Please try again.';
//     }
//   }

//   // Biometric Authentication
//   Future<void> _checkBiometricAvailability() async {
//     try {
//       canCheckBiometrics.value = await _localAuth.canCheckBiometrics;
//       print('🔐 Biometrics available: ${canCheckBiometrics.value}');
//     } catch (e) {
//       print('❌ Error checking biometrics: $e');
//       canCheckBiometrics.value = false;
//     }
//   }

//   Future<void> _loadBiometricPreference() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       isBiometricEnabled.value = prefs.getBool('biometric_enabled') ?? false;
//       print('🔐 Biometric enabled: ${isBiometricEnabled.value}');
//     } catch (e) {
//       print('❌ Error loading biometric preference: $e');
//     }
//   }

//   Future<void> setBiometricEnabled(bool enabled) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('biometric_enabled', enabled);
//       isBiometricEnabled.value = enabled;
//       print('🔐 Biometric ${enabled ? "enabled" : "disabled"}');
//     } catch (e) {
//       print('❌ Error setting biometric preference: $e');
//     }
//   }

//   Future<bool> authenticateWithBiometrics() async {
//     try {
//       if (!canCheckBiometrics.value) {
//         print('❌ Biometrics not available');
//         return false;
//       }

//       final authenticated = await _localAuth.authenticate(
//         localizedReason: 'Please authenticate to access the app',
//         options: const AuthenticationOptions(
//           stickyAuth: true,
//           biometricOnly: false, // Allows PIN/pattern as fallback
//         ),
//       );

//       print('🔐 Biometric authentication: ${authenticated ? "success" : "failed"}');
//       return authenticated;
//     } catch (e) {
//       print('❌ Biometric authentication error: $e');
//       return false;
//     }
//   }

//   bool get isLoggedIn => firebaseUser.value != null;
  
//   String? get currentUserId => firebaseUser.value?.uid;
  
//   // Centralized error message helper
//   String getFirebaseErrorMessage(FirebaseAuthException e) {
//     switch (e.code) {
//       case 'invalid-email':
//         return 'Invalid email format.';
//       case 'user-not-found':
//         return 'No account found with this email.';
//       case 'wrong-password':
//         return 'Incorrect password.';
//       case 'email-already-in-use':
//         return 'An account already exists with this email.';
//       case 'weak-password':
//         return 'Password is too weak. Use at least 6 characters.';
//       case 'too-many-requests':
//         return 'Too many attempts. Please try again later.';
//       case 'user-disabled':
//         return 'This account has been disabled.';
//       case 'operation-not-allowed':
//         return 'This sign-in method is not enabled.';
//       case 'account-exists-with-different-credential':
//         return 'An account already exists with the same email but different sign-in credentials.';
//       default:
//         return e.message ?? 'An authentication error occurred.';
//     }
//   }
// }
