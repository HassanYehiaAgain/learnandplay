import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';

class TeacherPage extends StatefulWidget {
  const TeacherPage({super.key});

  @override
  State<TeacherPage> createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  
  // Resources quick access panel state
  bool _isResourcesPanelExpanded = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
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
      backgroundColor: colorScheme.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/teacher/games/create');
        },
        backgroundColor: colorScheme.primary,
        icon: Icon(Icons.add, color: colorScheme.onPrimary),
        label: Text('Create Game', style: TextStyle(color: colorScheme.onPrimary)),
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
                      color: colorScheme.onSurface,
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
              Row(
                children: [
                  AppButton(
                    text: 'Quick Resources',
                    variant: ButtonVariant.outline,
                    leadingIcon: Icons.book,
                    onPressed: () {
                      setState(() {
                        _isResourcesPanelExpanded = !_isResourcesPanelExpanded;
                      });
                    },
                  ),
                  const SizedBox(width: 12),
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
            ],
          ),
          const SizedBox(height: 24),
          
          // Quick Resources Panel (Collapsible)
          if (_isResourcesPanelExpanded) _buildResourcesPanel(context),
          if (_isResourcesPanelExpanded) const SizedBox(height: 24),
          
          // Stats Overview Cards
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                SizedBox(
                  width: 200,
                  child: _buildStatCard(
                    context,
                    'Games Created',
                    '8',
                    Icons.videogame_asset,
                    colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 200,
                  child: _buildStatCard(
                    context,
                    'Active Students',
                    '34',
                    Icons.people,
                    colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 200,
                  child: _buildStatCard(
                    context,
                    'Total Plays',
                    '127',
                    Icons.bar_chart,
                    colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 200,
                  child: _buildStatCard(
                    context,
                    'Avg. Score',
                    '78%',
                    Icons.insert_chart,
                    Colors.amber,
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
                Tab(text: 'Classes'),
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
                _buildClassesTab(context),
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
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Analytics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Performance Chart
              Expanded(
                flex: 2,
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student Progress Over Time',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bar_chart,
                                size: 48,
                                color: colorScheme.primary.withOpacity(0.7),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Student performance chart',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        text: 'View Detailed Report',
                        variant: ButtonVariant.outline,
                        size: ButtonSize.small,
                        leadingIcon: Icons.analytics,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Top Performers
              Expanded(
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top Performers',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (var i = 0; i < 5; i++)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: i == 0 
                              ? colorScheme.tertiary.withOpacity(0.1)
                              : colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: i == 0 
                                    ? colorScheme.tertiary.withOpacity(0.2)
                                    : colorScheme.surfaceContainerHighest,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: i == 0 
                                        ? colorScheme.tertiary
                                        : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Student ${i + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      '${95 - i * 3}% avg. score',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.emoji_events,
                                size: 16,
                                color: i == 0 
                                  ? colorScheme.tertiary
                                  : colorScheme.onSurfaceVariant.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Game Performance
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Game Performance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (var i = 0; i < 4; i++)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 40,
                              height: 80 + (i % 3) * 30.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: [
                                  colorScheme.primary,
                                  colorScheme.secondary,
                                  colorScheme.tertiary,
                                  colorScheme.error,
                                ][i].withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Game ${i + 1}',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildClassesTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final classes = [
      {
        'name': 'Math 101',
        'students': 18,
        'grade': '5th Grade',
        'games': 5,
        'avgScore': 82,
        'icon': Icons.calculate,
        'color': colorScheme.primary,
      },
      {
        'name': 'Science Introduction',
        'students': 16,
        'grade': '6th Grade',
        'games': 3,
        'avgScore': 75,
        'icon': Icons.science,
        'color': colorScheme.tertiary,
      },
      {
        'name': 'Literature Basics',
        'students': 14,
        'grade': '4th Grade',
        'games': 6,
        'avgScore': 88,
        'icon': Icons.menu_book,
        'color': colorScheme.secondary,
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Classes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            AppButton(
              text: 'Create New Class',
              variant: ButtonVariant.outline,
              size: ButtonSize.small,
              leadingIcon: Icons.add,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: classes.length + 1, // +1 for "Create New Class" card
            itemBuilder: (context, index) {
              // "Create New Class" card
              if (index == classes.length) {
                return AppCard(
                  isHoverable: true,
                  onTap: () {},
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            size: 32,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Create New Class',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              final classData = classes[index];
              
              return AppCard(
                isHoverable: true,
                onTap: () {},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (classData['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            classData['icon'] as IconData,
                            color: classData['color'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                classData['name'] as String,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                classData['grade'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
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
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildClassStat(
                          context, 
                          'Students', 
                          classData['students'].toString(),
                          Icons.people,
                        ),
                        _buildClassStat(
                          context, 
                          'Games', 
                          classData['games'].toString(),
                          Icons.games,
                        ),
                        _buildClassStat(
                          context, 
                          'Avg. Score', 
                          '${classData['avgScore']}%',
                          Icons.score,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'View Class',
                            variant: ButtonVariant.outline,
                            size: ButtonSize.small,
                            isFullWidth: true,
                            leadingIcon: Icons.visibility,
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppButton(
                            text: 'Assign Game',
                            variant: ButtonVariant.primary,
                            size: ButtonSize.small,
                            isFullWidth: true,
                            leadingIcon: Icons.assignment,
                            onPressed: () {},
                          ),
                        ),
                      ],
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
  
  Widget _buildClassStat(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
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
  
  Widget _buildResourcesPanel(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final resources = [
      {
        'title': 'Lesson Planning Guide',
        'description': 'Templates and tips for effective lesson planning',
        'icon': Icons.description,
        'color': colorScheme.primary,
      },
      {
        'title': 'Game Creation Tutorial',
        'description': 'Step by step guide to creating engaging educational games',
        'icon': Icons.gamepad,
        'color': colorScheme.secondary,
      },
      {
        'title': 'Student Assessment Tools',
        'description': 'Methods for tracking and evaluating student progress',
        'icon': Icons.assessment,
        'color': colorScheme.tertiary,
      },
      {
        'title': 'Classroom Management',
        'description': 'Strategies for effective classroom organization',
        'icon': Icons.people,
        'color': Colors.amber,
      },
    ];
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Teaching Resources',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  setState(() {
                    _isResourcesPanelExpanded = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: resources.length,
            itemBuilder: (context, index) {
              final resource = resources[index];
              
              return AppCard(
                isHoverable: true,
                onTap: () {},
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (resource['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        resource['icon'] as IconData,
                        color: resource['color'] as Color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      resource['title'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        resource['description'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 