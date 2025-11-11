import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'core/my_app.dart';
import 'data/services/auth_service.dart';
import 'data/services/firestore_service.dart';
import 'data/services/parameter_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool firebaseInitialized = false;
  
  try {
    print('🚀 Initializing Firebase...');
    // Initialize Firebase with generated options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    print('✅ Firebase Core initialized');
    
    // Initialize GetX services
    await Get.putAsync(() async => AuthService());
    Get.put(FirestoreService());
    
    // Initialize and load parameters
    final parameterService = Get.put(ParameterService());
    await parameterService.loadParameters();
    
    firebaseInitialized = true;
    print('✅ All services initialized successfully');
  } catch (e, stackTrace) {
    print('❌ Firebase initialization failed: $e');
    print('Stack trace: $stackTrace');
    print('📱 Running app without Firebase (UI preview mode)');
    
    // Create a fallback navigation handler
    Future.delayed(const Duration(seconds: 1), () {
      if (Get.currentRoute == '/splash') {
        print('⚠️ Firebase unavailable - navigating to login');
        Get.offAllNamed('/login');
      }
    });
  }
  
  print('🎯 Starting app... Firebase: ${firebaseInitialized ? "✅" : "❌"}');
  runApp(const MyApp());
}