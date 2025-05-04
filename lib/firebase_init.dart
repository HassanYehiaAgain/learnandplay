import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:learn_play_level_up_flutter/firebase_options.dart';

/// A class responsible for initializing all Firebase services
class FirebaseInitializer {
  static final FirebaseInitializer _instance = FirebaseInitializer._internal();
  
  /// Factory constructor to return the same instance
  factory FirebaseInitializer() {
    return _instance;
  }
  
  FirebaseInitializer._internal();
  
  bool _initialized = false;
  String? _errorMessage;
  
  /// Check if Firebase has been successfully initialized
  bool get isInitialized => _initialized;
  
  /// Get any error message from initialization
  String? get errorMessage => _errorMessage;
  
  /// Initialize all Firebase services
  Future<bool> initialize() async {
    if (_initialized) return true;
    
    try {
      // Initialize Firebase core
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Set up Firestore settings
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      
      // Set up Auth persistence
      if (kIsWeb) {
        await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
      }
      
      _initialized = true;
      _errorMessage = null;
      
      print('Firebase services initialized successfully');
      return true;
    } catch (e) {
      _initialized = false;
      _errorMessage = 'Failed to initialize Firebase: $e';
      
      print('Error initializing Firebase: $e');
      return false;
    }
  }
  
  /// Check Firestore connection
  Future<bool> checkFirestoreConnection() async {
    if (!_initialized) return false;
    
    try {
      // Try a simple read operation as a connectivity test
      final testRef = FirebaseFirestore.instance.collection('app_settings').doc('connection_test');
      await testRef.get();
      return true;
    } catch (e) {
      print('Firestore connection test failed: $e');
      return false;
    }
  }
  
  /// Apply security rules via admin SDK (only for development purposes)
  Future<void> applySecurityRules() async {
    // This function would normally be implemented in a Firebase function
    // or a server-side admin application. Security rules are typically
    // deployed with the Firebase CLI or through the console.
    print('Security rules should be deployed using Firebase CLI: firebase deploy --only firestore:rules,storage:rules');
  }
} 