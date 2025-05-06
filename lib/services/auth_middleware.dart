import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Authentication middleware for route guarding
class AuthRequiredGuard {
  /// Checks if user is authenticated, redirects to sign in if not
  static Future<String?> canNavigate(BuildContext context, GoRouterState state) async {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    if (!isLoggedIn) {
      return '/signin';
    }
    return null;
  }
}

/// Student role middleware for route guarding
class StudentRoleGuard {
  /// Checks if user is authenticated and has student role
  static Future<String?> canNavigate(BuildContext context, GoRouterState state) async {
    final user = FirebaseAuth.instance.currentUser;
    
    // Not logged in
    if (user == null) {
      return '/signin';
    }
    
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (!userDoc.exists) {
        return '/unauthorized';
      }
      
      final role = userDoc.data()?['role'] as String?;
      
      // Not a student
      if (role != 'student') {
        return '/unauthorized';
      }
      
      // Has proper role, allow navigation
      return null;
    } catch (e) {
      debugPrint('Error in StudentRoleGuard: $e');
      return '/unauthorized';
    }
  }
}

/// Teacher role middleware for route guarding
class TeacherRoleGuard {
  /// Checks if user is authenticated and has teacher role
  static Future<String?> canNavigate(BuildContext context, GoRouterState state) async {
    final user = FirebaseAuth.instance.currentUser;
    
    // Not logged in
    if (user == null) {
      return '/signin';
    }
    
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (!userDoc.exists) {
        return '/unauthorized';
      }
      
      final role = userDoc.data()?['role'] as String?;
      
      // Not a teacher
      if (role != 'teacher') {
        return '/unauthorized';
      }
      
      // Has proper role, allow navigation
      return null;
    } catch (e) {
      debugPrint('Error in TeacherRoleGuard: $e');
      return '/unauthorized';
    }
  }
} 