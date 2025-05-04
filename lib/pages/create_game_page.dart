import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';
import 'package:learn_play_level_up_flutter/components/ui/input.dart';
import 'package:learn_play_level_up_flutter/models/firebase_models.dart';
import 'package:learn_play_level_up_flutter/services/firebase_service.dart';
import 'package:learn_play_level_up_flutter/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';

class CreateGamePage extends StatefulWidget {
  const CreateGamePage({super.key});

  @override
  State<CreateGamePage> createState() => _CreateGamePageState();
}

class _CreateGamePageState extends State<CreateGamePage> {
  final _formKey = GlobalKey<FormState>();
  final uuid = const Uuid();
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Form state
  String _selectedCategory = 'Mathematics';
  int _selectedDifficulty = 3;
  int _estimatedTime = 10;
  final List<Map<String, dynamic>> _questions = [];
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  String? _selectedSubjectId;
  List<Subject> _teacherSubjects = [];
  
  // Loading state
  bool _isLoading = true;
  bool _isSaving = false;
  
  // Added state variables for template selection
  bool _showTemplateSelection = true;
  String? _selectedTemplate;
  
  // Game templates
  final List<Map<String, dynamic>> _gameTemplates = [
    {
      'id': 'math_quiz',
      'name': 'Math Quiz',
      'description': 'A quiz focused on basic math operations',
      'icon': Icons.calculate,
      'color': Colors.blue,
      'category': 'Mathematics',
      'sampleQuestions': [
        {
          'text': 'What is 7 × 8?',
          'options': [
            {'text': '54', 'isCorrect': false},
            {'text': '56', 'isCorrect': true},
            {'text': '58', 'isCorrect': false},
            {'text': '63', 'isCorrect': false},
          ],
          'points': 10,
        },
        {
          'text': 'What is 25 + 18?',
          'options': [
            {'text': '33', 'isCorrect': false},
            {'text': '43', 'isCorrect': true},
            {'text': '45', 'isCorrect': false},
            {'text': '53', 'isCorrect': false},
          ],
          'points': 10,
        },
      ],
    },
    {
      'id': 'vocab_quiz',
      'name': 'Vocabulary Quiz',
      'description': 'Test knowledge of word meanings and definitions',
      'icon': Icons.menu_book,
      'color': Colors.green,
      'category': 'Language Arts',
      'sampleQuestions': [
        {
          'text': 'What does "benevolent" mean?',
          'options': [
            {'text': 'Harmful', 'isCorrect': false},
            {'text': 'Well-intentioned', 'isCorrect': true},
            {'text': 'Cautious', 'isCorrect': false},
            {'text': 'Hasty', 'isCorrect': false},
          ],
          'points': 15,
        },
        {
          'text': 'Which word is a synonym for "diligent"?',
          'options': [
            {'text': 'Lazy', 'isCorrect': false},
            {'text': 'Careless', 'isCorrect': false},
            {'text': 'Hardworking', 'isCorrect': true},
            {'text': 'Foolish', 'isCorrect': false},
          ],
          'points': 15,
        },
      ],
    },
    {
      'id': 'science_quiz',
      'name': 'Science Facts',
      'description': 'Test knowledge of scientific facts and concepts',
      'icon': Icons.science,
      'color': Colors.purple,
      'category': 'Science',
      'sampleQuestions': [
        {
          'text': 'What is the closest planet to the Sun?',
          'options': [
            {'text': 'Venus', 'isCorrect': false},
            {'text': 'Earth', 'isCorrect': false},
            {'text': 'Mercury', 'isCorrect': true},
            {'text': 'Mars', 'isCorrect': false},
          ],
          'points': 10,
        },
        {
          'text': 'What is the chemical symbol for water?',
          'options': [
            {'text': 'WA', 'isCorrect': false},
            {'text': 'H2O', 'isCorrect': true},
            {'text': 'W', 'isCorrect': false},
            {'text': 'HO', 'isCorrect': false},
          ],
          'points': 10,
        },
      ],
    },
    {
      'id': 'custom',
      'name': 'Custom Template',
      'description': 'Start from scratch and create your own game',
      'icon': Icons.create,
      'color': Colors.orange,
      'category': 'Other',
      'sampleQuestions': [],
    },
  ];
  
  @override
  void initState() {
    super.initState();
    // Template selection screen will be shown first
    _loadTeacherSubjects();
  }
  
  Future<void> _loadTeacherSubjects() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      
      // Get current user
      final currentUser = authService.currentUser;
      if (currentUser == null || currentUser.role != 'teacher') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must be logged in as a teacher to create games')),
          );
          GoRouter.of(context).go('/signin');
        }
        return;
      }
      
      // Load teacher's subjects
      _teacherSubjects = await firebaseService.getTeacherSubjects(currentUser.id);
      
      // If there are subjects, select the first one by default
      if (_teacherSubjects.isNotEmpty) {
        _selectedSubjectId = _teacherSubjects.first.id;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading subjects: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  void _selectTemplate(String templateId) {
    final template = _gameTemplates.firstWhere((t) => t['id'] == templateId);
    
    setState(() {
      _selectedTemplate = templateId;
      _showTemplateSelection = false;
      _selectedCategory = template['category'] as String;
      
      // Pre-fill title with template name if it's not a custom template
      if (templateId != 'custom') {
        _titleController.text = '${template['name']} Game';
      }
      
      // Add sample questions if available
      _questions.clear();
      if ((template['sampleQuestions'] as List).isNotEmpty) {
        for (var question in template['sampleQuestions']) {
          _questions.add({
            'text': question['text'],
            'points': question['points'],
            'options': List<Map<String, dynamic>>.from(question['options']),
          });
        }
      } else {
        // Add an empty question
        _addNewQuestion();
      }
    });
  }
  
  void _backToTemplates() {
    setState(() {
      _showTemplateSelection = true;
      _selectedTemplate = null;
      _questions.clear();
      _titleController.clear();
      _descriptionController.clear();
    });
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
  
  void _addOption(int questionIndex) {
    if (_questions[questionIndex]['options'].length < 6) {
      setState(() {
        _questions[questionIndex]['options'].add({
          'text': '',
          'isCorrect': false,
        });
      });
    }
  }
  
  void _removeOption(int questionIndex, int optionIndex) {
    if (_questions[questionIndex]['options'].length > 2) {
      // Check if this is the correct option
      bool isCorrect = _questions[questionIndex]['options'][optionIndex]['isCorrect'];
      
      setState(() {
        _questions[questionIndex]['options'].removeAt(optionIndex);
        
        // If we removed the correct option, make the first option correct
        if (isCorrect) {
          _questions[questionIndex]['options'][0]['isCorrect'] = true;
        }
      });
    }
  }
  
  void _duplicateQuestion(int index) {
    setState(() {
      final questionCopy = Map<String, dynamic>.from(_questions[index]);
      // Deep copy options
      questionCopy['options'] = List<Map<String, dynamic>>.from(
        _questions[index]['options'].map((option) => Map<String, dynamic>.from(option))
      );
      _questions.insert(index + 1, questionCopy);
    });
  }
  
  Future<void> _saveGame() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Validate subject selection
    if (_selectedSubjectId == null || _selectedSubjectId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subject')),
      );
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
      final authService = Provider.of<AuthService>(context, listen: false);
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      
      // Get current user
      final currentUser = authService.currentUser;
      if (currentUser == null || currentUser.role != 'teacher') {
        throw Exception('You must be logged in as a teacher to create games');
      }
      
      // Find selected subject to get grade year
      final selectedSubject = _teacherSubjects.firstWhere(
        (s) => s.id == _selectedSubjectId,
        orElse: () => throw Exception('Subject not found')
      );
      
      // Calculate max points
      int maxPoints = 0;
      for (final question in _questions) {
        maxPoints += question['points'] as int;
      }
      
      // Convert questions to GameQuestion objects
      final gameQuestions = _questions.map((q) {
        final options = (q['options'] as List).map((o) {
          return GameOption(
            id: uuid.v4(),
            text: o['text'],
            isCorrect: o['isCorrect'],
            explanation: null,
          );
        }).toList();
        
        return GameQuestion(
          id: uuid.v4(),
          text: q['text'],
          options: options,
          points: q['points'],
          imageUrl: null,
          timeLimit: 30, // Default time limit
        );
      }).toList();
      
      // Create the EducationalGame object
      final game = EducationalGame(
        id: '', // Will be set by Firestore
        title: _titleController.text,
        description: _descriptionController.text,
        coverImage: null,
        teacherId: currentUser.id,
        subjectId: _selectedSubjectId!,
        gradeYear: selectedSubject.gradeYear,
        createdAt: DateTime.now(),
        dueDate: _dueDate,
        isActive: true,
        questions: gameQuestions,
        difficulty: _selectedDifficulty,
        estimatedDuration: _estimatedTime,
        tags: [_selectedCategory],
        maxPoints: maxPoints,
      );
      
      // Save the game to Firebase
      final gameId = await firebaseService.createGame(game);
      
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game created successfully!')),
      );
      
      // Navigate back to teacher dashboard
      GoRouter.of(context).go('/teacher/dashboard');
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
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          const Navbar(isAuthenticated: true, userRole: 'teacher', isInternal: true),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _showTemplateSelection
                    ? _buildTemplateSelection(context, isSmallScreen)
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
                                    onPressed: _backToTemplates,
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
                                      child: _buildGameInfoCard(context, colorScheme),
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
                                              Row(
                                                children: [
                                                  AppButton(
                                                    text: 'Import Questions',
                                                    variant: ButtonVariant.outline,
                                                    size: ButtonSize.small,
                                                    leadingIcon: Icons.upload_file,
                                                    onPressed: () {
                                                      // TODO: Implement import functionality
                                                    },
                                                  ),
                                                  const SizedBox(width: 8),
                                                  AppButton(
                                                    text: 'Add Question',
                                                    variant: ButtonVariant.primary,
                                                    size: ButtonSize.small,
                                                    leadingIcon: Icons.add,
                                                    onPressed: _addNewQuestion,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          
                                          // Questions List
                                          ReorderableListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: _questions.length,
                                            onReorder: (oldIndex, newIndex) {
                                              setState(() {
                                                if (oldIndex < newIndex) {
                                                  newIndex -= 1;
                                                }
                                                final item = _questions.removeAt(oldIndex);
                                                _questions.insert(newIndex, item);
                                              });
                                            },
                                            itemBuilder: (context, index) {
                                              return _buildQuestionCard(context, index, key: ValueKey('question_$index'));
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
                                              GoRouter.of(context).go('/teacher/dashboard');
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
  
  Widget _buildTemplateSelection(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SingleChildScrollView(
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
                    GoRouter.of(context).go('/teacher/dashboard');
                  },
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose a Template',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select a template to start creating your game',
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Template Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isSmallScreen ? 1 : 2,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: isSmallScreen ? 1.2 : 1.5,
              ),
              itemCount: _gameTemplates.length,
              itemBuilder: (context, index) {
                final template = _gameTemplates[index];
                final templateId = template['id'] as String;
                final templateName = template['name'] as String;
                final templateDesc = template['description'] as String;
                final templateIcon = template['icon'] as IconData;
                final templateColor = template['color'] as Color;
                
                return AppCard(
                  isHoverable: true,
                  backgroundColor: colorScheme.surface,
                  onTap: () => _selectTemplate(templateId),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: templateColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              templateIcon,
                              color: templateColor,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                templateName,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Template',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        templateDesc,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      if (templateId != 'custom') ...[
                        Text(
                          'Preview:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: templateColor.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    'Q',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: templateColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sample Question',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      template['sampleQuestions'].isNotEmpty 
                                        ? template['sampleQuestions'][0]['text'] 
                                        : 'No sample questions',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: colorScheme.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      AppButton(
                        text: 'Use This Template',
                        variant: ButtonVariant.primary,
                        isFullWidth: true,
                        onPressed: () => _selectTemplate(templateId),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuestionCard(BuildContext context, int questionIndex, {required Key key}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final question = _questions[questionIndex];
    
    return Container(
      key: key,
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
              Row(
                children: [
                  Icon(
                    Icons.drag_indicator,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Question ${questionIndex + 1}',
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
                  IconButton(
                    icon: Icon(
                      Icons.copy,
                      color: colorScheme.primary,
                    ),
                    tooltip: 'Duplicate',
                    onPressed: () => _duplicateQuestion(questionIndex),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: colorScheme.error,
                    ),
                    tooltip: 'Delete',
                    onPressed: () => _removeQuestion(questionIndex),
                  ),
                ],
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
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Options (select the correct answer)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              TextButton.icon(
                icon: Icon(
                  Icons.add_circle_outline,
                  size: 16,
                  color: colorScheme.primary,
                ),
                label: Text(
                  'Add Option',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
                onPressed: () => _addOption(questionIndex),
              ),
            ],
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
              final optionLetter = String.fromCharCode(65 + optionIndex); // A, B, C, etc.
              
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
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCorrect 
                          ? colorScheme.primary.withOpacity(0.1) 
                          : colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCorrect 
                            ? colorScheme.primary
                            : colorScheme.outline.withOpacity(0.5),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          optionLetter,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCorrect ? colorScheme.primary : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: option['text'],
                        decoration: InputDecoration(
                          hintText: 'Option $optionLetter',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: isCorrect,
                          fillColor: isCorrect ? colorScheme.primary.withOpacity(0.05) : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        onChanged: (value) => _updateOptionText(questionIndex, optionIndex, value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (question['options'].length > 2)
                      IconButton(
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: colorScheme.error,
                          size: 20,
                        ),
                        tooltip: 'Remove Option',
                        onPressed: () => _removeOption(questionIndex, optionIndex),
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
  
  Widget _buildGameInfoCard(BuildContext context, ColorScheme colorScheme) {
    return Column(
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
        
        // Subject Selection
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subject',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedSubjectId,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: _teacherSubjects.map((subject) {
                return DropdownMenuItem<String>(
                  value: subject.id,
                  child: Text('${subject.name} (Grade ${subject.gradeYear})'),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedSubjectId = newValue;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a subject';
                }
                return null;
              },
            ),
          ],
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
        
        // Due Date Selection
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Due Date',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                
                if (pickedDate != null) {
                  setState(() {
                    _dueDate = pickedDate;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDate(_dueDate)),
                    Icon(Icons.calendar_today, color: colorScheme.primary),
                  ],
                ),
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
    );
  }
  
  // Helper method to format dates for display
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
} 