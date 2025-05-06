import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/services/gamification_service.dart';

class QuizShowGameView extends StatefulWidget {
  final QuizShowGame gameData;
  final Function(int score, int maxScore, Duration duration) onGameComplete;
  final VoidCallback onExit;

  const QuizShowGameView({
    super.key,
    required this.gameData,
    required this.onGameComplete,
    required this.onExit,
  });

  @override
  State<QuizShowGameView> createState() => _QuizShowGameViewState();
}

class _QuizShowGameViewState extends State<QuizShowGameView> with TickerProviderStateMixin {
  // Game state
  int _score = 0;
  final Set<String> _answeredQuestionIds = {};
  DateTime? _startTime;
  DateTime? _endTime;
  
  // Current question state
  QuizQuestion? _selectedQuestion;
  bool _isAnswering = false;
  String _userAnswer = '';
  bool _isAnswerCorrect = false;
  bool _hasCheckedAnswer = false;
  
  // Timer for question
  late AnimationController _timerController;
  int? _secondsRemaining;
  bool _timeIsUp = false;
  
  // Animations
  late AnimationController _boardAnimationController;
  late Animation<double> _boardAnimation;
  late AnimationController _questionAnimationController;
  late Animation<double> _questionAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize board animation
    _boardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _boardAnimation = CurvedAnimation(
      parent: _boardAnimationController,
      curve: Curves.easeOutQuad,
    );
    
    // Initialize question animation
    _questionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _questionAnimation = CurvedAnimation(
      parent: _questionAnimationController,
      curve: Curves.easeOutBack,
    );
    
    // Initialize timer
    _timerController = AnimationController(
      duration: const Duration(seconds: 30), // Default 30 seconds
      vsync: this,
    );
    
    _timerController.addListener(() {
      if (mounted && _selectedQuestion != null) {
        final timeLimit = _selectedQuestion!.timeLimit ?? 30;
        setState(() {
          _secondsRemaining = (timeLimit * (1 - _timerController.value)).ceil();
        });
      }
    });
    
    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isAnswering) {
        setState(() {
          _timeIsUp = true;
          _hasCheckedAnswer = true;
          _isAnswerCorrect = false;
        });
      }
    });
    
    _startGame();
  }
  
  @override
  void dispose() {
    _boardAnimationController.dispose();
    _questionAnimationController.dispose();
    _timerController.dispose();
    super.dispose();
  }
  
  void _startGame() {
    _startTime = DateTime.now();
    _boardAnimationController.forward();
  }
  
  void _selectQuestion(QuizCategory category, QuizQuestion question) {
    // Skip if already answered
    if (_answeredQuestionIds.contains(question.id)) {
      return;
    }
    
    setState(() {
      _selectedQuestion = question;
      _isAnswering = true;
      _userAnswer = '';
      _hasCheckedAnswer = false;
      _isAnswerCorrect = false;
      _timeIsUp = false;
      _secondsRemaining = question.timeLimit ?? 30;
      
      // Reset and start timer
      _timerController.duration = Duration(seconds: question.timeLimit ?? 30);
      _timerController.reset();
      _timerController.forward();
    });
    
    _questionAnimationController.forward(from: 0.0);
  }
  
  void _checkAnswer() {
    if (_userAnswer.trim().isEmpty) {
      return;
    }
    
    final correctAnswer = _selectedQuestion!.answer?.toLowerCase().trim() ?? '';
    final userAnswer = _userAnswer.toLowerCase().trim();
    
    // Stop timer
    _timerController.stop();
    
    // Exact match
    final exactMatch = userAnswer == correctAnswer;
    
    // Calculate the score
    int earnedPoints = 0;
    if (exactMatch) {
      earnedPoints = _selectedQuestion!.points;
      _isAnswerCorrect = true;
    } else if (widget.gameData.allowPartialPoints) {
      // Check for partial match (if enabled)
      // Simple implementation: check if answer contains key words
      final correctWords = correctAnswer.split(' ');
      final userWords = userAnswer.split(' ');
      
      int matchedWords = 0;
      for (final word in userWords) {
        if (word.length > 3 && correctWords.contains(word)) {
          matchedWords++;
        }
      }
      
      if (matchedWords > 0) {
        final matchRatio = matchedWords / correctWords.length;
        earnedPoints = (matchRatio * _selectedQuestion!.points).round();
        _isAnswerCorrect = earnedPoints > (_selectedQuestion!.points / 2);
      }
    }
    
    setState(() {
      _score += earnedPoints;
      _hasCheckedAnswer = true;
      _answeredQuestionIds.add(_selectedQuestion!.id);
    });
    
    // Provide haptic feedback
    if (_isAnswerCorrect) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.vibrate();
    }
  }
  
  void _returnToBoard() {
    setState(() {
      _selectedQuestion = null;
      _isAnswering = false;
    });
    
    _boardAnimationController.forward(from: 0.0);
  }
  
  void _finishGame() {
    _endTime = DateTime.now();
    final duration = _endTime!.difference(_startTime!);
    widget.onGameComplete(_score, _calculateMaxScore(), duration);
  }
  
  int _calculateMaxScore() {
    int maxScore = 0;
    for (var category in widget.gameData.categories) {
      for (var question in category.questions) {
        maxScore += question.points;
      }
    }
    return maxScore;
  }
  
  bool _allQuestionsAnswered() {
    int totalQuestions = 0;
    for (var category in widget.gameData.categories) {
      totalQuestions += category.questions.length;
    }
    return _answeredQuestionIds.length >= totalQuestions;
  }

  @override
  Widget build(BuildContext context) {
    if (_isAnswering && _selectedQuestion != null) {
      return _buildQuestionView();
    } else {
      return _buildGameBoard();
    }
  }
  
  Widget _buildGameBoard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      children: [
        // Top bar with score and exit
        _buildTopBar(),
        
        // Game board
        Expanded(
          child: AnimatedBuilder(
            animation: _boardAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _boardAnimation.value,
                child: Opacity(
                  opacity: _boardAnimation.value,
                  child: child,
                ),
              );
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Game title
                  Text(
                    widget.gameData.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Categories and questions
                  for (final category in widget.gameData.categories) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primaryContainer,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Category header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(11),
                                topRight: Radius.circular(11),
                              ),
                            ),
                            child: Text(
                              category.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: colorScheme.onPrimaryContainer,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          
                          // Questions
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                for (final question in category.questions)
                                  _buildQuestionTile(category, question),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Finish game button
                  ElevatedButton.icon(
                    onPressed: _allQuestionsAnswered() ? _finishGame : null,
                    icon: const Icon(Icons.done_all),
                    label: const Text('Finish Game'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: colorScheme.onPrimary,
                      backgroundColor: colorScheme.primary,
                      disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
                      disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuestionTile(QuizCategory category, QuizQuestion question) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final isAnswered = _answeredQuestionIds.contains(question.id);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isAnswered ? null : () => _selectQuestion(category, question),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 100,
          height: 60,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isAnswered 
                ? colorScheme.surfaceContainerHighest.withOpacity(0.5)
                : colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isAnswered
                  ? colorScheme.outline.withOpacity(0.3)
                  : colorScheme.secondaryContainer,
            ),
          ),
          child: Center(
            child: Text(
              isAnswered ? '✓' : '${question.points}',
              style: TextStyle(
                fontSize: isAnswered ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: isAnswered
                    ? colorScheme.onSurfaceVariant.withOpacity(0.5)
                    : colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuestionView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      children: [
        // Top bar with timer
        _buildTopBar(),
        
        // Question content
        Expanded(
          child: AnimatedBuilder(
            animation: _questionAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _questionAnimation.value,
                child: Opacity(
                  opacity: _questionAnimation.value,
                  child: child,
                ),
              );
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Point value
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Points: ${_selectedQuestion!.points}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Question text
                  Text(
                    _selectedQuestion!.questionText,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // Question image if available
                  if (_selectedQuestion!.imageUrl != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _selectedQuestion!.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.broken_image, size: 64),
                          ),
                        ),
                      ),
                    ),
                  ],
                  
                  // Answer input field
                  if (!_hasCheckedAnswer) ...[
                    const SizedBox(height: 32),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _userAnswer = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Your Answer',
                        hintText: 'Type your answer here',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                        suffixIcon: _userAnswer.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _userAnswer = '';
                                  });
                                },
                              )
                            : null,
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _checkAnswer(),
                      enabled: !_timeIsUp,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _userAnswer.isNotEmpty && !_timeIsUp ? _checkAnswer : null,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Submit Answer'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: colorScheme.onPrimary,
                        backgroundColor: colorScheme.primary,
                        disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
                        disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ] else ...[
                    // Show result
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isAnswerCorrect
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isAnswerCorrect
                              ? Colors.green
                              : Colors.red,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _isAnswerCorrect ? Icons.check_circle : Icons.cancel,
                            color: _isAnswerCorrect ? Colors.green : Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isAnswerCorrect ? 'Correct!' : 'Incorrect',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _isAnswerCorrect ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Your answer: $_userAnswer',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Correct answer: ${_selectedQuestion!.answer}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _returnToBoard,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to Board'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: colorScheme.onPrimaryContainer,
                        backgroundColor: colorScheme.primaryContainer,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTopBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final maxScore = _calculateMaxScore();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Exit button
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onExit,
            tooltip: 'Exit Game',
          ),
          const SizedBox(width: 8),
          
          // Score or progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (_isAnswering && _selectedQuestion != null) ...[
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: !_hasCheckedAnswer 
                            ? () {
                                _timerController.stop();
                                _returnToBoard();
                              }
                            : null,
                        tooltip: 'Back to Board',
                      ),
                    ] else ...[
                      Text(
                        'Questions: ${_answeredQuestionIds.length}/${_getTotalQuestionCount()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    Text(
                      'Score: $_score/$maxScore',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: _answeredQuestionIds.length / _getTotalQuestionCount(),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
          
          // Timer if applicable
          if (_isAnswering && _secondsRemaining != null) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _secondsRemaining! < 10
                    ? Colors.red.shade100
                    : colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: _secondsRemaining! < 10 ? Colors.red : null,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_secondsRemaining s',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _secondsRemaining! < 10
                          ? Colors.red
                          : colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  int _getTotalQuestionCount() {
    int count = 0;
    for (final category in widget.gameData.categories) {
      count += category.questions.length;
    }
    return count;
  }
} 