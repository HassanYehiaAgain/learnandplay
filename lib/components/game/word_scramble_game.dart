import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/services/gamification_service.dart';

class WordScrambleGameView extends StatefulWidget {
  final WordScrambleGame gameData;
  final Function(int score, int maxScore, Duration duration) onGameComplete;
  final VoidCallback onExit;

  const WordScrambleGameView({
    super.key,
    required this.gameData,
    required this.onGameComplete,
    required this.onExit,
  });

  @override
  State<WordScrambleGameView> createState() => _WordScrambleGameViewState();
}

class _WordScrambleGameViewState extends State<WordScrambleGameView> with TickerProviderStateMixin {
  int _currentWordIndex = 0;
  int _score = 0;
  bool _showHint = false;
  DateTime? _startTime;
  DateTime? _endTime;
  
  // For letter dragging
  List<String> _scrambledLetters = [];
  List<String?> _answerPlaceholders = [];
  Map<int, int> _letterPositions = {};  // Maps answer position to scrambled position
  
  // For animations
  late AnimationController _correctAnimationController;
  late Animation<double> _correctAnimation;
  bool _isShowingCorrectAnimation = false;
  
  // Timer related
  late AnimationController _timerController;
  int? _secondsRemaining;
  bool _timeIsUp = false;

  @override
  void initState() {
    super.initState();
    
    // Set up correct answer animation
    _correctAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _correctAnimation = CurvedAnimation(
      parent: _correctAnimationController,
      curve: Curves.elasticOut,
    );
    
    _correctAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isShowingCorrectAnimation = false;
          });
          
          // Move to next word
          if (_currentWordIndex < widget.gameData.words.length - 1) {
            _nextWord();
          } else {
            _finishGame();
          }
        }
      }
    });
    
    // Set up timer if there's a time limit
    if (widget.gameData.timeLimit != null) {
      _secondsRemaining = widget.gameData.timeLimit;
      _timerController = AnimationController(
        duration: Duration(seconds: widget.gameData.timeLimit!),
        vsync: this,
      );
      
      _timerController.addListener(() {
        if (mounted) {
          setState(() {
            _secondsRemaining = (widget.gameData.timeLimit! * (1 - _timerController.value)).ceil();
          });
        }
      });
      
      _timerController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _timeIsUp = true;
          });
        }
      });
    } else {
      // Create a dummy controller if no time limit
      _timerController = AnimationController(
        duration: const Duration(seconds: 1),
        vsync: this,
      );
    }
    
    _startGame();
  }
  
  @override
  void dispose() {
    _correctAnimationController.dispose();
    _timerController.dispose();
    super.dispose();
  }
  
  void _startGame() {
    _startTime = DateTime.now();
    _prepareCurrentWord();
    
    // Start timer if applicable
    if (widget.gameData.timeLimit != null) {
      _timerController.forward();
    }
  }
  
  void _prepareCurrentWord() {
    final currentWord = widget.gameData.words[_currentWordIndex];
    final originalWord = currentWord.word;
    
    // Create scrambled version
    List<String> letters = originalWord.split('');
    letters.shuffle();
    
    setState(() {
      _scrambledLetters = letters;
      _answerPlaceholders = List.filled(originalWord.length, null);
      _letterPositions = {};
      _showHint = false;
    });
  }
  
  void _nextWord() {
    setState(() {
      _currentWordIndex++;
      _prepareCurrentWord();
    });
  }
  
  void _checkAnswer() {
    // Check if answer is complete
    if (_answerPlaceholders.contains(null)) {
      return;
    }
    
    final currentWord = widget.gameData.words[_currentWordIndex];
    final originalWord = currentWord.word;
    final userAnswer = _answerPlaceholders.join('');
    
    final isCorrect = widget.gameData.caseSensitive 
        ? userAnswer == originalWord
        : userAnswer.toLowerCase() == originalWord.toLowerCase();
    
    if (isCorrect) {
      // Add points
      _score += currentWord.points;
      
      // Play correct animation
      setState(() {
        _isShowingCorrectAnimation = true;
      });
      _correctAnimationController.forward(from: 0.0);
      
      // Vibrate for success feedback
      HapticFeedback.lightImpact();
    } else {
      // Shake animation for incorrect answer
      setState(() {
        _answerPlaceholders = List.filled(originalWord.length, null);
        _letterPositions = {};
      });
      
      // Vibrate for error feedback
      HapticFeedback.vibrate();
    }
  }
  
  void _toggleHint() {
    setState(() {
      _showHint = !_showHint;
    });
  }
  
  void _finishGame() {
    _endTime = DateTime.now();
    final duration = _endTime!.difference(_startTime!);
    widget.onGameComplete(_score, _calculateMaxScore(), duration);
  }
  
  int _calculateMaxScore() {
    int maxScore = 0;
    for (var word in widget.gameData.words) {
      maxScore += word.points;
    }
    return maxScore;
  }
  
  void _dragLetterToPlaceholder(int letterIndex, int placeholderIndex) {
    if (_scrambledLetters[letterIndex].isEmpty) {
      return; // Letter already used
    }
    
    setState(() {
      _answerPlaceholders[placeholderIndex] = _scrambledLetters[letterIndex];
      _letterPositions[placeholderIndex] = letterIndex;
      
      // Mark the letter as used (empty string as a marker)
      List<String> newScrambledLetters = List.from(_scrambledLetters);
      newScrambledLetters[letterIndex] = '';
      _scrambledLetters = newScrambledLetters;
    });
    
    // Auto-check if answer is complete
    if (!_answerPlaceholders.contains(null)) {
      _checkAnswer();
    }
  }
  
  void _removeLetter(int placeholderIndex) {
    if (_answerPlaceholders[placeholderIndex] == null) {
      return;
    }
    
    final letterIndex = _letterPositions[placeholderIndex];
    if (letterIndex != null) {
      setState(() {
        // Put the letter back in the scrambled list
        List<String> newScrambledLetters = List.from(_scrambledLetters);
        newScrambledLetters[letterIndex] = _answerPlaceholders[placeholderIndex]!;
        _scrambledLetters = newScrambledLetters;
        
        // Remove from answer
        _answerPlaceholders[placeholderIndex] = null;
        _letterPositions.remove(placeholderIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // If showing correct animation
    if (_isShowingCorrectAnimation) {
      return _buildCorrectAnimation();
    }
    
    // If time is up
    if (_timeIsUp) {
      return _buildTimeUp();
    }
    
    final currentWord = widget.gameData.words[_currentWordIndex];
    final maxScore = _calculateMaxScore();
    
    return Column(
      children: [
        // Top bar with progress and timer
        _buildTopBar(maxScore),
        
        // Game content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Word prompt
                Text(
                  currentWord.hint,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Hint button and hint
                ElevatedButton.icon(
                  onPressed: _toggleHint,
                  icon: Icon(_showHint ? Icons.visibility_off : Icons.lightbulb),
                  label: Text(_showHint ? 'Hide Hint' : 'Show Hint'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: colorScheme.onSecondaryContainer,
                    backgroundColor: colorScheme.secondaryContainer,
                  ),
                ),
                
                if (_showHint) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.secondaryContainer,
                      ),
                    ),
                    child: Text(
                      'Unscramble: ${currentWord.getScrambledWord()}',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Answer area with placeholders
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.primaryContainer,
                      width: 2,
                    ),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 16,
                    children: List.generate(
                      _answerPlaceholders.length,
                      (index) => _buildLetterPlaceholder(index),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Scrambled letters
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 16,
                  children: List.generate(
                    _scrambledLetters.length,
                    (index) => _buildDraggableLetter(index),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Check button
                ElevatedButton.icon(
                  onPressed: _answerPlaceholders.contains(null) ? null : _checkAnswer,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Check Answer'),
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
      ],
    );
  }
  
  Widget _buildTopBar(int maxScore) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
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
          
          // Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Word ${_currentWordIndex + 1}/${widget.gameData.words.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                  value: (_currentWordIndex + 1) / widget.gameData.words.length,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
          
          // Timer if applicable
          if (_secondsRemaining != null) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$_secondsRemaining s',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
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
  
  Widget _buildLetterPlaceholder(int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final letter = _answerPlaceholders[index];
    final isEmpty = letter == null;
    
    return DragTarget<int>(
      onAcceptWithDetails: (letterIndex) {
        _dragLetterToPlaceholder(letterIndex, index);
      },
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: isEmpty ? null : () => _removeLetter(index),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isEmpty ? colorScheme.surface : colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isEmpty ? colorScheme.outline : colorScheme.primary,
                width: isEmpty ? 1 : 2,
              ),
              boxShadow: isEmpty ? null : [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                isEmpty ? '' : letter,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isEmpty ? colorScheme.onSurface : colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildDraggableLetter(int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // If letter is already used
    if (_scrambledLetters[index].isEmpty) {
      return const SizedBox(width: 44, height: 44);
    }
    
    return Draggable<int>(
      data: index,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _scrambledLetters[index],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ),
      childWhenDragging: const SizedBox(width: 44, height: 44),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _scrambledLetters[index],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCorrectAnimation() {
    return AnimatedBuilder(
      animation: _correctAnimation,
      builder: (context, child) {
        return Center(
          child: Transform.scale(
            scale: _correctAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.shade500,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 80,
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildTimeUp() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_off,
            size: 80,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Time\'s Up!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your score: $_score',
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _finishGame,
            icon: const Icon(Icons.flag),
            label: const Text('Finish Game'),
            style: ElevatedButton.styleFrom(
              foregroundColor: colorScheme.onPrimary,
              backgroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
} 