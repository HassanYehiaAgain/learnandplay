import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/models/tutorial_models.dart';
import 'package:learn_play_level_up_flutter/services/tutorial_service.dart';
import 'package:learn_play_level_up_flutter/widgets/tutorial/game_tutorial_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A page displaying a game-specific mini-tutorial
class GameTutorialPage extends StatefulWidget {
  final String gameType;
  final VoidCallback? onComplete;
  
  const GameTutorialPage({
    super.key,
    required this.gameType,
    this.onComplete,
  });

  @override
  State<GameTutorialPage> createState() => _GameTutorialPageState();
}

class _GameTutorialPageState extends State<GameTutorialPage> {
  final TutorialService _tutorialService = TutorialService();
  GameTutorial? _tutorial;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadTutorial();
  }
  
  Future<void> _loadTutorial() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final tutorial = _tutorialService.getGameTutorialByType(widget.gameType);
      
      setState(() {
        _tutorial = tutorial;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading game tutorial: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _completeTutorial() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      // Mark this game tutorial as completed
      await _tutorialService.markTutorialSequenceCompleted(userId, widget.gameType);
      
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error completing game tutorial: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? 'Tutorial' : (_tutorial?.title ?? 'Tutorial')),
        actions: [
          TextButton(
            onPressed: _completeTutorial,
            child: const Text('Skip'),
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _tutorial == null 
              ? _buildTutorialNotFound()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: GameTutorialCard(
                    tutorial: _tutorial!,
                    onComplete: _completeTutorial,
                  ),
                ),
    );
  }
  
  Widget _buildTutorialNotFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            Text(
              'Tutorial not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'No tutorial is available for this game type.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Return to Game'),
            ),
          ],
        ),
      ),
    );
  }
} 