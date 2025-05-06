import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_play_level_up_flutter/models/firebase_models.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EducationalQuizGameView extends StatefulWidget {
  final EducationalGame gameData;
  final Function(int score, int maxScore, Duration duration) onGameComplete;
  final VoidCallback onExit;

  const EducationalQuizGameView({
    super.key,
    required this.gameData,
    required this.onGameComplete,
    required this.onExit,
  });

  @override
  State<EducationalQuizGameView> createState() => _EducationalQuizGameViewState();
}

class _EducationalQuizGameViewState extends State<EducationalQuizGameView> with TickerProviderStateMixin {
  // Game state
  int _currentQuestionIndex = 0;
  int _score = 0;
  DateTime? _startTime;
  List<bool> _answeredCorrectly = [];
  List<int> _pointsEarned = [];
  List<int> _timeSpent = [];
  String? _selectedOptionId;
  
  // Timer for question
  late AnimationController _timerController;
  int? _secondsRemaining;
  bool _timeIsUp = false;
  
  // Animations
  late AnimationController _questionAnimationController;
  late Animation<double> _questionAnimation;
  late AnimationController _resultAnimationController;
  late Animation<double> _resultAnimation;
  
  // Question state
  bool _showResult = false;
  bool _isLastQuestion = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize arrays for tracking question results
    _answeredCorrectly = List.filled(widget.gameData.questions.length, false);
    _pointsEarned = List.filled(widget.gameData.questions.length, 0);
    _timeSpent = List.filled(widget.gameData.questions.length, 0);
    
    // Initialize animations
    _questionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _questionAnimation = CurvedAnimation(
      parent: _questionAnimationController,
      curve: Curves.easeOutBack,
    );
    
    _resultAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _resultAnimation = CurvedAnimation(
      parent: _resultAnimationController,
      curve: Curves.easeOutQuad,
    );
    
    // Initialize timer
    _timerController = AnimationController(
      duration: const Duration(seconds: 30), // Default, will update per question
      vsync: this,
    );
    
    _timerController.addListener(() {
      if (mounted) {
        setState(() {
          final timeLimit = widget.gameData.questions[_currentQuestionIndex].timeLimit;
          _secondsRemaining = (timeLimit * (1 - _timerController.value)).ceil();
          // Update time spent as the timer progresses
          _timeSpent[_currentQuestionIndex] = (timeLimit * _timerController.value).ceil();
        });
      }
    });
    
    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_showResult) {
        _onTimeUp();
      }
    });
    
    _startGame();
  }
  
  @override
  void dispose() {
    _timerController.dispose();
    _questionAnimationController.dispose();
    _resultAnimationController.dispose();
    super.dispose();
  }
  
  void _startGame() {
    _startTime = DateTime.now();
    _updateQuestionState();
    _questionAnimationController.forward();
  }
  
  void _updateQuestionState() {
    setState(() {
      // Update if this is the last question
      _isLastQuestion = _currentQuestionIndex == widget.gameData.questions.length - 1;
      
      // Reset question-specific state
      _selectedOptionId = null;
      _showResult = false;
      _timeIsUp = false;
      
      // Configure and start timer for this question
      final question = widget.gameData.questions[_currentQuestionIndex];
      final timeLimit = question.timeLimit;
      _timerController.duration = Duration(seconds: timeLimit);
      _timerController.reset();
      _timerController.forward();
    });
    
    _questionAnimationController.forward(from: 0.0);
  }
  
  void _selectOption(String optionId) {
    if (_showResult) return; // Prevent changing selection after submitting
    
    setState(() {
      _selectedOptionId = optionId;
    });
  }
  
  void _checkAnswer() {
    if (_selectedOptionId == null) return;
    
    // Stop the timer
    _timerController.stop();
    
    final currentQuestion = widget.gameData.questions[_currentQuestionIndex];
    
    // Find the selected option
    final selectedOption = currentQuestion.options.firstWhere(
      (option) => option.id == _selectedOptionId,
    );
    
    // Check if the answer is correct
    final isCorrect = selectedOption.isCorrect;
    final pointsEarned = isCorrect ? currentQuestion.points : 0;
    
    setState(() {
      _answeredCorrectly[_currentQuestionIndex] = isCorrect;
      _pointsEarned[_currentQuestionIndex] = pointsEarned;
      _score += pointsEarned;
      _showResult = true;
    });
    
    // Trigger haptic feedback
    if (isCorrect) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.vibrate();
    }
    
    // Show result animation
    _resultAnimationController.forward(from: 0.0);
  }
  
  void _onTimeUp() {
    setState(() {
      _timeIsUp = true;
      _showResult = true;
      _answeredCorrectly[_currentQuestionIndex] = false;
      _pointsEarned[_currentQuestionIndex] = 0;
    });
    
    HapticFeedback.vibrate();
    _resultAnimationController.forward(from: 0.0);
  }
  
  void _nextQuestion() {
    if (_currentQuestionIndex < widget.gameData.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _updateQuestionState();
    } else {
      _finishGame();
    }
  }
  
  void _finishGame() {
    final DateTime endTime = DateTime.now();
    final Duration duration = endTime.difference(_startTime!);
    
    widget.onGameComplete(_score, widget.gameData.maxPoints, duration);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Top bar with progress, score, and exit
              _buildTopBar(colorScheme),
              
              const SizedBox(height: 16),
              
              // Main quiz content
              Expanded(
                child: AnimatedBuilder(
                  animation: _questionAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _questionAnimation.value,
                      child: Opacity(
                        opacity: _questionAnimation.value,
                        child: _buildQuestionContent(colorScheme),
                      ),
                    );
                  },
                ),
              ),
              
              // Bottom bar with submit/next buttons
              _buildBottomBar(colorScheme),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTopBar(ColorScheme colorScheme) {
    return Row(
      children: [
        // Exit button
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface,
          ),
          onPressed: widget.onExit,
        ),
        
        // Progress indicator
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${widget.gameData.questions.length}',
                style: TextStyle(
                  fontFamily: 'PixelifySans',
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: ((_currentQuestionIndex + 1) / widget.gameData.questions.length),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Score display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.stars,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '$_score / ${widget.gameData.maxPoints}',
                style: TextStyle(
                  fontFamily: 'PixelifySans',
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuestionContent(ColorScheme colorScheme) {
    final currentQuestion = widget.gameData.questions[_currentQuestionIndex];
    
    return ListView(
      children: [
        // Timer indicator
        if (!_showResult) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer, 
                color: _secondsRemaining != null && _secondsRemaining! < 10
                    ? Colors.red
                    : colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Time Remaining: ${_secondsRemaining ?? currentQuestion.timeLimit} seconds',
                style: TextStyle(
                  fontFamily: 'PixelifySans',
                  color: _secondsRemaining != null && _secondsRemaining! < 10
                      ? Colors.red
                      : colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 1 - _timerController.value,
            backgroundColor: colorScheme.outlineVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              _secondsRemaining != null && _secondsRemaining! < 10
                  ? Colors.red
                  : colorScheme.primary,
            ),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
        
        const SizedBox(height: 24),
        
        // Question text
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_currentQuestionIndex + 1}',
                      style: TextStyle(
                        fontFamily: 'PixelifySans',
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${currentQuestion.points} points',
                      style: TextStyle(
                        fontFamily: 'PixelifySans',
                        color: colorScheme.tertiary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                currentQuestion.text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Options
        ...currentQuestion.options.map((option) {
          final isSelected = _selectedOptionId == option.id;
          final isCorrect = option.isCorrect;
          
          // Determine colors and style based on state
          Color bgColor;
          Color borderColor;
          Color textColor;
          
          if (_showResult) {
            if (isCorrect) {
              bgColor = Colors.green.withOpacity(0.2);
              borderColor = Colors.green;
              textColor = Colors.green.shade800;
            } else if (isSelected && !isCorrect) {
              bgColor = Colors.red.withOpacity(0.2);
              borderColor = Colors.red;
              textColor = Colors.red.shade800;
            } else {
              bgColor = colorScheme.surfaceContainerHighest;
              borderColor = colorScheme.outline.withOpacity(0.3);
              textColor = colorScheme.onSurface;
            }
          } else {
            if (isSelected) {
              bgColor = colorScheme.primary.withOpacity(0.1);
              borderColor = colorScheme.primary;
              textColor = colorScheme.primary;
            } else {
              bgColor = colorScheme.surfaceContainerHighest;
              borderColor = colorScheme.outline.withOpacity(0.3);
              textColor = colorScheme.onSurface;
            }
          }
          
          return GestureDetector(
            onTap: _showResult ? null : () => _selectOption(option.id),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? borderColor : colorScheme.outline,
                      ),
                      color: isSelected ? borderColor.withOpacity(0.1) : Colors.transparent,
                    ),
                    child: Center(
                      child: isSelected
                          ? Icon(
                              _showResult
                                  ? (isCorrect ? Icons.check : Icons.close)
                                  : Icons.circle,
                              size: 16,
                              color: isSelected ? borderColor : Colors.transparent,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option.text,
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(target: isSelected ? 1 : 0)
             .scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02)),
          );
        }).toList(),
        
        // Show result message
        if (_showResult) ...[
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _resultAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _resultAnimation.value,
                child: Opacity(
                  opacity: _resultAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _answeredCorrectly[_currentQuestionIndex]
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _answeredCorrectly[_currentQuestionIndex]
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _answeredCorrectly[_currentQuestionIndex]
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: _answeredCorrectly[_currentQuestionIndex]
                              ? Colors.green
                              : Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _answeredCorrectly[_currentQuestionIndex]
                              ? 'Correct! +${_pointsEarned[_currentQuestionIndex]} points'
                              : _timeIsUp
                                  ? 'Time\'s up! The correct answer is highlighted.'
                                  : 'Incorrect. The correct answer is highlighted.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _answeredCorrectly[_currentQuestionIndex]
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (currentQuestion.options.any((o) => o.isCorrect && o.explanation != null)) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Explanation:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentQuestion.options
                                      .firstWhere((o) => o.isCorrect)
                                      .explanation ?? 'No explanation provided.',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
  
  Widget _buildBottomBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_showResult) ...[
            AppButton(
              text: 'Submit Answer',
              variant: _selectedOptionId != null
                  ? ButtonVariant.primary
                  : ButtonVariant.outline,
              isFullWidth: true,
              onPressed: _selectedOptionId != null
                  ? _checkAnswer
                  : null,
            ),
          ] else ...[
            AppButton(
              text: _isLastQuestion ? 'Finish Quiz' : 'Next Question',
              variant: ButtonVariant.primary,
              isFullWidth: true,
              leadingIcon: _isLastQuestion ? Icons.check : Icons.arrow_forward,
              onPressed: _nextQuestion,
            ),
          ],
        ],
      ),
    );
  }
} 