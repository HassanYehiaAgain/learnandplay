import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';
import 'package:learn_play_level_up_flutter/components/ui/input.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

class FillInTheBlanksGameCreator extends StatefulWidget {
  final Function(FillInTheBlanksGame) onGameCreated;
  final String teacherId;
  final String subjectId;
  final int gradeYear;
  final FillInTheBlanksGame? existingGame; // For editing an existing game

  const FillInTheBlanksGameCreator({
    super.key,
    required this.onGameCreated,
    required this.teacherId,
    required this.subjectId,
    required this.gradeYear,
    this.existingGame,
  });

  @override
  State<FillInTheBlanksGameCreator> createState() => _FillInTheBlanksGameCreatorState();
}

class _FillInTheBlanksGameCreatorState extends State<FillInTheBlanksGameCreator> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _storyController = TextEditingController();
  
  // Form state
  int _difficulty = 3;
  int _estimatedDuration = 10;
  List<String> _tags = [];
  int _maxPoints = 0;
  int _xpReward = 100;
  int _coinReward = 50;
  List<BlankItem> _blanks = [];
  bool _provideWordBank = true;
  int? _timeLimit;
  
  bool _isLoading = false;
  final _tagController = TextEditingController();
  
  // Word selection state
  final _selectedTextNotifier = ValueNotifier<String>('');
  final _selectedRangeNotifier = ValueNotifier<TextRange?>(null);
  
  // Blank form controllers
  final _blankWordController = TextEditingController();
  final _blankHintController = TextEditingController();
  final _blankPointsController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    // Populate with existing game data if editing
    if (widget.existingGame != null) {
      _titleController.text = widget.existingGame!.title;
      _descriptionController.text = widget.existingGame!.description;
      _storyController.text = widget.existingGame!.story;
      _difficulty = widget.existingGame!.difficulty;
      _estimatedDuration = widget.existingGame!.estimatedDuration;
      _tags = List.from(widget.existingGame!.tags);
      _maxPoints = widget.existingGame!.maxPoints;
      _xpReward = widget.existingGame!.xpReward;
      _coinReward = widget.existingGame!.coinReward;
      _blanks = List.from(widget.existingGame!.blanks);
      _provideWordBank = widget.existingGame!.provideWordBank;
      _timeLimit = widget.existingGame!.timeLimit;
    }

    // Add listener to monitor selection changes
    _storyController.addListener(_checkTextSelection);
  }
  
  void _checkTextSelection() {
    if (_storyController.selection.isValid) {
      final selection = _storyController.selection;
      if (selection.start != selection.end) {
        final selectedText = _storyController.text.substring(selection.start, selection.end);
        _selectedTextNotifier.value = selectedText;
        _selectedRangeNotifier.value = selection;
      }
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _storyController.removeListener(_checkTextSelection);
    _storyController.dispose();
    _tagController.dispose();
    _blankWordController.dispose();
    _blankHintController.dispose();
    _blankPointsController.dispose();
    _selectedTextNotifier.dispose();
    _selectedRangeNotifier.dispose();
    super.dispose();
  }
  
  void _updateMaxPoints() {
    int total = 0;
    for (var blank in _blanks) {
      total += blank.points;
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
  
  void _addBlank() {
    final selectedText = _selectedTextNotifier.value;
    final selectedRange = _selectedRangeNotifier.value;
    
    if (selectedText.isEmpty || selectedRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a word in the story to mark as blank')),
      );
      return;
    }
    
    _blankWordController.text = selectedText;
    _blankHintController.text = '';
    _blankPointsController.text = '5';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Blank'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Selected Word: "$selectedText"'),
              const SizedBox(height: 16),
              AppInput(
                controller: _blankWordController,
                label: 'Word',
                placeholder: 'Enter word',
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a word';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppInput(
                controller: _blankHintController,
                label: 'Hint (Optional)',
                placeholder: 'Enter a hint for students',
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              AppInput(
                controller: _blankPointsController,
                label: 'Points',
                placeholder: 'Enter points',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter points';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Add the blank
              setState(() {
                _blanks.add(
                  BlankItem(
                    word: _blankWordController.text,
                    hint: _blankHintController.text.isEmpty ? null : _blankHintController.text,
                    index: selectedRange.start,
                    points: int.tryParse(_blankPointsController.text) ?? 5,
                  ),
                );
                
                // Replace the word with underscores in the story
                final storyText = _storyController.text;
                final before = storyText.substring(0, selectedRange.start);
                final after = storyText.substring(selectedRange.end);
                final blank = '_' * selectedText.length;
                
                _storyController.text = '$before$blank$after';
                
                _updateMaxPoints();
              });
              
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  void _removeBlank(int index) {
    setState(() {
      _blanks.removeAt(index);
      _updateMaxPoints();
    });
  }
  
  String _getStoryWithBlanks() {
    String story = _storyController.text;
    
    // Sort blanks by index in reverse order to avoid changing positions
    final sortedBlanks = List<BlankItem>.from(_blanks)
      ..sort((a, b) => b.index.compareTo(a.index));
    
    for (var blank in sortedBlanks) {
      final word = blank.word;
      final index = blank.index;
      
      if (index >= 0 && index + word.length <= story.length) {
        final before = story.substring(0, index);
        final after = story.substring(index + word.length);
        final blankText = '_' * word.length;
        
        story = '$before$blankText$after';
      }
    }
    
    return story;
  }
  
  Future<void> _saveGame() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_storyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a story')),
      );
      return;
    }
    
    if (_blanks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one blank')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Update max points before creating the game
      _updateMaxPoints();
      
      final FillInTheBlanksGame game = FillInTheBlanksGame(
        title: _titleController.text,
        description: _descriptionController.text,
        teacherId: widget.teacherId,
        subjectId: widget.subjectId,
        gradeYear: widget.gradeYear,
        createdAt: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 7)),
        difficulty: _difficulty,
        estimatedDuration: _estimatedDuration,
        tags: _tags,
        maxPoints: _maxPoints,
        xpReward: _xpReward,
        coinReward: _coinReward,
        story: _storyController.text,
        blanks: _blanks,
        provideWordBank: _provideWordBank,
        timeLimit: _timeLimit,
      );
      
      // Call the callback to save the game
      widget.onGameCreated(game);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving game: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 768;
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Information Card
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppInput(
                    controller: _titleController,
                    label: 'Game Title',
                    placeholder: 'Enter a title for your game',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    controller: _descriptionController,
                    label: 'Description',
                    placeholder: 'Enter a description of the game',
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tags',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: AppInput(
                          controller: _tagController,
                          placeholder: 'Add a tag',
                          onChanged: (_) {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        text: 'Add',
                        onPressed: _addTag,
                        variant: ButtonVariant.secondary,
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
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeTag(tag),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Difficulty',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _difficulty.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _difficulty.toString(),
                    onChanged: (value) {
                      setState(() {
                        _difficulty = value.toInt();
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Easy'),
                      const Text('Medium'),
                      const Text('Hard'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Duration (minutes)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Slider(
                                    value: _estimatedDuration.toDouble(),
                                    min: 5,
                                    max: 60,
                                    divisions: 11,
                                    label: '$_estimatedDuration min',
                                    onChanged: (value) {
                                      setState(() {
                                        _estimatedDuration = value.toInt();
                                      });
                                    },
                                  ),
                                ),
                                Text('$_estimatedDuration min'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppInput(
                          controller: TextEditingController(text: _xpReward.toString()),
                          label: 'XP Reward',
                          placeholder: 'Enter XP reward',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter XP reward';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _xpReward = int.tryParse(value) ?? 100;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppInput(
                          controller: TextEditingController(text: _coinReward.toString()),
                          label: 'Coin Reward',
                          placeholder: 'Enter coin reward',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter coin reward';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _coinReward = int.tryParse(value) ?? 50;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppInput(
                          controller: TextEditingController(text: _timeLimit?.toString() ?? ''),
                          label: 'Time Limit (seconds, optional)',
                          placeholder: 'Enter time limit or leave blank for none',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _timeLimit = value.isEmpty ? null : int.tryParse(value);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Provide Word Bank',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Switch(
                              value: _provideWordBank,
                              onChanged: (value) {
                                setState(() {
                                  _provideWordBank = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Story Card
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Your Story',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Write your story and select words to mark as blanks',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Text editor with selection
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Story Text',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            AppButton(
                              text: 'Mark as Blank',
                              onPressed: _addBlank,
                              variant: ButtonVariant.secondary,
                              size: ButtonSize.small,
                              leadingIcon: Icons.format_strikethrough,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _storyController,
                          maxLines: 10,
                          decoration: const InputDecoration(
                            hintText: 'Write or paste your story here...',
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a story';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            // If the text changes, clear selection info
                            if (_selectedTextNotifier.value.isNotEmpty) {
                              _selectedTextNotifier.value = '';
                              _selectedRangeNotifier.value = null;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Preview with blanks
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _blanks.isEmpty ? 
                            'Your story with blanks will appear here...' : 
                            _getStoryWithBlanks(),
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Blanks Card
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Word Blanks',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      ValueListenableBuilder<String>(
                        valueListenable: _selectedTextNotifier,
                        builder: (context, selectedText, child) {
                          return AppButton(
                            text: 'Mark Selected as Blank',
                            onPressed: selectedText.isNotEmpty ? _addBlank : null,
                            variant: ButtonVariant.secondary,
                            size: ButtonSize.small,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_blanks.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.format_strikethrough,
                              size: 48,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No blanks added yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select text in your story and click "Mark as Blank"',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _blanks.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final blank = _blanks[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.primary,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(blank.word),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (blank.hint != null)
                                Text('Hint: ${blank.hint}'),
                              Text('Points: ${blank.points}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeBlank(index),
                          ),
                          isThreeLine: blank.hint != null,
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Game points summary
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Game Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total Maximum Points: $_maxPoints',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Blanks: ${_blanks.length}'),
                  Text('Provide Word Bank: ${_provideWordBank ? 'Yes' : 'No'}'),
                  Text('XP Reward: $_xpReward'),
                  Text('Coin Reward: $_coinReward'),
                  if (_timeLimit != null) Text('Time Limit: $_timeLimit seconds'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Save button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppButton(
                text: 'Save Game',
                onPressed: _isLoading ? null : _saveGame,
                isLoading: _isLoading,
                variant: ButtonVariant.primary,
                size: ButtonSize.large,
              ),
            ],
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
} 