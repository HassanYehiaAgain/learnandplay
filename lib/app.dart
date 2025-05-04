import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learn_play_level_up_flutter/services/game_templates_provider.dart';
import 'package:learn_play_level_up_flutter/providers/accessibility_provider.dart';
import 'package:learn_play_level_up_flutter/providers/game_analytics_provider.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/screens/teacher/game_templates/drag_drop_categories_creation_screen.dart';
import 'package:learn_play_level_up_flutter/screens/teacher/game_templates/true_false_creation_screen.dart';
import 'package:learn_play_level_up_flutter/screens/student/games/drag_drop_categories_game_screen.dart';
import 'package:learn_play_level_up_flutter/screens/student/games/true_false_game_screen.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GameTemplatesProvider()),
            ChangeNotifierProvider(create: (_) => GameAnalyticsProvider()),
            ChangeNotifierProvider(
              create: (_) => AccessibilityProvider(snapshot.data!),
            ),
          ],
          child: Consumer<AccessibilityProvider>(
            builder: (context, accessibility, _) {
              return MaterialApp(
                title: 'Learn & Play',
                theme: accessibility.getThemeData(ThemeData(
                  primarySwatch: Colors.blue,
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                )),
                routes: {
                  '/teacher/games/templates/drag_drop_categories': (context) => 
                      const DragDropCategoriesCreationScreen(),
                  '/teacher/games/templates/true_false': (context) => 
                      const TrueFalseCreationScreen(),
                  '/student/games/drag_drop_categories': (context) => 
                      DragDropCategoriesGameScreen(
                        game: ModalRoute.of(context)!.settings.arguments 
                            as DragDropCategoriesGame,
                      ),
                  '/student/games/true_false': (context) => TrueFalseGameScreen(
                    game: ModalRoute.of(context)!.settings.arguments 
                        as TrueFalseGame,
                  ),
                },
              );
            },
          ),
        );
      },
    );
  }
} 