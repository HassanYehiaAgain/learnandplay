import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
// Import FirebaseModels with prefix to resolve conflict
import 'package:learn_play_level_up_flutter/models/firebase_models.dart' as firebase_models;
import 'package:learn_play_level_up_flutter/services/firebase_service.dart';
import 'package:learn_play_level_up_flutter/services/auth_service.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_play_level_up_flutter/services/tutorial_service.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/widgets/game/gamification_tutorial_game_view.dart';

class _MenuItem {
  final IconData icon;
  final String label;
  final String route;
  
  _MenuItem(this.icon, this.label, this.route);
}

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  firebase_models.FirebaseUser? _currentUser;
  
  // Data collections
  List<firebase_models.EducationalGame> _assignedGames = [];
  List<firebase_models.GameProgress> _gameProgress = [];
  List<firebase_models.Subject> _subjects = [];
  final Map<String, firebase_models.FirebaseUser> _teachersMap = {};
  
  // Filtered games
  String _selectedFilter = 'all'; // 'all', 'dueToday', 'overdue', 'completed', 'tutorial'
  String? _selectedSubject;
  
  // Show tutorial section - hide after first tutorial completion
  bool _showTutorial = true;
  
  // Add a property to track tutorial completion
  final TutorialService _tutorialService = TutorialService();
  bool _hasTutorialGame = false;
  GamificationTutorialGame? _tutorialGame;
  
  // Helper methods to get subject information
  String getSubjectName(String subjectId) {
    final subject = _subjects.firstWhere(
      (s) => s.id == subjectId,
      orElse: () => firebase_models.Subject(
        id: '',
        name: 'Unknown Subject',
        description: '',
        gradeYear: 0,
        teacherId: '',
        studentIds: [],
        createdAt: DateTime.now(),
      ),
    );
    return subject.name;
  }
  
  IconData getSubjectIcon(String subjectId) {
    final subject = _subjects.firstWhere(
      (s) => s.id == subjectId,
      orElse: () => firebase_models.Subject(
        id: '',
        name: '',
        description: '',
        gradeYear: 0,
        teacherId: '',
        studentIds: [],
        createdAt: DateTime.now(),
      ),
    );
    
    final name = subject.name.toLowerCase();
    if (name.contains('math')) return Icons.calculate;
    if (name.contains('language') || name.contains('english')) return Icons.menu_book;
    if (name.contains('science')) return Icons.science;
    if (name.contains('history') || name.contains('social')) return Icons.history_edu;
    if (name.contains('art')) return Icons.palette;
    if (name.contains('music')) return Icons.music_note;
    
    return Icons.school;
  }
  
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Fetch student data
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
      _errorMessage = null;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      
      // Get current user from Firebase
      _currentUser = await firebaseService.getCurrentUser();
      
      if (_currentUser == null || _currentUser!.role != 'student') {
        setState(() {
          _errorMessage = 'You must be logged in as a student to view this page';
          _isLoading = false;
        });
        return;
      }
      
      // Get enrolled subjects
      _subjects = await firebaseService.getStudentSubjects(_currentUser!.id);
      
      // Get all available games for this student
      _assignedGames = await firebaseService.getGamesForStudent(_currentUser!.id);
      
      // Get game progress
      _gameProgress = await firebaseService.getStudentGameProgress(_currentUser!.id);
      
      // Fetch teacher information
      final Set<String> teacherIds = {};
      for (final subject in _subjects) {
        teacherIds.add(subject.teacherId);
      }
      
      for (final teacherId in teacherIds) {
        final teacher = await firebaseService.getUserById(teacherId);
        if (teacher != null) {
          _teachersMap[teacherId] = teacher;
        }
      }
      
      // Check if tutorial should be shown
      // Logic: Hide tutorial if any game with "tutorial" in the title is completed
      final hasTutorialCompleted = _gameProgress.any((progress) {
        final game = _assignedGames.firstWhere(
          (g) => g.id == progress.gameId,
          orElse: () => firebase_models.EducationalGame(
            id: '',
            title: '',
            description: '',
            teacherId: '',
            subjectId: '',
            gradeYear: 0,
            createdAt: DateTime.now(),
            dueDate: DateTime.now(),
            isActive: false,
            questions: [],
            difficulty: 1,
            estimatedDuration: 0,
            tags: [],
            maxPoints: 0,
          ),
        );
        
        return progress.completedAt != null && 
               game.title.toLowerCase().contains('tutorial');
      });
      
      _showTutorial = !hasTutorialCompleted;
      
      // After loading user and student data, check if the user should see the tutorial
      await _checkForTutorialGame();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error in student dashboard: $e');
      String errorMessage = 'Error loading student data';
      
      // Check for Firebase index error
      if (e.toString().contains('failed-precondition') && 
          e.toString().contains('requires an index')) {
        errorMessage = 'Database configuration needed. Please contact your teacher or administrator.';
      }
      
      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
      });
    }
  }
  
  // New method to check if the user should have the tutorial game
  Future<void> _checkForTutorialGame() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.id;
      
      if (userId == null) return;
      
      // Check if user has completed the gamification tutorial
      final tutorialProgress = await _tutorialService.getUserTutorialProgress(userId);
      
      if (!tutorialProgress.hasCompletedGamification) {
        // Create a tutorial game if one doesn't exist
        setState(() {
          _hasTutorialGame = true;
          _tutorialGame = GamificationTutorialGame.createDefault();
        });
      }
    } catch (e) {
      debugPrint('Error checking for tutorial game: $e');
    }
  }

  // Record tutorial game completion
  Future<void> _markTutorialCompleted() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.id;
      
      if (userId == null) return;
      
      // Mark the gamification tutorial as completed
      await _tutorialService.markTutorialSequenceCompleted(userId, 'gamification');
      
      // Hide the tutorial game
      setState(() {
        _hasTutorialGame = false;
        _tutorialGame = null;
      });
    } catch (e) {
      debugPrint('Error marking tutorial as completed: $e');
    }
  }
  
  // Filter games based on selected filter and subject
  bool isVisible(firebase_models.EducationalGame game) {
    // Check if a game should be visible based on the selected filter
    final isCompleted = _gameProgress.any((progress) => 
      progress.gameId == game.id && progress.completedAt != null
    );
    
    if (_selectedFilter == 'tutorial') {
      // Only show games with the 'tutorial' tag when this filter is selected
      return game.tags.contains('tutorial');
    } else if (_selectedFilter == 'completed' && !isCompleted) {
      return false;
    } else if (_selectedFilter == 'dueToday') {
      // Format the date to ignore time
      final today = DateTime.now();
      final formattedToday = DateTime(today.year, today.month, today.day);
      final dueDate = game.dueDate;
      final formattedDueDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
      
      return formattedDueDate.isAtSameMomentAs(formattedToday);
    } else if (_selectedFilter == 'overdue') {
      final today = DateTime.now();
      return game.dueDate.isBefore(today) && !isCompleted;
    }
    
    // 'all' filter or other cases
    return true;
  }
  
  // Get games by completion status
  List<firebase_models.EducationalGame> get completedGames {
    final completedGameIds = _gameProgress
        .where((progress) => progress.completedAt != null)
        .map((progress) => progress.gameId)
        .toSet();
    
    return _assignedGames
        .where((game) => completedGameIds.contains(game.id))
        .toList();
  }
  
  List<firebase_models.EducationalGame> get inProgressGames {
    final completedGameIds = _gameProgress
        .where((progress) => progress.completedAt != null)
        .map((progress) => progress.gameId)
        .toSet();
    
    final inProgressGameIds = _gameProgress
        .where((progress) => progress.completedAt == null)
        .map((progress) => progress.gameId)
        .toSet();
    
    return _assignedGames
        .where((game) => 
            inProgressGameIds.contains(game.id) && 
            !completedGameIds.contains(game.id))
        .toList();
  }
  
  List<firebase_models.EducationalGame> get newGames {
    final progressGameIds = _gameProgress
        .map((progress) => progress.gameId)
        .toSet();
    
    return _assignedGames
        .where((game) => !progressGameIds.contains(game.id))
        .toList();
  }
  
  // Get progress for a specific game
  firebase_models.GameProgress? getProgressForGame(String gameId) {
    try {
      return _gameProgress.firstWhere(
        (progress) => progress.gameId == gameId,
      );
    } catch (e) {
      return null;
    }
  }

  // Filter games based on selected filter and subject
  List<firebase_models.EducationalGame> get filteredGames {
    return _assignedGames.where((game) {
      // Filter by subject
      if (_selectedSubject != null && game.subjectId != _selectedSubject) {
        return false;
      }
      
      return isVisible(game);
    }).toList();
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
          Navbar(
            isAuthenticated: true, 
            username: _currentUser?.name,
            userRole: 'student',
            onSignOut: () async {
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.signOut();
              if (mounted) {
                GoRouter.of(context).go('/');
              }
            }
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: AppCard(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: colorScheme.error.withOpacity(0.7),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Could Not Load Student Dashboard',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppButton(
                                    text: 'Try Again',
                                    leadingIcon: Icons.refresh,
                                    onPressed: _fetchStudentData,
                                  ),
                                  const SizedBox(width: 16),
                                  AppButton(
                                    text: 'Return Home',
                                    variant: ButtonVariant.outline,
                                    onPressed: () => GoRouter.of(context).go('/'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Student stats and info card
                            Card(
                              margin: const EdgeInsets.only(bottom: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Row(
                                  children: [
                                    // Student basic info
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Welcome, ${_currentUser?.name ?? 'Student'}!',
                                            style: theme.textTheme.headlineMedium?.copyWith(
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _currentUser?.studentGradeYear == 0 
                                                ? 'Kindergarten' 
                                                : 'Grade ${_currentUser?.studentGradeYear ?? "Unknown"}',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Student stats
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          // XP
                                          _buildStatChip(
                                            context,
                                            Icons.star,
                                            '${_currentUser?.xp ?? 0} XP',
                                            colorScheme.primary,
                                          ),
                                          const SizedBox(width: 16),
                                          
                                          // Level
                                          _buildStatChip(
                                            context,
                                            Icons.trending_up,
                                            'Level ${(_currentUser?.xp ?? 0) ~/ 100 + 1}',
                                            colorScheme.secondary,
                                          ),
                                          const SizedBox(width: 16),
                                          
                                          // Coins
                                          _buildStatChip(
                                            context,
                                            Icons.monetization_on,
                                            '${_currentUser?.coins ?? 0} Coins',
                                            colorScheme.tertiary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Tutorial banner - show for new users
                            if (_hasTutorialGame && _tutorialGame != null)
                              _buildTutorialBanner(context),
                            
                            // Replace existing filters with the new _buildFilters method
                            _buildFilters(),
                            
                            // Tabs
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: _buildTabRow(),
                            ),
                            
                            // Games section
                            _buildGamesSection(context)
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatChip(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabRow() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'Assigned Games'),
        Tab(text: 'Completed Games'),
        Tab(text: 'Leaderboard'),
        Tab(text: 'Achievements'),
      ],
      labelColor: Theme.of(context).colorScheme.primary,
      unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
    );
  }
  
  Widget _buildGamesSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // If tutorial game exists and should be shown, convert it to Firebase model
    List<firebase_models.EducationalGame> allGames = [..._assignedGames];
    
    // Add tutorial game if it exists and we're viewing tutorials or all games
    if (_hasTutorialGame && _tutorialGame != null && 
        (_selectedFilter == 'all' || _selectedFilter == 'tutorial')) {
      // Create a temporary Firebase EducationalGame model from the tutorial game
      final tutorialGame = firebase_models.EducationalGame(
        id: 'tutorial_game',
        title: _tutorialGame!.title,
        description: _tutorialGame!.description,
        coverImage: null,
        teacherId: _tutorialGame!.teacherId,
        subjectId: _tutorialGame!.subjectId,
        gradeYear: _tutorialGame!.gradeYear,
        createdAt: _tutorialGame!.createdAt,
        dueDate: _tutorialGame!.dueDate,
        isActive: true,
        questions: [], // Empty list as we don't need the questions here
        difficulty: 1,
        estimatedDuration: 10,
        tags: ['tutorial'],
        maxPoints: 100,
      );
      
      allGames = [tutorialGame, ...allGames];
    }
    
    // Filter the games based on current filter and selected subject
    final games = allGames.where(isVisible).toList();
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Always show the TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Assigned Games Tab
                _buildAssignedGamesTab(games),
                
                // Completed Games Tab
                _buildCompletedGamesTab(),
                
                // Leaderboard Tab
                _buildLeaderboardTab(),
                
                // Achievements Tab
                _buildAchievementsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAssignedGamesTab(List<firebase_models.EducationalGame> games) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    
    // Always render the container with appropriate content
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: games.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videogame_asset_outlined,
                    size: 64,
                    color: colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No games available yet',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your teacher will assign games soon',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                final progress = getProgressForGame(game.id);
                
                return _buildGameCard(context, game, progress);
              },
            ),
    );
  }

  // Menu items
  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      onTap: () {
        context.go(route);
      },
    );
  }

  // Bottom navigation
  final _menuItems = [
    _MenuItem(Icons.home, 'Dashboard', '/student/dashboard'),
    _MenuItem(Icons.games, 'Games', '/student/games'),
    _MenuItem(Icons.analytics, 'My Progress', '/student/analytics'),
    _MenuItem(Icons.account_circle, 'Profile', '/student/profile'),
  ];

  // Update the dropdown items in the filter section
  Widget _buildFilters() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Game status filter
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Game Status',
                  prefixIcon: Icon(Icons.filter_list, color: Theme.of(context).colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: _selectedFilter,
                items: const [
                  DropdownMenuItem<String>(
                    value: 'all',
                    child: Text('All Games'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'dueToday',
                    child: Text('Due Today'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'overdue',
                    child: Text('Overdue'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'completed',
                    child: Text('Completed'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'tutorial',
                    child: Text('Tutorials'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedFilter = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            
            // Subject filter
            Expanded(
              child: DropdownButtonFormField<String?>(
                decoration: InputDecoration(
                  labelText: 'Subject',
                  prefixIcon: Icon(Icons.book, color: Theme.of(context).colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: _selectedSubject,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Subjects'),
                  ),
                  ..._subjects.map((subject) {
                    return DropdownMenuItem<String?>(
                      value: subject.id,
                      child: Text(subject.name),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSubject = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New method to build the tutorial banner
  Widget _buildTutorialBanner(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.purple.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.purple,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Student Tutorial',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Complete this tutorial to learn about rewards and gamification in the app!',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // Skip tutorial and mark as completed
                    _markTutorialCompleted();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurface,
                  ),
                  child: const Text('Skip'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the tutorial game
                    final tutorialGame = _tutorialGame;
                    if (tutorialGame != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GamificationTutorialGameView(
                            game: _tutorialGame!,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Start Tutorial'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, firebase_models.EducationalGame game, firebase_models.GameProgress? progress) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    
    // Get game status and color
    final isCompleted = progress != null && progress.completedAt != null;
    final isStarted = progress != null && progress.completedAt == null;
    final isOverdue = !isCompleted && game.dueDate.isBefore(now);
    final isDueSoon = !isCompleted && !isOverdue && 
        game.dueDate.difference(now).inDays <= 2;
    
    // Determine status text and color
    Color statusColor;
    String statusText;
    
    if (isCompleted) {
      statusColor = Colors.green;
      statusText = 'Completed';
    } else if (isOverdue) {
      statusColor = Colors.red;
      statusText = 'Overdue';
    } else if (isDueSoon) {
      statusColor = Colors.orange;
      statusText = 'Due Soon';
    } else if (isStarted) {
      statusColor = Colors.blue;
      statusText = 'In Progress';
    } else {
      statusColor = colorScheme.primary;
      statusText = 'New';
    }
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // Special handling for tutorial game
          if (game.id == 'tutorial_game' && _tutorialGame != null) {
            _showTutorialGame();
          } else {
            // Regular game navigation
            GoRouter.of(context).go('/student/games/${game.id}/play?type=quiz');
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      getSubjectIcon(game.subjectId),
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          getSubjectName(game.subjectId),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                game.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              if (isStarted) ...[
                LinearProgressIndicator(
                  value: (progress.completionPercentage ?? 0) / 100,
                  backgroundColor: colorScheme.primaryContainer.withOpacity(0.2),
                  color: statusColor,
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.event, size: 14, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        'Due: ${_formatDate(game.dueDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isOverdue ? Colors.red : colorScheme.onSurfaceVariant,
                          fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.timer, size: 14, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '${game.estimatedDuration} min',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: isStarted ? 'Continue' : 'Start',
                  variant: isStarted ? ButtonVariant.outline : ButtonVariant.primary,
                  onPressed: () {
                    // Special handling for tutorial game
                    if (game.id == 'tutorial_game' && _tutorialGame != null) {
                      _showTutorialGame();
                    } else {
                      // Regular game navigation
                      GoRouter.of(context).go('/student/games/${game.id}/play?type=quiz');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to show the tutorial game in a separate route
  void _showTutorialGame() {
    if (_tutorialGame == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamificationTutorialGameView(
          game: _tutorialGame!,
        ),
      ),
    );
  }

  Widget _buildCompletedGamesTab() {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    
    final completedGames = this.completedGames;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: completedGames.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No completed games yet',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your completed games will appear here',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: completedGames.length,
              itemBuilder: (context, index) {
                final game = completedGames[index];
                final progress = getProgressForGame(game.id);
                
                return _buildGameCard(context, game, progress);
              },
            ),
    );
  }
  
  Widget _buildLeaderboardTab() {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard_outlined,
              size: 64,
              color: colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Leaderboard Coming Soon',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Compare your scores with classmates',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAchievementsTab() {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Achievements Coming Soon',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Track your progress and unlock badges',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 