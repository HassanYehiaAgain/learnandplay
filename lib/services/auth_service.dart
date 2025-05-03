import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learn_play_level_up_flutter/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  String? _token;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _currentUser != null;

  AuthService() {
    // Try to load user session on initialization
    loadUserFromStorage();
    
    // Listen to Firebase auth state changes
    _firebaseAuth.authStateChanges().listen((firebase_auth.User? firebaseUser) {
      if (firebaseUser != null) {
        _fetchUserFromFirestore(firebaseUser.uid);
      } else {
        _currentUser = null;
        _token = null;
        notifyListeners();
      }
    });
  }

  // Load user data from local storage
  Future<void> loadUserFromStorage() async {
    try {
      _token = await _secureStorage.read(key: 'auth_token');
      
      if (_token != null) {
        final prefs = await SharedPreferences.getInstance();
        final String? userData = prefs.getString('user_data');
        
        if (userData != null) {
          final Map<String, dynamic> userMap = jsonDecode(userData);
          _currentUser = User(
            id: userMap['id'], 
            email: userMap['email'], 
            name: userMap['name'], 
            role: userMap['role'],
            createdAt: DateTime.parse(userMap['createdAt']),
            avatar: userMap['avatar'],
          );
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserFromFirestore(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      
      if (docSnapshot.exists) {
        final userData = docSnapshot.data()!;
        
        _currentUser = User(
          id: uid,
          email: userData['email'] ?? '',
          name: userData['name'] ?? '',
          role: userData['role'] ?? 'student',
          createdAt: userData['createdAt']?.toDate() ?? DateTime.now(),
          avatar: userData['avatar'] ?? '',
        );
        
        // Get token
        _token = await _firebaseAuth.currentUser?.getIdToken();
        
        // Save token securely
        if (_token != null) {
          await _secureStorage.write(key: 'auth_token', value: _token);
          
          // Save user data in SharedPreferences for quick access
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', jsonEncode({
            'id': _currentUser!.id,
            'email': _currentUser!.email,
            'name': _currentUser!.name,
            'role': _currentUser!.role,
            'createdAt': _currentUser!.createdAt.toIso8601String(),
            'avatar': _currentUser!.avatar,
          }));
        }
        
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error fetching user data: $e';
      debugPrint(_error);
    }
  }

  // Sign in user
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        await _fetchUserFromFirestore(userCredential.user!.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to sign in';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      _error = _getFirebaseAuthErrorMessage(e.code);
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error signing in: $e';
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register new user
  Future<bool> register(String name, String email, String password, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Create user in Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Create user document in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'name': name,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          'avatar': '',
        });
        
        // Wait a moment for Firestore to update
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Fetch user data from Firestore
        await _fetchUserFromFirestore(userCredential.user!.uid);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to register';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      _error = _getFirebaseAuthErrorMessage(e.code);
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error registering: $e';
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out user
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      
      // Clear secure storage
      await _secureStorage.delete(key: 'auth_token');
      
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      
      // Clear local state
      _token = null;
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error signing out: $e';
      debugPrint(_error);
    }
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    if (_currentUser == null) return false;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // Update user document in Firestore
      await _firestore.collection('users').doc(_currentUser!.id).update(userData);
      
      // Fetch updated user data
      await _fetchUserFromFirestore(_currentUser!.id);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error updating profile: $e';
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Helper method to get readable error messages
  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication error: $code';
    }
  }
} 