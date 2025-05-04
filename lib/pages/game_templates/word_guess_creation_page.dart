import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/pages/game_templates/template_creation_base_page.dart';
import 'package:learn_play_level_up_flutter/services/game_templates_provider.dart';
import 'package:uuid/uuid.dart';

class WordGuessCreationPage extends StatefulWidget {
  const WordGuessCreationPage({Key? key}) : super(key: key);

  @override
  _WordGuessCreationPageState createState() => _WordGuessCreationPageState();
}

class _WordGuessCreationPageState extends State<WordGuessCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _wordController = TextEditingController();
  final _hintController = TextEditingController();
  final _categoryController = TextEditingController();
  final List<WordGuessItem> _puzzles = [];
  
  String _gameMode = 'singleWords'; // 'singleWords', 'phrases', 'categoryBased'
  int _maxWrongGuesses = 6;
  bool _showHintAutomatically = false;
  bool _revealFirstLetter = false;
  bool _revealLastLetter = false;
  int? _timeLimit;
  int _estimatedDuration = 10;
  int _xpReward = 100;
  int _coinReward = 50;
  int _maxPoints = 100;
  String? _category;
  
  // For bulk import
  final _bulkImportController = TextEditingController();
  bool _showBulkImport = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _wordController.dispose();
    _hintController.dispose();
    _categoryController.dispose();
    _bulkImportController.dispose();
    super.dispose();
  }

  void _addPuzzle() {
    if (_wordController.text.isEmpty || _hintController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both word and hint')),
      );
      return;
    }

    setState(() {
      _puzzles.add(WordGuessItem(
        word: _wordController.text,
        hint: _hintController.text,
        points: 10,
      ));
      _wordController.clear();
      _hintController.clear();
    });
  }

  void _removePuzzle(int index) {
    setState(() {
      _puzzles.removeAt(index);
    });
  }

  void _processBulkImport() {
    if (_bulkImportController.text.isEmpty) return;
    
    // Expected format: word,hint\nword,hint
    final lines = _bulkImportController.text.split('\n');
    final newPuzzles = <WordGuessItem>[];
    
    for (final line in lines) {
      final parts = line.split(',');
      if (parts.length >= 2) {
        final word = parts[0].trim();
        final hint = parts[1].trim();
        
        if (word.isNotEmpty && hint.isNotEmpty) {
          newPuzzles.add(WordGuessItem(
            word: word,
            hint: hint,
            points: 10,
          ));
        }
      }
    }
    
    if (newPuzzles.isNotEmpty) {
      setState(() {
        _puzzles.addAll(newPuzzles);
        _bulkImportController.clear();
        _showBulkImport = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${newPuzzles.length} words')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No valid words found. Use format: word,hint')),
      );
    }
  }

  Future<void> _saveGame() async {
    if (!_formKey.currentState!.validate()) return;
    if (_puzzles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one word')),
      );
      return;
    }

    // Calculate total points
    int totalPoints = 0;
    for (var puzzle in _puzzles) {
      totalPoints += puzzle.points;
    }

    final game = WordGuessGame(
      title: _titleController.text,
      description: _descriptionController.text,
      teacherId: Provider.of<GameTemplatesProvider>(context, listen: false).currentUser!.id,
      subjectId: Provider.of<GameTemplatesProvider>(context, listen: false).selectedSubject!.id,
      gradeYear: Provider.of<GameTemplatesProvider>(context, listen: false).selectedGradeYear!,
      createdAt: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 7)),
      estimatedDuration: _estimatedDuration,
      tags: ['word_guess', 'hangman', _gameMode],
      maxPoints: _maxPoints,
      xpReward: _xpReward,
      coinReward: _coinReward,
      puzzles: _puzzles,
      maxWrongGuesses: _maxWrongGuesses,
      showHintAutomatically: _showHintAutomatically,
      category: _category,
    );

    try {
      await Provider.of<GameTemplatesProvider>(context, listen: false).saveGame(game);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving game: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TemplateCreationBasePage(
      type: 'word_guess',
      title: 'Create Word Guess Game',
      icon: Icons.abc,
      color: Colors.teal,
      contentBuilder: (context) => Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic info
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Game Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value?.isEmpty ?? true) ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Instructions (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // Game mode selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Game Mode',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      RadioListTile<String>(
                        title: const Text('Single Words'),
                        value: 'singleWords',
                        groupValue: _gameMode,
                        onChanged: (value) {
                          setState(() {
                            _gameMode = value!;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Phrases/Sentences'),
                        value: 'phrases',
                        groupValue: _gameMode,
                        onChanged: (value) {
                          setState(() {
                            _gameMode = value!;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Category-Based Word Sets'),
                        value: 'categoryBased',
                        groupValue: _gameMode,
                        onChanged: (value) {
                          setState(() {
                            _gameMode = value!;
                          });
                        },
                      ),
                      
                      if (_gameMode == 'categoryBased') ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _categoryController,
                          decoration: const InputDecoration(
                            labelText: 'Category Name',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _category = value;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Word list
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Words/Phrases',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.upload_file),
                                label: const Text('Bulk Import'),
                                onPressed: () {
                                  setState(() {
                                    _showBulkImport = !_showBulkImport;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle),
                                onPressed: _addPuzzle,
                                tooltip: 'Add Word',
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Bulk import section
                      if (_showBulkImport) ...[
                        TextFormField(
                          controller: _bulkImportController,
                          decoration: const InputDecoration(
                            labelText: 'Bulk Import (word,hint format)',
                            hintText: 'apple,A fruit\nbanana,Yellow fruit',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check),
                              label: const Text('Import'),
                              onPressed: _processBulkImport,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                      ],
                      
                      // Individual word input
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _wordController,
                              decoration: InputDecoration(
                                labelText: _gameMode == 'phrases' ? 'Phrase' : 'Word',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _hintController,
                              decoration: const InputDecoration(
                                labelText: 'Hint/Clue',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Word list
                      if (_puzzles.isNotEmpty) ...[
                        const Text(
                          'Added Words:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _puzzles.length,
                          itemBuilder: (context, index) {
                            final puzzle = _puzzles[index];
                            return Card(
                              child: ListTile(
                                title: Text(puzzle.word),
                                subtitle: Text(puzzle.hint),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removePuzzle(index),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Game settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Game Settings',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      // Wrong guesses slider
                      Row(
                        children: [
                          const Text('Maximum Wrong Guesses:'),
                          Expanded(
                            child: Slider(
                              value: _maxWrongGuesses.toDouble(),
                              min: 5,
                              max: 10,
                              divisions: 5,
                              label: _maxWrongGuesses.toString(),
                              onChanged: (value) {
                                setState(() {
                                  _maxWrongGuesses = value.toInt();
                                });
                              },
                            ),
                          ),
                          Text(_maxWrongGuesses.toString()),
                        ],
                      ),
                      
                      // Hint settings
                      SwitchListTile(
                        title: const Text('Show Hint Automatically'),
                        subtitle: const Text('Display hints without requiring the player to click'),
                        value: _showHintAutomatically,
                        onChanged: (value) {
                          setState(() {
                            _showHintAutomatically = value;
                          });
                        },
                      ),
                      
                      // Reveal letter settings
                      SwitchListTile(
                        title: const Text('Reveal First Letter'),
                        value: _revealFirstLetter,
                        onChanged: (value) {
                          setState(() {
                            _revealFirstLetter = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Reveal Last Letter'),
                        value: _revealLastLetter,
                        onChanged: (value) {
                          setState(() {
                            _revealLastLetter = value;
                          });
                        },
                      ),
                      
                      // Time settings
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Time Limit per Word (seconds, optional)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _timeLimit = int.tryParse(value);
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Estimated Duration (minutes)',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: '10',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _estimatedDuration = int.tryParse(value) ?? 10;
                        },
                      ),
                      
                      // Reward settings
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'XP Reward',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: '100',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _xpReward = int.tryParse(value) ?? 100;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Coin Reward',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: '50',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _coinReward = int.tryParse(value) ?? 50;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Maximum Points',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: '100',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _maxPoints = int.tryParse(value) ?? 100;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      saveToFirebase: (context, {
        required String title,
        required String description,
        required String teacherId,
        required String subjectId,
        required int gradeYear,
        required DateTime dueDate,
        required int maxPoints,
        required int xpReward,
        required int coinReward,
      }) async {
        try {
          final game = WordGuessGame(
            title: title,
            description: description,
            teacherId: teacherId,
            subjectId: subjectId,
            gradeYear: gradeYear,
            createdAt: DateTime.now(),
            dueDate: dueDate,
            estimatedDuration: _estimatedDuration,
            tags: ['word_guess', 'hangman', _gameMode],
            maxPoints: maxPoints,
            xpReward: xpReward,
            coinReward: coinReward,
            puzzles: _puzzles,
            maxWrongGuesses: _maxWrongGuesses,
            showHintAutomatically: _showHintAutomatically,
            category: _category,
          );
          
          await Provider.of<GameTemplatesProvider>(context, listen: false).saveGame(game);
          return true;
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error saving game: $e')),
            );
          }
          return false;
        }
      },
      validateForm: () {
        return _formKey.currentState?.validate() ?? false && _puzzles.isNotEmpty;
      },
    );
  }
} 