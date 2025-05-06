import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'teacher_dashboard.dart';
import 'student_dashboard.dart';

class DashboardGate extends StatefulWidget {
  const DashboardGate({super.key});

  @override
  State<DashboardGate> createState() => _DashboardGateState();
}

class _DashboardGateState extends State<DashboardGate> {
  bool _isLoading = true;
  String _error = '';
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _determineUserRole();
  }

  Future<void> _determineUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        setState(() {
          _isLoading = false;
          _error = 'No user is logged in.';
        });
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        setState(() {
          _isLoading = false;
          _error = 'User profile not found.';
        });
        return;
      }

      // Determine which dashboard to show based on role
      final role = userDoc.data()?['role'] as String?;
      setState(() {
        _isLoading = false;
        _userRole = role;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Error loading user data: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard Error'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  _error,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    context.go('/');
                  },
                  child: const Text('Go Back to Welcome'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Route to the appropriate dashboard based on user role
    if (_userRole == 'teacher') {
      return const TeacherDashboard();
    } else if (_userRole == 'student') {
      return const StudentDashboard();
    } else {
      // Unknown role
      return Scaffold(
        appBar: AppBar(
          title: const Text('Unknown Role'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.help_outline,
                  color: Colors.orange,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Unknown user role: $_userRole',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    context.go('/');
                  },
                  child: const Text('Go Back to Welcome'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
} 