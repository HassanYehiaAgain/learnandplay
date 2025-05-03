import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// Import our interop patch before Firebase imports
import 'package:learn_play_level_up_flutter/interop_patch.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learn_play_level_up_flutter/firebase_config.dart';
import 'package:learn_play_level_up_flutter/pages/create_game_page.dart';
import 'package:learn_play_level_up_flutter/pages/game_library_page.dart';
import 'package:learn_play_level_up_flutter/pages/game_page.dart';
import 'package:learn_play_level_up_flutter/pages/home_page.dart';
import 'package:learn_play_level_up_flutter/pages/not_found_page.dart';
import 'package:learn_play_level_up_flutter/pages/register_page.dart';
import 'package:learn_play_level_up_flutter/pages/sign_in_page.dart';
import 'package:learn_play_level_up_flutter/pages/student_page.dart';
import 'package:learn_play_level_up_flutter/pages/teacher_page.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';
import 'package:learn_play_level_up_flutter/theme/theme_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:learn_play_level_up_flutter/services/auth_service.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditionally import firebase_options.dart
import 'firebase_options.dart' if (kIsWeb) 'package:flutter/material.dart' as firebase_options;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase initialization with web support
  try {
    if (kIsWeb) {
      // Web-specific Firebase initialization
      await Firebase.initializeApp(
        options: FirebaseConfig.webOptions,
      );
    } else {
      // Mobile/desktop initialization
      await Firebase.initializeApp();
    }
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
    // Continue without Firebase for now
  }
  
  runApp(
    provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const ProviderScope(
        child: MyApp(),
      ),
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
      path: '/games',
      builder: (context, state) => const GameLibraryPage(),
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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current theme mode from the provider
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp.router(
      title: 'Learn, Play, Level Up',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
