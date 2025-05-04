import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/pages/game_templates/template_creation_base_page.dart';
import 'package:learn_play_level_up_flutter/services/firebase_service.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:learn_play_level_up_flutter/models/firebase_models.dart';

class GeneralQuizCreationPage extends StatefulWidget {
  const GeneralQuizCreationPage({super.key});

  @override
  State<GeneralQuizCreationPage> createState() => _GeneralQuizCreationPageState();
}

class _GeneralQuizCreationPageState extends State<GeneralQuizCreationPage> {
  // Section management
  final List<QuizSection> _sections = [];
  final TextEditingController _sectionTitleController = TextEditingController();
  final TextEditingController _sectionDescriptionController = TextEditingController();
  
  // Question management
  final TextEditingController _questionTextController = TextEditingController();
  final List<String> _options = [];
  final TextEditingController _optionController = TextEditingController();
  final List<String> _correctAnswers = [];
  final TextEditingController _explanationController = TextEditingController();
  final List<String> _questionTags = [];
  final TextEditingController _questionTagController = TextEditingController();
  String _selectedQuestionType = 'multiple_choice';
  int _questionPoints = 1;
  int? _questionDifficulty;
  String? _questionImageUrl;
  
  // Quiz settings
  bool _hasTimeLimit = false;
  int _timeLimitMinutes = 30;
  String _navigationMode = 'sequential';
  String _displayMode = 'one_per_page';
  bool _randomizeQuestions = false;
  bool _randomizeAnswers = false;
  int _passThreshold = 70;
  bool _allowReview = true;
  bool _showExplanations = true;
  bool _autoSubmit = false;
  bool _allowFlagging = true;
  
  @override
  void dispose() {
    _sectionTitleController.dispose();
    _sectionDescriptionController.dispose();
    _questionTextController.dispose();
    _optionController.dispose();
    _explanationController.dispose();
    _questionTagController.dispose();
    super.dispose();
  }
  
  void _addSection() {
    if (_sectionTitleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a section title')),
      );
      return;
    }
    
    setState(() {
      _sections.add(QuizSection(
        id: const Uuid().v4(),
        title: _sectionTitleController.text,
        description: _sectionDescriptionController.text.isNotEmpty ? _sectionDescriptionController.text : null,
        questions: [],
        position: _sections.length,
      ));
      
      // Clear form
      _sectionTitleController.clear();
      _sectionDescriptionController.clear();
    });
  }
  
  void _removeSection(int index) {
    setState(() {
      _sections.removeAt(index);
      // Update positions
      for (int i = index; i < _sections.length; i++) {
        _sections[i] = QuizSection(
          id: _sections[i].id,
          title: _sections[i].title,
          description: _sections[i].description,
          questions: _sections[i].questions,
          position: i,
        );
      }
    });
  }
  
  void _moveSection(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final section = _sections.removeAt(oldIndex);
    setState(() {
      _sections.insert(newIndex, QuizSection(
        id: section.id,
        title: section.title,
        description: section.description,
        questions: section.questions,
        position: newIndex,
      ));
      
      // Update positions
      for (int i = 0; i < _sections.length; i++) {
        if (i != newIndex) {
          _sections[i] = QuizSection(
            id: _sections[i].id,
            title: _sections[i].title,
            description: _sections[i].description,
            questions: _sections[i].questions,
            position: i,
          );
        }
      }
    });
  }
  
  void _addQuestion(int sectionIndex) {
    if (_questionTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a question')),
      );
      return;
    }
    
    if (_selectedQuestionType == 'multiple_choice' && _options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 2 options')),
      );
      return;
    }
    
    if (_selectedQuestionType == 'multiple_choice' && _correctAnswers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one correct answer')),
      );
      return;
    }
    
    setState(() {
      final section = _sections[sectionIndex];
      final questions = List<QuizQuestion>.from(section.questions);
      
      questions.add(QuizQuestion(
        id: const Uuid().v4(),
        type: _selectedQuestionType,
        questionText: _questionTextController.text,
        imageUrl: _questionImageUrl,
        options: _selectedQuestionType == 'multiple_choice' || _selectedQuestionType == 'multiple_select' ? List.from(_options) : null,
        correctAnswers: List.from(_correctAnswers),
        points: _questionPoints,
        difficulty: _questionDifficulty,
        explanation: _explanationController.text.isNotEmpty ? _explanationController.text : null,
        tags: List.from(_questionTags),
        position: questions.length,
      ));
      
      _sections[sectionIndex] = QuizSection(
        id: section.id,
        title: section.title,
        description: section.description,
        questions: questions,
        position: section.position,
      );
      
      // Clear form
      _questionTextController.clear();
      _options.clear();
      _correctAnswers.clear();
      _explanationController.clear();
      _questionTags.clear();
      _questionImageUrl = null;
      _questionPoints = 1;
      _questionDifficulty = null;
    });
  }
  
  void _removeQuestion(int sectionIndex, int questionIndex) {
    setState(() {
      final section = _sections[sectionIndex];
      final questions = List<QuizQuestion>.from(section.questions);
      questions.removeAt(questionIndex);
      
      // Update positions
      for (int i = questionIndex; i < questions.length; i++) {
        questions[i] = QuizQuestion(
          id: questions[i].id,
          type: questions[i].type,
          questionText: questions[i].questionText,
          imageUrl: questions[i].imageUrl,
          options: questions[i].options,
          correctAnswers: questions[i].correctAnswers,
          points: questions[i].points,
          difficulty: questions[i].difficulty,
          explanation: questions[i].explanation,
          tags: questions[i].tags,
          position: i,
        );
      }
      
      _sections[sectionIndex] = QuizSection(
        id: section.id,
        title: section.title,
        description: section.description,
        questions: questions,
        position: section.position,
      );
    });
  }
  
  void _moveQuestion(int sectionIndex, int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    setState(() {
      final section = _sections[sectionIndex];
      final questions = List<QuizQuestion>.from(section.questions);
      final question = questions.removeAt(oldIndex);
      
      questions.insert(newIndex, QuizQuestion(
        id: question.id,
        type: question.type,
        questionText: question.questionText,
        imageUrl: question.imageUrl,
        options: question.options,
        correctAnswers: question.correctAnswers,
        points: question.points,
        difficulty: question.difficulty,
        explanation: question.explanation,
        tags: question.tags,
        position: newIndex,
      ));
      
      // Update positions
      for (int i = 0; i < questions.length; i++) {
        if (i != newIndex) {
          questions[i] = QuizQuestion(
            id: questions[i].id,
            type: questions[i].type,
            questionText: questions[i].questionText,
            imageUrl: questions[i].imageUrl,
            options: questions[i].options,
            correctAnswers: questions[i].correctAnswers,
            points: questions[i].points,
            difficulty: questions[i].difficulty,
            explanation: questions[i].explanation,
            tags: questions[i].tags,
            position: i,
          );
        }
      }
      
      _sections[sectionIndex] = QuizSection(
        id: section.id,
        title: section.title,
        description: section.description,
        questions: questions,
        position: section.position,
      );
    });
  }
  
  Future<bool> _saveGame(BuildContext context, {
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
    if (_sections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one section')),
      );
      return false;
    }
    
    bool hasQuestions = false;
    for (final section in _sections) {
      if (section.questions.isNotEmpty) {
        hasQuestions = true;
        break;
      }
    }
    
    if (!hasQuestions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one question')),
      );
      return false;
    }
    
    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      
      final game = GeneralQuizGame(
        title: title,
        description: description,
        coverImage: null,
        teacherId: teacherId,
        subjectId: subjectId,
        gradeYear: gradeYear,
        createdAt: DateTime.now(),
        dueDate: dueDate,
        isActive: true,
        estimatedDuration: _hasTimeLimit ? _timeLimitMinutes : 0,
        tags: [],
        maxPoints: maxPoints,
        xpReward: xpReward,
        coinReward: coinReward,
        sections: _sections,
        hasTimeLimit: _hasTimeLimit,
        timeLimitMinutes: _hasTimeLimit ? _timeLimitMinutes : null,
        navigationMode: _navigationMode,
        displayMode: _displayMode,
        randomizeQuestions: _randomizeQuestions,
        randomizeAnswers: _randomizeAnswers,
        passThreshold: _passThreshold,
        allowReview: _allowReview,
        showExplanations: _showExplanations,
        autoSubmit: _autoSubmit,
        allowFlagging: _allowFlagging,
      );
      
      await firebaseService.createGame(
        EducationalGame(
          id: game.id,
          title: game.title,
          description: game.description,
          coverImage: game.coverImage,
          teacherId: game.teacherId,
          subjectId: game.subjectId,
          gradeYear: game.gradeYear,
          createdAt: game.createdAt,
          dueDate: game.dueDate,
          isActive: game.isActive,
          questions: [], // Optionally map quiz questions if needed
          difficulty: 1,
          estimatedDuration: game.estimatedDuration,
          tags: game.tags,
          maxPoints: game.maxPoints,
        )
      );
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving game: $e')),
      );
      return false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return TemplateCreationBasePage(
      type: 'general_quiz',
      title: 'General Quiz',
      icon: Icons.quiz,
      color: Colors.blue,
      contentBuilder: (context) => _buildContent(),
      saveToFirebase: _saveGame,
    );
  }
  
  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quiz settings
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quiz Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Time limit
                SwitchListTile(
                  title: const Text('Enable Time Limit'),
                  value: _hasTimeLimit,
                  onChanged: (value) {
                    setState(() {
                      _hasTimeLimit = value;
                    });
                  },
                ),
                if (_hasTimeLimit)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('$_timeLimitMinutes minutes'),
                        ),
                        Expanded(
                          flex: 2,
                          child: Slider(
                            value: _timeLimitMinutes.toDouble(),
                            min: 5,
                            max: 120,
                            divisions: 23,
                            label: '$_timeLimitMinutes minutes',
                            onChanged: (value) {
                              setState(() {
                                _timeLimitMinutes = value.toInt();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Navigation mode
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Navigation Mode',
                    border: OutlineInputBorder(),
                  ),
                  value: _navigationMode,
                  items: const [
                    DropdownMenuItem(value: 'sequential', child: Text('Sequential Only')),
                    DropdownMenuItem(value: 'free', child: Text('Free Navigation')),
                    DropdownMenuItem(value: 'no_backtracking', child: Text('No Backtracking')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _navigationMode = value!;
                    });
                  },
                ),
                
                // Display mode
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Display Mode',
                    border: OutlineInputBorder(),
                  ),
                  value: _displayMode,
                  items: const [
                    DropdownMenuItem(value: 'one_per_page', child: Text('One Question Per Page')),
                    DropdownMenuItem(value: 'all_on_one', child: Text('All Questions On One Page')),
                    DropdownMenuItem(value: 'sectioned', child: Text('Sectioned Groups')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _displayMode = value!;
                    });
                  },
                ),
                
                // Randomization options
                SwitchListTile(
                  title: const Text('Randomize Question Order'),
                  value: _randomizeQuestions,
                  onChanged: (value) {
                    setState(() {
                      _randomizeQuestions = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Randomize Answer Order'),
                  value: _randomizeAnswers,
                  onChanged: (value) {
                    setState(() {
                      _randomizeAnswers = value;
                    });
                  },
                ),
                
                // Pass threshold
                ListTile(
                  title: const Text('Pass Threshold'),
                  subtitle: Text('$_passThreshold%'),
                  trailing: SizedBox(
                    width: 200,
                    child: Slider(
                      value: _passThreshold.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: '$_passThreshold%',
                      onChanged: (value) {
                        setState(() {
                          _passThreshold = value.toInt();
                        });
                      },
                    ),
                  ),
                ),
                
                // Additional settings
                SwitchListTile(
                  title: const Text('Allow Review After Completion'),
                  value: _allowReview,
                  onChanged: (value) {
                    setState(() {
                      _allowReview = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Show Explanations'),
                  value: _showExplanations,
                  onChanged: (value) {
                    setState(() {
                      _showExplanations = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Auto-Submit On Time Limit'),
                  value: _autoSubmit,
                  onChanged: (value) {
                    setState(() {
                      _autoSubmit = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Allow Question Flagging'),
                  value: _allowFlagging,
                  onChanged: (value) {
                    setState(() {
                      _allowFlagging = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Section creation form
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Section',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Section title
                TextFormField(
                  controller: _sectionTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Section Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Section description
                TextFormField(
                  controller: _sectionDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Section Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                // Add section button
                ElevatedButton(
                  onPressed: _addSection,
                  child: const Text('Add Section'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Sections list
        if (_sections.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sections',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _sections.length,
                itemBuilder: (context, index) {
                  final section = _sections[index];
                  return Card(
                    key: ValueKey(section.id),
                    child: ExpansionTile(
                      title: Text(section.title),
                      subtitle: section.description != null ? Text(section.description!) : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeSection(index),
                      ),
                      children: [
                        // Question creation form
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Add Question',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Question type
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Question Type',
                                  border: OutlineInputBorder(),
                                ),
                                value: _selectedQuestionType,
                                items: const [
                                  DropdownMenuItem(value: 'multiple_choice', child: Text('Multiple Choice')),
                                  DropdownMenuItem(value: 'multiple_select', child: Text('Multiple Select')),
                                  DropdownMenuItem(value: 'true_false', child: Text('True/False')),
                                  DropdownMenuItem(value: 'short_answer', child: Text('Short Answer')),
                                  DropdownMenuItem(value: 'essay', child: Text('Essay')),
                                  DropdownMenuItem(value: 'matching', child: Text('Matching')),
                                  DropdownMenuItem(value: 'numerical', child: Text('Numerical')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedQuestionType = value!;
                                    _options.clear();
                                    _correctAnswers.clear();
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Question text
                              TextFormField(
                                controller: _questionTextController,
                                decoration: const InputDecoration(
                                  labelText: 'Question Text',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 16),
                              
                              // Options (for multiple choice/select)
                              if (_selectedQuestionType == 'multiple_choice' || _selectedQuestionType == 'multiple_select')
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Options',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        ..._options.map((option) => Chip(
                                          label: Text(option),
                                          onDeleted: () {
                                            setState(() {
                                              _options.remove(option);
                                              _correctAnswers.remove(option);
                                            });
                                          },
                                        )),
                                        SizedBox(
                                          width: 200,
                                          child: TextField(
                                            controller: _optionController,
                                            decoration: const InputDecoration(
                                              labelText: 'Add Option',
                                              border: OutlineInputBorder(),
                                            ),
                                            onSubmitted: (value) {
                                              if (value.isNotEmpty && !_options.contains(value)) {
                                                setState(() {
                                                  _options.add(value);
                                                  _optionController.clear();
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Correct answers
                                    const Text(
                                      'Correct Answers',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      children: _options.map((option) => FilterChip(
                                        label: Text(option),
                                        selected: _correctAnswers.contains(option),
                                        onSelected: (selected) {
                                          setState(() {
                                            if (selected) {
                                              _correctAnswers.add(option);
                                            } else {
                                              _correctAnswers.remove(option);
                                            }
                                          });
                                        },
                                      )).toList(),
                                    ),
                                  ],
                                ),
                              
                              // Points
                              ListTile(
                                title: const Text('Points'),
                                subtitle: Text('$_questionPoints'),
                                trailing: SizedBox(
                                  width: 200,
                                  child: Slider(
                                    value: _questionPoints.toDouble(),
                                    min: 1,
                                    max: 10,
                                    divisions: 9,
                                    label: '$_questionPoints',
                                    onChanged: (value) {
                                      setState(() {
                                        _questionPoints = value.toInt();
                                      });
                                    },
                                  ),
                                ),
                              ),
                              
                              // Difficulty
                              ListTile(
                                title: const Text('Difficulty (Optional)'),
                                subtitle: Text(_questionDifficulty != null ? '$_questionDifficulty' : 'Not set'),
                                trailing: SizedBox(
                                  width: 200,
                                  child: Slider(
                                    value: (_questionDifficulty ?? 1).toDouble(),
                                    min: 1,
                                    max: 5,
                                    divisions: 4,
                                    label: _questionDifficulty != null ? '$_questionDifficulty' : '1',
                                    onChanged: (value) {
                                      setState(() {
                                        _questionDifficulty = value.toInt();
                                      });
                                    },
                                  ),
                                ),
                              ),
                              
                              // Explanation
                              TextFormField(
                                controller: _explanationController,
                                decoration: const InputDecoration(
                                  labelText: 'Explanation (Optional)',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 16),
                              
                              // Tags
                              Wrap(
                                spacing: 8,
                                children: [
                                  ..._questionTags.map((tag) => Chip(
                                    label: Text(tag),
                                    onDeleted: () {
                                      setState(() {
                                        _questionTags.remove(tag);
                                      });
                                    },
                                  )),
                                  SizedBox(
                                    width: 200,
                                    child: TextField(
                                      controller: _questionTagController,
                                      decoration: const InputDecoration(
                                        labelText: 'Add Tag',
                                        border: OutlineInputBorder(),
                                      ),
                                      onSubmitted: (value) {
                                        if (value.isNotEmpty && !_questionTags.contains(value)) {
                                          setState(() {
                                            _questionTags.add(value);
                                            _questionTagController.clear();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Add question button
                              ElevatedButton(
                                onPressed: () => _addQuestion(index),
                                child: const Text('Add Question'),
                              ),
                            ],
                          ),
                        ),
                        
                        // Questions list
                        if (section.questions.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'Questions',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ReorderableListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: section.questions.length,
                                itemBuilder: (context, questionIndex) {
                                  final question = section.questions[questionIndex];
                                  return Card(
                                    key: ValueKey(question.id),
                                    child: ListTile(
                                      title: Text(question.questionText),
                                      subtitle: Text('${question.type} • ${question.points} points'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => _removeQuestion(index, questionIndex),
                                      ),
                                    ),
                                  );
                                },
                                onReorder: (oldIndex, newIndex) => _moveQuestion(index, oldIndex, newIndex),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
                onReorder: _moveSection,
              ),
            ],
          ),
      ],
    );
  }
} 