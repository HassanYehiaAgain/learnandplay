import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';

// This is the gate component
class StudentDashboardGate extends ConsumerWidget {
  const StudentDashboardGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser == null) {
      // not signed in → go to welcome/login
      context.go('/');
      return const SizedBox.shrink();
    }
    // else push into the real dashboard with the proper constructor
    return StudentDashboard(key: const ValueKey('student_dashboard'), userId: fbUser.uid);
  }
}

// This is the actual dashboard implementation
class StudentDashboard extends ConsumerStatefulWidget {
  final String? userId;
  
  const StudentDashboard({super.key, this.userId});
  
  @override
  ConsumerState<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends ConsumerState<StudentDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard', 
          style: TextStyle(fontFamily: 'RetroPixel')),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/profile/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              context.go('/');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome, Student!', 
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                fontFamily: 'RetroPixel'
              )
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.push('/games/browse'),
              child: const Text('Browse Games', 
                style: TextStyle(fontFamily: 'RetroPixel')),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/games/history'),
              child: const Text('My Game History', 
                style: TextStyle(fontFamily: 'RetroPixel')),
            ),
          ],
        ),
      ),
    );
  }
}