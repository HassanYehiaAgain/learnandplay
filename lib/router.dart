import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Auth
import 'features/auth/welcome_page.dart';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';

// Dashboard
import 'features/dashboard/dashboard_gate.dart';

// Games
import 'features/games/game_create_page.dart';
import 'features/games/game_play_page.dart';
import 'features/games/student_browse_games_page.dart';
import 'features/games/teacher_game_students_page.dart';

// Profile
import 'features/profile/profile_edit_page.dart';

// Placeholder widget for screens to be created later
class PlaceholderScreen extends StatelessWidget {
  final String title;
  
  const PlaceholderScreen({super.key, required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('$title Screen'),
      ),
    );
  }
}

// App router configuration
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Auth routes
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) {
        final role = state.uri.queryParameters['role'] ?? 'student';
        return RegisterPage(role: role);
      },
    ),

    // Dashboard route
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardGate(),
    ),

    // Game routes
    GoRoute(
      path: '/games/browse',
      builder: (context, state) => const StudentBrowseGamesPage(),
    ),
    GoRoute(
      path: '/game/create',
      builder: (context, state) => const GameCreatePage(),
    ),
    GoRoute(
      path: '/game/:id',
      builder: (context, state) {
        final gameId = state.pathParameters['id'] ?? '';
        return GamePlayPage(gameId: gameId);
      },
    ),
    GoRoute(
      path: '/game/:id/students',
      builder: (context, state) {
        final gameId = state.pathParameters['id'] ?? '';
        return TeacherGameStudentsPage(gameId: gameId);
      },
    ),

    // Profile route
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const ProfileEditPage(),
    ),
  ],
);