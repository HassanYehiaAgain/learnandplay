import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/gamification/xp_indicator.dart';
import 'package:learn_play_level_up_flutter/components/gamification/badge_display.dart';
import 'package:learn_play_level_up_flutter/components/gamification/currency_display.dart';
import 'package:learn_play_level_up_flutter/components/gamification/streak_tracker.dart';
import 'package:learn_play_level_up_flutter/components/gamification/leaderboard.dart';
import 'package:learn_play_level_up_flutter/components/gamification/progress_visualization.dart';
import 'package:learn_play_level_up_flutter/models/gamification_models.dart' as gamification;
import 'package:learn_play_level_up_flutter/services/gamification_service.dart';

class GamificationDashboardPage extends StatefulWidget {
  const GamificationDashboardPage({super.key});

  @override
  State<GamificationDashboardPage> createState() => _GamificationDashboardPageState();
}

class _GamificationDashboardPageState extends State<GamificationDashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Sample data (in a real app, this would come from your GamificationService)
  late gamification.UserProgress _userProgress;
  late List<gamification.Badge> _badges;
  late List<String> _earnedBadgeIds;
  late List<String> _newBadgeIds;
  late List<DateTime> _activeDates;
  late DateTime _currentMonth;
  late Map<String, double> _subjectMasteryPercentages;
  late Map<String, String> _subjectIcons;
  late List<Map<String, dynamic>> _pathNodes;
  late int _currentPathNodeIndex;
  
  int _selectedLeaderboardTab = 0;
  final List<String> _leaderboardCategories = ['Global', 'Math', 'Science', 'Language', 'History'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMockData();
  }
  
  void _loadMockData() {
    // Mock user progress
    _userProgress = gamification.UserProgress(
      userId: 'user123',
      level: 5,
      totalXp: 1250,
      coins: 350,
      loginStreak: 7,
      lastLogin: DateTime.now(),
      subjectProgress: {
        'Math': gamification.SubjectProgress(
          subjectId: 'Math',
          xpEarned: 450,
          gamesCompleted: 25,
          perfectScores: 18,
          currentStreak: 3,
          highestStreak: 5,
          personalBests: {
            'game1': 98,
            'game2': 85,
          },
        ),
        'Science': gamification.SubjectProgress(
          subjectId: 'Science',
          xpEarned: 320,
          gamesCompleted: 18,
          perfectScores: 12,
          currentStreak: 2,
          highestStreak: 4,
          personalBests: {
            'game3': 78,
            'game4': 92,
          },
        ),
        'Language': gamification.SubjectProgress(
          subjectId: 'Language',
          xpEarned: 280,
          gamesCompleted: 15,
          perfectScores: 9,
          currentStreak: 0,
          highestStreak: 3,
          personalBests: {
            'game5': 88,
            'game6': 72,
          },
        ),
        'History': gamification.SubjectProgress(
          subjectId: 'History',
          xpEarned: 200,
          gamesCompleted: 12,
          perfectScores: 5,
          currentStreak: 1,
          highestStreak: 2,
          personalBests: {
            'game7': 65,
            'game8': 82,
          },
        ),
      },
    );
    
    // Mock badges
    _badges = [
      gamification.Badge(
        id: 'badge1',
        name: 'First Step',
        description: 'Complete your first game',
        category: 'achievement',
        iconPath: 'assets/images/badge_first_step.png',
        requiredValue: 1,
      ),
      gamification.Badge(
        id: 'badge2',
        name: 'Perfect Score',
        description: 'Get a perfect score in any game',
        category: 'achievement',
        iconPath: 'assets/images/badge_perfect.png',
        requiredValue: 1,
      ),
      gamification.Badge(
        id: 'badge3',
        name: 'Math Novice',
        description: 'Earn 100 XP in Math',
        category: 'subject_mastery',
        subjectId: 'Math',
        iconPath: 'assets/images/badge_math.png',
        requiredValue: 100,
      ),
      gamification.Badge(
        id: 'badge4',
        name: 'Science Explorer',
        description: 'Earn 100 XP in Science',
        category: 'subject_mastery',
        subjectId: 'Science',
        iconPath: 'assets/images/badge_science.png',
        requiredValue: 100,
      ),
      gamification.Badge(
        id: 'badge5',
        name: 'Word Master',
        description: 'Earn 100 XP in Language',
        category: 'subject_mastery',
        subjectId: 'Language',
        iconPath: 'assets/images/badge_language.png',
        requiredValue: 100,
      ),
      gamification.Badge(
        id: 'badge6',
        name: 'History Buff',
        description: 'Earn 100 XP in History',
        category: 'subject_mastery',
        subjectId: 'History',
        iconPath: 'assets/images/badge_history.png',
        requiredValue: 100,
      ),
      gamification.Badge(
        id: 'badge7',
        name: '3-Day Streak',
        description: 'Login for 3 consecutive days',
        category: 'login_streak',
        iconPath: 'assets/images/badge_streak.png',
        requiredValue: 3,
      ),
      gamification.Badge(
        id: 'badge8',
        name: '7-Day Streak',
        description: 'Login for 7 consecutive days',
        category: 'login_streak',
        iconPath: 'assets/images/badge_streak_7.png',
        requiredValue: 7,
      ),
      gamification.Badge(
        id: 'badge9',
        name: 'Level 5',
        description: 'Reach level 5',
        category: 'level',
        iconPath: 'assets/images/badge_level_5.png',
        requiredValue: 5,
      ),
    ];
    
    // Mock earned and new badges
    _earnedBadgeIds = ['badge1', 'badge2', 'badge3', 'badge4', 'badge7', 'badge8', 'badge9'];
    _newBadgeIds = ['badge9'];
    
    // Mock active dates for streak calendar
    final now = DateTime.now();
    _activeDates = [
      DateTime(now.year, now.month, now.day - 7),
      DateTime(now.year, now.month, now.day - 6),
      DateTime(now.year, now.month, now.day - 5),
      DateTime(now.year, now.month, now.day - 4),
      DateTime(now.year, now.month, now.day - 3),
      DateTime(now.year, now.month, now.day - 2),
      DateTime(now.year, now.month, now.day),
    ];
    _currentMonth = DateTime(now.year, now.month);
    
    // Mock subject mastery percentages
    _subjectMasteryPercentages = {
      'Math': 75.0,
      'Science': 60.0,
      'Language': 45.0,
      'History': 30.0,
      'Geography': 15.0,
      'Art': 5.0,
    };
    
    // Mock subject icons
    _subjectIcons = {
      'Math': 'assets/images/icon_math.png',
      'Science': 'assets/images/icon_science.png',
      'Language': 'assets/images/icon_language.png',
      'History': 'assets/images/icon_history.png',
      'Geography': 'assets/images/icon_geography.png',
      'Art': 'assets/images/icon_art.png',
    };
    
    // Mock learning path nodes
    _pathNodes = [
      {
        'title': 'Introduction to Numbers',
        'isComplete': true,
        'primarySkill': 'Basic Math',
        'icon': 'assets/images/icon_math.png',
      },
      {
        'title': 'Addition and Subtraction',
        'isComplete': true,
        'primarySkill': 'Basic Math',
        'icon': 'assets/images/icon_math.png',
      },
      {
        'title': 'Multiplication and Division',
        'isComplete': false,
        'primarySkill': 'Math',
        'icon': 'assets/images/icon_math.png',
      },
      {
        'title': 'Basic Science Concepts',
        'isComplete': false,
        'primarySkill': 'Science',
        'icon': 'assets/images/icon_science.png',
      },
      {
        'title': 'Grammar Basics',
        'isComplete': false,
        'primarySkill': 'Language',
        'icon': 'assets/images/icon_language.png',
      },
    ];
    _currentPathNodeIndex = 2;
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Get the current and next level
    final gamificationService = GamificationService();
    final currentLevel = gamificationService.getCurrentLevel(_userProgress.totalXp);
    final progress = gamificationService.getProgressToNextLevel(_userProgress.totalXp);
    
    // Calculate XP needed for next level
    final xpNeeded = gamificationService.getXpNeededForNextLevel(_userProgress.totalXp);
    final nextLevel = xpNeeded > 0 ? gamificationService.getLevelByNumber(currentLevel.level + 1) : null;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
        actions: [
          CoinDisplay(
            coins: _userProgress.coins,
            compact: true,
            onTap: () {
              // Navigate to store
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart), text: 'Progress'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Achievements'),
            Tab(icon: Icon(Icons.leaderboard), text: 'Leaderboards'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Progress Tab
          _buildProgressTab(currentLevel, nextLevel, progress),
          
          // Achievements Tab
          _buildAchievementsTab(),
          
          // Leaderboards Tab
          _buildLeaderboardsTab(),
        ],
      ),
    );
  }
  
  Widget _buildProgressTab(
    gamification.XpLevel currentLevel,
    gamification.XpLevel? nextLevel,
    double progress,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // XP indicator
          XpIndicator(
            currentXp: _userProgress.totalXp,
            level: currentLevel,
            nextLevel: nextLevel,
            progress: progress,
            showLabel: true,
          ),
          const SizedBox(height: 24),
          
          // Daily login streak
          const Text(
            'Daily Streak',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          StreakCalendar(
            activeDates: _activeDates,
            currentMonth: _currentMonth,
            currentStreak: _userProgress.loginStreak,
            onMonthChanged: () {
              // Handle month change
            },
          ),
          const SizedBox(height: 24),
          
          // Streak milestones
          const Text(
            'Streak Milestones',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: StreakMilestone(
                  requiredDays: 3,
                  currentStreak: _userProgress.loginStreak,
                  reward: '50 Coins',
                  progress: _userProgress.loginStreak / 3,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StreakMilestone(
                  requiredDays: 7,
                  currentStreak: _userProgress.loginStreak,
                  reward: '100 Coins + Badge',
                  progress: _userProgress.loginStreak / 7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Subject progress
          const Text(
            'Subject Progress',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          
          // Math progress
          SubjectProgressCard(
            subjectName: 'Mathematics',
            subjectIcon: 'assets/images/icon_math.png',
            completionPercentage: 75,
            gamesCompleted: _userProgress.subjectProgress['Math']?.gamesCompleted ?? 0,
            perfectScores: _userProgress.subjectProgress['Math']?.perfectScores ?? 0,
            xpEarned: _userProgress.subjectProgress['Math']?.xpEarned ?? 0,
          ),
          
          // Science progress
          SubjectProgressCard(
            subjectName: 'Science',
            subjectIcon: 'assets/images/icon_science.png',
            completionPercentage: 60,
            gamesCompleted: _userProgress.subjectProgress['Science']?.gamesCompleted ?? 0,
            perfectScores: _userProgress.subjectProgress['Science']?.perfectScores ?? 0,
            xpEarned: _userProgress.subjectProgress['Science']?.xpEarned ?? 0,
          ),
          
          // Progress graph
          const ProgressGraph(
            dailyXpValues: [50, 75, 30, 90, 120, 60, 45],
            labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            title: 'Daily XP Earnings',
          ),
          const SizedBox(height: 24),
          
          // Subject mastery map
          MasteryMap(
            subjectMasteryPercentages: _subjectMasteryPercentages,
            subjectIcons: _subjectIcons,
          ),
          const SizedBox(height: 24),
          
          // Learning path
          LearningPathVisualization(
            pathNodes: _pathNodes,
            currentNodeIndex: _currentPathNodeIndex,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAchievementsTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Badges',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You have earned ${_earnedBadgeIds.length} out of ${_badges.length} badges',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          
          // Achievement category
          const Text(
            'Achievements',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          BadgeGrid(
            badges: _badges.where((b) => b.category == 'achievement').toList(),
            earnedBadgeIds: _earnedBadgeIds,
            newBadgeIds: _newBadgeIds,
            onBadgeTap: (badge) {
              showDialog(
                context: context,
                builder: (context) => BadgeDetailDialog(
                  badge: badge,
                  isEarned: _earnedBadgeIds.contains(badge.id),
                  earnedDate: DateTime.now().subtract(const Duration(days: 2)),
                ),
              );
            },
            categoryFilter: 'achievement',
          ),
          const SizedBox(height: 24),
          
          // Subject mastery category
          const Text(
            'Subject Mastery',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          BadgeGrid(
            badges: _badges.where((b) => b.category == 'subject_mastery').toList(),
            earnedBadgeIds: _earnedBadgeIds,
            newBadgeIds: _newBadgeIds,
            onBadgeTap: (badge) {
              showDialog(
                context: context,
                builder: (context) => BadgeDetailDialog(
                  badge: badge,
                  isEarned: _earnedBadgeIds.contains(badge.id),
                  earnedDate: DateTime.now().subtract(const Duration(days: 5)),
                ),
              );
            },
            categoryFilter: 'subject_mastery',
          ),
          const SizedBox(height: 24),
          
          // Streaks category
          const Text(
            'Streaks',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          BadgeGrid(
            badges: _badges.where((b) => b.category == 'login_streak').toList(),
            earnedBadgeIds: _earnedBadgeIds,
            newBadgeIds: _newBadgeIds,
            onBadgeTap: (badge) {
              showDialog(
                context: context,
                builder: (context) => BadgeDetailDialog(
                  badge: badge,
                  isEarned: _earnedBadgeIds.contains(badge.id),
                  earnedDate: DateTime.now().subtract(const Duration(days: 1)),
                ),
              );
            },
            categoryFilter: 'login_streak',
          ),
          const SizedBox(height: 24),
          
          // Level category
          const Text(
            'Levels',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          BadgeGrid(
            badges: _badges.where((b) => b.category == 'level').toList(),
            earnedBadgeIds: _earnedBadgeIds,
            newBadgeIds: _newBadgeIds,
            onBadgeTap: (badge) {
              showDialog(
                context: context,
                builder: (context) => BadgeDetailDialog(
                  badge: badge,
                  isEarned: _earnedBadgeIds.contains(badge.id),
                  earnedDate: DateTime.now(),
                ),
              );
            },
            categoryFilter: 'level',
          ),
        ],
      ),
    );
  }
  
  Widget _buildLeaderboardsTab() {
    // Mock leaderboard entries
    final entries = List.generate(10, (index) {
      return gamification.LeaderboardEntry(
        userId: 'user${index + 1}',
        userName: index == 0 ? 'You' : 'User ${index + 1}',
        value: 1000 - (index * 75),
        updatedAt: DateTime.now().subtract(Duration(hours: index)),
      );
    });
    
    return Column(
      children: [
        LeaderboardTabSelector(
          categories: _leaderboardCategories,
          selectedIndex: _selectedLeaderboardTab,
          onChanged: (index) {
            setState(() {
              _selectedLeaderboardTab = index;
            });
          },
        ),
        Expanded(
          child: LeaderboardDisplay(
            entries: entries,
            title: _leaderboardCategories[_selectedLeaderboardTab],
            currentUserId: 'user1',
            currentUserRank: 1,
            totalParticipants: 50,
            onRefresh: () {
              // Refresh leaderboard
            },
          ),
        ),
      ],
    );
  }
} 