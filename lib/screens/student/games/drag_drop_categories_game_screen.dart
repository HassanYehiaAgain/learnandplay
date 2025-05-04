import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/services/game_progress_provider.dart';
import 'package:learn_play_level_up_flutter/widgets/common/timer_widget.dart';
import 'package:learn_play_level_up_flutter/widgets/common/score_widget.dart';
import 'package:learn_play_level_up_flutter/widgets/common/celebration_animation.dart';

class DragDropCategoriesGameScreen extends StatefulWidget {
  final DragDropCategoriesGame game;

  const DragDropCategoriesGameScreen({
    Key? key,
    required this.game,
  }) : super(key: key);

  @override
  _DragDropCategoriesGameScreenState createState() => _DragDropCategoriesGameScreenState();
}

class _DragDropCategoriesGameScreenState extends State<DragDropCategoriesGameScreen> {
  late List<DraggableItem> _remainingItems;
  final Map<String, List<DraggableItem>> _categorizedItems = {};
  int _score = 0;
  int _attempts = 0;
  bool _isGameComplete = false;
  DateTime? _startTime;
  DateTime? _endTime;
  String? _activeHint;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _remainingItems = List.from(widget.game.items);
    _remainingItems.shuffle();
    for (final category in widget.game.categories) {
      _categorizedItems[category.id] = [];
    }
    _startTime = DateTime.now();
  }

  void _handleItemDropped(DraggableItem item, String categoryId) {
    setState(() {
      _attempts++;
      final isCorrect = item.correctCategoryId == categoryId;
      
      if (isCorrect) {
        _score += 10;
        _remainingItems.remove(item);
        _categorizedItems[categoryId]!.add(item);
        
        if (widget.game.immediateCorrectnessFeedback) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Correct!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        if (widget.game.immediateCorrectnessFeedback) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Try again!'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }

      if (_remainingItems.isEmpty) {
        _endTime = DateTime.now();
        _isGameComplete = true;
        _saveGameProgress();
      }
    });
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

  Widget _buildItemContent(DraggableItem item) {
    if (item.contentType == 'image') {
      return Image.network(
        item.content,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 48);
        },
      );
    } else {
      return Text(
        item.content,
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _buildDraggableItem(DraggableItem item) {
    return Draggable<DraggableItem>(
      data: item,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 100,
          height: 100,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: _buildItemContent(item),
        ),
      ),
      childWhenDragging: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: GestureDetector(
        onTap: item.hint != null
            ? () {
                setState(() {
                  _activeHint = _activeHint == item.hint ? null : item.hint;
                });
              }
            : null,
        child: Container(
          width: 100,
          height: 100,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: _buildItemContent(item)),
              if (item.hint != null)
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: _activeHint == item.hint ? Colors.amber : Colors.grey,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryContainer(CategoryItem category) {
    final items = _categorizedItems[category.id]!;
    
    return DragTarget<DraggableItem>(
      onWillAccept: (_) => true,
      onAccept: (item) => _handleItemDropped(item, category.id),
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.1),
            border: Border.all(
              color: candidateData.isNotEmpty
                  ? category.color
                  : category.color.withOpacity(0.5),
              width: candidateData.isNotEmpty ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: category.color,
                ),
              ),
              if (widget.game.showCategoryDescriptions && category.description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    category.description!,
                    style: TextStyle(
                      color: category.color.withOpacity(0.8),
                    ),
                  ),
                ),
              if (items.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: items.map((item) {
                    return Container(
                      width: 100,
                      height: 100,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildItemContent(item),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
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
                    maxAttempts: widget.game.items.length,
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
                    maxAttempts: widget.game.items.length,
                  ),
                ),
                if (_activeHint != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb, color: Colors.amber),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _activeHint!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _activeHint = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ...widget.game.categories.map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildCategoryContainer(category),
                          );
                        }),
                        const SizedBox(height: 16),
                        if (_remainingItems.isNotEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Items to Categorize',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _remainingItems
                                        .map(_buildDraggableItem)
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
} 