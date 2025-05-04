import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/services/game_progress_provider.dart';
import 'package:learn_play_level_up_flutter/widgets/common/timer_widget.dart';
import 'package:learn_play_level_up_flutter/widgets/common/score_widget.dart';
import 'package:learn_play_level_up_flutter/widgets/common/celebration_animation.dart';

class TrueFalseGameScreen extends StatefulWidget {
  final TrueFalseGame game;

  const TrueFalseGameScreen({
    Key? key,
    required this.game,
  }) : super(key: key);

  @override
  _TrueFalseGameScreenState createState() => _TrueFalseGameScreenState();
}

class _TrueFalseGameScreenState extends State<TrueFalseGameScreen> {
  late List<TrueFalseStatement> _statements;
  late List<bool?> _answers;
  late List<bool> _showExplanations;
  int _currentIndex = 0;
  int _score = 0;
  int _attempts = 0;
  bool _isGameComplete = false;
  DateTime? _startTime;
  DateTime? _endTime;
  Timer? _statementTimer;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _statementTimer?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    _statements = List.from(widget.game.statements);
    if (widget.game.randomizeOrder) {
      _statements.shuffle();
    }
    _answers = List.filled(_statements.length, null);
    _showExplanations = List.filled(_statements.length, false);
    _startTime = DateTime.now();
    _startStatementTimer();
  }

  void _startStatementTimer() {
    _statementTimer?.cancel();
    if (widget.game.timePerStatement != null) {
      _statementTimer = Timer(
        Duration(seconds: widget.game.timePerStatement!),
        () {
          if (_answers[_currentIndex] == null) {
            _handleAnswer(false);
          }
        },
      );
    }
  }

  void _handleAnswer(bool answer) {
    if (_answers[_currentIndex] != null) return;

    setState(() {
      _attempts++;
      _answers[_currentIndex] = answer;
      _showExplanations[_currentIndex] = true;

      if (answer == _statements[_currentIndex].isTrue) {
        _score += _statements[_currentIndex].points;
      }

      if (_currentIndex < _statements.length - 1 && widget.game.allowSkipping) {
        _currentIndex++;
        _startStatementTimer();
      } else {
        bool allAnswered = _answers.every((answer) => answer != null);
        if (allAnswered) {
          _endTime = DateTime.now();
          _isGameComplete = true;
          _saveGameProgress();
        }
      }
    });
  }

  void _navigateToStatement(int index) {
    if (!widget.game.allowSkipping) return;
    
    setState(() {
      _currentIndex = index;
      _startStatementTimer();
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

  Widget _buildAnswerButton({
    required bool answer,
    required Color color,
    required IconData icon,
  }) {
    final isAnswered = _answers[_currentIndex] != null;
    final isSelected = _answers[_currentIndex] == answer;
    final isCorrect = _statements[_currentIndex].isTrue == answer;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: isAnswered ? null : () => _handleAnswer(answer),
          style: ElevatedButton.styleFrom(
            backgroundColor: isAnswered
                ? isSelected
                    ? isCorrect
                        ? Colors.green
                        : Colors.red
                    : color.withOpacity(0.3)
                : color,
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                answer ? 'TRUE' : 'FALSE',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
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
                    maxAttempts: widget.game.statements.length,
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
                    maxAttempts: widget.game.statements.length,
                  ),
                ),
                if (widget.game.allowSkipping)
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _statements.length,
                      itemBuilder: (context, index) {
                        final isAnswered = _answers[index] != null;
                        final isCorrect = isAnswered &&
                            _answers[index] == _statements[index].isTrue;
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => _navigateToStatement(index),
                            child: CircleAvatar(
                              backgroundColor: isAnswered
                                  ? isCorrect
                                      ? Colors.green
                                      : Colors.red
                                  : index == _currentIndex
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  'Statement ${_currentIndex + 1}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _statements[_currentIndex].statement,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (_statements[_currentIndex].imageUrl != null) ...[
                                  const SizedBox(height: 16),
                                  Image.network(
                                    _statements[_currentIndex].imageUrl!,
                                    height: 200,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.broken_image, size: 100);
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildAnswerButton(
                              answer: true,
                              color: Colors.green,
                              icon: Icons.check_circle,
                            ),
                            _buildAnswerButton(
                              answer: false,
                              color: Colors.red,
                              icon: Icons.cancel,
                            ),
                          ],
                        ),
                        if (_showExplanations[_currentIndex]) ...[
                          const SizedBox(height: 16),
                          Card(
                            color: _answers[_currentIndex] == _statements[_currentIndex].isTrue
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _answers[_currentIndex] == _statements[_currentIndex].isTrue
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: _answers[_currentIndex] == _statements[_currentIndex].isTrue
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _answers[_currentIndex] == _statements[_currentIndex].isTrue
                                            ? 'Correct!'
                                            : 'Incorrect',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _statements[_currentIndex].explanation,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (widget.game.allowSkipping)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _currentIndex > 0
                              ? () => _navigateToStatement(_currentIndex - 1)
                              : null,
                          child: const Text('Previous'),
                        ),
                        ElevatedButton(
                          onPressed: _currentIndex < _statements.length - 1
                              ? () => _navigateToStatement(_currentIndex + 1)
                              : null,
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
} 