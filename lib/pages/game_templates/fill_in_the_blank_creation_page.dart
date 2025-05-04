import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/pages/game_templates/template_creation_base_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class FillInTheBlankCreationPage extends StatefulWidget {
  const FillInTheBlankCreationPage({super.key});

  @override
  State<FillInTheBlankCreationPage> createState() => _FillInTheBlankCreationPageState();
}

class _FillInTheBlankCreationPageState extends State<FillInTheBlankCreationPage> {
  final List<FillInTheBlankItem> _blanks = [];
  final TextEditingController _passageController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();
  final TextEditingController _alternativeAnswersController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Game settings
  bool _showHints = true;
  bool _autoCheck = false;
  bool _caseSensitive = false;
  int _timeLimit = 300; // 5 minutes in seconds
  String? _instructions;
  List<String>? _wordBank;
  
  @override
  void dispose() {
    _passageController.dispose();
    _answerController.dispose();
    _hintController.dispose();
    _alternativeAnswersController.dispose();
    super.dispose();
  }
  
  void _addBlank() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _blanks.add(
          FillInTheBlankItem(
            id: const Uuid().v4(),
            correctAnswer: _answerController.text.trim(),
            alternativeAnswers: _alternativeAnswersController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
            hint: _hintController.text.trim(),
            position: _blanks.length,
            caseSensitive: _caseSensitive,
          ),
        );
        
        // Clear the form
        _answerController.clear();
        _hintController.clear();
        _alternativeAnswersController.clear();
      });
    }
  }
  
  void _removeBlank(int index) {
    setState(() {
      _blanks.removeAt(index);
      // Update positions
      for (var i = 0; i < _blanks.length; i++) {
        _blanks[i] = FillInTheBlankItem(
          id: _blanks[i].id,
          correctAnswer: _blanks[i].correctAnswer,
          alternativeAnswers: _blanks[i].alternativeAnswers,
          hint: _blanks[i].hint,
          position: i,
          caseSensitive: _blanks[i].caseSensitive,
        );
      }
    });
  }
  
  void _generateWordBank() {
    if (_blanks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one blank first')),
      );
      return;
    }
    
    setState(() {
      _wordBank = [
        ..._blanks.map((b) => b.correctAnswer),
        ..._blanks.expand((b) => b.alternativeAnswers),
      ];
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
      // Create the game object
      final game = FillInTheBlankGame(
        title: title,
        description: description,
        teacherId: teacherId,
        subjectId: subjectId,
        gradeYear: gradeYear,
        createdAt: DateTime.now(),
        dueDate: dueDate,
        isActive: true,
        estimatedDuration: (_timeLimit / 60).ceil(),
        tags: ['fill_in_the_blank', 'vocabulary', 'comprehension'],
        maxPoints: maxPoints,
        xpReward: xpReward,
        coinReward: coinReward,
        passage: _passageController.text,
        blanks: _blanks,
        wordBank: _wordBank,
        showHints: _showHints,
        autoCheck: _autoCheck,
        timeLimit: _timeLimit,
        instructions: _instructions,
        caseSensitive: _caseSensitive,
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
  
  Widget _buildFillInTheBlankContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fill-in-the-Blank Content',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Passage input
          Text(
            'Passage',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passageController,
            decoration: InputDecoration(
              hintText: 'Enter the passage text. Use ___ to indicate blank spaces.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a passage';
              }
              if (!value.contains('___')) {
                return 'Please use ___ to indicate blank spaces';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // Game settings
          Text(
            'Game Settings',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text('Show Hints'),
            subtitle: const Text('Allow students to view hints for each blank'),
            value: _showHints,
            onChanged: (value) {
              setState(() {
                _showHints = value;
              });
            },
          ),
          
          SwitchListTile(
            title: const Text('Auto-Check Answers'),
            subtitle: const Text('Automatically check answers as students type'),
            value: _autoCheck,
            onChanged: (value) {
              setState(() {
                _autoCheck = value;
              });
            },
          ),
          
          SwitchListTile(
            title: const Text('Case Sensitive'),
            subtitle: const Text('Answers must match case exactly'),
            value: _caseSensitive,
            onChanged: (value) {
              setState(() {
                _caseSensitive = value;
              });
            },
          ),
          
          ListTile(
            title: const Text('Time Limit'),
            subtitle: Text('${(_timeLimit / 60).floor()} minutes'),
          ),
          Slider(
            value: _timeLimit.toDouble(),
            min: 60,
            max: 1800,
            divisions: 29,
            label: '${(_timeLimit / 60).floor()} minutes',
            onChanged: (value) {
              setState(() {
                _timeLimit = value.toInt();
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // Blanks form
          Text(
            'Blank Spaces',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _answerController,
                  decoration: InputDecoration(
                    labelText: 'Correct Answer',
                    hintText: 'Enter the correct answer for this blank',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a correct answer';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _alternativeAnswersController,
                  decoration: InputDecoration(
                    labelText: 'Alternative Answers (Optional)',
                    hintText: 'Enter alternative correct answers, separated by commas',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _hintController,
                  decoration: InputDecoration(
                    labelText: 'Hint (Optional)',
                    hintText: 'Enter a hint for this blank',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Blank'),
                  onPressed: _addBlank,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Blanks list
          if (_blanks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No blanks added yet. Add at least one blank to create a game.',
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
              itemCount: _blanks.length,
              itemBuilder: (context, index) {
                final blank = _blanks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primary.withOpacity(0.2),
                      child: Text((index + 1).toString()),
                    ),
                    title: Text(blank.correctAnswer),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (blank.alternativeAnswers.isNotEmpty)
                          Text(
                            'Alternatives: ${blank.alternativeAnswers.join(', ')}',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        if (blank.hint != null)
                          Text(
                            'Hint: ${blank.hint}',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: colorScheme.error),
                      onPressed: () => _removeBlank(index),
                    ),
                  ),
                );
              },
            ),
          
          const SizedBox(height: 24),
          
          // Word bank
          Text(
            'Word Bank',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Generate from Blanks'),
                  onPressed: _generateWordBank,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Manually'),
                  onPressed: () {
                    // TODO: Implement manual word bank editing
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
                  ),
                ),
              ),
            ],
          ),
          
          if (_wordBank != null) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _wordBank!.map((word) {
                return Chip(
                  label: Text(word),
                  onDeleted: () {
                    setState(() {
                      _wordBank!.remove(word);
                    });
                  },
                );
              }).toList(),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Instructions
          Text(
            'Instructions (Optional)',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Enter game instructions for students',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 3,
            onChanged: (value) {
              setState(() {
                _instructions = value.trim();
              });
            },
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return TemplateCreationBasePage(
      type: 'fill_in_the_blank',
      title: 'Fill-in-the-Blank',
      icon: Icons.edit_note,
      color: Colors.blue,
      contentBuilder: _buildFillInTheBlankContent,
      saveToFirebase: _saveToFirebase,
      validateForm: () {
        if (_passageController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a passage')),
          );
          return false;
        }
        if (_blanks.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please add at least one blank')),
          );
          return false;
        }
        return true;
      },
    );
  }
} 