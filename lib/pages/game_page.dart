import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';

class GamePage extends StatefulWidget {
  final String gameId;
  
  const GamePage({
    super.key,
    required this.gameId,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  bool _isLoading = true;
  int _currentQuestionIndex = 0;
  num _score = 0;
  bool _gameStarted = false;
  bool _gameCompleted = false;
  List<String> _selectedAnswers = [];
  
  // New state variables for enhanced features
  double _progressPercentage = 0.0;
  bool _showAchievement = false;
  String _achievementTitle = '';
  String _achievementDescription = '';
  IconData _achievementIcon = Icons.star;
  bool _showInstructions = false;
  late AnimationController _achievementAnimationController;
  late Animation<double> _achievementAnimation;
  
  // Mock game data
  late Map<String, dynamic> _gameData;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize achievement animation controller
    _achievementAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _achievementAnimation = CurvedAnimation(
      parent: _achievementAnimationController,
      curve: Curves.easeOutBack,
    );
    
    _loadGameData();
  }
  
  @override
  void dispose() {
    _achievementAnimationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadGameData() async {
    // In a real app, this would fetch from an API
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock game data based on ID
    _gameData = {
      'id': widget.gameId,
      'title': 'Math Challenge',
      'description': 'Test your math skills with these fun problems!',
      'author': 'Teacher Smith',
      'coverImage': null,
      'category': 'Mathematics',
      'difficulty': 3,
      'totalQuestions': 5,
      'estimatedTime': 10,
      'instructions': [
        'Read each question carefully',
        'Select the best answer from the options provided',
        'Earn points for each correct answer',
        'Try to complete the game within the estimated time',
        'You can only select one answer per question',
      ],
      'achievements': [
        {
          'id': 'first_correct',
          'title': 'First Step',
          'description': 'Answer your first question correctly',
          'icon': Icons.emoji_events,
          'condition': 'FIRST_CORRECT',
        },
        {
          'id': 'speed_demon',
          'title': 'Speed Demon',
          'description': 'Answer a question in under 5 seconds',
          'icon': Icons.speed,
          'condition': 'FAST_ANSWER',
        },
        {
          'id': 'perfect_score',
          'title': 'Perfect Score',
          'description': 'Get all questions correct',
          'icon': Icons.workspace_premium,
          'condition': 'PERFECT_SCORE',
        },
      ],
      'questions': [
        {
          'id': 'q1',
          'text': 'What is 9 × 7?',
          'options': [
            {'id': 'a', 'text': '56', 'isCorrect': false},
            {'id': 'b', 'text': '63', 'isCorrect': true},
            {'id': 'c', 'text': '72', 'isCorrect': false},
            {'id': 'd', 'text': '81', 'isCorrect': false},
          ],
          'points': 10,
          'hint': 'Try multiplying 9 x 7 = 63',
        },
        {
          'id': 'q2',
          'text': 'What is the square root of 144?',
          'options': [
            {'id': 'a', 'text': '12', 'isCorrect': true},
            {'id': 'b', 'text': '14', 'isCorrect': false},
            {'id': 'c', 'text': '16', 'isCorrect': false},
            {'id': 'd', 'text': '18', 'isCorrect': false},
          ],
          'points': 15,
          'hint': 'Find the number that, when multiplied by itself, equals 144',
        },
        {
          'id': 'q3',
          'text': 'If x + 5 = 12, what is x?',
          'options': [
            {'id': 'a', 'text': '5', 'isCorrect': false},
            {'id': 'b', 'text': '7', 'isCorrect': true},
            {'id': 'c', 'text': '8', 'isCorrect': false},
            {'id': 'd', 'text': '17', 'isCorrect': false},
          ],
          'points': 10,
          'hint': 'Subtract 5 from both sides of the equation',
        },
        {
          'id': 'q4',
          'text': 'What is the area of a rectangle with length 8 cm and width 5 cm?',
          'options': [
            {'id': 'a', 'text': '13 cm²', 'isCorrect': false},
            {'id': 'b', 'text': '26 cm²', 'isCorrect': false},
            {'id': 'c', 'text': '40 cm²', 'isCorrect': true},
            {'id': 'd', 'text': '45 cm²', 'isCorrect': false},
          ],
          'points': 20,
          'hint': 'Area = length × width',
        },
        {
          'id': 'q5',
          'text': 'What is 25% of 80?',
          'options': [
            {'id': 'a', 'text': '15', 'isCorrect': false},
            {'id': 'b', 'text': '20', 'isCorrect': true},
            {'id': 'c', 'text': '25', 'isCorrect': false},
            {'id': 'd', 'text': '30', 'isCorrect': false},
          ],
          'points': 15,
          'hint': '25% means one quarter or 0.25 of the total amount',
        },
      ],
    };
    
    setState(() {
      _isLoading = false;
      _selectedAnswers = List.filled(_gameData['questions'].length, '');
    });
  }
  
  void _startGame() {
    setState(() {
      _gameStarted = true;
      _currentQuestionIndex = 0;
      _score = 0;
      _gameCompleted = false;
      _progressPercentage = 0.0;
    });
    
    // Show instructions by default
    _toggleInstructions();
  }
  
  void _selectAnswer(String optionId) {
    if (_selectedAnswers[_currentQuestionIndex].isNotEmpty) {
      return; // Already answered
    }
    
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = optionId;
    });
    
    // Check if correct
    final currentQuestion = _gameData['questions'][_currentQuestionIndex];
    final correctOption = currentQuestion['options'].firstWhere((option) => option['isCorrect'] == true);
    
    if (optionId == correctOption['id']) {
      setState(() {
        _score += currentQuestion['points'];
      });
      
      // Check for achievements
      if (_currentQuestionIndex == 0) {
        _showAchievementPopup(
          'First Step',
          'Answered your first question correctly!',
          Icons.emoji_events,
        );
      }
    }
    
    // Update progress
    setState(() {
      _progressPercentage = (_currentQuestionIndex + 1) / _gameData['questions'].length;
    });
    
    // Move to next question after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      if (_currentQuestionIndex < _gameData['questions'].length - 1) {
        setState(() {
          _currentQuestionIndex++;
        });
      } else {
        _completeGame();
      }
    });
  }
  
  void _completeGame() {
    setState(() {
      _gameCompleted = true;
    });
    
    // Calculate total points
    num totalPoints = 0;
    for (var question in _gameData['questions']) {
      totalPoints += question['points'];
    }
    
    // Check for perfect score achievement
    if (_score == totalPoints) {
      _showAchievementPopup(
        'Perfect Score',
        'You answered all questions correctly!',
        Icons.workspace_premium,
      );
    }
  }
  
  void _showAchievementPopup(String title, String description, IconData icon) {
    setState(() {
      _showAchievement = true;
      _achievementTitle = title;
      _achievementDescription = description;
      _achievementIcon = icon;
    });
    
    _achievementAnimationController.forward(from: 0.0);
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showAchievement = false;
        });
      }
    });
  }
  
  void _toggleInstructions() {
    setState(() {
      _showInstructions = !_showInstructions;
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
      // Show the help button when game is started
      floatingActionButton: _gameStarted && !_gameCompleted ? FloatingActionButton(
        onPressed: _toggleInstructions,
        backgroundColor: colorScheme.primaryContainer,
        child: Icon(
          _showInstructions ? Icons.close : Icons.help_outline,
          color: colorScheme.onPrimaryContainer,
        ),
      ) : null,
      body: Stack(
        children: [
          Column(
            children: [
              const Navbar(isAuthenticated: true),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _gameStarted
                        ? _gameCompleted
                            ? _buildGameComplete(context)
                            : _buildGameplay(context, isSmallScreen)
                        : _buildGameIntro(context, isSmallScreen),
              ),
            ],
          ),
          
          // Achievement popup overlay
          if (_showAchievement)
            _buildAchievementPopup(context),
            
          // Instructions overlay
          if (_showInstructions && _gameStarted && !_gameCompleted)
            _buildInstructionsOverlay(context),
        ],
      ),
    );
  }
  
  Widget _buildGameIntro(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 24),
            
            // Game header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Game image
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.calculate,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _gameData['title'],
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'By ${_gameData['author']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildGameInfoChip(
                            context, 
                            Icons.category_outlined, 
                            _gameData['category'],
                          ),
                          const SizedBox(width: 12),
                          _buildGameInfoChip(
                            context, 
                            Icons.timer_outlined, 
                            '${_gameData['estimatedTime']} min',
                          ),
                          const SizedBox(width: 12),
                          _buildGameInfoChip(
                            context, 
                            Icons.question_mark_outlined, 
                            '${_gameData['totalQuestions']} questions',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Game description
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About this game',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _gameData['description'],
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Difficulty:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < _gameData['difficulty'] ? Icons.star : Icons.star_border,
                            color: index < _gameData['difficulty'] ? colorScheme.tertiary : colorScheme.outline,
                            size: 20,
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Start Game',
                    variant: ButtonVariant.primary,
                    size: ButtonSize.large,
                    isFullWidth: true,
                    leadingIcon: Icons.play_arrow,
                    onPressed: _startGame,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Game leaderboard
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leaderboard',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Placeholder for leaderboard
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.leaderboard_outlined,
                          size: 48,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Play the game to get on the leaderboard!',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGameplay(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentQuestion = _gameData['questions'][_currentQuestionIndex];
    final questionNumber = _currentQuestionIndex + 1;
    final totalQuestions = _gameData['questions'].length;
    
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _gameData['title'],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                'Score: $_score',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Enhanced Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progressPercentage,
                  minHeight: 10,
                  backgroundColor: colorScheme.outline.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question $questionNumber of $totalQuestions',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Points: ${currentQuestion['points']}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Progress indicators for each question
              Row(
                children: List.generate(
                  _gameData['questions'].length,
                  (index) {
                    Color indicatorColor;
                    if (index < _currentQuestionIndex) {
                      // Answered question
                      final questionAnswered = _gameData['questions'][index];
                      final correctOption = questionAnswered['options'].firstWhere((option) => option['isCorrect'] == true);
                      indicatorColor = _selectedAnswers[index] == correctOption['id'] 
                          ? colorScheme.secondary 
                          : colorScheme.error;
                    } else if (index == _currentQuestionIndex) {
                      // Current question
                      indicatorColor = colorScheme.primary;
                    } else {
                      // Upcoming question
                      indicatorColor = colorScheme.outline.withOpacity(0.3);
                    }
                    
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: indicatorColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Question
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentQuestion['text'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (currentQuestion.containsKey('hint') && _selectedAnswers[_currentQuestionIndex].isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.tertiary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorScheme.tertiary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: colorScheme.tertiary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                currentQuestion['hint'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurface,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Options
          Expanded(
            child: ListView.builder(
              itemCount: currentQuestion['options'].length,
              itemBuilder: (context, index) {
                final option = currentQuestion['options'][index];
                final isSelected = _selectedAnswers[_currentQuestionIndex] == option['id'];
                
                // Determine if we should show the answer feedback
                final bool showFeedback = _selectedAnswers[_currentQuestionIndex].isNotEmpty;
                final bool isCorrect = option['isCorrect'] == true;
                
                Color? backgroundColor;
                Color? borderColor;
                
                if (showFeedback) {
                  if (isSelected && isCorrect) {
                    // Selected and correct
                    backgroundColor = colorScheme.secondary.withOpacity(0.2);
                    borderColor = colorScheme.secondary;
                  } else if (isSelected && !isCorrect) {
                    // Selected but incorrect
                    backgroundColor = colorScheme.error.withOpacity(0.2);
                    borderColor = colorScheme.error;
                  } else if (!isSelected && isCorrect) {
                    // Not selected but this is the correct answer
                    backgroundColor = colorScheme.secondary.withOpacity(0.1);
                    borderColor = colorScheme.secondary.withOpacity(0.5);
                  } else {
                    // Not selected and not correct
                    backgroundColor = colorScheme.surfaceContainerHighest.withOpacity(0.3);
                    borderColor = colorScheme.outline.withOpacity(0.3);
                  }
                } else {
                  backgroundColor = isSelected
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest.withOpacity(0.3);
                  borderColor = isSelected
                      ? colorScheme.primary
                      : colorScheme.outline.withOpacity(0.3);
                }
                
                return GestureDetector(
                  onTap: () {
                    if (_selectedAnswers[_currentQuestionIndex].isEmpty) {
                      _selectAnswer(option['id']);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: borderColor,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: showFeedback
                                ? (isSelected ? (isCorrect ? colorScheme.secondary : colorScheme.error) : colorScheme.surfaceContainerHighest)
                                : colorScheme.surfaceContainerHighest,
                            border: Border.all(
                              color: showFeedback
                                  ? (isSelected ? Colors.transparent : colorScheme.outline.withOpacity(0.3))
                                  : colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          child: Center(
                            child: showFeedback && isSelected
                                ? Icon(
                                    isCorrect ? Icons.check : Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : Text(
                                    option['id'].toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            option['text'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (showFeedback && isCorrect) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.check_circle_outline,
                            color: colorScheme.secondary,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGameComplete(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Calculate total points
    num totalPoints = 0;
    for (var question in _gameData['questions']) {
      totalPoints += question['points'];
    }
    
    final percentage = (_score / totalPoints) * 100;
    
    String feedback;
    IconData feedbackIcon;
    Color feedbackColor;
    
    if (percentage >= 80) {
      feedback = 'Excellent job!';
      feedbackIcon = Icons.emoji_events;
      feedbackColor = colorScheme.tertiary;
    } else if (percentage >= 60) {
      feedback = 'Good work!';
      feedbackIcon = Icons.thumb_up;
      feedbackColor = colorScheme.secondary;
    } else {
      feedback = 'Keep practicing!';
      feedbackIcon = Icons.replay;
      feedbackColor = colorScheme.primary;
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: feedbackColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                feedbackIcon,
                size: 80,
                color: feedbackColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Game Complete!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              feedback,
              style: TextStyle(
                fontSize: 20,
                color: feedbackColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Your Score',
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_score / $totalPoints',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '${percentage.round()}%',
              style: TextStyle(
                fontSize: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppButton(
                  text: 'Play Again',
                  variant: ButtonVariant.primary,
                  leadingIcon: Icons.replay,
                  onPressed: _startGame,
                ),
                const SizedBox(width: 16),
                AppButton(
                  text: 'Back to Games',
                  variant: ButtonVariant.outline,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAchievementPopup(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Center(
        child: ScaleTransition(
          scale: _achievementAnimation,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _achievementIcon,
                    size: 40,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Achievement Unlocked!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _achievementTitle,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _achievementDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 10,
                      width: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 10,
                      width: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 10,
                      width: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildInstructionsOverlay(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      color: colorScheme.background.withOpacity(0.9),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Game Instructions',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: _toggleInstructions,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _gameData['instructions'].length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _gameData['instructions'][index],
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Got it!',
                variant: ButtonVariant.primary,
                isFullWidth: true,
                onPressed: _toggleInstructions,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildGameInfoChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
} 