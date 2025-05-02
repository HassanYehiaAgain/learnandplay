import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';

class TeacherPage extends StatefulWidget {
  const TeacherPage({Key? key}) : super(key: key);

  @override
  State<TeacherPage> createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Fetch teacher data, created games, etc.
    _fetchTeacherData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _fetchTeacherData() async {
    setState(() {
      _isLoading = true;
    });
    
    // TODO: Implement API calls to fetch teacher data
    
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/teacher/games/create');
        },
        backgroundColor: colorScheme.primary,
        child: Icon(Icons.add, color: colorScheme.onPrimary),
      ),
      body: Column(
        children: [
          const Navbar(isAuthenticated: true, userRole: 'teacher'),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Teacher Dashboard',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create games, manage students, and track performance',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              AppButton(
                text: 'Create New Game',
                variant: ButtonVariant.primary,
                leadingIcon: Icons.add,
                onPressed: () {
                  Navigator.pushNamed(context, '/teacher/games/create');
                },
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
                    'Games Created',
                    '8',
                    Icons.videogame_asset,
                    colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Active Students',
                    '34',
                    Icons.people,
                    colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Plays',
                    '127',
                    Icons.bar_chart,
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
                Tab(text: 'Students'),
                Tab(text: 'Analytics'),
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
                _buildStudentsTab(context),
                _buildAnalyticsTab(context),
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
    
    // Mock data for created games
    final createdGames = [
      {
        'title': 'Math Challenge',
        'description': 'Fun math puzzles and problems for all grade levels',
        'plays': 43,
        'students': 12,
        'avgScore': 78,
        'lastPlayed': '2 days ago',
        'image': Icons.calculate,
        'color': colorScheme.primary,
      },
      {
        'title': 'Vocabulary Quest',
        'description': 'Build vocabulary through interactive word games',
        'plays': 67,
        'students': 18,
        'avgScore': 85,
        'lastPlayed': 'Yesterday',
        'image': Icons.menu_book,
        'color': colorScheme.secondary,
      },
      {
        'title': 'Science Explorer',
        'description': 'Discover scientific concepts through virtual experiments',
        'plays': 12,
        'students': 8,
        'avgScore': 92,
        'lastPlayed': '3 days ago',
        'image': Icons.science,
        'color': colorScheme.tertiary,
      },
      {
        'title': 'History Timeline',
        'description': 'Navigate through history with interactive timelines',
        'plays': 5,
        'students': 5,
        'avgScore': 72,
        'lastPlayed': '5 days ago',
        'image': Icons.history_edu,
        'color': colorScheme.error,
      },
    ];
    
    if (createdGames.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videogame_asset_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No games created yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first educational game',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Create Game',
              variant: ButtonVariant.primary,
              leadingIcon: Icons.add,
              onPressed: () {
                Navigator.pushNamed(context, '/teacher/games/create');
              },
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 1.5,
      ),
      itemCount: createdGames.length,
      itemBuilder: (context, index) {
        final game = createdGames[index];
        
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      game['title'] as String,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.content_copy),
                            SizedBox(width: 8),
                            Text('Duplicate'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {},
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Text(
                  game['description'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildGameStat(context, 'Plays', game['plays'].toString()),
                  _buildGameStat(context, 'Students', game['students'].toString()),
                  _buildGameStat(context, 'Avg. Score', '${game['avgScore']}%'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Preview',
                      variant: ButtonVariant.outline,
                      size: ButtonSize.small,
                      isFullWidth: true,
                      leadingIcon: Icons.visibility,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Edit',
                      variant: ButtonVariant.primary,
                      size: ButtonSize.small,
                      isFullWidth: true,
                      leadingIcon: Icons.edit,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildGameStat(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStudentsTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Student Management',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Student list and performance data coming soon...',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Invite Students',
            variant: ButtonVariant.outline,
            leadingIcon: Icons.person_add,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnalyticsTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Analytics Dashboard',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Detailed analytics and reports coming soon...',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Generate Basic Report',
            variant: ButtonVariant.outline,
            leadingIcon: Icons.download,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
} 