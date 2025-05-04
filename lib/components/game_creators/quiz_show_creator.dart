import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';
import 'package:learn_play_level_up_flutter/components/ui/input.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';

class QuizShowGameCreator extends StatefulWidget {
  final Function(QuizShowGame) onGameCreated;
  final String teacherId;
  final String subjectId;
  final int gradeYear;
  final QuizShowGame? existingGame;

  const QuizShowGameCreator({
    super.key,
    required this.onGameCreated,
    required this.teacherId,
    required this.subjectId,
    required this.gradeYear,
    this.existingGame,
  });

  @override
  State<QuizShowGameCreator> createState() => _QuizShowGameCreatorState();
}

class _QuizShowGameCreatorState extends State<QuizShowGameCreator> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Form state
  int _difficulty = 3;
  int _estimatedDuration = 15;
  List<String> _tags = [];
  int _maxPoints = 0;
  int _xpReward = 150;
  int _coinReward = 75;
  List<QuizCategory> _categories = [];
  bool _allowPartialPoints = false;
  
  bool _isLoading = false;
  final _tagController = TextEditingController();
  final _categoryNameController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    if (widget.existingGame != null) {
      _titleController.text = widget.existingGame!.title;
      _descriptionController.text = widget.existingGame!.description;
      _difficulty = widget.existingGame!.difficulty;
      _estimatedDuration = widget.existingGame!.estimatedDuration;
      _tags = List.from(widget.existingGame!.tags);
      _maxPoints = widget.existingGame!.maxPoints;
      _xpReward = widget.existingGame!.xpReward;
      _coinReward = widget.existingGame!.coinReward;
      _categories = List.from(widget.existingGame!.categories);
      _allowPartialPoints = widget.existingGame!.allowPartialPoints;
    } else {
      // Add initial category
      _addCategory();
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    _categoryNameController.dispose();
    super.dispose();
  }
  
  void _addCategory() {
    setState(() {
      _categories.add(
        QuizCategory(
          name: 'Category ${_categories.length + 1}',
          questions: [
            QuizQuestion(
              question: '',
              answer: '',
              pointValue: 100,
            ),
            QuizQuestion(
              question: '',
              answer: '',
              pointValue: 200,
            ),
            QuizQuestion(
              question: '',
              answer: '',
              pointValue: 300,
            ),
          ],
        ),
      );
    });
  }
  
  void _removeCategory(int index) {
    if (_categories.length > 1) {
      setState(() {
        _categories.removeAt(index);
        _updateMaxPoints();
      });
    }
  }
  
  void _updateCategoryName(int index, String name) {
    setState(() {
      final updatedCategory = QuizCategory(
        id: _categories[index].id,
        name: name,
        questions: _categories[index].questions,
      );
      _categories[index] = updatedCategory;
    });
  }
  
  void _addQuestion(int categoryIndex) {
    setState(() {
      final highestPointValue = _categories[categoryIndex].questions.isNotEmpty 
          ? _categories[categoryIndex].questions.map((q) => q.pointValue).reduce((a, b) => a > b ? a : b) 
          : 0;
      
      _categories[categoryIndex].questions.add(
        QuizQuestion(
          question: '',
          answer: '',
          pointValue: highestPointValue + 100,
        ),
      );
      _updateMaxPoints();
    });
  }
  
  void _removeQuestion(int categoryIndex, int questionIndex) {
    if (_categories[categoryIndex].questions.length > 1) {
      setState(() {
        _categories[categoryIndex].questions.removeAt(questionIndex);
        _updateMaxPoints();
      });
    }
  }
  
  void _updateQuestion(int categoryIndex, int questionIndex, String question) {
    setState(() {
      final questions = List<QuizQuestion>.from(_categories[categoryIndex].questions);
      questions[questionIndex] = QuizQuestion(
        id: questions[questionIndex].id,
        question: question,
        answer: questions[questionIndex].answer,
        imageUrl: questions[questionIndex].imageUrl,
        pointValue: questions[questionIndex].pointValue,
        timeLimit: questions[questionIndex].timeLimit,
      );
      
      final updatedCategory = QuizCategory(
        id: _categories[categoryIndex].id,
        name: _categories[categoryIndex].name,
        questions: questions,
      );
      _categories[categoryIndex] = updatedCategory;
    });
  }
  
  void _updateAnswer(int categoryIndex, int questionIndex, String answer) {
    setState(() {
      final questions = List<QuizQuestion>.from(_categories[categoryIndex].questions);
      questions[questionIndex] = QuizQuestion(
        id: questions[questionIndex].id,
        question: questions[questionIndex].question,
        answer: answer,
        imageUrl: questions[questionIndex].imageUrl,
        pointValue: questions[questionIndex].pointValue,
        timeLimit: questions[questionIndex].timeLimit,
      );
      
      final updatedCategory = QuizCategory(
        id: _categories[categoryIndex].id,
        name: _categories[categoryIndex].name,
        questions: questions,
      );
      _categories[categoryIndex] = updatedCategory;
    });
  }
  
  void _updatePointValue(int categoryIndex, int questionIndex, int pointValue) {
    setState(() {
      final questions = List<QuizQuestion>.from(_categories[categoryIndex].questions);
      questions[questionIndex] = QuizQuestion(
        id: questions[questionIndex].id,
        question: questions[questionIndex].question,
        answer: questions[questionIndex].answer,
        imageUrl: questions[questionIndex].imageUrl,
        pointValue: pointValue,
        timeLimit: questions[questionIndex].timeLimit,
      );
      
      final updatedCategory = QuizCategory(
        id: _categories[categoryIndex].id,
        name: _categories[categoryIndex].name,
        questions: questions,
      );
      _categories[categoryIndex] = updatedCategory;
      _updateMaxPoints();
    });
  }
  
  void _updateMaxPoints() {
    int total = 0;
    for (var category in _categories) {
      for (var question in category.questions) {
        total += question.pointValue;
      }
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
    
    // Validate categories and questions
    for (var i = 0; i < _categories.length; i++) {
      if (_categories[i].name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category ${i + 1} name is empty')),
        );
        return;
      }
      
      for (var j = 0; j < _categories[i].questions.length; j++) {
        if (_categories[i].questions[j].question.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Question is empty in category ${_categories[i].name}')),
          );
          return;
        }
        
        if (_categories[i].questions[j].answer.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Answer is empty in category ${_categories[i].name}')),
          );
          return;
        }
      }
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Update max points before creating the game
      _updateMaxPoints();
      
      final QuizShowGame game = QuizShowGame(
        title: _titleController.text,
        description: _descriptionController.text,
        teacherId: widget.teacherId,
        subjectId: widget.subjectId,
        gradeYear: widget.gradeYear,
        createdAt: widget.existingGame?.createdAt ?? DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 7)),
        difficulty: _difficulty,
        estimatedDuration: _estimatedDuration,
        tags: _tags,
        maxPoints: _maxPoints,
        xpReward: _xpReward,
        coinReward: _coinReward,
        categories: _categories,
        allowPartialPoints: _allowPartialPoints,
      );
      
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
            'Create Quiz Show Game',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a Jeopardy-style quiz with categories and point values',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          
          // Basic Game Info
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
                
                // Game settings (difficulty, duration, rewards)
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
                
                // Tags
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
                
                // Rewards
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
                                _xpReward = int.tryParse(value) ?? 150;
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
                                _coinReward = int.tryParse(value) ?? 75;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Quiz Show specific options
                Row(
                  children: [
                    Checkbox(
                      value: _allowPartialPoints,
                      onChanged: (value) {
                        setState(() {
                          _allowPartialPoints = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Allow partial points for partially correct answers',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Categories Section
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    AppButton(
                      text: 'Add Category',
                      variant: ButtonVariant.primary,
                      size: ButtonSize.small,
                      leadingIcon: Icons.add,
                      onPressed: _addCategory,
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
                
                // Categories List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    return _buildCategoryCard(context, index);
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
  
  Widget _buildCategoryCard(BuildContext context, int categoryIndex) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final category = _categories[categoryIndex];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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
              Expanded(
                child: TextFormField(
                  initialValue: category.name,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) => _updateCategoryName(categoryIndex, value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: colorScheme.primary,
                    ),
                    tooltip: 'Add Question',
                    onPressed: () => _addQuestion(categoryIndex),
                  ),
                  if (_categories.length > 1)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: colorScheme.error,
                      ),
                      tooltip: 'Delete Category',
                      onPressed: () => _removeCategory(categoryIndex),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Questions List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: category.questions.length,
            itemBuilder: (context, questionIndex) {
              return _buildQuestionCard(context, categoryIndex, questionIndex);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuestionCard(BuildContext context, int categoryIndex, int questionIndex) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final question = _categories[categoryIndex].questions[questionIndex];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Point value
              DropdownButton<int>(
                value: question.pointValue,
                items: [100, 200, 300, 400, 500, 1000].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value points'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    _updatePointValue(categoryIndex, questionIndex, newValue);
                  }
                },
              ),
              if (_categories[categoryIndex].questions.length > 1)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: colorScheme.error,
                  ),
                  tooltip: 'Delete Question',
                  onPressed: () => _removeQuestion(categoryIndex, questionIndex),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Question text
          TextFormField(
            initialValue: question.question,
            decoration: InputDecoration(
              labelText: 'Question',
              hintText: 'Enter your question',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 2,
            onChanged: (value) => _updateQuestion(categoryIndex, questionIndex, value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a question';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Answer
          TextFormField(
            initialValue: question.answer,
            decoration: InputDecoration(
              labelText: 'Answer',
              hintText: 'Enter the correct answer',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) => _updateAnswer(categoryIndex, questionIndex, value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an answer';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
} 