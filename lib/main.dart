import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learn_play_level_up_flutter/pages/create_game_page.dart';
import 'package:learn_play_level_up_flutter/pages/game_page.dart';
import 'package:learn_play_level_up_flutter/pages/home_page.dart';
import 'package:learn_play_level_up_flutter/pages/not_found_page.dart';
import 'package:learn_play_level_up_flutter/pages/register_page.dart';
import 'package:learn_play_level_up_flutter/pages/sign_in_page.dart';
import 'package:learn_play_level_up_flutter/pages/student_page.dart';
import 'package:learn_play_level_up_flutter/pages/teacher_page.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/student/dashboard',
      builder: (context, state) => const StudentPage(),
    ),
    GoRoute(
      path: '/teacher/dashboard',
      builder: (context, state) => const TeacherPage(),
    ),
    GoRoute(
      path: '/games/:gameId',
      builder: (context, state) => GamePage(
        gameId: state.pathParameters['gameId'] ?? '',
      ),
    ),
    GoRoute(
      path: '/signin',
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/teacher/games/create',
      builder: (context, state) => const CreateGamePage(),
    ),
  ],
  errorBuilder: (context, state) => const NotFoundPage(),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Learn, Play, Level Up',
      theme: ThemeData(
        colorScheme: lightColorScheme,
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      darkTheme: ThemeData(
        colorScheme: darkColorScheme,
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
