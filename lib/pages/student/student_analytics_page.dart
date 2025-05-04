import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:intl/intl.dart';
import 'package:learn_play_level_up_flutter/models/analytics_models.dart';
import 'package:learn_play_level_up_flutter/models/gamification_models.dart' as gamification;
import 'package:learn_play_level_up_flutter/services/analytics_service.dart';
import 'package:learn_play_level_up_flutter/services/gamification_service.dart';
import 'package:learn_play_level_up_flutter/widgets/analytics/performance_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StudentAnalyticsPage extends StatefulWidget {
  const StudentAnalyticsPage({super.key});

  @override
  State<StudentAnalyticsPage> createState() => _StudentAnalyticsPageState();
}

class _StudentAnalyticsPageState extends State<StudentAnalyticsPage> with SingleTickerProviderStateMixin {
  final AnalyticsService _analyticsService = AnalyticsService();
  final GamificationService _gamificationService = GamificationService();
  late TabController _tabController;
  
  StudentAnalytics? _analytics;
  gamification.UserProgress? _userProgress;
  List<AnalyticsGameSession> _recentGames = [];
  List<PerformanceTrend> _performanceTrends = [];
  List<gamification.Badge> _earnedBadges = [];
  List<gamification.UserBadge> _userBadges = [];
  bool _isLoading = true;
  String _selectedTimeRange = 'Last 30 Days';
  String? _selectedSubject;
  
  final List<String> _timeRanges = ['Last 7 Days', 'Last 30 Days', 'Last 90 Days', 'All Time'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    _loadAnalytics();
  }
  
  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
  
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {});
    }
  }
  
  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userId = auth.FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      // Load user progress
      final userProgress = await _gamificationService.getUserProgress(userId);
      
      // Load student analytics
      final analytics = await _analyticsService.getStudentAnalytics(userId);
      
      // Load recent games
      final recentGames = await _analyticsService.getStudentGameHistory(userId);
      
      // Load performance trends
      final performanceTrends = await _analyticsService.getStudentPerformanceTrends(userId);
      
      // Load badges
      final badges = await _gamificationService.getUserBadges(userId);
      
      setState(() {
        _userProgress = userProgress;
        _analytics = analytics;
        _recentGames = recentGames;
        _performanceTrends = performanceTrends;
        _userBadges = badges;
        _isLoading = false;
      });
      
      // Load badge details (for display)
      _loadBadgeDetails();
    } catch (e) {
      debugPrint('Error loading analytics: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadBadgeDetails() async {
    try {
      final badgeIds = _userBadges.map((b) => b.badgeId).toList();
      
      if (badgeIds.isNotEmpty) {
        final badges = await _gamificationService.getBadgesByIds(badgeIds);
        
        setState(() {
          _earnedBadges = badges;
        });
      }
    } catch (e) {
      debugPrint('Error loading badge details: $e');
    }
  }
  
  List<PerformanceTrend> _filterTrendsByTimeRange() {
    if (_performanceTrends.isEmpty) return [];
    
    final now = DateTime.now();
    DateTime cutoffDate;
    
    switch (_selectedTimeRange) {
      case 'Last 7 Days':
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case 'Last 30 Days':
        cutoffDate = now.subtract(const Duration(days: 30));
        break;
      case 'Last 90 Days':
        cutoffDate = now.subtract(const Duration(days: 90));
        break;
      case 'All Time':
      default:
        return _performanceTrends;
    }
    
    return _performanceTrends.where((trend) => trend.date.isAfter(cutoffDate)).toList();
  }
  
  List<AnalyticsGameSession> _filterGamesBySubject() {
    if (_recentGames.isEmpty || _selectedSubject == null) {
      return _recentGames;
    }
    
    // In a real app, you would filter by subject ID here
    // This is a placeholder for the concept
    return _recentGames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Game History'),
            Tab(text: 'Achievements'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
            tooltip: 'Refresh Analytics',
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildGameHistoryTab(),
                _buildAchievementsTab(),
              ],
            ),
    );
  }
  
  Widget _buildOverviewTab() {
    if (_userProgress == null) {
      return const Center(
        child: Text('No progress data available'),
      );
    }
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress overview
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Level ${_userProgress!.level}',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _gamificationService.getLevelByNumber(_userProgress!.level)?.title ?? 'Novice',
                              style: TextStyle(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.monetization_on, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${_userProgress!.coins}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // XP progress bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'XP: ${_userProgress!.totalXp}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Next Level: ${_gamificationService.getXpNeededForNextLevel(_userProgress!.totalXp)} XP needed',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _gamificationService.getProgressToNextLevel(_userProgress!.totalXp),
                            minHeight: 8,
                            backgroundColor: colorScheme.surfaceVariant,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Streak
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Current Streak: ${_userProgress!.loginStreak} days',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Subject mastery
            Text(
              'Subject Mastery',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            
            if (_analytics?.subjectMastery.isEmpty ?? true)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No subject data available'),
                ),
              )
            else
              ..._analytics!.subjectMastery.values.map((subject) => 
                _buildSubjectMasteryCard(subject)
              ),
            
            const SizedBox(height: 24),
            
            // Performance charts
            Text(
              'Performance Trends',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            
            // Time range filter
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Time Range',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _timeRanges.map((range) => DropdownMenuItem(
                  value: range,
                  child: Text(range),
                )).toList(),
                value: _selectedTimeRange,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedTimeRange = value;
                    });
                  }
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Score chart
            SizedBox(
              height: 240,
              child: PerformanceChart(
                trends: _filterTrendsByTimeRange(),
                metricType: 'score',
                title: 'Score History',
                yAxisLabel: 'Score (%)',
                lineColor: colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Time spent chart
            SizedBox(
              height: 240,
              child: PerformanceChart(
                trends: _filterTrendsByTimeRange(),
                metricType: 'time',
                title: 'Time Spent Learning',
                yAxisLabel: 'Minutes',
                lineColor: colorScheme.tertiary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Games completed chart
            SizedBox(
              height: 240,
              child: PerformanceChart(
                trends: _filterTrendsByTimeRange(),
                metricType: 'games_completed',
                title: 'Games Completed',
                yAxisLabel: 'Count',
                lineColor: colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSubjectMasteryCard(SubjectMastery subject) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.book,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  subject.subjectName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  '${subject.masteryPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getColorForMastery(subject.masteryPercentage),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: subject.masteryPercentage / 100,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceVariant,
                color: _getColorForMastery(subject.masteryPercentage),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Games completed: ${subject.gamesCompleted}',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGameHistoryTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      child: Column(
        children: [
          // Filter options
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Subject filter
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Subjects')),
                      // Add subject items here from _analytics?.subjectMastery
                      if (_analytics != null)
                        ..._analytics!.subjectMastery.values.map(
                          (subject) => DropdownMenuItem(
                            value: subject.subjectId,
                            child: Text(subject.subjectName),
                          ),
                        ),
                    ],
                    value: _selectedSubject,
                    onChanged: (value) {
                      setState(() {
                        _selectedSubject = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                
                // Game type filter (optional)
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Game Type',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('All Types')),
                      if (_analytics != null)
                        ..._analytics!.gameTypePerformance.entries.map(
                          (entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(_formatGameType(entry.key)),
                          ),
                        ),
                    ],
                    value: 'all',
                    onChanged: (value) {
                      // Implement filtering by game type
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Game history list
          Expanded(
            child: _recentGames.isEmpty
                ? const Center(
                    child: Text('No game history available'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filterGamesBySubject().length,
                    itemBuilder: (context, index) {
                      final game = _filterGamesBySubject()[index];
                      return _buildGameHistoryCard(game);
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGameHistoryCard(AnalyticsGameSession game) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final dateFormat = DateFormat('MMM d, yyyy - h:mm a');
    
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getIconForGameType(game.gameType),
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.gameTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(game.completedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getColorForScore(game.scorePercentage).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getColorForScore(game.scorePercentage),
                    ),
                  ),
                  child: Text(
                    '${game.scorePercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getColorForScore(game.scorePercentage),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // XP earned
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 16,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${game.xpEarned} XP earned',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                
                // Coins earned
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      size: 16,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${game.coinsEarned} coins earned',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                
                // Time spent
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatDuration(game.durationSeconds.toDouble())}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAchievementsTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (_userProgress == null) {
      return const Center(
        child: Text('No achievement data available'),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level progress
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Level',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Level ${_userProgress!.level}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            Text(
                              _gamificationService.getLevelByNumber(_userProgress!.level)?.title ?? 'Novice',
                              style: TextStyle(
                                color: colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        // Level icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${_userProgress!.level}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Progress to next level
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress to Level ${_userProgress!.level + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_gamificationService.getXpNeededForNextLevel(_userProgress!.totalXp)} XP needed',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _gamificationService.getProgressToNextLevel(_userProgress!.totalXp),
                            minHeight: 8,
                            backgroundColor: colorScheme.surfaceVariant,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total XP: ${_userProgress!.totalXp}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate()
             .fade(duration: 400.ms)
             .slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 24),
            
            // Login streak
            Text(
              'Activity Streak',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.orange.shade700,
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_userProgress!.loginStreak} days',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current Streak',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    
                    // Calendar streak visualization
                    const SizedBox(height: 8),
                    Text(
                      'Last 7 Days',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStreakCalendar(),
                    
                    const SizedBox(height: 16),
                    Text(
                      'Keep your streak going by playing at least one game every day!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate()
             .fade(duration: 400.ms, delay: 100.ms)
             .slideY(begin: 0.1, end: 0),
             
            const SizedBox(height: 24),
            
            // Badges
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Badges Earned',
                  style: theme.textTheme.titleLarge,
                ),
                Text(
                  '${_userBadges.length} / ${_earnedBadges.length + 5}',  // Total badges count (earned + placeholder)
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Badge grid
            if (_earnedBadges.isEmpty)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 48,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No badges earned yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete games and challenges to earn badges!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _earnedBadges.length,
                itemBuilder: (context, index) {
                  final badge = _earnedBadges[index];
                  // Find the matching user badge to get progress
                  final userBadge = _userBadges.firstWhere(
                    (ub) => ub.badgeId == badge.id,
                    orElse: () => gamification.UserBadge(
                      badgeId: badge.id,
                      earnedAt: DateTime.now(),
                    ),
                  );
                  
                  return _buildBadgeCard(badge, userBadge, index);
                },
              ).animate().fadeIn(
                duration: 600.ms,
                delay: 200.ms,
              ),
              
            // Add locked badges placeholders
            const SizedBox(height: 16),
            Text(
              'Locked Badges',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 3,  // Show 3 locked badges as placeholders
              itemBuilder: (context, index) {
                return _buildLockedBadgeCard(index);
              },
            ).animate().fadeIn(
              duration: 600.ms,
              delay: 300.ms,
            ),
              
            const SizedBox(height: 24),
              
            // Coins and rewards
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rewards',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildRewardItem(
                          context,
                          '${_userProgress!.coins}',
                          'Coins',
                          Icons.monetization_on,
                          Colors.amber,
                        ),
                        _buildRewardItem(
                          context,
                          '${_userProgress!.totalXp}',
                          'Total XP',
                          Icons.star,
                          Colors.purple,
                        ),
                        _buildRewardItem(
                          context,
                          _earnedBadges.length.toString(),
                          'Badges',
                          Icons.emoji_events,
                          Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Recent Rewards',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Recent rewards list - could be populated from game history
                    ...List.generate(
                      _recentGames.length > 3 ? 3 : _recentGames.length,
                      (index) {
                        if (_recentGames.isEmpty) return const SizedBox();
                        final game = _recentGames[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(
                              _getIconForGameType(game.gameType),
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          title: Text(game.gameTitle),
                          subtitle: Text(
                            'Score: ${game.scorePercentage.toStringAsFixed(1)}%',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text('+${(game.scorePercentage / 10).round()} XP'),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.monetization_on,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text('+${(game.scorePercentage / 20).round()} coins'),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ).animate()
             .fade(duration: 400.ms, delay: 400.ms)
             .slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  /// Build streak calendar
  Widget _buildStreakCalendar() {
    final today = DateTime.now();
    final days = List<DateTime>.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
    
    // In a real app, you'd fetch the actual login dates from Firebase
    // For now, let's simulate some activity
    // Typically, you'd want to check against _userProgress.lastLoginDates or similar
    final activeDates = <DateTime>[];
    final streak = _userProgress?.loginStreak ?? 0;
    
    // Simulate activity based on streak and today
    for (int i = 0; i < streak && i < 7; i++) {
      activeDates.add(today.subtract(Duration(days: i)));
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        final isActive = activeDates.any((d) => 
          d.year == day.year && d.month == day.month && d.day == day.day);
        
        return _buildCalendarDay(day, isActive);
      }).toList(),
    );
  }
  
  /// Build a single day cell for the streak calendar
  Widget _buildCalendarDay(DateTime date, bool isActive) {
    final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dayIndex = date.weekday - 1; // 0 = Monday, 6 = Sunday
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      children: [
        Text(
          dayNames[dayIndex],
          style: TextStyle(
            fontSize: 10,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive 
                ? Colors.orange.shade700
                : colorScheme.surfaceVariant.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${date.day}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive 
                    ? Colors.white
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  /// Build badge card with progress
  Widget _buildBadgeCard(gamification.Badge badge, gamification.UserBadge userBadge, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: userBadge.isCompleted ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: userBadge.isCompleted 
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: userBadge.isCompleted 
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceVariant.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  _getIconForBadge(badge.type),
                  size: 32,
                  color: userBadge.isCompleted 
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Badge name
            Text(
              badge.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: userBadge.isCompleted 
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Progress or completion
            if (userBadge.isCompleted)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 12,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Text(
                    '${userBadge.progress}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: userBadge.progress / 100,
                      minHeight: 4,
                      backgroundColor: colorScheme.surfaceVariant,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ).animate()
       .fadeIn(duration: const Duration(milliseconds: 200), delay: Duration(milliseconds: 50 * index))
       .slideY(begin: 0.2, end: 0);
  }
  
  /// Build locked badge placeholder
  Widget _buildLockedBadgeCard(int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 1,
      color: colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.lock,
                  size: 28,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Badge name
            Text(
              'Mystery Badge',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            // Hint
            Text(
              'Keep playing to unlock',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    ).animate()
       .fadeIn(duration: const Duration(milliseconds: 200), delay: Duration(milliseconds: 300 + (50 * index)));
  }
  
  /// Build reward item
  Widget _buildRewardItem(
    BuildContext context, 
    String value, 
    String label, 
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
  
  // Helper to get icon for badge type
  IconData _getIconForBadge(String badgeType) {
    switch (badgeType.toLowerCase()) {
      case 'achievement':
        return Icons.emoji_events;
      case 'streak':
        return Icons.local_fire_department;
      case 'mastery':
        return Icons.school;
      case 'completion':
        return Icons.check_circle;
      case 'score':
        return Icons.stars;
      default:
        return Icons.emoji_events;
    }
  }
  
  // Helper to get icon for game type
  IconData _getIconForGameType(String gameType) {
    switch (gameType.toLowerCase()) {
      case 'quiz':
        return Icons.quiz;
      case 'matching':
        return Icons.extension;
      case 'flashcard':
        return Icons.flip_to_back;
      case 'puzzle':
        return Icons.extension;
      default:
        return Icons.videogame_asset;
    }
  }
  
  // Helper to format game type for display
  String _formatGameType(String gameType) {
    // Convert from camelCase or snake_case to Title Case
    final words = gameType
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .replaceAll('_', ' ')
        .trim()
        .split(' ');
    
    return words.map((word) => word.isNotEmpty 
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '').join(' ');
  }
  
  // Helper to get color based on score
  Color _getColorForScore(double score) {
    if (score >= 90) {
      return Colors.green.shade700;
    } else if (score >= 70) {
      return Colors.green;
    } else if (score >= 60) {
      return Colors.lightGreen;
    } else if (score >= 50) {
      return Colors.amber;
    } else if (score >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  /// Get color based on mastery percentage.
  Color _getColorForMastery(double mastery) {
    if (mastery >= 90) {
      return Colors.green.shade700;
    } else if (mastery >= 70) {
      return Colors.green;
    } else if (mastery >= 50) {
      return Colors.amber;
    } else if (mastery >= 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  /// Format duration to mm:ss or m:ss format.
  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
} 