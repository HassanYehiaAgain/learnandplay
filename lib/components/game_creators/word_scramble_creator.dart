import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';
import 'package:learn_play_level_up_flutter/components/ui/input.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WordScrambleGameCreator extends StatefulWidget {
  final Function(WordScrambleGame) onGameCreated;
  final String teacherId;
  final String subjectId;
  final int gradeYear;
  final WordScrambleGame? existingGame; // For editing an existing game

  const WordScrambleGameCreator({
    super.key,
    required this.onGameCreated,
    required this.teacherId,
    required this.subjectId,
    required this.gradeYear,
    this.existingGame,
  });

  @override
  State<WordScrambleGameCreator> createState() => _WordScrambleGameCreatorState();
}

class _WordScrambleGameCreatorState extends State<WordScrambleGameCreator> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Form state
  int _difficulty = 3;
  int _estimatedDuration = 10;
  List<String> _tags = [];
  int _maxPoints = 0;
  int _xpReward = 100;
  int _coinReward = 50;
  List<WordScrambleItem> _words = [];
  bool _caseSensitive = false;
  int? _timeLimit;
  
  bool _isLoading = false;
  final _tagController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    // Populate with existing game data if editing
    if (widget.existingGame != null) {
      _titleController.text = widget.existingGame!.title;
      _descriptionController.text = widget.existingGame!.description;
      _difficulty = widget.existingGame!.difficulty;
      _estimatedDuration = widget.existingGame!.estimatedDuration;
      _tags = List.from(widget.existingGame!.tags);
      _maxPoints = widget.existingGame!.maxPoints;
      _xpReward = widget.existingGame!.xpReward;
      _coinReward = widget.existingGame!.coinReward;
      _words = List.from(widget.existingGame!.words);
      _caseSensitive = widget.existingGame!.caseSensitive;
      _timeLimit = widget.existingGame!.timeLimit;
    } else {
      // Add initial empty word
      _addNewWord();
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }
  
  void _addNewWord() {
    setState(() {
      _words.add(
        WordScrambleItem(
          word: '',
          hint: '',
          points: 10,
        ),
      );
    });
  }
  
  void _removeWord(int index) {
    if (_words.length > 1) {
      setState(() {
        _words.removeAt(index);
        _updateMaxPoints();
      });
    }
  }
  
  void _duplicateWord(int index) {
    setState(() {
      final original = _words[index];
      _words.insert(index + 1, WordScrambleItem(
        word: original.word,
        hint: original.hint,
        points: original.points,
      ));
      _updateMaxPoints();
    });
  }
  
  void _updateWord(int index, String word) {
    setState(() {
      _words[index] = WordScrambleItem(
        id: _words[index].id,
        word: word,
        hint: _words[index].hint,
        points: _words[index].points,
      );
    });
  }
  
  void _updateHint(int index, String hint) {
    setState(() {
      _words[index] = WordScrambleItem(
        id: _words[index].id,
        word: _words[index].word,
        hint: hint,
        points: _words[index].points,
      );
    });
  }
  
  void _updatePoints(int index, int points) {
    setState(() {
      _words[index] = WordScrambleItem(
        id: _words[index].id,
        word: _words[index].word,
        hint: _words[index].hint,
        points: points,
      );
      _updateMaxPoints();
    });
  }
  
  void _updateMaxPoints() {
    int total = 0;
    for (var word in _words) {
      total += word.points;
    }
    setState(() {
      _maxPoints = total;
    });
  }
  
  void _addTag() {
    if (_tagController.text.isNotEmpty && !_tags.contains(_tagController.text)) {
      setState(() {
        _tags.add(_tagController.text);
        _tagController.clear();
      });
    }
  }
  
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }
  
  Future<void> _saveGame() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Validate words
    for (var i = 0; i < _words.length; i++) {
      if (_words[i].word.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Word ${i + 1} is empty')),
        );
        return;
      }
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Update max points before creating the game
      _updateMaxPoints();
      
      final WordScrambleGame game = WordScrambleGame(
        title: _titleController.text,
        description: _descriptionController.text,
        teacherId: widget.teacherId,
        subjectId: widget.subjectId,
        gradeYear: widget.gradeYear,
        createdAt: widget.existingGame?.createdAt ?? DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 7)), // Default due date
        difficulty: _difficulty,
        estimatedDuration: _estimatedDuration,
        tags: _tags,
        maxPoints: _maxPoints,
        xpReward: _xpReward,
        coinReward: _coinReward,
        words: _words,
        caseSensitive: _caseSensitive,
        timeLimit: _timeLimit,
      );
      
      // Call the callback to notify parent that a game has been created
      widget.onGameCreated(game);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving game: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Word Scramble Game',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a game where students unscramble words based on hints',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          
          // Game Basic Info
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Game Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                
                AppInput(
                  label: 'Game Title',
                  placeholder: 'Enter a title for your game',
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                AppInput(
                  label: 'Description',
                  placeholder: 'Enter a description of your game',
                  controller: _descriptionController,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Difficulty Level',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(5, (index) {
                              return IconButton(
                                icon: Icon(
                                  index < _difficulty
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: index < _difficulty
                                      ? colorScheme.tertiary
                                      : colorScheme.outline,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _difficulty = index + 1;
                                  });
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimated Time (minutes)',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Slider(
                            value: _estimatedDuration.toDouble(),
                            min: 5,
                            max: 30,
                            divisions: 5,
                            label: _estimatedDuration.toString(),
                            onChanged: (double value) {
                              setState(() {
                                _estimatedDuration = value.toInt();
                              });
                            },
                          ),
                          Center(
                            child: Text(
                              '$_estimatedDuration minutes',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tags',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tagController,
                            decoration: InputDecoration(
                              hintText: 'Add a tag',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onFieldSubmitted: (_) => _addTag(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Icons.add_circle,
                            color: colorScheme.primary,
                          ),
                          onPressed: _addTag,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => _removeTag(tag),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'XP Reward',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: _xpReward.toString(),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              prefixIcon: Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _xpReward = int.tryParse(value) ?? 100;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coin Reward',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: _coinReward.toString(),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              prefixIcon: Icon(
                                Icons.monetization_on,
                                color: Colors.amber,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _coinReward = int.tryParse(value) ?? 50;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Checkbox(
                      value: _caseSensitive,
                      onChanged: (value) {
                        setState(() {
                          _caseSensitive = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Case sensitive',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Text(
                      'Time limit per word:',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<int?>(
                      value: _timeLimit,
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('No limit'),
                        ),
                        ...List.generate(6, (index) {
                          int seconds = (index + 1) * 10;
                          return DropdownMenuItem<int?>(
                            value: seconds,
                            child: Text('$seconds seconds'),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _timeLimit = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Words Section
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Words to Scramble',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    AppButton(
                      text: 'Add Word',
                      variant: ButtonVariant.primary,
                      size: ButtonSize.small,
                      leadingIcon: Icons.add,
                      onPressed: _addNewWord,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Total Points: $_maxPoints',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Words List
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _words.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final item = _words.removeAt(oldIndex);
                      _words.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildWordCard(context, index, key: ValueKey('word_${_words[index].id}'));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          AppButton(
            text: 'Save Game',
            variant: ButtonVariant.primary,
            isFullWidth: true,
            isLoading: _isLoading,
            onPressed: _saveGame,
          ),
        ],
      ),
    );
  }
  
  Widget _buildWordCard(BuildContext context, int wordIndex, {required Key key}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final word = _words[wordIndex];
    
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.drag_indicator,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Word ${wordIndex + 1}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Row(
                    children: [
                      Text(
                        'Points:',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: word.points,
                        items: [5, 10, 15, 20, 25].map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value'),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            _updatePoints(wordIndex, newValue);
                          }
                        },
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.content_copy,
                      color: colorScheme.primary,
                    ),
                    tooltip: 'Duplicate',
                    onPressed: () => _duplicateWord(wordIndex),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: colorScheme.error,
                    ),
                    tooltip: 'Delete',
                    onPressed: () => _removeWord(wordIndex),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Word input
          TextFormField(
            initialValue: word.word,
            decoration: InputDecoration(
              labelText: 'Word to scramble',
              hintText: 'Enter the word students need to unscramble',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.shuffle),
            ),
            onChanged: (value) => _updateWord(wordIndex, value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a word';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Hint input
          TextFormField(
            initialValue: word.hint,
            decoration: InputDecoration(
              labelText: 'Hint',
              hintText: 'Provide a hint to help students guess the word',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.lightbulb_outline),
            ),
            onChanged: (value) => _updateHint(wordIndex, value),
          ),
          
          const SizedBox(height: 16),
          if (word.word.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shuffle, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Preview: ${word.getScrambledWord()}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
} 