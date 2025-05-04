import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/services/game_progress_provider.dart';
import 'package:learn_play_level_up_flutter/widgets/common/timer_widget.dart';
import 'package:learn_play_level_up_flutter/widgets/common/score_widget.dart';
import 'package:learn_play_level_up_flutter/widgets/common/celebration_animation.dart';

class MemoryFlipCardsGameScreen extends StatefulWidget {
  final MemoryFlipCardsGame game;

  const MemoryFlipCardsGameScreen({
    Key? key,
    required this.game,
  }) : super(key: key);

  @override
  _MemoryFlipCardsGameScreenState createState() => _MemoryFlipCardsGameScreenState();
}

class _MemoryFlipCardsGameScreenState extends State<MemoryFlipCardsGameScreen> {
  late List<MemoryCardPair> _shuffledPairs;
  late List<bool> _flippedCards;
  late List<bool> _matchedCards;
  int? _firstCardIndex;
  int? _secondCardIndex;
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
    // Create pairs for the grid
    final totalPairs = (widget.game.gridSize * widget.game.gridSize) ~/ 2;
    _shuffledPairs = List.from(widget.game.cardPairs.take(totalPairs));
    
    // Duplicate each pair for matching
    final List<MemoryCardPair> allCards = [];
    for (var pair in _shuffledPairs) {
      allCards.add(pair);
      allCards.add(MemoryCardPair(
        id: '${pair.id}_copy',
        item1: pair.item1,
        item2: pair.item2,
        item1Type: pair.item1Type,
        item2Type: pair.item2Type,
      ));
    }
    
    allCards.shuffle();
    _shuffledPairs = allCards;
    _flippedCards = List.filled(_shuffledPairs.length, false);
    _matchedCards = List.filled(_shuffledPairs.length, false);
    _startTime = DateTime.now();
  }

  void _handleCardFlip(int index) {
    if (_flippedCards[index] || _matchedCards[index]) return;
    if (_firstCardIndex != null && _secondCardIndex != null) return;

    setState(() {
      _flippedCards[index] = true;

      if (_firstCardIndex == null) {
        _firstCardIndex = index;
      } else {
        _secondCardIndex = index;
        _attempts++;
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    final firstCard = _shuffledPairs[_firstCardIndex!];
    final secondCard = _shuffledPairs[_secondCardIndex!];

    if (firstCard.id.replaceAll('_copy', '') == secondCard.id.replaceAll('_copy', '')) {
      setState(() {
        _matchedCards[_firstCardIndex!] = true;
        _matchedCards[_secondCardIndex!] = true;
        _score += 10;
        _firstCardIndex = null;
        _secondCardIndex = null;
      });
      _checkGameCompletion();
    } else {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _flippedCards[_firstCardIndex!] = false;
            _flippedCards[_secondCardIndex!] = false;
            _firstCardIndex = null;
            _secondCardIndex = null;
          });
        }
      });
    }
  }

  void _checkGameCompletion() {
    if (_matchedCards.every((matched) => matched)) {
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

  Widget _buildCard(int index) {
    final card = _shuffledPairs[index];
    final isFlipped = _flippedCards[index];
    final isMatched = _matchedCards[index];

    return Card(
      margin: const EdgeInsets.all(4),
      child: InkWell(
        onTap: () => _handleCardFlip(index),
        child: Container(
          decoration: BoxDecoration(
            color: isMatched ? Colors.green.shade100 : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: isFlipped || isMatched
                ? _buildCardContent(card)
                : const Icon(Icons.question_mark, size: 48),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(MemoryCardPair card) {
    if (widget.game.gameMode == 'image_pairs') {
      return Image.network(
        card.item1,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image);
        },
      );
    } else if (widget.game.gameMode == 'word_pairs') {
      return Text(
        card.item1,
        style: const TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      );
    } else {
      // image_word_pairs mode
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            card.item1,
            height: 60,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.broken_image);
            },
          ),
          const SizedBox(height: 8),
          Text(
            card.item2,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
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
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: widget.game.gridSize,
                      childAspectRatio: 1,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _shuffledPairs.length,
                    itemBuilder: (context, index) => _buildCard(index),
                  ),
                ),
              ],
            ),
    );
  }
} 