import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/pages/game_templates/template_creation_base_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class WordSearchCreationPage extends StatefulWidget {
  const WordSearchCreationPage({super.key});

  @override
  State<WordSearchCreationPage> createState() => _WordSearchCreationPageState();
}

class _WordSearchCreationPageState extends State<WordSearchCreationPage> {
  final List<WordSearchItem> _words = [];
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Game settings
  int _gridSize = 10;
  bool _enableDiagonal = true;
  bool _enableReverse = false;
  int _timeLimit = 180; // 3 minutes in seconds
  
  @override
  void initState() {
    super.initState();
    _pointsController.text = '10';
  }
  
  @override
  void dispose() {
    _wordController.dispose();
    _hintController.dispose();
    _pointsController.dispose();
    super.dispose();
  }
  
  void _addWord() {
    if (_formKey.currentState!.validate()) {
      final String word = _wordController.text.trim().toUpperCase();
      
      // Check if the word is too long for the grid
      if (word.length > _gridSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Word "$word" is too long for a ${_gridSize}x${_gridSize} grid. Increase grid size or use a shorter word.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      setState(() {
        _words.add(
          WordSearchItem(
            word: word,
            hint: _hintController.text.trim(),
            points: int.tryParse(_pointsController.text) ?? 10,
          ),
        );
        
        // Clear the form
        _wordController.clear();
        _hintController.clear();
        _pointsController.text = '10';
      });
    }
  }
  
  void _removeWord(int index) {
    setState(() {
      _words.removeAt(index);
    });
  }
  
  bool _validateForm() {
    if (_words.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one word to create a word search game'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    
    // Check for very large grids that might cause performance issues
    if (_gridSize > 15 && _words.length > 10) {
      // Show a warning dialog and require confirmation
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Warning: Large Grid Size'),
          content: const Text(
            'Creating a large grid (>15x15) with many words may cause performance issues on some devices. '
            'Consider reducing the grid size or number of words.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('ADJUST SETTINGS'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('CONTINUE ANYWAY'),
            ),
          ],
        ),
      ).then((confirmed) {
        return confirmed ?? false;
      });
      
      return false;
    }
    
    return true;
  }
  
  Future<bool> _saveToFirebase(BuildContext context, {
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
      // Calculate total max points
      int totalPoints = 0;
      for (final word in _words) {
        totalPoints += word.points;
      }
      
      // Create the game object
      final game = WordSearchGame(
        title: title,
        description: description,
        teacherId: teacherId,
        subjectId: subjectId,
        gradeYear: gradeYear,
        createdAt: DateTime.now(),
        dueDate: dueDate,
        isActive: true,
        estimatedDuration: (_timeLimit / 60).ceil(),
        tags: ['word_search', 'vocabulary', 'language'],
        maxPoints: maxPoints > 0 ? maxPoints : totalPoints,
        xpReward: xpReward,
        coinReward: coinReward,
        words: _words,
        gridSize: _gridSize,
        enableDiagonal: _enableDiagonal,
        enableReverse: _enableReverse,
        timeLimit: _timeLimit > 0 ? _timeLimit : null,
      );
      
      // Save to Firestore
      await FirebaseFirestore.instance.collection('games').add(game.toFirestore());
      return true;
    } catch (e) {
      print('Error saving game: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving game: $e')),
      );
      return false;
    }
  }
  
  Widget _buildWordSearchContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Word Search Content',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Grid size selector
          Row(
            children: [
              Expanded(
                child: Text(
                  'Grid Size (${_gridSize}x${_gridSize})',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<int>(
                value: _gridSize,
                items: [8, 10, 12, 15, 18, 20].map((size) {
                  return DropdownMenuItem<int>(
                    value: size,
                    child: Text('${size}x${size}'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _gridSize = value;
                      
                      // Check if any existing words are now too long
                      final tooLongWords = _words.where((word) => word.word.length > _gridSize).toList();
                      if (tooLongWords.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${tooLongWords.length} words are too long for a ${_gridSize}x${_gridSize} grid and will need to be removed'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Game options
          Text(
            'Word Search Options',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          
          SwitchListTile(
            title: const Text('Allow Diagonal Words'),
            subtitle: const Text('Words can be placed diagonally on the grid'),
            value: _enableDiagonal,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) {
              setState(() {
                _enableDiagonal = value;
              });
            },
          ),
          
          SwitchListTile(
            title: const Text('Allow Reversed Words'),
            subtitle: const Text('Words can be placed backwards on the grid'),
            value: _enableReverse,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) {
              setState(() {
                _enableReverse = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Time limit slider
          Row(
            children: [
              Expanded(
                child: Text(
                  'Time Limit: ${(_timeLimit / 60).floor()}:${(_timeLimit % 60).toString().padLeft(2, '0')}',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          
          Slider(
            value: _timeLimit.toDouble(),
            min: 60, // 1 minute minimum
            max: 600, // 10 minutes maximum
            divisions: 18,
            label: "${(_timeLimit / 60).floor()}:${(_timeLimit % 60).toString().padLeft(2, '0')}",
            onChanged: (value) {
              setState(() {
                _timeLimit = value.toInt();
              });
            },
          ),
          
          const Divider(),
          const SizedBox(height: 16),
          
          // Words form
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Words and Hints',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                
                // Word input
                TextFormField(
                  controller: _wordController,
                  decoration: InputDecoration(
                    labelText: 'Word',
                    hintText: 'Enter a word to find (no spaces)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a word';
                    }
                    if (value.trim().contains(' ')) {
                      return 'Please enter a single word (no spaces)';
                    }
                    if (value.trim().length > _gridSize) {
                      return 'Word is too long for the current grid size';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Hint input
                TextFormField(
                  controller: _hintController,
                  decoration: InputDecoration(
                    labelText: 'Hint',
                    hintText: 'Enter a hint for this word',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a hint';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Points input
                TextFormField(
                  controller: _pointsController,
                  decoration: InputDecoration(
                    labelText: 'Points',
                    hintText: 'Points for finding this word',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter points';
                    }
                    final points = int.tryParse(value);
                    if (points == null || points <= 0) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Add word button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(
                      text: 'Add Word',
                      leadingIcon: Icons.add,
                      onPressed: _addWord,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Word list with preview grid
          Text(
            'Added Words',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          
          if (_words.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No words added yet. Add at least one word to create a game.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Column(
              children: [
                // Visual indicator of word count and grid utilization
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${_words.length}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Words',
                            style: theme.textTheme.labelMedium,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${_gridSize}x${_gridSize}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Grid Size',
                            style: theme.textTheme.labelMedium,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            _words.map((w) => w.points).reduce((a, b) => a + b).toString(),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Total Points',
                            style: theme.textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // List of words with ability to remove
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _words.length,
                  itemBuilder: (context, index) {
                    final word = _words[index];
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          word.word,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Hint: ${word.hint}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${word.points} pts',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () => _removeWord(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          
          const SizedBox(height: 16),
          
          // Word grid preview (simplified representation)
          if (_words.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grid Preview (Simplified)',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                
                // Simplified grid visualization
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _gridSize,
                      ),
                      itemCount: _gridSize * _gridSize,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              // Just a placeholder, in a real app this would show a proper word search preview
                              String.fromCharCode(65 + (index % 26)),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Note about preview
                Text(
                  'Note: This is a simplified preview. The actual word search puzzle will be generated when students play the game.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return TemplateCreationBasePage(
      type: 'word_search',
      title: 'Word Search',
      icon: Icons.search,
      color: Colors.teal,
      contentBuilder: _buildWordSearchContent,
      saveToFirebase: _saveToFirebase,
      validateForm: _validateForm,
    );
  }
} 