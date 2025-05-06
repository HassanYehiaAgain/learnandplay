import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import 'widgets/true_false_widget.dart';
import 'widgets/drag_drop_widget.dart';
import 'widgets/matching_widget.dart';
import 'widgets/memory_widget.dart';
import 'widgets/flash_card_widget.dart';
import 'widgets/fill_blank_widget.dart';
import 'widgets/hangman_widget.dart';
import 'widgets/crossword_widget.dart';

// State providers for game score and streak
final scoreProvider = StateProvider<int>((ref) => 0);
final streakProvider = StateProvider<int>((ref) => 0);

class GamePlayPage extends ConsumerStatefulWidget {
  final String gameId;
  
  const GamePlayPage({
    super.key,
    required this.gameId,
  });

  @override
  ConsumerState<GamePlayPage> createState() => _GamePlayPageState();
}

class _GamePlayPageState extends ConsumerState<GamePlayPage> {
  bool _isLoading = true;
  Game? _game;
  int _currentQuestionIndex = 0;
  bool _isGameComplete = false;
  
  @override
  void initState() {
    super.initState();
    _loadGame();
  }
  
  // Reset the score and streak when starting a new game
  void _resetScore() {
    ref.read(scoreProvider.notifier).state = 0;
    ref.read(streakProvider.notifier).state = 0;
  }
  
  // Update score based on correct answer
  void _updateScore(bool isCorrect) {
    if (isCorrect) {
      final currentStreak = ref.read(streakProvider);
      final multiplier = 1 + (currentStreak * 0.1);
      final points = (10 * multiplier).round();
      
      ref.read(scoreProvider.notifier).state += points;
      ref.read(streakProvider.notifier).state += 1;
    } else {
      // Reset streak on wrong answer
      ref.read(streakProvider.notifier).state = 0;
    }
  }
  
  // Move to the next question or complete the game
  void _nextQuestion() {
    if (_game == null) return;
    
    setState(() {
      if (_currentQuestionIndex < _game!.questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _completeGame();
      }
    });
  }
  
  // Mark the game as complete and save completion to Firestore
  Future<void> _completeGame() async {
    if (_game == null || _isGameComplete) return;
    
    setState(() {
      _isGameComplete = true;
    });
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final score = ref.read(scoreProvider);
        
        // Create a completion record
        final completion = GameCompletion(
          id: const Uuid().v4(),
          gameId: _game!.id,
          uid: user.uid,
          score: score,
          completedAt: DateTime.now(),
        );
        
        // Save to Firestore
        await FirebaseFirestore.instance
            .collection('games')
            .doc(_game!.id)
            .collection('completions')
            .doc(completion.id)
            .set(completion.toJson());
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Game completed 🎉'),
              duration: Duration(seconds: 2),
            ),
          );
          
          // Go back to dashboard after a short delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              context.go('/dashboard');
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving completion: $e')),
        );
      }
    }
  }
  
  Future<void> _loadGame() async {
    try {
      _resetScore();
      
      final gameDoc = await FirebaseFirestore.instance
          .collection('games')
          .doc(widget.gameId)
          .get();
      
      if (!gameDoc.exists) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }
      
      final data = gameDoc.data()!;
      data['id'] = gameDoc.id;
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _game = Game.fromJson(data);
          _currentQuestionIndex = 0;
          _isGameComplete = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading game: $e')),
        );
      }
    }
  }
  
  // Build the appropriate widget based on game template
  Widget _buildGameWidget() {
    if (_game == null || _game!.questions.isEmpty) {
      return const Center(
        child: Text('No questions available for this game'),
      );
    }
    
    final currentQuestion = _game!.questions[_currentQuestionIndex];
    
    // Callback for when a question is answered
    void onAnswer(bool isCorrect) {
      _updateScore(isCorrect);
      _nextQuestion();
    }
    
    // Return the appropriate widget based on template
    switch (_game!.template) {
      case GameTemplate.trueFalse:
        return TrueFalseWidget(
          question: currentQuestion,
          onAnswer: onAnswer,
        );
        
      case GameTemplate.dragDrop:
        return DragDropWidget(
          question: currentQuestion,
          onAnswer: onAnswer,
        );
        
      case GameTemplate.matching:
        return MatchingWidget(
          question: currentQuestion,
          onAnswer: onAnswer,
        );
        
      case GameTemplate.memory:
        return MemoryWidget(
          question: currentQuestion,
          onAnswer: onAnswer,
        );
        
      case GameTemplate.flashCard:
        return FlashCardWidget(
          question: currentQuestion,
          onAnswer: onAnswer,
        );
        
      case GameTemplate.fillBlank:
        return FillBlankWidget(
          question: currentQuestion,
          onAnswer: onAnswer,
        );
        
      case GameTemplate.hangman:
        return HangmanWidget(
          question: currentQuestion,
          onAnswer: onAnswer,
        );
        
      case GameTemplate.crossword:
        return CrosswordWidget(
          question: currentQuestion,
          onAnswer: onAnswer,
        );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final score = ref.watch(scoreProvider);
    final streak = ref.watch(streakProvider);
    final multiplier = 1 + (streak * 0.1);
    
    return Scaffold(
      appBar: AppBar(
        title: _game != null 
            ? Text(_game!.title) 
            : Text('Game ${widget.gameId}'),
        actions: [
          if (_game != null)
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                // Show game instructions
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('How to Play'),
                    content: Text(_getInstructions()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Got It'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _game == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Game not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/dashboard'),
                    child: const Text('Back to Dashboard'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Score banner
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.blue.shade100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Score: $score  ×${multiplier.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontFamily: 'Retropix',
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Progress indicator
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _game!.questions.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                
                // Game content
                Expanded(
                  child: _isGameComplete
                    ? _buildCompletionScreen()
                    : _buildGameWidget(),
                ),
              ],
            ),
    );
  }
  
  // Screen shown when the game is completed
  Widget _buildCompletionScreen() {
    final score = ref.read(scoreProvider);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.celebration,
            size: 80,
            color: Colors.amber,
          ),
          const SizedBox(height: 24),
          Text(
            'Game Completed!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Your score: $score',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontFamily: 'Retropix',
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go('/dashboard'),
            child: const Text('Back to Dashboard'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _resetScore();
                _currentQuestionIndex = 0;
                _isGameComplete = false;
              });
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }
  
  // Get instructions based on game template
  String _getInstructions() {
    if (_game == null) return '';
    
    switch (_game!.template) {
      case GameTemplate.trueFalse:
        return 'Read the statement and tap True or False. The faster you answer correctly, the higher your streak multiplier!';
        
      case GameTemplate.dragDrop:
        return 'Drag the items to their correct targets. Each correct match increases your streak!';
        
      case GameTemplate.matching:
        return 'Tap cards to find matching pairs. Remember the positions to match them quickly!';
        
      case GameTemplate.memory:
        return 'Flip cards to find matching pairs. The faster you complete it, the higher your score!';
        
      case GameTemplate.flashCard:
        return 'Swipe through the flash cards to reveal the answer. Mark if you got it right!';
        
      case GameTemplate.fillBlank:
        return 'Fill in the blanks with the correct words to complete the sentence.';
        
      case GameTemplate.hangman:
        return 'Guess the word one letter at a time. Be careful - too many wrong guesses and you\'ll lose points!';
        
      case GameTemplate.crossword:
        return 'Fill in the crossword puzzle using the clues provided for across and down words.';
    }
  }
} 