import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_play_level_up_flutter/components/game_creators/word_scramble_creator.dart';
import 'package:learn_play_level_up_flutter/components/game_creators/quiz_show_creator.dart';
import 'package:learn_play_level_up_flutter/components/game_creators/word_guess_creator.dart';
import 'package:learn_play_level_up_flutter/components/game_creators/sorting_game_creator.dart';
import 'package:learn_play_level_up_flutter/components/game_creators/picture_puzzle_creator.dart';
import 'package:learn_play_level_up_flutter/components/game_creators/timeline_game_creator.dart';
import 'package:learn_play_level_up_flutter/components/game_creators/fill_in_the_blanks_creator.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';

class GameCreatorPage extends StatefulWidget {
  final String? initialGameType;
  
  const GameCreatorPage({
    super.key,
    this.initialGameType,
  });

  @override
  State<GameCreatorPage> createState() => _GameCreatorPageState();
}

class _GameCreatorPageState extends State<GameCreatorPage> {
  bool _showTemplateSelection = true;
  String? _selectedTemplate;
  bool _isLoading = false;
  bool _isSaving = false;
  
  // Mock teacher ID and subject until we have authentication
  final String _teacherId = 'teacher123';
  final String _subjectId = 'math101';
  final int _gradeYear = 5;
  
  // Game templates
  final List<Map<String, dynamic>> _gameTemplates = [
    {
      'id': 'word_scramble',
      'name': 'Word Scramble',
      'description': 'Create a game where students unscramble words',
      'icon': Icons.shuffle,
      'color': Colors.purple,
    },
    {
      'id': 'quiz_show',
      'name': 'Quiz Show',
      'description': 'Jeopardy-style quiz with categories and point values',
      'icon': Icons.quiz,
      'color': Colors.blue,
    },
    {
      'id': 'word_guess',
      'name': 'Word Guess',
      'description': 'Hangman-style game where students guess a word',
      'icon': Icons.text_fields,
      'color': Colors.green,
    },
    {
      'id': 'sorting_game',
      'name': 'Sorting Game',
      'description': 'Students sort items into the correct categories',
      'icon': Icons.category,
      'color': Colors.orange,
    },
    {
      'id': 'picture_puzzle',
      'name': 'Picture Puzzle',
      'description': 'Students solve picture puzzles of varying difficulty',
      'icon': Icons.image,
      'color': Colors.cyan,
    },
    {
      'id': 'timeline_ordering',
      'name': 'Timeline Game',
      'description': 'Place historical events in the correct order',
      'icon': Icons.timeline,
      'color': Colors.amber,
    },
    {
      'id': 'fill_in_the_blanks',
      'name': 'Fill in the Blanks',
      'description': 'Students fill in missing words in a story or text',
      'icon': Icons.text_format,
      'color': Colors.pink,
    },
    {
      'id': 'crossword',
      'name': 'Crossword Puzzle',
      'description': 'Students solve clues to complete a crossword',
      'icon': Icons.grid_on,
      'color': Colors.indigo,
    },
    {
      'id': 'word_search',
      'name': 'Word Search',
      'description': 'Students find hidden words in a grid of letters',
      'icon': Icons.search,
      'color': Colors.teal,
    },
    {
      'id': 'labeling_diagram',
      'name': 'Labeling Diagram',
      'description': 'Students label parts of an image or diagram',
      'icon': Icons.add_location,
      'color': Colors.deepOrange,
    },
    {
      'id': 'speed_math',
      'name': 'Speed Math',
      'description': 'Students solve math problems against the clock',
      'icon': Icons.calculate,
      'color': Colors.lightBlue,
    },
    {
      'id': 'flashcards',
      'name': 'Flashcards',
      'description': 'Create digital flashcards for study and review',
      'icon': Icons.flip,
      'color': Colors.lime,
    },
    {
      'id': 'quiz',
      'name': 'Quiz System',
      'description': 'Create comprehensive quizzes with multiple question types',
      'icon': Icons.assignment,
      'color': Colors.deepPurple,
    },
  ];
  
  @override
  void initState() {
    super.initState();
    
    // If initial game type is provided, skip template selection
    if (widget.initialGameType != null) {
      _selectTemplate(widget.initialGameType!);
    }
  }
  
  void _selectTemplate(String templateId) {
    setState(() {
      _selectedTemplate = templateId;
      _showTemplateSelection = false;
    });
  }
  
  void _backToTemplates() {
    setState(() {
      _showTemplateSelection = true;
      _selectedTemplate = null;
    });
  }
  
  Future<void> _handleGameCreated(GameTemplate game) async {
    setState(() {
      _isSaving = true;
    });
    
    try {
      // Save game to Firestore
      final collection = FirebaseFirestore.instance.collection('games');
      await collection.add(game.toFirestore());
      
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
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          const Navbar(isAuthenticated: true, userRole: 'teacher'),
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
                                  _buildPageTitle(),
                                ],
                              ),
                              const SizedBox(height: 32),
                              _buildGameCreator(),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPageTitle() {
    if (_selectedTemplate == null) return const SizedBox();
    
    final template = _gameTemplates.firstWhere((t) => t['id'] == _selectedTemplate);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (template['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            template['icon'] as IconData,
            color: template['color'] as Color,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create ${template['name']}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildGameCreator() {
    switch (_selectedTemplate) {
      case 'word_scramble':
        return WordScrambleGameCreator(
          teacherId: _teacherId,
          subjectId: _subjectId,
          gradeYear: _gradeYear,
          onGameCreated: (game) => _handleGameCreated(game),
        );
      case 'quiz_show':
        return QuizShowGameCreator(
          teacherId: _teacherId,
          subjectId: _subjectId,
          gradeYear: _gradeYear,
          onGameCreated: (game) => _handleGameCreated(game),
        );
      case 'word_guess':
        return WordGuessGameCreator(
          teacherId: _teacherId,
          subjectId: _subjectId,
          gradeYear: _gradeYear,
          onGameCreated: (game) => _handleGameCreated(game),
        );
      case 'sorting_game':
        return SortingGameCreator(
          teacherId: _teacherId,
          subjectId: _subjectId,
          gradeYear: _gradeYear,
          onGameCreated: (game) => _handleGameCreated(game),
        );
      case 'picture_puzzle':
        return PicturePuzzleGameCreator(
          teacherId: _teacherId,
          subjectId: _subjectId,
          gradeYear: _gradeYear,
          onGameCreated: (game) => _handleGameCreated(game),
        );
      case 'timeline_ordering':
        return TimelineGameCreator(
          teacherId: _teacherId,
          subjectId: _subjectId,
          gradeYear: _gradeYear,
          onGameCreated: (game) => _handleGameCreated(game),
        );
      case 'fill_in_the_blanks':
        return FillInTheBlanksGameCreator(
          teacherId: _teacherId,
          subjectId: _subjectId,
          gradeYear: _gradeYear,
          onGameCreated: (game) => _handleGameCreated(game),
        );
      case 'crossword':
      case 'word_search':
      case 'labeling_diagram':
      case 'speed_math':
      case 'flashcards':
      case 'quiz':
        // Placeholder for future implementation
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _gameTemplates.firstWhere((t) => t['id'] == _selectedTemplate)['icon'] as IconData,
                size: 64,
                color: (_gameTemplates.firstWhere((t) => t['id'] == _selectedTemplate)['color'] as Color).withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'The ${_gameTemplates.firstWhere((t) => t['id'] == _selectedTemplate)['name']} creator is under development',
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'This game template will be available soon',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      default:
        return Center(
          child: Text(
            'Game creator for $_selectedTemplate is under development',
            style: const TextStyle(fontSize: 18),
          ),
        );
    }
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
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose a Game Type',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select a game type to create for your students',
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
                crossAxisCount: isSmallScreen ? 1 : 3,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: isSmallScreen ? 1.5 : 1.0,
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
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: templateColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            templateIcon,
                            color: templateColor,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          templateName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          templateDesc,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        AppButton(
                          text: 'Create Game',
                          variant: ButtonVariant.primary,
                          isFullWidth: true,
                          onPressed: () => _selectTemplate(templateId),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 