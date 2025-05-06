import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';

class GameCreatePage extends StatefulWidget {
  const GameCreatePage({super.key});

  @override
  State<GameCreatePage> createState() => _GameCreatePageState();
}

class _GameCreatePageState extends State<GameCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  GameTemplate _selectedTemplate = GameTemplate.trueFalse;
  String _selectedSubject = 'Math';
  final List<int> _selectedGradeYears = [1];
  bool _isTutorial = false;
  bool _isLoading = false;
  
  // List of questions
  final List<Map<String, dynamic>> _questions = [];
  
  // Controllers for new question
  final _promptController = TextEditingController();
  final _answerController = TextEditingController();
  final _secondaryController = TextEditingController(); // For right/back/target/hint
  
  // For crossword
  List<List<String>> _crosswordGrid = List.generate(
    10, (_) => List.generate(10, (_) => ''));
  final List<String> _cluesAcross = [];
  final List<String> _cluesDown = [];
  
  // Subject options
  final List<String> _subjects = [
    'Math', 'Science', 'English', 'History', 'Geography', 
    'Art', 'Music', 'Physical Education', 'Computer Science'
  ];
  
  // Grade year options
  final List<int> _gradeYears = List.generate(12, (index) => index + 1);
  
  @override
  void dispose() {
    _titleController.dispose();
    _promptController.dispose();
    _answerController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }
  
  // Helper to get question field labels based on template
  Map<String, String> get _fieldLabels {
    switch (_selectedTemplate) {
      case GameTemplate.trueFalse:
        return {
          'prompt': 'Question Text',
          'answer': 'Correct Answer (true/false)',
        };
      case GameTemplate.dragDrop:
        return {
          'prompt': 'Draggable Item',
          'answer': 'Target Location',
        };
      case GameTemplate.matching:
        return {
          'prompt': 'Left Item',
          'answer': 'Right Item',
        };
      case GameTemplate.memory:
        return {
          'prompt': 'Card Front',
          'answer': 'Card Back',
        };
      case GameTemplate.flashCard:
        return {
          'prompt': 'Card Front',
          'answer': 'Card Back',
        };
      case GameTemplate.fillBlank:
        return {
          'prompt': 'Sentence (use ___ for blank)',
          'answer': 'Answer',
        };
      case GameTemplate.hangman:
        return {
          'prompt': 'Word',
          'answer': 'Hint',
        };
      case GameTemplate.crossword:
        return {
          'prompt': 'Clue',
          'answer': 'Answer',
        };
    }
  }
  
  // Add a question based on the template
  void _addQuestion() {
    if (_promptController.text.isEmpty || _answerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }
    
    final questionId = const Uuid().v4();
    
    switch (_selectedTemplate) {
      case GameTemplate.trueFalse:
        final isTrue = _answerController.text.toLowerCase() == 'true';
        _questions.add({
          'id': questionId,
          'type': 'trueFalse',
          'text': _promptController.text,
          'correctAnswer': isTrue,
        });
        break;
      
      case GameTemplate.dragDrop:
        _questions.add({
          'id': questionId,
          'type': 'dragDrop',
          'items': [_promptController.text],
          'targets': [_answerController.text],
          'correctMapping': [0],
        });
        break;
      
      case GameTemplate.matching:
        _questions.add({
          'id': questionId,
          'type': 'matching',
          'leftItems': [_promptController.text],
          'rightItems': [_answerController.text],
          'correctMatches': [0],
        });
        break;
      
      case GameTemplate.memory:
        _questions.add({
          'id': questionId,
          'type': 'memory',
          'front': _promptController.text,
          'back': _answerController.text,
        });
        break;

      case GameTemplate.flashCard:
        _questions.add({
          'id': questionId,
          'type': 'flashCard',
          'front': _promptController.text,
          'back': _answerController.text,
        });
        break;
      
      case GameTemplate.fillBlank:
        _questions.add({
          'id': questionId,
          'type': 'fillBlank',
          'textWithBlanks': _promptController.text,
          'blanks': [_answerController.text],
        });
        break;
      
      case GameTemplate.hangman:
        _questions.add({
          'id': questionId,
          'type': 'hangman',
          'word': _promptController.text,
          'hint': _answerController.text,
        });
        break;
      
      case GameTemplate.crossword:
        if (_cluesAcross.isEmpty && _cluesDown.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please add some clues first')),
          );
          return;
        }
        // We handle crossword differently as it's a single complex question
        break;
    }
    
    setState(() {
      _promptController.clear();
      _answerController.clear();
      _secondaryController.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Question added')),
    );
  }
  
  // Save the game to Firestore
  Future<void> _saveGame() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    if (_questions.isEmpty && _selectedTemplate != GameTemplate.crossword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one question')),
      );
      return;
    }
    
    if (_selectedTemplate == GameTemplate.crossword && 
        _cluesAcross.isEmpty && _cluesDown.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add clues for your crossword')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to create a game')),
        );
        setState(() => _isLoading = false);
        return;
      }
      
      // Convert questions to GameQuestion objects
      final gameQuestions = <GameQuestion>[];
      
      for (final q in _questions) {
        Question question;
        
        switch (q['type']) {
          case 'trueFalse':
            question = Question.trueFalse(
              text: q['text'],
              correctAnswer: q['correctAnswer'],
            );
            break;
          
          case 'dragDrop':
            question = Question.dragDrop(
              items: List<String>.from(q['items']),
              targets: List<String>.from(q['targets']),
              correctMapping: List<int>.from(q['correctMapping'] as List<dynamic>),
            );
            break;
          
          case 'matching':
            question = Question.matching(
              leftItems: List<String>.from(q['leftItems']),
              rightItems: List<String>.from(q['rightItems']),
              correctMatches: List<int>.from(q['correctMatches']),
            );
            break;
          
          case 'memory':
            question = Question.flashCard(
              front: q['front'],
              back: q['back'],
            );
            break;
          
          case 'flashCard':
            question = Question.flashCard(
              front: q['front'],
              back: q['back'],
            );
            break;
          
          case 'fillBlank':
            question = Question.fillBlank(
              textWithBlanks: q['textWithBlanks'],
              blanks: List<String>.from(q['blanks']),
            );
            break;
          
          case 'hangman':
            // Since we don't have a hangman question type directly in our model,
            // we'll use fillBlank as a substitute
            question = Question.fillBlank(
              textWithBlanks: '${q['hint']} (____)',
              blanks: [q['word']],
            );
            break;
          
          default:
            continue;
        }
        
        gameQuestions.add(GameQuestion(
          id: q['id'],
          question: question,
          points: 10,
        ));
      }
      
      // For crossword, add as a single question if there are clues
      if (_selectedTemplate == GameTemplate.crossword && 
          (_cluesAcross.isNotEmpty || _cluesDown.isNotEmpty)) {
        // Create a crossword question with proper parameters
        final crosswordQuestion = Question.crossword(
          grid: List.generate(
            10, // Default size 10x10
            (_) => List.generate(10, (_) => null)
          ),
          acrossClues: Map.fromEntries(
            _cluesAcross.asMap().entries.map((e) => MapEntry(e.key + 1, e.value))
          ),
          downClues: Map.fromEntries(
            _cluesDown.asMap().entries.map((e) => MapEntry(e.key + 1, e.value))
          ),
        );
        
        gameQuestions.add(GameQuestion(
          id: const Uuid().v4(),
          question: crosswordQuestion,
          points: 50, // Crosswords are worth more
        ));
      }
      
      // Create Game object
      final gameId = const Uuid().v4();
      final game = Game(
        id: gameId,
        ownerUid: user.uid,
        template: _selectedTemplate,
        title: _titleController.text,
        gradeYears: _selectedGradeYears,
        subject: _selectedSubject,
        questions: gameQuestions,
        isTutorial: _isTutorial,
        createdAt: DateTime.now(),
      );
      
      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('games')
          .doc(gameId)
          .set(game.toJson());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Game created successfully')),
        );
        
        context.go('/dashboard');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating game: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  // UI for the question builder
  Widget _buildQuestionInput() {
    if (_selectedTemplate == GameTemplate.crossword) {
      return _buildCrosswordInput();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        const Text('Add Questions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        
        // Show existing questions
        if (_questions.isNotEmpty) ...[
          Text('${_questions.length} Questions Added', 
            style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ListView.builder(
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final q = _questions[index];
                String summary;
                
                switch (_selectedTemplate) {
                  case GameTemplate.trueFalse:
                    summary = '${q['text']} (${q['correctAnswer'] ? 'True' : 'False'})';
                    break;
                  case GameTemplate.dragDrop:
                    summary = 'Drag "${q['items'][0]}" to "${q['targets'][0]}"';
                    break;
                  case GameTemplate.matching:
                    summary = 'Match "${q['leftItems'][0]}" with "${q['rightItems'][0]}"';
                    break;
                  case GameTemplate.memory:
                  case GameTemplate.flashCard:
                    summary = 'Front: ${q['front']}, Back: ${q['back']}';
                    break;
                  case GameTemplate.fillBlank:
                    summary = '${q['textWithBlanks']} (Answer: ${q['blanks'][0]})';
                    break;
                  case GameTemplate.hangman:
                    summary = 'Word: ${q['word']}, Hint: ${q['hint']}';
                    break;
                  default:
                    summary = 'Question ${index + 1}';
                }
                
                return ListTile(
                  title: Text(summary, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _questions.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // New question input
        TextFormField(
          controller: _promptController,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: _fieldLabels['prompt'],
            filled: true,
            fillColor: Colors.white,
            labelStyle: const TextStyle(color: Colors.black),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _answerController,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: _fieldLabels['answer'],
            filled: true,
            fillColor: Colors.white,
            labelStyle: const TextStyle(color: Colors.black),
            border: const OutlineInputBorder(),
          ),
        ),
        
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _addQuestion,
          icon: const Icon(Icons.add),
          label: const Text('Add Question'),
        ),
      ],
    );
  }
  
  // UI for crossword input
  Widget _buildCrosswordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        const Text('Crossword Builder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        
        // Clues
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Across Clues', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListView.builder(
                      itemCount: _cluesAcross.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_cluesAcross[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _cluesAcross.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Down Clues', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListView.builder(
                      itemCount: _cluesDown.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_cluesDown[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _cluesDown.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Add clue
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _promptController,
                decoration: const InputDecoration(
                  labelText: 'Clue',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _answerController,
                decoration: const InputDecoration(
                  labelText: 'Answer',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                if (_promptController.text.isNotEmpty && _answerController.text.isNotEmpty) {
                  setState(() {
                    _cluesAcross.add('${_promptController.text} (${_answerController.text})');
                    _promptController.clear();
                    _answerController.clear();
                  });
                }
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Add Across Clue'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {
                if (_promptController.text.isNotEmpty && _answerController.text.isNotEmpty) {
                  setState(() {
                    _cluesDown.add('${_promptController.text} (${_answerController.text})');
                    _promptController.clear();
                    _answerController.clear();
                  });
                }
              },
              icon: const Icon(Icons.arrow_downward),
              label: const Text('Add Down Clue'),
            ),
          ],
        ),
        
        // Future: Add grid editor
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Game'),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                      labelText: 'Game Title',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title for your game';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  const Text('Game Type', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<GameTemplate>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedTemplate,
                    items: GameTemplate.values.map((template) {
                      String displayName = '';
                      switch (template) {
                        case GameTemplate.trueFalse:
                          displayName = 'True/False';
                          break;
                        case GameTemplate.dragDrop:
                          displayName = 'Drag & Drop';
                          break;
                        case GameTemplate.matching:
                          displayName = 'Matching';
                          break;
                        case GameTemplate.memory:
                          displayName = 'Memory';
                          break;
                        case GameTemplate.flashCard:
                          displayName = 'Flash Cards';
                          break;
                        case GameTemplate.fillBlank:
                          displayName = 'Fill in the Blanks';
                          break;
                        case GameTemplate.hangman:
                          displayName = 'Hangman';
                          break;
                        case GameTemplate.crossword:
                          displayName = 'Crossword';
                          break;
                      }
                      return DropdownMenuItem<GameTemplate>(
                        value: template,
                        child: Text(displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        // Confirm if changing will clear questions
                        if (_questions.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Change Game Type?'),
                              content: const Text(
                                'Changing the game type will clear all your current questions. Continue?'
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      _selectedTemplate = value;
                                      _questions.clear();
                                      _cluesAcross.clear();
                                      _cluesDown.clear();
                                    });
                                  },
                                  child: const Text('Continue'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          setState(() {
                            _selectedTemplate = value;
                          });
                        }
                      }
                    },
                  ),
                  
                  // Question builder based on template
                  _buildQuestionInput(),
                  
                  const SizedBox(height: 24),
                  
                  const Text('Subject', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedSubject,
                    items: _subjects.map((subject) {
                      return DropdownMenuItem<String>(
                        value: subject,
                        child: Text(subject),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedSubject = value;
                        });
                      }
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Text('Grade Years', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _gradeYears.map((grade) {
                      final isSelected = _selectedGradeYears.contains(grade);
                      return FilterChip(
                        label: Text('Grade $grade'),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedGradeYears.add(grade);
                            } else {
                              if (_selectedGradeYears.length > 1) {
                                _selectedGradeYears.remove(grade);
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Checkbox(
                        value: _isTutorial,
                        onChanged: (value) {
                          setState(() {
                            _isTutorial = value ?? false;
                          });
                        },
                      ),
                      const Text('Mark as Tutorial Game'),
                      const Tooltip(
                        message: 'Tutorial games are shown at the top for students',
                        child: Icon(Icons.info_outline, size: 16),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    onPressed: _saveGame,
                    child: const Text('Publish Game'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextButton(
                    onPressed: () => context.go('/dashboard'),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
} 