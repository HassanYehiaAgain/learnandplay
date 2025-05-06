import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' show sin, pi;
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/services/gamification_service.dart';

class WordGuessGameView extends StatefulWidget {
  final WordGuessGame gameData;
  final Function(int score, int maxScore, Duration duration) onGameComplete;
  final VoidCallback onExit;

  const WordGuessGameView({
    super.key,
    required this.gameData,
    required this.onGameComplete,
    required this.onExit,
  });

  @override
  State<WordGuessGameView> createState() => _WordGuessGameViewState();
}

class _WordGuessGameViewState extends State<WordGuessGameView> with TickerProviderStateMixin {
  // Game state
  int _currentWordIndex = 0;
  int _score = 0;
  int _incorrectGuesses = 0;
  Set<String> _guessedLetters = {};
  bool _showHint = false;
  DateTime? _startTime;
  DateTime? _endTime;
  
  // Result state
  bool _wordCompleted = false;
  bool _wordFailed = false;
  bool _gameCompleted = false;
  
  // Animations
  late AnimationController _correctAnimationController;
  late Animation<double> _correctAnimation;
  late AnimationController _incorrectAnimationController;
  late Animation<double> _incorrectAnimation;
  late AnimationController _figureAnimationController;
  late Animation<double> _figureAnimation;
  
  // Constants
  final int _maxIncorrectGuesses = 6; // Standard hangman rules
  
  // Letter keyboard layout
  final List<List<String>> _keyboardRows = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize correct animation
    _correctAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _correctAnimation = CurvedAnimation(
      parent: _correctAnimationController,
      curve: Curves.elasticOut,
    );
    
    // Initialize incorrect animation
    _incorrectAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _incorrectAnimation = CurvedAnimation(
      parent: _incorrectAnimationController,
      curve: Curves.easeInOut,
    );
    
    // Initialize figure animation
    _figureAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _figureAnimation = CurvedAnimation(
      parent: _figureAnimationController,
      curve: Curves.easeOut,
    );
    
    _startGame();
  }
  
  @override
  void dispose() {
    _correctAnimationController.dispose();
    _incorrectAnimationController.dispose();
    _figureAnimationController.dispose();
    super.dispose();
  }
  
  void _startGame() {
    _startTime = DateTime.now();
    _resetWordState();
  }
  
  void _resetWordState() {
    setState(() {
      _incorrectGuesses = 0;
      _guessedLetters = {};
      _showHint = false;
      _wordCompleted = false;
      _wordFailed = false;
      _figureAnimationController.reset();
    });
  }
  
  void _guessLetter(String letter) {
    final currentWord = widget.gameData.puzzles[_currentWordIndex];
    final word = currentWord.word.toUpperCase();
    
    // Skip if already guessed or game over
    if (_guessedLetters.contains(letter) || _wordCompleted || _wordFailed) {
      return;
    }
    
    setState(() {
      _guessedLetters.add(letter);
    });
    
    final letterInWord = word.contains(letter);
    
    if (letterInWord) {
      // Correct guess
      _correctAnimationController.forward(from: 0.0);
      HapticFeedback.lightImpact();
      
      // Check if word completed
      if (_isWordComplete(word)) {
        _onWordComplete();
      }
    } else {
      // Incorrect guess
      setState(() {
        _incorrectGuesses++;
      });
      
      _incorrectAnimationController.forward(from: 0.0);
      _figureAnimationController.forward(from: 0.0);
      HapticFeedback.vibrate();
      
      // Check if max guesses reached
      if (_incorrectGuesses >= _maxIncorrectGuesses) {
        _onWordFailed();
      }
    }
  }
  
  bool _isWordComplete(String word) {
    for (int i = 0; i < word.length; i++) {
      final char = word[i];
      if (char != ' ' && !_guessedLetters.contains(char)) {
        return false;
      }
    }
    return true;
  }
  
  void _onWordComplete() {
    final currentWord = widget.gameData.puzzles[_currentWordIndex];
    final pointsEarned = _calculateWordPoints(currentWord);
    
    setState(() {
      _wordCompleted = true;
      _score += pointsEarned;
    });
    
    // Delay before moving to next word
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _moveToNextWord();
      }
    });
  }
  
  void _onWordFailed() {
    setState(() {
      _wordFailed = true;
    });
    
    // Delay before moving to next word
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _moveToNextWord();
      }
    });
  }
  
  int _calculateWordPoints(WordGuessItem word) {
    // Base points
    int points = word.points;
    
    // Bonus for fewer incorrect guesses
    final incorrectRatio = _incorrectGuesses / _maxIncorrectGuesses;
    final bonusMultiplier = 1.0 + (1.0 - incorrectRatio);
    
    return (points * bonusMultiplier).round();
  }
  
  void _moveToNextWord() {
    if (_currentWordIndex < widget.gameData.puzzles.length - 1) {
      setState(() {
        _currentWordIndex++;
        _resetWordState();
      });
    } else {
      _finishGame();
    }
  }
  
  void _toggleHint() {
    setState(() {
      _showHint = !_showHint;
    });
  }
  
  void _finishGame() {
    setState(() {
      _gameCompleted = true;
    });
    
    _endTime = DateTime.now();
    final duration = _endTime!.difference(_startTime!);
    widget.onGameComplete(_score, _calculateMaxScore(), duration);
  }
  
  int _calculateMaxScore() {
    int maxScore = 0;
    for (var word in widget.gameData.puzzles) {
      // Convert double to int using round()
      maxScore += (word.points * 2).round();
    }
    return maxScore;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final currentWord = widget.gameData.puzzles[_currentWordIndex];
    final word = currentWord.word.toUpperCase();
    final maxScore = _calculateMaxScore();
    
    return Column(
      children: [
        // Top bar with score and progress
        _buildTopBar(maxScore),
        
        // Game content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Category or hint
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.gameData.category ?? "Word Guess",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Hangman figure
                _buildHangmanFigure(_incorrectGuesses),
                const SizedBox(height: 24),
                
                // Word display
                _buildWordDisplay(word),
                const SizedBox(height: 24),
                
                // Hint button
                ElevatedButton.icon(
                  onPressed: (!_wordCompleted && !_wordFailed) ? _toggleHint : null,
                  icon: Icon(_showHint ? Icons.visibility_off : Icons.lightbulb),
                  label: Text(_showHint ? 'Hide Hint' : 'Show Hint'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: colorScheme.onSecondaryContainer,
                    backgroundColor: colorScheme.secondaryContainer,
                    disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                    disabledForegroundColor: colorScheme.onSurfaceVariant,
                  ),
                ),
                
                // Hint text
                if (_showHint)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.secondaryContainer),
                    ),
                    child: Text(
                      currentWord.hint,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                // Status messages
                if (_wordCompleted)
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Word Complete!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Points Earned: ${_calculateWordPoints(currentWord)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                if (_wordFailed)
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Out of Guesses!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'The word was: ${currentWord.word}',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // Letter keyboard
                if (!_wordCompleted && !_wordFailed) 
                  _buildKeyboard()
                else
                  ElevatedButton.icon(
                    onPressed: _moveToNextWord,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(_currentWordIndex < widget.gameData.puzzles.length - 1 
                        ? 'Next Word' 
                        : 'Finish Game'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: colorScheme.onPrimary,
                      backgroundColor: colorScheme.primary,
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
                      'Word ${_currentWordIndex + 1}/${widget.gameData.puzzles.length}',
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
                  value: (_currentWordIndex) / widget.gameData.puzzles.length,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
          
          // Guesses remaining indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _incorrectGuesses > _maxIncorrectGuesses - 3
                  ? Colors.red.withOpacity(0.1)
                  : colorScheme.primaryContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _incorrectGuesses > _maxIncorrectGuesses - 3
                    ? Colors.red
                    : colorScheme.primaryContainer,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.favorite,
                  size: 16,
                  color: _incorrectGuesses > _maxIncorrectGuesses - 3
                      ? Colors.red
                      : colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_maxIncorrectGuesses - _incorrectGuesses}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _incorrectGuesses > _maxIncorrectGuesses - 3
                        ? Colors.red
                        : colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWordDisplay(String word) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(word.length, (index) {
        final char = word[index];
        
        // Handle spaces
        if (char == ' ') {
          return const SizedBox(width: 12);
        }
        
        final isRevealed = _guessedLetters.contains(char) || _wordFailed;
        
        return Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isRevealed 
                ? colorScheme.primaryContainer
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isRevealed 
                  ? colorScheme.primary
                  : colorScheme.outline,
              width: isRevealed ? 2 : 1,
            ),
            boxShadow: isRevealed ? [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.2),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ] : null,
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: _correctAnimation,
              builder: (context, child) {
                final scale = isRevealed && _guessedLetters.contains(char) && !_wordFailed
                    ? (1.0 + (_correctAnimation.value * 0.3))
                    : 1.0;
                    
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Text(
                isRevealed ? char : '',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isRevealed 
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
  
  Widget _buildKeyboard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      children: [
        for (final row in _keyboardRows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final letter in row)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _buildLetterKey(letter, colorScheme),
                  ),
              ],
            ),
          ),
      ],
    );
  }
  
  Widget _buildLetterKey(String letter, ColorScheme colorScheme) {
    final isGuessed = _guessedLetters.contains(letter);
    final currentWord = widget.gameData.puzzles[_currentWordIndex];
    final word = currentWord.word.toUpperCase();
    final isCorrect = word.contains(letter) && isGuessed;
    
    return AnimatedBuilder(
      animation: _incorrectAnimation,
      builder: (context, child) {
        final shake = isGuessed && !isCorrect && _incorrectAnimation.status == AnimationStatus.forward
            ? sin(_incorrectAnimation.value * 3 * pi) * 5
            : 0.0;
            
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isGuessed ? null : () => _guessLetter(letter),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 32,
            height: 40,
            decoration: BoxDecoration(
              color: isGuessed
                  ? isCorrect
                      ? Colors.green.shade100
                      : Colors.red.shade100
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isGuessed
                    ? isCorrect
                        ? Colors.green
                        : Colors.red
                    : colorScheme.outline.withOpacity(0.5),
              ),
            ),
            child: Center(
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isGuessed
                      ? isCorrect
                          ? Colors.green.shade700
                          : Colors.red.shade700
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHangmanFigure(int incorrectGuesses) {
    return AnimatedBuilder(
      animation: _figureAnimation,
      builder: (context, child) {
        return SizedBox(
          height: 180,
          width: double.infinity,
          child: CustomPaint(
            painter: HangmanPainter(
              incorrectGuesses: incorrectGuesses, 
              animationValue: _figureAnimation.value,
            ),
          ),
        );
      },
    );
  }
}

class HangmanPainter extends CustomPainter {
  final int incorrectGuesses;
  final double animationValue;
  
  HangmanPainter({
    required this.incorrectGuesses,
    required this.animationValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
      
    final center = Offset(size.width / 2, size.height / 2);
    
    // Base and post - always visible
    // Base
    canvas.drawLine(
      Offset(center.dx - 60, size.height - 20),
      Offset(center.dx + 60, size.height - 20),
      paint,
    );
    
    // Post
    canvas.drawLine(
      Offset(center.dx - 40, size.height - 20),
      Offset(center.dx - 40, 20),
      paint,
    );
    
    // Crossbeam
    canvas.drawLine(
      Offset(center.dx - 40, 20),
      Offset(center.dx + 40, 20),
      paint,
    );
    
    // Rope
    canvas.drawLine(
      Offset(center.dx + 40, 20),
      Offset(center.dx + 40, 40),
      paint,
    );
    
    // Draw figure parts based on incorrect guesses
    if (incorrectGuesses >= 1) {
      // Head
      final headProgress = incorrectGuesses >= 2 ? 1.0 : animationValue;
      _drawHead(canvas, center, paint, headProgress);
    }
    
    if (incorrectGuesses >= 2) {
      // Body
      final bodyProgress = incorrectGuesses >= 3 ? 1.0 : animationValue;
      _drawBody(canvas, center, paint, bodyProgress);
    }
    
    if (incorrectGuesses >= 3) {
      // Left arm
      final leftArmProgress = incorrectGuesses >= 4 ? 1.0 : animationValue;
      _drawLeftArm(canvas, center, paint, leftArmProgress);
    }
    
    if (incorrectGuesses >= 4) {
      // Right arm
      final rightArmProgress = incorrectGuesses >= 5 ? 1.0 : animationValue;
      _drawRightArm(canvas, center, paint, rightArmProgress);
    }
    
    if (incorrectGuesses >= 5) {
      // Left leg
      final leftLegProgress = incorrectGuesses >= 6 ? 1.0 : animationValue;
      _drawLeftLeg(canvas, center, paint, leftLegProgress);
    }
    
    if (incorrectGuesses >= 6) {
      // Right leg
      _drawRightLeg(canvas, center, paint, animationValue);
    }
  }
  
  void _drawHead(Canvas canvas, Offset center, Paint paint, double progress) {
    final headCenter = Offset(center.dx + 40, 60);
    final radius = 20.0 * progress;
    
    canvas.drawCircle(headCenter, radius, paint);
  }
  
  void _drawBody(Canvas canvas, Offset center, Paint paint, double progress) {
    final start = Offset(center.dx + 40, 80);
    final end = Offset(center.dx + 40, 80 + 50 * progress);
    
    canvas.drawLine(start, end, paint);
  }
  
  void _drawLeftArm(Canvas canvas, Offset center, Paint paint, double progress) {
    final start = Offset(center.dx + 40, 95);
    final end = Offset(center.dx + 40 - 30 * progress, 110);
    
    canvas.drawLine(start, end, paint);
  }
  
  void _drawRightArm(Canvas canvas, Offset center, Paint paint, double progress) {
    final start = Offset(center.dx + 40, 95);
    final end = Offset(center.dx + 40 + 30 * progress, 110);
    
    canvas.drawLine(start, end, paint);
  }
  
  void _drawLeftLeg(Canvas canvas, Offset center, Paint paint, double progress) {
    final start = Offset(center.dx + 40, 130);
    final end = Offset(center.dx + 40 - 30 * progress, 160);
    
    canvas.drawLine(start, end, paint);
  }
  
  void _drawRightLeg(Canvas canvas, Offset center, Paint paint, double progress) {
    final start = Offset(center.dx + 40, 130);
    final end = Offset(center.dx + 40 + 30 * progress, 160);
    
    canvas.drawLine(start, end, paint);
  }
  
  @override
  bool shouldRepaint(covariant HangmanPainter oldDelegate) {
    return oldDelegate.incorrectGuesses != incorrectGuesses ||
        oldDelegate.animationValue != animationValue;
  }
} 