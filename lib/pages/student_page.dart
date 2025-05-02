import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({Key? key}) : super(key: key);

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Fetch student data, enrolled games, etc.
    _fetchStudentData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _fetchStudentData() async {
    setState(() {
      _isLoading = true;
    });
    
    // TODO: Implement API calls to fetch student data
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 768;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          const Navbar(isAuthenticated: true, userRole: 'student'),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildDashboardContent(context, isSmallScreen),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDashboardContent(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Dashboard',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your progress, play games, and earn achievements',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
            ),
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
                    'Games Played',
                    '12',
                    Icons.sports_esports,
                    colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Score',
                    '8,540',
                    Icons.leaderboard,
                    colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Achievements',
                    '8',
                    Icons.emoji_events,
                    colorScheme.tertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'My Games'),
                Tab(text: 'Achievements'),
                Tab(text: 'Performance'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMyGamesTab(context),
                _buildAchievementsTab(context),
                _buildPerformanceTab(context),
              ],
            ),
          ),
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMyGamesTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Mock data for enrolled games
    final enrolledGames = [
      {
        'title': 'Math Challenge',
        'progress': 0.75,
        'lastPlayed': 'Yesterday',
        'image': Icons.calculate,
        'color': colorScheme.primary,
      },
      {
        'title': 'Vocabulary Quest',
        'progress': 0.45,
        'lastPlayed': '2 days ago',
        'image': Icons.menu_book,
        'color': colorScheme.secondary,
      },
      {
        'title': 'Science Explorer',
        'progress': 0.2,
        'lastPlayed': 'Last week',
        'image': Icons.science,
        'color': colorScheme.tertiary,
      },
    ];
    
    if (enrolledGames.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_esports_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No games enrolled yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse available games and start playing',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Browse Games',
              variant: ButtonVariant.primary,
              leadingIcon: Icons.search,
              onPressed: () {},
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: enrolledGames.length,
      itemBuilder: (context, index) {
        final game = enrolledGames[index];
        
        return AppCard(
          onTap: () {},
          isHoverable: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (game['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      game['image'] as IconData,
                      color: game['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'play',
                        child: Row(
                          children: [
                            Icon(Icons.play_arrow),
                            SizedBox(width: 8),
                            Text('Play'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'details',
                        child: Row(
                          children: [
                            Icon(Icons.info_outline),
                            SizedBox(width: 8),
                            Text('Details'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                game['title'] as String,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last played: ${game['lastPlayed']}',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: game['progress'] as double,
                backgroundColor: colorScheme.outline.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(game['color'] as Color),
              ),
              const SizedBox(height: 8),
              Text(
                'Progress: ${((game['progress'] as double) * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              AppButton(
                text: 'Continue',
                variant: ButtonVariant.primary,
                size: ButtonSize.small,
                isFullWidth: true,
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildAchievementsTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Mock data for achievements
    final achievements = [
      {
        'title': 'First Victory',
        'description': 'Complete your first game',
        'icon': Icons.emoji_events,
        'earned': true,
        'date': '2023-09-10',
      },
      {
        'title': 'Quick Learner',
        'description': 'Answer 10 questions correctly in a row',
        'icon': Icons.bolt,
        'earned': true,
        'date': '2023-09-15',
      },
      {
        'title': 'Math Wizard',
        'description': 'Score 100% in a math game',
        'icon': Icons.calculate,
        'earned': true,
        'date': '2023-10-02',
      },
      {
        'title': 'Science Expert',
        'description': 'Complete all levels in Science Explorer',
        'icon': Icons.science,
        'earned': false,
        'date': null,
      },
      {
        'title': 'Vocabulary Master',
        'description': 'Learn 100 new words',
        'icon': Icons.menu_book,
        'earned': false,
        'date': null,
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Achievements',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'You have earned ${achievements.where((a) => a['earned'] as bool).length} out of ${achievements.length} achievements',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              final isEarned = achievement['earned'] as bool;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isEarned 
                      ? colorScheme.surfaceVariant.withOpacity(0.3)
                      : colorScheme.surfaceVariant.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isEarned
                        ? colorScheme.primary.withOpacity(0.2)
                        : colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isEarned
                            ? colorScheme.primary.withOpacity(0.1)
                            : colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        achievement['icon'] as IconData,
                        color: isEarned
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant.withOpacity(0.5),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement['title'] as String,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            achievement['description'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (isEarned && achievement['date'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Earned on: ${achievement['date']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isEarned
                            ? colorScheme.primary
                            : colorScheme.surfaceVariant.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          isEarned ? Icons.check : Icons.lock_outline,
                          color: isEarned
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant.withOpacity(0.5),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildPerformanceTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Performance Analytics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Charts and visualizations coming soon...',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'View Basic Stats',
            variant: ButtonVariant.outline,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
} 