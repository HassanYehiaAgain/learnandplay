import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Import Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learn_play_level_up_flutter/firebase_init.dart';

import 'package:learn_play_level_up_flutter/pages/create_game_page.dart';
import 'package:learn_play_level_up_flutter/pages/game_library_page.dart';
import 'package:learn_play_level_up_flutter/pages/game_page.dart';
import 'package:learn_play_level_up_flutter/pages/home_page.dart';
import 'package:learn_play_level_up_flutter/pages/not_found_page.dart';
import 'package:learn_play_level_up_flutter/pages/register_page.dart';
import 'package:learn_play_level_up_flutter/pages/sign_in_page.dart';
import 'package:learn_play_level_up_flutter/pages/student_page.dart';
import 'package:learn_play_level_up_flutter/pages/teacher_page.dart';
import 'package:learn_play_level_up_flutter/router/app_router.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';
import 'package:learn_play_level_up_flutter/theme/theme_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:learn_play_level_up_flutter/services/auth_service.dart';
import 'package:learn_play_level_up_flutter/services/firebase_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:learn_play_level_up_flutter/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase using our centralizing initializer
  final firebaseInitializer = FirebaseInitializer();
  bool firebaseInitialized = await firebaseInitializer.initialize();
  
  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();
  
  if (!firebaseInitialized) {
    print('Warning: Firebase initialization failed. Some features may not work correctly.');
    // You could show a special UI or handle this differently in a production app
  }
  
  runApp(
    provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => AuthService()),
        provider.Provider<FirebaseService>(create: (_) => FirebaseService()),
        provider.Provider(create: (_) => LocalStorageService(prefs)),
      ],
      child: const ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}

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
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
