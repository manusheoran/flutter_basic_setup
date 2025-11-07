import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> firebaseUser = Rx<User?>(null);
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    try {
      print('🔥 AuthService initializing...');
      firebaseUser.bindStream(_auth.authStateChanges());
      ever(firebaseUser, _setInitialScreen);
      print('✅ Auth state listener registered');
      
      // Fallback: If auth state doesn't fire within 3 seconds, navigate manually
      Future.delayed(const Duration(seconds: 3), () {
        if (Get.currentRoute == '/splash') {
          print('⚠️ Auth state timeout - navigating from splash');
          final user = _auth.currentUser;
          if (user != null) {
            print('📱 User found in cache: ${user.uid}');
            _setInitialScreen(user);
          } else {
            print('📱 No user found - going to login');
            Get.offAllNamed('/login');
          }
        }
      });
    } catch (e) {
      print('❌ AuthService: Firebase not available - $e');
      // Navigate to login page in preview mode
      Future.delayed(const Duration(milliseconds: 500), () {
        print('🔀 Navigating to login (Firebase unavailable)');
        Get.offAllNamed('/login');
      });
    }
  }

  void _setInitialScreen(User? user) async {
    print('🔄 Auth state changed: ${user != null ? "Logged in (${user.uid})" : "Logged out"}');
    
    final currentRoute = Get.currentRoute;
    print('📍 Current route: $currentRoute');
    
    if (user == null) {
      // User is logged out - go to login
      if (currentRoute != '/login') {
        print('🔀 Navigating to login page');
        Get.offAllNamed('/login');
      }
    } else {
      // User is logged in - load data and navigate
      await loadCurrentUser(user.uid);
      
      // Determine target route based on role
      final targetRoute = currentUser.value?.role == 'admin' ? '/admin' : '/home';
      
      // Navigate if on splash or login or different target
      if (currentRoute == '/splash' || currentRoute == '/login' || currentRoute != targetRoute) {
        print('🔀 Navigating to $targetRoute');
        Get.offAllNamed(targetRoute);
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
            name: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
            role: 'user',
            disciples: [],
            displayParameters: {
              'nindra': true,
              'wakeUp': true,
              'daySleep': true,
              'japa': true,
              'pathan': true,
              'sravan': true,
              'seva': true,
            },
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          // Save to Firestore
          await _firestore.collection('users').doc(uid).set(newUser.toFirestore());
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
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      final userData = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        role: role,
        disciples: [],
        displayParameters: {
          'nindra': true,
          'wakeUp': true,
          'daySleep': true,
          'japa': true,
          'pathan': true,
          'sravan': true,
          'seva': true,
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData.toFirestore());

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Sign up failed';
    } catch (e) {
      return 'An error occurred during sign up. Please try again.';
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed';
    } catch (e) {
      return 'An error occurred during login. Please try again.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    currentUser.value = null;
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  bool get isLoggedIn => firebaseUser.value != null;
  
  String? get currentUserId => firebaseUser.value?.uid;
}
