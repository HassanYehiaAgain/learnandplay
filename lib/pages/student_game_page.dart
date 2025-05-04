import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learn_play_level_up_flutter/components/game/word_scramble_game.dart';
import 'package:learn_play_level_up_flutter/components/game/quiz_show_game.dart';
import 'package:learn_play_level_up_flutter/components/game/word_guess_game.dart';
import 'package:learn_play_level_up_flutter/components/game/educational_quiz_game.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/models/firebase_models.dart';
import 'package:learn_play_level_up_flutter/services/gamification_service.dart';

class StudentGamePage extends StatefulWidget {
  final String gameId;
  final String gameType;
  
  const StudentGamePage({
    super.key,
    required this.gameId,
    required this.gameType,
  });

  @override
  State<StudentGamePage> createState() => _StudentGamePageState();
}

class _StudentGamePageState extends State<StudentGamePage> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  dynamic _gameData;
  bool _showIntro = true;
  final GamificationService _gamificationService = GamificationService();
  
  @override
  void initState() {
    super.initState();
    _loadGameData();
  }
  
  Future<void> _loadGameData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      
      final db = FirebaseFirestore.instance;
      
      // Fetch game data
      final gameDoc = await db.collection('games').doc(widget.gameId).get();
      
      if (!gameDoc.exists) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Game not found!';
        });
        return;
      }
      
      final data = gameDoc.data()!;
      
      // Create appropriate game model based on type
      switch (widget.gameType) {
        case 'word_scramble':
          _gameData = WordScrambleGame.fromFirestore(gameDoc);
          break;
        case 'quiz_show':
          _gameData = QuizShowGame.fromFirestore(gameDoc);
          break;
        case 'word_guess':
          _gameData = WordGuessGame.fromFirestore(gameDoc);
          break;
        case 'quiz':
          // Load educational quiz game created by teachers
          final docRef = db.collection('games').doc(widget.gameId).withConverter(
            fromFirestore: (snapshot, _) => EducationalGame.fromFirestore(snapshot, null),
            toFirestore: (EducationalGame game, _) => game.toFirestore(),
          );
          final docSnap = await docRef.get();
          _gameData = docSnap.data()!;
          break;
        // Add more game types here
        default:
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'Unsupported game type: ${widget.gameType}';
          });
          return;
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load game: $e';
      });
    }
  }
  
  void _startGame() {
    setState(() {
      _showIntro = false;
    });
  }
  
  Future<void> _handleGameComplete(int score, int maxScore, Duration duration) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    
    // Create a game session to record progress and rewards
    await _gamificationService.recordGameSession(
      userId: userId,
      gameId: widget.gameId,
      gameType: widget.gameType,
      score: score,
      maxScore: maxScore,
      duration: duration,
      subjectId: _gameData.subjectId,
    );
    
    // Show reward screen
    Navigator.pop(context);
    Navigator.pushNamed(
      context, 
      '/reward', 
      arguments: {
        'gameTitle': _gameData.title,
        'score': score,
        'maxScore': maxScore,
      },
    );
  }
  
  void _exitGame() {
    Navigator.pop(context);
  }
  
  Widget _buildGameIntro() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _gameData.getColor().withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _gameData.getColor(),
                  width: 2,
                ),
              ),
              child: Icon(
                _gameData.getIcon(),
                size: 48,
                color: _gameData.getColor(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _gameData.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _gameData.description,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primaryContainer,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Game Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildGameDetailRow(
                    Icons.star,
                    'Difficulty',
                    '${_gameData.difficulty}/5',
                  ),
                  _buildGameDetailRow(
                    Icons.timer,
                    'Estimated Time',
                    '${_gameData.estimatedDuration} min',
                  ),
                  _buildGameDetailRow(
                    Icons.emoji_events,
                    'XP Reward',
                    'Up to ${_gameData.xpReward} XP',
                  ),
                  _buildGameDetailRow(
                    Icons.monetization_on,
                    'Coin Reward',
                    'Up to ${_gameData.coinReward} coins',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _exitGame,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurface,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _startGame,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Game'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: colorScheme.onPrimary,
                    backgroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGameDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGameContent() {
    if (_showIntro) {
      return _buildGameIntro();
    }
    
    switch (widget.gameType) {
      case 'word_scramble':
        return WordScrambleGameView(
          gameData: _gameData,
          onGameComplete: _handleGameComplete,
          onExit: () => setState(() => _showIntro = true),
        );
      case 'quiz_show':
        return QuizShowGameView(
          gameData: _gameData,
          onGameComplete: _handleGameComplete,
          onExit: () => setState(() => _showIntro = true),
        );
      case 'word_guess':
        return WordGuessGameView(
          gameData: _gameData,
          onGameComplete: _handleGameComplete,
          onExit: () => setState(() => _showIntro = true),
        );
      case 'quiz':
        // Use the educational quiz view for teacher-created games
        return EducationalQuizGameView(
          gameData: _gameData,
          onGameComplete: _handleGameComplete,
          onExit: () => setState(() => _showIntro = true),
        );
      // Add more game types here
      default:
        return Center(
          child: Text('Unsupported game type: ${widget.gameType}'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_gameData?.title ?? 'Loading Game...'),
        actions: [
          IconButton(
            onPressed: _exitGame,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(_errorMessage),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _exitGame,
                        child: const Text('Back to Games'),
                      ),
                    ],
                  ),
                )
              : _buildGameContent(),
    );
  }
} 