import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/pages/game_templates/template_creation_base_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class WordScrambleCreationPage extends StatefulWidget {
  const WordScrambleCreationPage({super.key});

  @override
  State<WordScrambleCreationPage> createState() => _WordScrambleCreationPageState();
}

class _WordScrambleCreationPageState extends State<WordScrambleCreationPage> {
  final List<WordScrambleItem> _words = [];
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _caseSensitive = false;
  int _timePerWord = 30; // seconds
  
  @override
  void initState() {
    super.initState();
    _pointsController.text = '10'; // Set default points value
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
      setState(() {
        _words.add(
          WordScrambleItem(
            word: _wordController.text.trim(),
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
      for (final item in _words) {
        totalPoints += item.points;
      }
      
      // Create the game object
      final game = WordScrambleGame(
        title: title,
        description: description,
        teacherId: teacherId,
        subjectId: subjectId,
        gradeYear: gradeYear,
        createdAt: DateTime.now(),
        dueDate: dueDate,
        isActive: true,
        estimatedDuration: _words.length * (_timePerWord / 60).ceil(), // Convert to minutes
        tags: ['word_scramble', 'anagram', 'language'],
        maxPoints: maxPoints > 0 ? maxPoints : totalPoints,
        xpReward: xpReward,
        coinReward: coinReward,
        words: _words,
        caseSensitive: _caseSensitive,
        timeLimit: _timePerWord > 0 ? _timePerWord : null,
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
  
  Widget _buildWordScrambleContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Word Scramble Content',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
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
                    hintText: 'Enter a word to be scrambled',
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
                    hintText: 'Points for solving this word',
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
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Word'),
                      onPressed: _addWord,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Word list
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
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _words.length,
              itemBuilder: (context, index) {
                final word = _words[index];
                final scrambled = word.getScrambledWord();
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.withOpacity(0.2),
                      child: Text(word.word.substring(0, 1).toUpperCase()),
                    ),
                    title: Text(word.word),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hint: ${word.hint}'),
                        Text('Scrambled: $scrambled', 
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${word.points} pts'),
                        IconButton(
                          icon: Icon(Icons.delete, color: colorScheme.error),
                          onPressed: () => _removeWord(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          
          const SizedBox(height: 24),
          
          // Game-specific settings
          Text(
            'Word Scramble Settings',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          // Case sensitive toggle
          SwitchListTile(
            title: const Text('Case Sensitive'),
            subtitle: const Text('Require correct capitalization'),
            value: _caseSensitive,
            onChanged: (value) {
              setState(() {
                _caseSensitive = value;
              });
            },
          ),
          
          // Time per word slider
          ListTile(
            title: const Text('Time Per Word'),
            subtitle: Text('$_timePerWord seconds per word'),
          ),
          Slider(
            value: _timePerWord.toDouble(),
            min: 10,
            max: 60,
            divisions: 10,
            label: '$_timePerWord seconds',
            onChanged: (value) {
              setState(() {
                _timePerWord = value.toInt();
              });
            },
          ),
          
          // Preview section
          if (_words.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Game Preview',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text('Unscramble the word:'),
                  const SizedBox(height: 16),
                  Text(
                    _words[0].getScrambledWord(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hint: ${_words[0].hint}',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TemplateCreationBasePage(
      type: 'word_scramble',
      title: 'Word Scramble',
      icon: Icons.shuffle,
      color: Colors.purple,
      contentBuilder: _buildWordScrambleContent,
      saveToFirebase: _saveToFirebase,
      validateForm: () {
        if (_words.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please add at least one word')),
          );
          return false;
        }
        return true;
      },
    );
  }
} 