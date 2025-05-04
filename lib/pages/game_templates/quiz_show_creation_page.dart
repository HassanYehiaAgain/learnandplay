import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/pages/game_templates/template_creation_base_page.dart';
import 'package:learn_play_level_up_flutter/services/game_templates_provider.dart';
import 'package:learn_play_level_up_flutter/widgets/common/image_upload.dart';
import 'package:uuid/uuid.dart';

class QuizShowCreationPage extends StatefulWidget {
  const QuizShowCreationPage({Key? key}) : super(key: key);

  @override
  _QuizShowCreationPageState createState() => _QuizShowCreationPageState();
}

class _QuizShowCreationPageState extends State<QuizShowCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Categories
  final List<QuizCategory> _categories = [];
  final _categoryNameController = TextEditingController();
  final _categoryDescriptionController = TextEditingController();
  
  // Questions
  String? _selectedCategoryId;
  final _questionTextController = TextEditingController();
  final _answerController = TextEditingController();
  final _pointsController = TextEditingController();
  final _timeLimitController = TextEditingController();
  int _selectedPointValue = 100;
  String? _questionImageUrl;
  int? _questionTimeLimit;
  
  // Final Jeopardy
  bool _includeFinalJeopardy = false;
  final _finalQuestionController = TextEditingController();
  final _finalAnswerController = TextEditingController();
  final _finalPointsController = TextEditingController();
  final _finalTimeLimitController = TextEditingController();
  int _finalPointValue = 500;
  String? _finalImageUrl;
  int? _finalTimeLimit;
  
  // Game settings
  bool _allowNegativeScores = false;
  bool _enableWrongAnswerPenalty = false;
  bool _includeRandomDailyDoubles = false;
  int _estimatedDuration = 20;
  int _xpReward = 200;
  int _coinReward = 100;
  int _maxPoints = 1000;
  
  // Possible point values
  final List<int> _pointValues = [100, 200, 300, 400, 500];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryNameController.dispose();
    _categoryDescriptionController.dispose();
    _questionTextController.dispose();
    _answerController.dispose();
    _pointsController.dispose();
    _timeLimitController.dispose();
    _finalQuestionController.dispose();
    _finalAnswerController.dispose();
    _finalPointsController.dispose();
    _finalTimeLimitController.dispose();
    super.dispose();
  }

  void _addCategory() {
    if (_categoryNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    final categoryId = const Uuid().v4();
    setState(() {
      _categories.add(
        QuizCategory(
          id: categoryId,
          name: _categoryNameController.text,
          questions: [],
        ),
      );
      _categoryNameController.clear();
      _categoryDescriptionController.clear();
      _selectedCategoryId = categoryId; // Auto-select the new category
    });
  }

  void _removeCategory(String categoryId) {
    setState(() {
      _categories.removeWhere((c) => c.id == categoryId);
      if (_selectedCategoryId == categoryId) {
        _selectedCategoryId = _categories.isNotEmpty ? _categories.first.id : null;
      }
    });
  }

  void _addQuestion() {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category first')),
      );
      return;
    }

    if (_questionTextController.text.isEmpty || _answerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter question text and answer')),
      );
      return;
    }

    final newQuestion = QuizQuestion(
      id: const Uuid().v4(),
      type: 'short_answer', // For quiz show style
      questionText: _questionTextController.text,
      answer: _answerController.text,
      points: int.tryParse(_pointsController.text) ?? 100,
      timeLimit: int.tryParse(_timeLimitController.text) ?? 30,
      position: _categories.firstWhere((c) => c.id == _selectedCategoryId).questions.length,
    );

    setState(() {
      final categoryIndex = _categories.indexWhere((c) => c.id == _selectedCategoryId);
      if (categoryIndex != -1) {
        final updatedQuestions = List<QuizQuestion>.from(_categories[categoryIndex].questions)..add(newQuestion);
        _categories[categoryIndex] = QuizCategory(
          id: _categories[categoryIndex].id,
          name: _categories[categoryIndex].name,
          questions: updatedQuestions,
        );
      }

      // Clear form
      _questionTextController.clear();
      _answerController.clear();
      _pointsController.clear();
      _timeLimitController.clear();
      _questionImageUrl = null;
    });
  }

  void _removeQuestion(String categoryId, int questionIndex) {
    setState(() {
      final categoryIndex = _categories.indexWhere((c) => c.id == categoryId);
      if (categoryIndex != -1) {
        final questions = List<QuizQuestion>.from(_categories[categoryIndex].questions);
        questions.removeAt(questionIndex);
        
        _categories[categoryIndex] = QuizCategory(
          id: _categories[categoryIndex].id,
          name: _categories[categoryIndex].name,
          questions: questions,
        );
      }
    });
  }

  Future<void> _saveGame() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one category')),
      );
      return;
    }
    
    // Check if all categories have questions
    bool hasEmptyCategory = false;
    for (final category in _categories) {
      if (category.questions.isEmpty) {
        hasEmptyCategory = true;
        break;
      }
    }
    
    if (hasEmptyCategory) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All categories must have at least one question')),
      );
      return;
    }
    
    // Create final game data
    final List<QuizCategory> gameCategories = List.from(_categories);
    
    // Add final Jeopardy as a special category if enabled
    if (_includeFinalJeopardy) {
      if (_finalQuestionController.text.isEmpty || _finalAnswerController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete the Final Jeopardy question')),
        );
        return;
      }
      
      final finalQuestion = QuizQuestion(
        id: const Uuid().v4(),
        type: 'short_answer', // For quiz show style
        questionText: _finalQuestionController.text,
        answer: _finalAnswerController.text,
        points: int.tryParse(_finalPointsController.text) ?? 1000,
        timeLimit: int.tryParse(_finalTimeLimitController.text) ?? 30,
        position: _categories.firstWhere((c) => c.id == _selectedCategoryId).questions.length,
      );
      
      gameCategories.add(QuizCategory(
        name: 'Final Jeopardy',
        questions: [finalQuestion],
      ));
    }

    final game = QuizShowGame(
      title: _titleController.text,
      description: _descriptionController.text,
      teacherId: Provider.of<GameTemplatesProvider>(context, listen: false).currentUser!.id,
      subjectId: Provider.of<GameTemplatesProvider>(context, listen: false).selectedSubject!.id,
      gradeYear: Provider.of<GameTemplatesProvider>(context, listen: false).selectedGradeYear!,
      createdAt: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 7)),
      estimatedDuration: _estimatedDuration,
      tags: ['quiz_show', 'jeopardy'],
      maxPoints: _maxPoints,
      xpReward: _xpReward,
      coinReward: _coinReward,
      categories: gameCategories,
      allowPartialPoints: true,
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
      type: 'quiz_show',
      title: 'Create Quiz Show Game',
      icon: Icons.quiz,
      color: Colors.indigo,
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
                validator: (value) => value == null || value.isEmpty 
                    ? 'Please enter a title' : null,
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
              const SizedBox(height: 24),
              
              // Categories section
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
                            'Categories',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Add Category'),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => _buildAddCategoryDialog(),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Category chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((category) {
                          final isSelected = category.id == _selectedCategoryId;
                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(category.name),
                                if (isSelected) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _removeCategory(category.id),
                                    child: const Icon(Icons.cancel, size: 16),
                                  ),
                                ],
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategoryId = selected ? category.id : null;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      
                      // Selected category questions
                      if (_selectedCategoryId != null) ...[
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Questions for ${_getCategoryName(_selectedCategoryId!)}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Add Question'),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => _buildAddQuestionDialog(),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Questions list
                        _buildQuestionsTable(_selectedCategoryId!),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Final Jeopardy
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _includeFinalJeopardy,
                            onChanged: (value) {
                              setState(() {
                                _includeFinalJeopardy = value ?? false;
                              });
                            },
                          ),
                          const Text(
                            'Include Final Jeopardy Question',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      
                      if (_includeFinalJeopardy) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _finalQuestionController,
                          decoration: const InputDecoration(
                            labelText: 'Final Question',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                          validator: (value) => _includeFinalJeopardy && (value == null || value.isEmpty)
                              ? 'Please enter the final question' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _finalAnswerController,
                          decoration: const InputDecoration(
                            labelText: 'Final Answer',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => _includeFinalJeopardy && (value == null || value.isEmpty)
                              ? 'Please enter the final answer' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        // Final Jeopardy point value and image upload
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                decoration: const InputDecoration(
                                  labelText: 'Point Value',
                                  border: OutlineInputBorder(),
                                ),
                                value: _finalPointValue,
                                items: [500, 1000, 1500, 2000].map((value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(value.toString()),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _finalPointValue = value ?? 500;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Image (Optional):'),
                                  const SizedBox(height: 8),
                                  ImageUploadField(
                                    onImageSelected: (url) {
                                      setState(() {
                                        _finalImageUrl = url;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Time Limit (seconds, optional)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _finalTimeLimit = int.tryParse(value);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
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
                      
                      // Score settings
                      SwitchListTile(
                        title: const Text('Allow Negative Scores'),
                        subtitle: const Text('Players can go below zero points'),
                        value: _allowNegativeScores,
                        onChanged: (value) {
                          setState(() {
                            _allowNegativeScores = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Wrong Answer Penalty'),
                        subtitle: const Text('Deduct points for incorrect answers'),
                        value: _enableWrongAnswerPenalty,
                        onChanged: (value) {
                          setState(() {
                            _enableWrongAnswerPenalty = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Include Random Daily Doubles'),
                        subtitle: const Text('Some questions will be worth double points'),
                        value: _includeRandomDailyDoubles,
                        onChanged: (value) {
                          setState(() {
                            _includeRandomDailyDoubles = value;
                          });
                        },
                      ),
                      
                      // Game reward settings
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Estimated Duration (minutes)',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: '20',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _estimatedDuration = int.tryParse(value) ?? 20;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'XP Reward',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: '200',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _xpReward = int.tryParse(value) ?? 200;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Coin Reward',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: '100',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _coinReward = int.tryParse(value) ?? 100;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Maximum Points',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: '1000',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _maxPoints = int.tryParse(value) ?? 1000;
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
          // Create final game data
          final List<QuizCategory> gameCategories = List.from(_categories);
          
          // Add final Jeopardy as a special category if enabled
          if (_includeFinalJeopardy) {
            if (_finalQuestionController.text.isEmpty || _finalAnswerController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please complete the Final Jeopardy question')),
              );
              return false;
            }
            
            final finalQuestion = QuizQuestion(
              id: const Uuid().v4(),
              type: 'short_answer', // For quiz show style
              questionText: _finalQuestionController.text,
              answer: _finalAnswerController.text,
              points: int.tryParse(_finalPointsController.text) ?? 1000,
              timeLimit: int.tryParse(_finalTimeLimitController.text) ?? 30,
              position: _categories.firstWhere((c) => c.id == _selectedCategoryId).questions.length,
            );
            
            gameCategories.add(QuizCategory(
              name: 'Final Jeopardy',
              questions: [finalQuestion],
            ));
          }
      
          final game = QuizShowGame(
            title: title,
            description: description,
            teacherId: teacherId,
            subjectId: subjectId,
            gradeYear: gradeYear,
            createdAt: DateTime.now(),
            dueDate: dueDate,
            estimatedDuration: _estimatedDuration,
            tags: ['quiz_show', 'jeopardy'],
            maxPoints: maxPoints,
            xpReward: xpReward,
            coinReward: coinReward,
            categories: gameCategories,
            allowPartialPoints: true,
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
        if (!_formKey.currentState!.validate()) return false;
        if (_categories.isEmpty) return false;
        
        // Check if all categories have questions
        for (final category in _categories) {
          if (category.questions.isEmpty) {
            return false;
          }
        }
        
        return true;
      },
    );
  }
  
  String _getCategoryName(String categoryId) {
    final category = _categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => QuizCategory(name: 'Unknown', questions: []),
    );
    return category.name;
  }
  
  Widget _buildQuestionsTable(String categoryId) {
    final category = _categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => QuizCategory(name: 'Unknown', questions: []),
    );
    
    if (category.questions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text('No questions added yet'),
        ),
      );
    }
    
    return Column(
      children: [
        Table(
          border: TableBorder.all(),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(1),
          },
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Colors.grey),
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Question', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Answer', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Points', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Image', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            ...List.generate(category.questions.length, (index) {
              final question = category.questions[index];
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(question.questionText),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(question.answer ?? ''),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(question.points.toString()),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: question.imageUrl != null
                        ? const Icon(Icons.check, color: Colors.green)
                        : const Icon(Icons.close, color: Colors.red),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeQuestion(categoryId, index),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }
  
  Widget _buildAddCategoryDialog() {
    return AlertDialog(
      title: const Text('Add Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _categoryNameController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _categoryDescriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_categoryNameController.text.isNotEmpty) {
              _addCategory();
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
  
  Widget _buildAddQuestionDialog() {
    return AlertDialog(
      title: const Text('Add Question'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _questionTextController,
              decoration: const InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _answerController,
              decoration: const InputDecoration(
                labelText: 'Answer',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Point Value',
                border: OutlineInputBorder(),
              ),
              value: _selectedPointValue,
              items: _pointValues.map((value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPointValue = value ?? 100;
                });
              },
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Image (Optional):'),
                const SizedBox(height: 8),
                ImageUploadField(
                  onImageSelected: (url) {
                    setState(() {
                      _questionImageUrl = url;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Time Limit (seconds, optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _questionTimeLimit = int.tryParse(value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            // Clear form data
            _questionTextController.clear();
            _answerController.clear();
            _pointsController.clear();
            _timeLimitController.clear();
            _questionImageUrl = null;
            _questionTimeLimit = null;
            _selectedPointValue = 100;
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_questionTextController.text.isNotEmpty && _answerController.text.isNotEmpty) {
              _addQuestion();
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
} 