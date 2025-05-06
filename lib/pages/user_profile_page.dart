import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/models/gamification_models.dart' as gamification;
import 'package:learn_play_level_up_flutter/services/gamification_service.dart';
import 'package:learn_play_level_up_flutter/components/gamification/xp_indicator.dart';
import 'package:learn_play_level_up_flutter/components/gamification/badge_display.dart';
import 'package:learn_play_level_up_flutter/components/gamification/currency_display.dart';
import 'package:learn_play_level_up_flutter/components/gamification/streak_tracker.dart';
import 'package:learn_play_level_up_flutter/components/gamification/progress_visualization.dart';
import 'package:learn_play_level_up_flutter/pages/store_page.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({
    super.key,
    required this.userId,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final GamificationService _gamificationService = GamificationService();
  
  gamification.UserProgress? _userProgress;
  List<gamification.Badge> _badges = [];
  List<gamification.UserBadge> _userBadges = [];
  gamification.XpLevel? _currentLevel;
  gamification.XpLevel? _nextLevel;
  double _progressToNextLevel = 0.0;
  int _userRank = -1;
  List<DateTime> _activeDates = [];
  List<Map<String, dynamic>> _recentAchievements = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load user progress
      final progress = await _gamificationService.getUserProgress(widget.userId);
      
      if (progress != null) {
        // Get user's current level
        final currentLevel = _gamificationService.getCurrentLevel(progress.totalXp);
        final nextLevelProgress = _gamificationService.getProgressToNextLevel(progress.totalXp);
        
        // Get next level (if not at max)
        final nextLevel = _gamificationService.getXpNeededForNextLevel(progress.totalXp) > 0
            ? _gamificationService.getLevelByNumber(currentLevel.level + 1)
            : null;
        
        // Get user badges
        final userBadges = await _gamificationService.getUserBadges(widget.userId);
        
        // Get badge details
        final badgeIds = userBadges.map((b) => b.badgeId).toList();
        final badges = await _gamificationService.getBadgesByIds(badgeIds);
        
        // Get user's global rank
        final rank = await _gamificationService.getUserLeaderboardRank('global', widget.userId);
        
        // Get active login dates (for streak calendar)
        final now = DateTime.now();
        final activeDates = <DateTime>[];
        
        // Assume last 7 days of login based on streak
        for (int i = 0; i < progress.loginStreak; i++) {
          activeDates.add(now.subtract(Duration(days: i)));
        }
        
        // Generate recent achievements
        final achievements = <Map<String, dynamic>>[];
        
        // Add badges as achievements
        for (final userBadge in userBadges) {
          final badge = badges.firstWhere(
            (b) => b.id == userBadge.badgeId,
            orElse: () => gamification.Badge(
              name: 'Unknown Badge',
              description: 'Badge details not available',
              iconPath: 'assets/images/badges/unknown.png',
              category: 'unknown',
              requiredValue: 0,
            ),
          );
          
          achievements.add({
            'type': 'badge',
            'title': 'Earned ${badge.name}',
            'description': badge.description,
            'iconPath': badge.iconPath,
            'date': userBadge.earnedAt,
          });
        }
        
        // Sort by date (newest first)
        achievements.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
        
        setState(() {
          _userProgress = progress;
          _currentLevel = currentLevel;
          _nextLevel = nextLevel;
          _progressToNextLevel = nextLevelProgress;
          _badges = badges;
          _userBadges = userBadges;
          _userRank = rank;
          _activeDates = activeDates;
          _recentAchievements = achievements;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_userProgress == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: const Center(child: Text('Failed to load user data')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          CoinDisplay(
            coins: _userProgress!.coins,
            compact: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StorePage(userId: widget.userId),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info and level card
              _buildUserInfoCard(),
              const SizedBox(height: 24),
              
              // Progress bars
              _buildProgressSection(),
              const SizedBox(height: 24),
              
              // Streak tracker
              _buildStreakSection(),
              const SizedBox(height: 24),
              
              // Badges
              _buildBadgesSection(),
              const SizedBox(height: 24),
              
              // Recent achievements
              _buildRecentAchievementsSection(),
              const SizedBox(height: 24),
              
              // Personal stats
              _buildPersonalStatsSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildUserInfoCard() {
    if (_currentLevel == null) return const SizedBox();
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar with level indicator
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 40,
                  backgroundColor: _currentLevel!.color.withOpacity(0.3),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: _currentLevel!.color,
                    child: Text(
                      _currentLevel!.level.toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                // Level badge
                Positioned(
                  right: -10,
                  bottom: -5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _currentLevel!.color,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _currentLevel!.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Student', // Replace with actual username
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Rank info
                  Row(
                    children: [
                      Icon(
                        Icons.leaderboard,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _userRank > 0 ? 'Rank #$_userRank' : 'Not ranked yet',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // XP info
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_userProgress!.totalXp} XP total',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // XP progress bar
                  if (_currentLevel != null)
                    XpIndicator(
                      currentXp: _userProgress!.totalXp,
                      level: _currentLevel!,
                      nextLevel: _nextLevel,
                      progress: _progressToNextLevel,
                      showLabel: false,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Get subject progress
    final subjectProgress = _userProgress!.subjectProgress;
    
    // Sort subjects by XP earned (descending)
    final subjects = subjectProgress.entries.toList()
      ..sort((a, b) => b.value.xpEarned.compareTo(a.value.xpEarned));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subject Progress',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        
        // Subject progress cards
        ...subjects.map((entry) {
          final subject = entry.value;
          const maxXp = 1000; // Example max XP for full progress
          final progress = subject.xpEarned / maxXp;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SubjectProgressCard(
              subjectName: subject.subjectId,
              subjectIcon: 'assets/images/icon_${subject.subjectId.toLowerCase()}.png',
              completionPercentage: (progress * 100).round(),
              gamesCompleted: subject.gamesCompleted,
              perfectScores: subject.perfectScores,
              xpEarned: subject.xpEarned,
            ),
          );
        }).toList(),
        
        const SizedBox(height: 16),
        
        // Subject mastery map
        MasteryMap(
          subjectMasteryPercentages: Map.fromEntries(
            subjects.map((entry) {
              const maxXp = 1000; // Example max XP for full mastery
              final progress = entry.value.xpEarned / maxXp;
              return MapEntry(entry.key, progress.clamp(0.0, 1.0) * 100);
            }),
          ),
          subjectIcons: Map.fromEntries(
            subjects.map((entry) => MapEntry(
              entry.key,
              'assets/images/icon_${entry.key.toLowerCase()}.png',
            )),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStreakSection() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Login Streak',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        
        // Streak info card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Streak flame icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.red],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Streak: ${_userProgress!.loginStreak} days',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Keep logging in daily to earn rewards!',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Streak calendar
        StreakCalendar(
          activeDates: _activeDates,
          currentMonth: DateTime.now(),
          currentStreak: _userProgress!.loginStreak,
          onMonthChanged: () {
            // Handle month change
          },
        ),
        const SizedBox(height: 16),
        
        // Streak milestones
        Row(
          children: [
            Expanded(
              child: StreakMilestone(
                requiredDays: 3,
                currentStreak: _userProgress!.loginStreak,
                reward: '50 Coins',
                progress: _userProgress!.loginStreak / 3.0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StreakMilestone(
                requiredDays: 7,
                currentStreak: _userProgress!.loginStreak,
                reward: '100 Coins + Badge',
                progress: _userProgress!.loginStreak / 7.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildBadgesSection() {
    final theme = Theme.of(context);
    
    // Group badges by category
    final badgesByCategory = <String, List<gamification.Badge>>{};
    
    for (final badge in _badges) {
      if (!badgesByCategory.containsKey(badge.category)) {
        badgesByCategory[badge.category] = [];
      }
      badgesByCategory[badge.category]!.add(badge);
    }
    
    // Get earned badge IDs
    final earnedBadgeIds = _userBadges.map((b) => b.badgeId).toList();
    
    // Get new badge IDs (unviewed)
    final newBadgeIds = _userBadges
        .where((b) => b.isNew)
        .map((b) => b.badgeId)
        .toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Badges',
              style: theme.textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                // Navigate to full badges collection
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'You have earned ${earnedBadgeIds.length} badges',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        
        // Display badges by category
        ...badgesByCategory.entries.map((entry) {
          final category = entry.key;
          final categoryBadges = entry.value;
          
          // Format category name
          String categoryName = category.replaceAll('_', ' ');
          categoryName = categoryName[0].toUpperCase() + categoryName.substring(1);
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                categoryName,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryBadges.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final badge = categoryBadges[index];
                    final isEarned = earnedBadgeIds.contains(badge.id);
                    final isNew = newBadgeIds.contains(badge.id);
                    
                    return Column(
                      children: [
                        BadgeDisplay(
                          badge: badge,
                          isEarned: isEarned,
                          isNew: isNew,
                          size: 60,
                          onTap: () {
                            // Show badge details
                            showDialog(
                              context: context,
                              builder: (context) => BadgeDetailDialog(
                                badge: badge,
                                isEarned: isEarned,
                                earnedDate: isEarned
                                    ? _userBadges
                                        .firstWhere((b) => b.badgeId == badge.id)
                                        .earnedAt
                                    : null,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          badge.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isEarned ? FontWeight.bold : FontWeight.normal,
                            color: isEarned
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ],
    );
  }
  
  Widget _buildRecentAchievementsSection() {
    final theme = Theme.of(context);
    
    if (_recentAchievements.isEmpty) {
      return const SizedBox();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Achievements',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        
        // Recent achievements list
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentAchievements.length.clamp(0, 5),
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final achievement = _recentAchievements[index];
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: achievement['type'] == 'badge'
                      ? Image.asset(
                          achievement['iconPath'] as String,
                          width: 24,
                          height: 24,
                        )
                      : const Icon(Icons.emoji_events),
                ),
                title: Text(achievement['title'] as String),
                subtitle: Text(achievement['description'] as String),
                trailing: Text(
                  _formatDate(achievement['date'] as DateTime),
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildPersonalStatsSection() {
    final theme = Theme.of(context);
    
    // Get total games played and perfect scores
    int totalGamesPlayed = 0;
    int totalPerfectScores = 0;
    
    for (final subject in _userProgress!.subjectProgress.values) {
      totalGamesPlayed += subject.gamesCompleted;
      totalPerfectScores += subject.perfectScores;
    }
    
    // Calculate perfect score percentage
    final perfectScorePercentage = totalGamesPlayed > 0
        ? (totalPerfectScores / totalGamesPlayed * 100).round()
        : 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Stats',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            _buildStatCard(
              icon: Icons.sports_esports,
              value: totalGamesPlayed.toString(),
              label: 'Games Played',
              color: Colors.blue,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              icon: Icons.verified,
              value: '$perfectScorePercentage%',
              label: 'Perfect Score Rate',
              color: Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(
              icon: Icons.star,
              value: _userProgress!.totalXp.toString(),
              label: 'Total XP',
              color: Colors.amber,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              icon: Icons.local_fire_department,
              value: _userProgress!.loginStreak.toString(),
              label: 'Day Streak',
              color: Colors.orange,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
} 