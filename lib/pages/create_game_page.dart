import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';
import 'package:learn_play_level_up_flutter/components/ui/input.dart';

class CreateGamePage extends StatefulWidget {
  const CreateGamePage({Key? key}) : super(key: key);

  @override
  State<CreateGamePage> createState() => _CreateGamePageState();
}

class _CreateGamePageState extends State<CreateGamePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Form state
  String _selectedCategory = 'Mathematics';
  int _selectedDifficulty = 3;
  int _estimatedTime = 10;
  List<Map<String, dynamic>> _questions = [];
  
  bool _isLoading = false;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    // Add an empty question to start with
    _addNewQuestion();
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  void _addNewQuestion() {
    setState(() {
      _questions.add({
        'text': '',
        'points': 10,
        'options': [
          {'text': '', 'isCorrect': true},
          {'text': '', 'isCorrect': false},
          {'text': '', 'isCorrect': false},
          {'text': '', 'isCorrect': false},
        ],
      });
    });
  }
  
  void _removeQuestion(int index) {
    if (_questions.length > 1) {
      setState(() {
        _questions.removeAt(index);
      });
    }
  }
  
  void _updateQuestionText(int index, String text) {
    setState(() {
      _questions[index]['text'] = text;
    });
  }
  
  void _updateOptionText(int questionIndex, int optionIndex, String text) {
    setState(() {
      _questions[questionIndex]['options'][optionIndex]['text'] = text;
    });
  }
  
  void _setCorrectOption(int questionIndex, int optionIndex) {
    setState(() {
      for (var i = 0; i < _questions[questionIndex]['options'].length; i++) {
        _questions[questionIndex]['options'][i]['isCorrect'] = i == optionIndex;
      }
    });
  }
  
  void _updatePoints(int questionIndex, int points) {
    setState(() {
      _questions[questionIndex]['points'] = points;
    });
  }
  
  Future<void> _saveGame() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Validate questions
    for (var i = 0; i < _questions.length; i++) {
      if (_questions[i]['text'].isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Question ${i + 1} is empty')),
        );
        return;
      }
      
      bool hasValidOptions = false;
      for (var option in _questions[i]['options']) {
        if (option['text'].isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Question ${i + 1} has empty options')),
          );
          return;
        }
        if (option['isCorrect']) {
          hasValidOptions = true;
        }
      }
      
      if (!hasValidOptions) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Question ${i + 1} has no correct answer marked')),
        );
        return;
      }
    }
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      // TODO: Implement API call to save game
      
      // Mock save operation
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game created successfully!')),
      );
      
      // Navigate back to teacher dashboard
      Navigator.pushReplacementNamed(context, '/teacher/dashboard');
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating game: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 768;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          const Navbar(isAuthenticated: true, userRole: 'teacher'),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Create New Game',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Design an educational game for your students',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Category',
                                                  style: TextStyle(
                                                    color: colorScheme.onSurface,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                DropdownButtonFormField<String>(
                                                  value: _selectedCategory,
                                                  decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    contentPadding: const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12,
                                                    ),
                                                  ),
                                                  items: [
                                                    'Mathematics',
                                                    'Science',
                                                    'Language Arts',
                                                    'Social Studies',
                                                    'Foreign Languages',
                                                    'Programming',
                                                    'Arts',
                                                    'Other',
                                                  ].map((String category) {
                                                    return DropdownMenuItem<String>(
                                                      value: category,
                                                      child: Text(category),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String? newValue) {
                                                    if (newValue != null) {
                                                      setState(() {
                                                        _selectedCategory = newValue;
                                                      });
                                                    }
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
                                                        index < _selectedDifficulty
                                                            ? Icons.star
                                                            : Icons.star_border,
                                                        color: index < _selectedDifficulty
                                                            ? colorScheme.tertiary
                                                            : colorScheme.outline,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          _selectedDifficulty = index + 1;
                                                        });
                                                      },
                                                    );
                                                  }),
                                                ),
                                              ],
                                            ),
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
                                                  'Estimated Time (minutes)',
                                                  style: TextStyle(
                                                    color: colorScheme.onSurface,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Slider(
                                                  value: _estimatedTime.toDouble(),
                                                  min: 5,
                                                  max: 30,
                                                  divisions: 5,
                                                  label: _estimatedTime.toString(),
                                                  onChanged: (double value) {
                                                    setState(() {
                                                      _estimatedTime = value.toInt();
                                                    });
                                                  },
                                                ),
                                                Center(
                                                  child: Text(
                                                    '$_estimatedTime minutes',
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
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                // Questions Section
                                AppCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Questions',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          AppButton(
                                            text: 'Add Question',
                                            variant: ButtonVariant.outline,
                                            size: ButtonSize.small,
                                            leadingIcon: Icons.add,
                                            onPressed: _addNewQuestion,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      
                                      // Questions List
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: _questions.length,
                                        itemBuilder: (context, index) {
                                          return _buildQuestionCard(context, index);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppButton(
                                        text: 'Cancel',
                                        variant: ButtonVariant.outline,
                                        isFullWidth: true,
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: AppButton(
                                        text: 'Save Game',
                                        variant: ButtonVariant.primary,
                                        isFullWidth: true,
                                        isLoading: _isSaving,
                                        onPressed: _saveGame,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuestionCard(BuildContext context, int questionIndex) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final question = _questions[questionIndex];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${questionIndex + 1}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: colorScheme.error,
                ),
                onPressed: () => _removeQuestion(questionIndex),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Question text
          TextFormField(
            initialValue: question['text'],
            decoration: InputDecoration(
              hintText: 'Enter your question',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) => _updateQuestionText(questionIndex, value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a question';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Text(
                'Points:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<int>(
                value: question['points'],
                items: [5, 10, 15, 20, 25].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value pts'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    _updatePoints(questionIndex, newValue);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Text(
            'Options (select the correct answer)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          // Options
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: question['options'].length,
            itemBuilder: (context, optionIndex) {
              final option = question['options'][optionIndex];
              final isCorrect = option['isCorrect'] == true;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Radio(
                      value: true,
                      groupValue: isCorrect,
                      onChanged: (value) {
                        _setCorrectOption(questionIndex, optionIndex);
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: option['text'],
                        decoration: InputDecoration(
                          hintText: 'Option ${['A', 'B', 'C', 'D'][optionIndex]}',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: isCorrect,
                          fillColor: isCorrect ? colorScheme.secondary.withOpacity(0.1) : null,
                        ),
                        onChanged: (value) => _updateOptionText(questionIndex, optionIndex, value),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 