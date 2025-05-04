import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';
import 'package:learn_play_level_up_flutter/components/student/achievement_showcase.dart';
import 'package:learn_play_level_up_flutter/components/student/trophy_case.dart';
import 'package:learn_play_level_up_flutter/components/student/subject_progress.dart';
import 'package:learn_play_level_up_flutter/components/student/game_progress.dart';
import 'package:learn_play_level_up_flutter/components/student/weekly_schedule.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  bool _isLoading = true;
  
  // Mock data
  final List<Map<String, dynamic>> _assignedGames = [
    {
      'title': 'Math Challenge',
      'subject': 'Mathematics',
      'icon': Icons.calculate,
      'color': Colors.blue,
      'dueDate': 'Oct 25',
      'isNew': true,
    },
    {
      'title': 'Vocabulary Quest',
      'subject': 'Language Arts',
      'icon': Icons.menu_book,
      'color': Colors.purple,
      'dueDate': 'Oct 28',
    },
    {
      'title': 'Science Explorer',
      'subject': 'Science',
      'icon': Icons.science,
      'color': Colors.green,
      'isOverdue': true,
      'dueDate': 'Oct 15',
    },
  ];
  
  final List<Map<String, dynamic>> _inProgressGames = [
    {
      'title': 'Math Challenge',
      'progress': 0.75,
      'lastPlayed': 'Yesterday',
      'icon': Icons.calculate,
      'color': Colors.blue,
    },
    {
      'title': 'Vocabulary Quest',
      'progress': 0.45,
      'lastPlayed': '2 days ago',
      'icon': Icons.menu_book,
      'color': Colors.purple,
    },
  ];
  
  final List<Map<String, dynamic>> _subjects = [
    {
      'name': 'Mathematics',
      'icon': Icons.calculate,
      'color': Colors.blue,
      'progress': 0.65,
      'completedLessons': 13,
      'totalLessons': 20,
    },
    {
      'name': 'Language Arts',
      'icon': Icons.menu_book,
      'color': Colors.purple,
      'progress': 0.35,
      'completedLessons': 7,
      'totalLessons': 20,
    },
    {
      'name': 'Science',
      'icon': Icons.science,
      'color': Colors.green,
      'progress': 0.1,
      'completedLessons': 2,
      'totalLessons': 20,
    },
  ];
  
  final List<Map<String, dynamic>> _achievements = [
    {
      'title': 'First Victory',
      'description': 'Complete your first game',
      'icon': Icons.emoji_events,
      'date': 'Oct 10',
    },
    {
      'title': 'Quick Learner',
      'description': 'Answer 10 questions correctly in a row',
      'icon': Icons.bolt,
      'date': 'Oct 15',
      'isNew': true,
    },
    {
      'title': 'Math Wizard',
      'description': 'Score 100% in a math game',
      'icon': Icons.calculate,
      'date': 'Yesterday',
      'isNew': true,
    },
  ];
  
  final List<Map<String, dynamic>> _trophies = [
    {
      'title': 'Bronze Math',
      'icon': Icons.calculate,
      'level': 'LVL 1',
    },
    {
      'title': 'Silver Reader',
      'icon': Icons.menu_book,
      'level': 'LVL 2',
    },
    {
      'title': 'Gold Trophy',
      'icon': Icons.emoji_events,
      'level': 'LVL 3',
      'isLocked': true,
    },
    {
      'title': 'Expert',
      'icon': Icons.science,
      'level': 'LVL 5',
      'isLocked': true,
    },
  ];
  
  final List<Map<String, dynamic>> _scheduleItems = [
    {
      'day': 0, // Monday
      'time': '9 AM',
      'icon': Icons.calculate,
      'color': Colors.blue,
      'title': 'Math Quiz',
    },
    {
      'day': 2, // Wednesday
      'time': '10 AM',
      'icon': Icons.menu_book,
      'color': Colors.purple,
      'title': 'Vocabulary',
    },
    {
      'day': 4, // Friday
      'time': '2 PM', 
      'icon': Icons.science,
      'color': Colors.green,
      'title': 'Science Lab',
    },
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Simulate data fetching
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 768;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          const Navbar(isAuthenticated: true, userRole: 'student'),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  )
                : _buildDashboardContent(context, isSmallScreen),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDashboardContent(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with welcome message
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppGradients.purpleToPink,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'JS',
                    style: TextStyle(
                      fontFamily: 'PixelifySans',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ).animate()
               .fadeIn(duration: 600.ms)
               .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, John!',
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 20,
                        color: colorScheme.onSurface,
                      ),
                    ).animate()
                     .fadeIn(duration: 600.ms, delay: 300.ms)
                     .slideX(begin: 0.2, end: 0),
                    const SizedBox(height: 4),
                    Text(
                      'Ready to level up your learning today?',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ).animate()
                     .fadeIn(duration: 600.ms, delay: 500.ms)
                     .slideX(begin: 0.2, end: 0),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Stats Overview Cards
          SizedBox(
            height: 120,
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'XP Points',
                    '1,250',
                    Icons.stars,
                    colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Current Level',
                    '8',
                    Icons.trending_up,
                    colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Streak',
                    '5 days',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
              ],
            ).animate()
             .fadeIn(duration: 600.ms, delay: 600.ms),
          ),
          const SizedBox(height: 32),
          
          // Game Progress Section (Assigned and In-Progress Games)
          GameProgress(
            assignedGames: _assignedGames,
            inProgressGames: _inProgressGames,
            isLoading: false,
          ).animate()
           .fadeIn(duration: 600.ms, delay: 800.ms),
          const SizedBox(height: 32),
          
          // Trophy Case
          TrophyCase(
            trophies: _trophies,
            isLoading: false,
          ).animate()
           .fadeIn(duration: 600.ms, delay: 1000.ms),
          const SizedBox(height: 32),
          
          // Subject Progress
          SubjectProgress(
            subjects: _subjects,
            isLoading: false,
          ).animate()
           .fadeIn(duration: 600.ms, delay: 1200.ms),
          const SizedBox(height: 32),
          
          // Achievements
          AchievementShowcase(
            achievements: _achievements,
            isLoading: false,
          ).animate()
           .fadeIn(duration: 600.ms, delay: 1400.ms),
          const SizedBox(height: 32),
          
          // Weekly Schedule
          WeeklySchedule(
            scheduleItems: _scheduleItems,
            isLoading: false,
          ).animate()
           .fadeIn(duration: 600.ms, delay: 1600.ms),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AppCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: color.withOpacity(0.3),
        width: 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                size: 14,
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 20,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
} 