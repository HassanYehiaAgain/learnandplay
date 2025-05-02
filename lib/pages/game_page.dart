import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';

class GamePage extends StatefulWidget {
  final String gameId;
  
  const GamePage({
    Key? key,
    required this.gameId,
  }) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  bool _isLoading = true;
  int _currentQuestionIndex = 0;
  num _score = 0;
  bool _gameStarted = false;
  bool _gameCompleted = false;
  List<String> _selectedAnswers = [];
  
  // Mock game data
  late Map<String, dynamic> _gameData;
  
  @override
  void initState() {
    super.initState();
    _loadGameData();
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
    });
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
    }
    
    // Move to next question after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      if (_currentQuestionIndex < _gameData['questions'].length - 1) {
        setState(() {
          _currentQuestionIndex++;
        });
      } else {
        setState(() {
          _gameCompleted = true;
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
      backgroundColor: colorScheme.background,
      body: Column(
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
          
          // Progress bar
          LinearProgressIndicator(
            value: questionNumber / totalQuestions,
            backgroundColor: colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
          const SizedBox(height: 4),
          Text(
            'Question $questionNumber of $totalQuestions',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
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
                const SizedBox(height: 8),
                Text(
                  'Points: ${currentQuestion['points']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.primary,
                  ),
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
                    backgroundColor = colorScheme.surfaceVariant.withOpacity(0.3);
                    borderColor = colorScheme.outline.withOpacity(0.3);
                  }
                } else {
                  backgroundColor = isSelected
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceVariant.withOpacity(0.3);
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
                                ? (isSelected ? (isCorrect ? colorScheme.secondary : colorScheme.error) : colorScheme.surfaceVariant)
                                : colorScheme.surfaceVariant,
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
  
  Widget _buildGameInfoChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
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