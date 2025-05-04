import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';
import 'package:learn_play_level_up_flutter/models/firebase_models.dart';
import 'package:learn_play_level_up_flutter/services/firebase_service.dart';
import 'package:learn_play_level_up_flutter/services/auth_service.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class _MenuItem {
  final IconData icon;
  final String label;
  final String route;
  
  _MenuItem(this.icon, this.label, this.route);
}

class TeacherPage extends StatefulWidget {
  const TeacherPage({super.key});

  @override
  State<TeacherPage> createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  FirebaseUser? _currentUser;
  
  // Data collections
  List<EducationalGame> _games = [];
  List<Subject> _subjects = [];
  Map<String, FirebaseUser> _studentsMap = {};
  Map<String, List<GameProgress>> _gameProgressMap = {};
  
  // Filter states
  String? _selectedSubjectId;
  int? _selectedGradeYear;
  String _dueFilter = 'all'; // 'all', 'overdue', 'upcoming', 'completed'
  
  // Analytics data
  int _totalStudents = 0;
  int _totalGames = 0;
  int _totalCompletions = 0;
  double _averageScore = 0;
  
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
      _errorMessage = null;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
    
      // Get current user from Firebase
      _currentUser = await firebaseService.getCurrentUser();
    
      if (_currentUser == null || _currentUser!.role != 'teacher') {
    setState(() {
          _errorMessage = 'You must be logged in as a teacher to view this page';
      _isLoading = false;
    });
        return;
      }
      
      // Get all subjects for this teacher
      _subjects = await firebaseService.getTeacherSubjects(_currentUser!.id);
      
      // Get all games created by this teacher
      _games = await firebaseService.getTeacherGames(_currentUser!.id);
      
      // Collect all student IDs from all subjects
      final Set<String> studentIds = {};
      for (final subject in _subjects) {
        studentIds.addAll(subject.studentIds);
      }
      
      // Fetch student data for all students
      for (final studentId in studentIds) {
        final student = await firebaseService.getUserById(studentId);
        if (student != null) {
          _studentsMap[studentId] = student;
        }
      }
      
      // Fetch game progress for each subject
      for (final subject in _subjects) {
        final progress = await firebaseService.getGameProgressForSubject(subject.id);
        _gameProgressMap[subject.id] = progress;
      }
      
      // Calculate analytics
      _totalStudents = studentIds.length;
      _totalGames = _games.length;
      
      // Calculate total completions and average scores
      int totalCompletions = 0;
      double scoreSum = 0;
      int scoreCount = 0;
      
      _gameProgressMap.forEach((_, progressList) {
        for (final progress in progressList) {
          if (progress.completedAt != null) {
            totalCompletions++;
            scoreSum += progress.score;
            scoreCount++;
          }
        }
      });
      
      _totalCompletions = totalCompletions;
      _averageScore = scoreCount > 0 ? scoreSum / scoreCount : 0;
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading teacher data: $e';
        _isLoading = false;
      });
    }
  }

  // Filter games based on selected filters
  List<EducationalGame> get filteredGames {
    return _games.where((game) {
      // Filter by subject
      if (_selectedSubjectId != null && game.subjectId != _selectedSubjectId) {
        return false;
      }
      
      // Filter by grade year
      if (_selectedGradeYear != null && game.gradeYear != _selectedGradeYear) {
        return false;
      }
      
      // Filter by due date
      final now = DateTime.now();
      if (_dueFilter == 'overdue') {
        return game.dueDate.isBefore(now) && game.isActive;
      } else if (_dueFilter == 'upcoming') {
        return game.dueDate.isAfter(now) && game.isActive;
      } else if (_dueFilter == 'completed') {
        return !game.isActive;
      }
      
      return true;
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          GoRouter.of(context).go('/teacher/games/templates');
        },
        backgroundColor: colorScheme.primary,
        icon: Icon(Icons.add, color: colorScheme.onPrimary),
        label: Text('Create Game', style: TextStyle(color: colorScheme.onPrimary)),
      ),
      body: Column(
        children: [
          Navbar(
            isAuthenticated: true, 
            username: _currentUser?.name,
            userRole: 'teacher',
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
                ? Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: colorScheme.error),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          text: 'Go to Home',
                          onPressed: () => GoRouter.of(context).go('/'),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome and simple stats section
                        Card(
                          margin: const EdgeInsets.only(bottom: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome, ${_currentUser?.name ?? 'Teacher'}!',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Create games, manage students, and track performance',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    AppButton(
                                      text: 'Create New Game',
                                      variant: ButtonVariant.gradient,
                                      leadingIcon: Icons.add_circle,
                                      onPressed: () {
                                        GoRouter.of(context).go('/teacher/games/templates');
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Filter and tabs row
                        Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    // Subject filter
                                    Expanded(
                                      child: DropdownButtonFormField<String?>(
                                        decoration: InputDecoration(
                                          labelText: 'Subject',
                                          prefixIcon: Icon(Icons.book, color: colorScheme.primary),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        value: _selectedSubjectId,
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
                                            _selectedSubjectId = value;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    // Grade Year filter
                                    Expanded(
                                      child: DropdownButtonFormField<int?>(
                                        decoration: InputDecoration(
                                          labelText: 'Grade Year',
                                          prefixIcon: Icon(Icons.school, color: colorScheme.primary),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        value: _selectedGradeYear,
                                        items: [
                                          const DropdownMenuItem<int?>(
                                            value: null,
                                            child: Text('All Grades'),
                                          ),
                                          for (var i = 0; i <= 12; i++)
                                            DropdownMenuItem<int?>(
                                              value: i,
                                              child: Text(i == 0 ? 'Kindergarten' : 'Grade $i'),
                                            ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedGradeYear = value;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    // Games filter
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                          labelText: 'Status',
                                          prefixIcon: Icon(Icons.filter_list, color: colorScheme.primary),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        value: _dueFilter,
                                        items: const [
                                          DropdownMenuItem<String>(
                                            value: 'all',
                                            child: Text('All Games'),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'overdue',
                                            child: Text('Overdue'),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'upcoming',
                                            child: Text('Upcoming'),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'completed',
                                            child: Text('Completed'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            if (value != null) {
                                              _dueFilter = value;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Tabs and content
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  tabs: const [
                                    Tab(text: 'My Games'),
                                    Tab(text: 'Students'),
                                    Tab(text: 'Analytics'),
                                    Tab(text: 'Classes'),
                                  ],
                                  labelColor: colorScheme.primary,
                                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  indicator: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: colorScheme.secondaryContainer,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    // My Games Tab
                                    _buildGamesTab(context),
                                    
                                    // Students Tab
                                    _buildStudentsTab(context),
                                    
                                    // Analytics Tab
                                    _buildAnalyticsTab(context),
                                    
                                    // Classes Tab
                                    _buildClassesTab(context),
                                  ],
                                ),
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
    );
  }
  
  Widget _buildGamesTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final games = filteredGames;
    
    if (games.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videogame_asset_off,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No games found',
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or create a new game',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Create New Game',
              variant: ButtonVariant.gradient,
              leadingIcon: Icons.add,
              onPressed: () {
                GoRouter.of(context).go('/teacher/games/templates');
              },
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        final subject = _subjects.firstWhere(
          (s) => s.id == game.subjectId,
          orElse: () => Subject(
            id: '',
            name: 'Unknown Subject',
            description: '',
            gradeYear: 0,
            teacherId: '',
            studentIds: [],
            createdAt: DateTime.now(),
          ),
        );
        
        // Get completion statistics for this game
        int completions = 0;
        double averageScore = 0;
        int totalScores = 0;
        
        for (final progressList in _gameProgressMap.values) {
          for (final progress in progressList) {
            if (progress.gameId == game.id && progress.completedAt != null) {
              completions++;
              totalScores += progress.score;
            }
          }
        }
        
        if (completions > 0) {
          averageScore = totalScores / completions;
        }

        final isOverdue = game.dueDate.isBefore(DateTime.now()) && game.isActive;
        final isUpcoming = game.dueDate.isAfter(DateTime.now()) && game.isActive;
        final isDueSoon = game.dueDate.difference(DateTime.now()).inDays <= 3 && isUpcoming;
        
        return _buildGameCard(
          context,
          game,
          subject,
          completions,
          averageScore,
          isOverdue,
          isDueSoon,
        );
      },
    );
  }
  
  Widget _buildGameCard(
    BuildContext context,
    EducationalGame game,
    Subject subject,
    int completions,
    double averageScore,
    bool isOverdue,
    bool isDueSoon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color statusColor = colorScheme.primary;
    String statusText = 'Active';
    IconData statusIcon = Icons.check_circle;
    
    if (!game.isActive) {
      statusColor = colorScheme.onSurfaceVariant;
      statusText = 'Completed';
      statusIcon = Icons.task_alt;
    } else if (isOverdue) {
      statusColor = colorScheme.error;
      statusText = 'Overdue';
      statusIcon = Icons.warning_amber;
    } else if (isDueSoon) {
      statusColor = Colors.orange;
      statusText = 'Due Soon';
      statusIcon = Icons.schedule;
    }
        
        return AppCard(
      onTap: () {
        // Navigate to game details
        GoRouter.of(context).go('/games/${game.id}');
      },
      backgroundColor: colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Header with subject and status
              Row(
                children: [
                  Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                    child: Text(
                  subject.name,
                      style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const Spacer(),
              Icon(statusIcon, color: statusColor, size: 16),
              const SizedBox(width: 4),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Game title
          Text(
            game.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          
          // Game description
          Text(
            subject.description != null && subject.description!.isNotEmpty
                ? subject.description!
                : 'No description available',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
          
          // Stats and due date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$completions played',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
              Row(
                children: [
                      Icon(
                        Icons.score,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Avg: ${averageScore.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
                    'Due date:',
          style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
                    DateFormat('MMM d, y').format(game.dueDate),
          style: TextStyle(
            fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isOverdue ? colorScheme.error : colorScheme.onSurface,
          ),
        ),
      ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () {
                  // Navigate to edit game
                },
                tooltip: 'Edit Game',
              ),
              IconButton(
                icon: const Icon(Icons.bar_chart, size: 18),
                onPressed: () {
                  // Navigate to stats
                },
                tooltip: 'View Statistics',
              ),
              IconButton(
                icon: Icon(
                  game.isActive ? Icons.archive : Icons.unarchive,
                  size: 18,
                ),
                onPressed: () {
                  // Toggle archive
                },
                tooltip: game.isActive ? 'Archive Game' : 'Unarchive Game',
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStudentsTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (_studentsMap.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
              Icons.people_alt,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
              'No students found',
            style: TextStyle(
              fontSize: 18,
                color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
              'Create classes and add students to get started',
            style: TextStyle(
              fontSize: 14,
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
        ],
      ),
    );
  }
  
    // Group students by grade year
    Map<int, List<FirebaseUser>> studentsByGrade = {};
    
    for (final student in _studentsMap.values) {
      if (student.studentGradeYear != null) {
        studentsByGrade.putIfAbsent(student.studentGradeYear!, () => []);
        studentsByGrade[student.studentGradeYear!]!.add(student);
      }
    }
    
    return ListView.builder(
      itemCount: studentsByGrade.length,
      itemBuilder: (context, index) {
        final gradeYear = studentsByGrade.keys.elementAt(index);
        final students = studentsByGrade[gradeYear]!;
        
        return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                gradeYear == 0 ? 'Kindergarten' : 'Grade $gradeYear',
            style: TextStyle(
                  fontSize: 18,
              fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
            
            // Student cards for this grade
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: students.length,
              itemBuilder: (context, studentIndex) {
                final student = students[studentIndex];
                
                // Calculate student stats
                int gamesCompleted = 0;
                int totalGamesAssigned = 0;
                double averageScore = 0;
                int totalScore = 0;
                
                for (final progressList in _gameProgressMap.values) {
                  for (final progress in progressList) {
                    if (progress.studentId == student.id) {
                      totalGamesAssigned++;
                      if (progress.completedAt != null) {
                        gamesCompleted++;
                        totalScore += progress.score;
                      }
                    }
                  }
                }
                
                if (gamesCompleted > 0) {
                  averageScore = totalScore / gamesCompleted;
                }
                
                return _buildStudentCard(
                  context,
                  student,
                  gamesCompleted,
                  totalGamesAssigned,
                  averageScore,
                );
              },
            ),
            
          const SizedBox(height: 16),
            const Divider(),
          ],
        );
      },
    );
  }
  
  Widget _buildStudentCard(
    BuildContext context,
    FirebaseUser student,
    int gamesCompleted,
    int totalGamesAssigned,
    double averageScore,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AppCard(
      backgroundColor: colorScheme.surface,
      child: Row(
            children: [
          // Avatar or initials
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: student.avatar != null && student.avatar!.isNotEmpty
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(student.avatar!),
                      radius: 25,
                    )
                  : Text(
                      student.name.isNotEmpty
                          ? student.name.substring(0, 1).toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Student info
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                  student.name,
                  style: const TextStyle(
                          fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                            children: [
                              Icon(
                      Icons.videogame_asset,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                              Text(
                      '$gamesCompleted/$totalGamesAssigned games',
                                style: TextStyle(
                        fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.score,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${averageScore.toStringAsFixed(1)}%',
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
          
          // Actions
          IconButton(
            icon: const Icon(Icons.visibility, size: 18),
            onPressed: () {
              // Navigate to student details
            },
            tooltip: 'View Details',
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnalyticsTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return ListView(
      children: [
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
          ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                'Game Completions',
                        style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
              const SizedBox(height: 8),
              Text(
                'Summary of game completions and average scores by subject',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                                child: Center(
                                  child: Text(
                    'Chart will be implemented here',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                                    ),
                                  ),
                                ),
            ],
          ),
        ),
        
        // Student Performance
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
          ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                'Student Performance',
                                      style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
              const SizedBox(height: 8),
                                    Text(
                'Score distribution across all students',
                                      style: TextStyle(
                  fontSize: 14,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: Text(
                    'Chart will be implemented here',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
                              ),
                            ],
                          ),
                        ),
        
        // Game Usage Metrics
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
          ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                'Game Usage Metrics',
                  style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                'Usage patterns and engagement metrics over time',
                              style: TextStyle(
                  fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: Text(
                    'Chart will be implemented here',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  ),
                ),
              ],
            ),
          ),
        ],
    );
  }
  
  Widget _buildClassesTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (_subjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
      children: [
            Icon(
              Icons.class_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No classes found',
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Contact your administrator to create classes',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }
    
    // Sort subjects by grade year
    final sortedSubjects = List<Subject>.from(_subjects)
      ..sort((a, b) => a.gradeYear.compareTo(b.gradeYear));
    
    return ListView.builder(
      itemCount: sortedSubjects.length,
            itemBuilder: (context, index) {
        final subject = sortedSubjects[index];
        final hasStudents = subject.studentIds.isNotEmpty;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              child: Text(
                subject.name.substring(0, 1).toUpperCase(),
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
            title: Text(
              subject.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Grade ${subject.gradeYear} • ${subject.studentIds.length} students',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
                  children: [
              Padding(
                padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                      'Class Description',
                                style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                    const SizedBox(height: 8),
                              Text(
                      subject.description != null && subject.description!.isNotEmpty
                          ? subject.description!
                          : 'No description available',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                    const SizedBox(height: 16),
                    
                    // Class stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildClassStat(
                          context, 
                          'Students', 
                            subject.studentIds.length.toString(),
                          Icons.people,
                        ),
                        ),
                        Expanded(
                          child: _buildClassStat(
                          context, 
                          'Games', 
                            _games.where((g) => g.subjectId == subject.id).length.toString(),
                            Icons.videogame_asset,
                        ),
                        ),
                        Expanded(
                          child: _buildClassStat(
                            context,
                            'Created',
                            DateFormat('MMM d, y').format(subject.createdAt),
                            Icons.calendar_today,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Students list
            Text(
                      'Students',
              style: TextStyle(
                fontSize: 16,
                        fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
                    const SizedBox(height: 8),
                    
                    if (!hasStudents)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No students in this class yet',
          style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: subject.studentIds.length,
                        itemBuilder: (context, studentIndex) {
                          final studentId = subject.studentIds[studentIndex];
                          final student = _studentsMap[studentId];
                          
                          if (student == null) {
                            return ListTile(
                              title: Text('Unknown Student (ID: $studentId)'),
                              subtitle: const Text('Student data not available'),
                            );
                          }
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: colorScheme.secondary.withOpacity(0.1),
                              child: Text(
                                student.name.substring(0, 1).toUpperCase(),
                                style: TextStyle(color: colorScheme.secondary),
                              ),
                            ),
                            title: Text(student.name),
                            subtitle: Text(
                              'XP: ${student.xp} • Streak: ${student.currentStreak} days',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: colorScheme.error,
                              onPressed: () {
                                // Show confirmation dialog for removing student
                              },
                              tooltip: 'Remove Student',
                            ),
                          );
                        },
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
            children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit Class'),
                          onPressed: () {
                            // Navigate to edit class
                            GoRouter.of(context).go('/subjects');
                          },
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.person_add, size: 16),
                          label: const Text('Add Students'),
                onPressed: () {
                            // Show dialog to add students
                },
              ),
            ],
          ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildClassStat(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
                child: Column(
                  children: [
          Icon(icon, color: colorScheme.primary, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
                    Text(
            label,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
          ),
        ],
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
    _MenuItem(Icons.home, 'Dashboard', '/teacher/dashboard'),
    _MenuItem(Icons.analytics, 'Analytics', '/teacher/analytics'),
    _MenuItem(Icons.games, 'Games', '/teacher/games'),
    _MenuItem(Icons.account_circle, 'Profile', '/teacher/profile'),
  ];
} 