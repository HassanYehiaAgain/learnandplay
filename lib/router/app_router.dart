import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_play_level_up_flutter/pages/create_game_page.dart';
import 'package:learn_play_level_up_flutter/pages/game_library_page.dart';
import 'package:learn_play_level_up_flutter/pages/game_page.dart';
import 'package:learn_play_level_up_flutter/pages/home_page.dart';
import 'package:learn_play_level_up_flutter/pages/not_found_page.dart';
import 'package:learn_play_level_up_flutter/pages/profile_page.dart';
import 'package:learn_play_level_up_flutter/pages/register_page.dart';
import 'package:learn_play_level_up_flutter/pages/reward_screen.dart';
import 'package:learn_play_level_up_flutter/pages/sign_in_page.dart';
import 'package:learn_play_level_up_flutter/pages/student_game_page.dart';
import 'package:learn_play_level_up_flutter/pages/student_page.dart';
import 'package:learn_play_level_up_flutter/pages/subject_management_page.dart';
import 'package:learn_play_level_up_flutter/pages/teacher_page.dart';
import 'package:learn_play_level_up_flutter/pages/unauthorized_page.dart';
import 'package:learn_play_level_up_flutter/pages/teacher/teacher_analytics_dashboard.dart';
import 'package:learn_play_level_up_flutter/pages/student/student_analytics_page.dart';
import 'package:learn_play_level_up_flutter/pages/game_templates/game_templates_selection_page.dart';
import 'package:learn_play_level_up_flutter/pages/game_templates/word_scramble_creation_page.dart';
import 'package:learn_play_level_up_flutter/pages/game_templates/word_search_creation_page.dart';
import 'package:learn_play_level_up_flutter/pages/game_templates/template_creation_base_page.dart';
import 'package:learn_play_level_up_flutter/services/auth_middleware.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';

// Add imports for profile edit pages
import 'package:learn_play_level_up_flutter/pages/teacher/teacher_profile_edit.dart';
import 'package:learn_play_level_up_flutter/pages/student/student_profile_edit.dart';
// Add import for quiz show template
import 'package:learn_play_level_up_flutter/pages/game_templates/quiz_show_creation_page.dart';
// Add import for word guess template
import 'package:learn_play_level_up_flutter/pages/game_templates/word_guess_creation_page.dart';
import 'package:learn_play_level_up_flutter/pages/game_templates/fill_in_the_blank_creation_page.dart';
import 'package:learn_play_level_up_flutter/pages/game_templates/flashcard_game_creation_page.dart';
import 'package:learn_play_level_up_flutter/pages/game_templates/sorting_game_creation_page.dart';
import 'package:learn_play_level_up_flutter/pages/game_templates/general_quiz_creation_page.dart';

// Create a router provider that can be used throughout the app
class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) async {
      // Handle any global redirects if needed
      return null;
    },
    routes: [
      // Public routes (no authentication required)
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
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
        path: '/unauthorized',
        builder: (context, state) => const UnauthorizedPage(),
      ),
      
      // Routes that require authentication (any role)
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
        redirect: (context, state) => AuthRequiredGuard.canNavigate(context, state),
      ),
      GoRoute(
        path: '/games/:gameId',
        builder: (context, state) => GamePage(
          gameId: state.pathParameters['gameId'] ?? '',
        ),
        redirect: (context, state) => AuthRequiredGuard.canNavigate(context, state),
      ),
      
      // Subject management - available to both roles
      GoRoute(
        path: '/subjects',
        builder: (context, state) => const SubjectManagementPage(),
        redirect: (context, state) => AuthRequiredGuard.canNavigate(context, state),
      ),
      
      // Student-specific routes
      GoRoute(
        path: '/student/dashboard',
        builder: (context, state) => const StudentPage(),
        redirect: (context, state) => StudentRoleGuard.canNavigate(context, state),
      ),
      GoRoute(
        path: '/student/games',
        builder: (context, state) => const GameLibraryPage(),
        redirect: (context, state) => StudentRoleGuard.canNavigate(context, state),
      ),
      GoRoute(
        path: '/student/analytics',
        builder: (context, state) => const StudentAnalyticsPage(),
        redirect: (context, state) => StudentRoleGuard.canNavigate(context, state),
      ),
      GoRoute(
        path: '/student/games/:gameId/play',
        builder: (context, state) => StudentGamePage(
          gameId: state.pathParameters['gameId'] ?? '',
          gameType: state.uri.queryParameters['type'] ?? 'quiz',
        ),
        redirect: (context, state) => StudentRoleGuard.canNavigate(context, state),
      ),
      GoRoute(
        path: '/reward',
        builder: (context, state) {
          final Map<String, dynamic> args = state.extra as Map<String, dynamic>;
          return RewardScreen(
            gameTitle: args['gameTitle'] as String,
            score: args['score'] as int,
            maxScore: args['maxScore'] as int,
          );
        },
        redirect: (context, state) => StudentRoleGuard.canNavigate(context, state),
      ),
      
      // Teacher-specific routes
      GoRoute(
        path: '/teacher/dashboard',
        builder: (context, state) => const TeacherPage(),
        redirect: (context, state) => TeacherRoleGuard.canNavigate(context, state),
      ),
      GoRoute(
        path: '/teacher/analytics',
        builder: (context, state) => const TeacherAnalyticsDashboard(),
        redirect: (context, state) => TeacherRoleGuard.canNavigate(context, state),
      ),
      GoRoute(
        path: '/teacher/games',
        builder: (context, state) => const GameLibraryPage(),
        redirect: (context, state) => TeacherRoleGuard.canNavigate(context, state),
      ),
      GoRoute(
        path: '/teacher/games/create',
        builder: (context, state) => const CreateGamePage(),
        redirect: (context, state) => TeacherRoleGuard.canNavigate(context, state),
      ),
      // Game Templates routes
      GoRoute(
        path: '/teacher/games/templates',
        builder: (context, state) => const GameTemplatesSelectionPage(),
        redirect: (context, state) => TeacherRoleGuard.canNavigate(context, state),
      ),
      // Generic template route that handles all template types
      GoRoute(
        path: '/teacher/games/templates/:templateType',
        builder: (context, state) {
          final templateType = state.pathParameters['templateType'] ?? 'custom';
          // Map template types to their dedicated creation pages
          switch (templateType) {
            case 'word_scramble':
              return const WordScrambleCreationPage();
            case 'quiz_show':
              return const QuizShowCreationPage();
            case 'word_guess':
              return const WordGuessCreationPage();
            case 'fill_in_the_blank':
              return const FillInTheBlankCreationPage();
            case 'flashcard_game':
              return const FlashcardGameCreationPage();
            case 'sorting_game':
              return const SortingGameCreationPage();
            case 'general_quiz':
              return const GeneralQuizCreationPage();
            // TODO: Add cases for matching_pairs, memory_flip_cards, drag_drop_categories, true_false, etc. if implemented
            default:
              // Fallback to generic template creation page
              final templates = UniversalGameTemplateInfo.getAllTemplates();
              final templateInfo = templates.firstWhere(
                (t) => t.type == templateType,
                orElse: () => templates.last,
              );
              return TemplateCreationBasePage(
                type: templateInfo.type,
                title: templateInfo.title,
                icon: templateInfo.icon,
                color: templateInfo.color,
              );
          }
        },
        redirect: (context, state) => TeacherRoleGuard.canNavigate(context, state),
      ),
      // Add student profile edit route after student dashboard route:
      GoRoute(
        path: '/student/profile/edit',
        builder: (context, state) => const StudentProfileEditPage(),
        redirect: (context, state) => StudentRoleGuard.canNavigate(context, state),
      ),
      // Add teacher profile edit route:
      GoRoute(
        path: '/teacher/profile/edit',
        builder: (context, state) => const TeacherProfileEditPage(),
        redirect: (context, state) => TeacherRoleGuard.canNavigate(context, state),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
} 