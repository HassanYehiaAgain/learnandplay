import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:learn_play_level_up_flutter/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  String? _token;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String _baseUrl = 'https://api.example.com'; // Replace with actual API URL
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _currentUser != null;

  AuthService() {
    // Try to load user session on initialization
    loadUserFromStorage();
  }

  // Load user from secure storage
  Future<void> loadUserFromStorage() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Get token from secure storage
      final token = await _secureStorage.read(key: 'auth_token');
      if (token != null) {
        _token = token;
        
        // Get user data from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final userData = prefs.getString('user_data');
        
        if (userData != null) {
          final Map<String, dynamic> userMap = jsonDecode(userData);
          // For simplicity, we're not using the generated User.fromJson here
          _currentUser = User(
            id: userMap['id'], 
            email: userMap['email'], 
            name: userMap['name'], 
            role: userMap['role'],
            createdAt: DateTime.parse(userMap['createdAt']),
            avatar: userMap['avatar'],
          );
        } else {
          // If we have a token but no user data, fetch the user data
          await fetchUserProfile();
        }
      }
    } catch (e) {
      _error = 'Failed to load user session: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in user
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _token = data['token'];
        
        // Save token securely
        await _secureStorage.write(key: 'auth_token', value: _token);
        
        // Create user object
        // For simplicity, we're not using the generated User.fromJson here
        _currentUser = User(
          id: data['user']['id'], 
          email: data['user']['email'], 
          name: data['user']['name'], 
          role: data['user']['role'],
          createdAt: DateTime.parse(data['user']['createdAt']),
          avatar: data['user']['avatar'],
        );
        
        // Save user data in SharedPreferences for quick access
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data['user']));
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to sign in';
        _isLoading = false;
        notifyListeners();
        return false;
      }
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
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );
      
      if (response.statusCode == 201) {
        // Registration successful, now sign in
        return await signIn(email, password);
      } else {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to register';
        _isLoading = false;
        notifyListeners();
        return false;
      }
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

  // Fetch user profile
  Future<void> fetchUserProfile() async {
    if (_token == null) return;
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/profile'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // For simplicity, we're not using the generated User.fromJson here
        _currentUser = User(
          id: data['id'], 
          email: data['email'], 
          name: data['name'], 
          role: data['role'],
          createdAt: DateTime.parse(data['createdAt']),
          avatar: data['avatar'],
        );
        
        // Save user data in SharedPreferences for quick access
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data));
        
        notifyListeners();
      } else if (response.statusCode == 401) {
        // Token expired or invalid, sign out
        await signOut();
      }
    } catch (e) {
      _error = 'Error fetching user profile: $e';
      debugPrint(_error);
    }
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    if (_token == null || _currentUser == null) return false;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/users/${_currentUser!.id}'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userData),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Update current user
        _currentUser = User(
          id: data['id'], 
          email: data['email'], 
          name: data['name'], 
          role: data['role'],
          createdAt: DateTime.parse(data['createdAt']),
          avatar: data['avatar'],
        );
        
        // Update stored user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data));
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to update profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error updating profile: $e';
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
} 