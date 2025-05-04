import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/services/game_progress_provider.dart';
import 'package:learn_play_level_up_flutter/widgets/common/timer_widget.dart';
import 'package:learn_play_level_up_flutter/widgets/common/score_widget.dart';
import 'package:learn_play_level_up_flutter/widgets/common/celebration_animation.dart';

class MatchingPairsGameScreen extends StatefulWidget {
  final MatchingPairsGame game;

  const MatchingPairsGameScreen({
    Key? key,
    required this.game,
  }) : super(key: key);

  @override
  _MatchingPairsGameScreenState createState() => _MatchingPairsGameScreenState();
}

class _MatchingPairsGameScreenState extends State<MatchingPairsGameScreen> {
  late List<MatchingPairItem> _shuffledPairs;
  late List<bool> _matchedPairs;
  int? _selectedIndex;
  int _attempts = 0;
  int _score = 0;
  bool _isGameComplete = false;
  DateTime? _startTime;
  DateTime? _endTime;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _shuffledPairs = List.from(widget.game.pairs);
    if (widget.game.randomizeOrder) {
      _shuffledPairs.shuffle();
    }
    _matchedPairs = List.filled(_shuffledPairs.length, false);
    _startTime = DateTime.now();
  }

  void _handlePairSelection(int index) {
    if (_matchedPairs[index] || _selectedIndex == index) return;

    setState(() {
      if (_selectedIndex == null) {
        _selectedIndex = index;
      } else {
        _attempts++;
        final firstPair = _shuffledPairs[_selectedIndex!];
        final secondPair = _shuffledPairs[index];

        if (firstPair.rightItem == secondPair.rightItem) {
          _matchedPairs[_selectedIndex!] = true;
          _matchedPairs[index] = true;
          _score += 10;
        }

        _selectedIndex = null;
      }
    });

    _checkGameCompletion();
  }

  void _checkGameCompletion() {
    if (_matchedPairs.every((matched) => matched)) {
      setState(() {
        _isGameComplete = true;
        _endTime = DateTime.now();
      });
      _saveGameProgress();
    }
  }

  Future<void> _saveGameProgress() async {
    final duration = _endTime!.difference(_startTime!);
    final progress = GameProgress(
      gameId: widget.game.id,
      score: _score,
      attempts: _attempts,
      timeSpent: duration.inSeconds,
      completedAt: _endTime!,
    );

    try {
      await Provider.of<GameProgressProvider>(context, listen: false)
          .saveProgress(progress);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving progress: $e')),
        );
      }
    }
  }

  Widget _buildPairItem(int index) {
    final pair = _shuffledPairs[index];
    final isSelected = _selectedIndex == index;
    final isMatched = _matchedPairs[index];

    return Card(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () => _handlePairSelection(index),
        child: Container(
          width: 150,
          height: 150,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: isMatched
                ? const Icon(Icons.check_circle, color: Colors.green, size: 48)
                : isSelected
                    ? _buildItemContent(pair.rightItem, pair.rightType)
                    : _buildItemContent(pair.leftItem, pair.leftType),
          ),
        ),
      ),
    );
  }

  Widget _buildItemContent(String content, String type) {
    if (type == 'image') {
      return Image.network(
        content,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image);
        },
      );
    } else {
      return Text(
        content,
        style: const TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.title),
        actions: [
          TimerWidget(
            timeLimit: widget.game.timeLimit,
            onTimeUp: () {
              if (!_isGameComplete) {
                _endTime = DateTime.now();
                _saveGameProgress();
                setState(() {
                  _isGameComplete = true;
                });
              }
            },
          ),
        ],
      ),
      body: _isGameComplete
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CelebrationAnimation(),
                  const SizedBox(height: 24),
                  Text(
                    'Game Complete!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  ScoreWidget(
                    score: _score,
                    maxScore: widget.game.maxPoints,
                    attempts: _attempts,
                    maxAttempts: widget.game.maxAttempts,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Games'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ScoreWidget(
                    score: _score,
                    maxScore: widget.game.maxPoints,
                    attempts: _attempts,
                    maxAttempts: widget.game.maxAttempts,
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _shuffledPairs.length,
                    itemBuilder: (context, index) => _buildPairItem(index),
                  ),
                ),
              ],
            ),
    );
  }
} 