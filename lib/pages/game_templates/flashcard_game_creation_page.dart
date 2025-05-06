import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/pages/game_templates/template_creation_base_page.dart';
import 'package:learn_play_level_up_flutter/services/firebase_service.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:learn_play_level_up_flutter/models/firebase_models.dart';

class FlashcardGameCreationPage extends StatefulWidget {
  const FlashcardGameCreationPage({super.key});

  @override
  State<FlashcardGameCreationPage> createState() => _FlashcardGameCreationPageState();
}

class _FlashcardGameCreationPageState extends State<FlashcardGameCreationPage> {
  // Card management
  final List<Flashcard> _cards = [];
  final TextEditingController _frontContentController = TextEditingController();
  final TextEditingController _backContentController = TextEditingController();
  final TextEditingController _additionalInfoController = TextEditingController();
  final List<String> _cardTags = [];
  final TextEditingController _tagController = TextEditingController();
  
  // Design settings
  final Map<String, dynamic> _designSettings = {
    'backgroundColor': Colors.white.value,
    'fontStyle': 'default',
    'layoutTemplate': 'standard',
  };
  
  // Study mode settings
  String _studyMode = 'sequential';
  bool _enableTimeLimit = false;
  int _timePerCard = 30;
  bool _allowSelfAssessment = true;
  bool _showProgress = true;
  bool _showStatistics = true;
  bool _autoAdvance = false;
  final String _flipAnimationStyle = 'flip';
  
  // File upload
  String? _frontImageUrl;
  String? _backImageUrl;
  
  @override
  void dispose() {
    _frontContentController.dispose();
    _backContentController.dispose();
    _additionalInfoController.dispose();
    _tagController.dispose();
    super.dispose();
  }
  
  void _addCard() {
    if (_frontContentController.text.isEmpty || _backContentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both front and back content')),
      );
      return;
    }
    
    setState(() {
      _cards.add(Flashcard(
        id: const Uuid().v4(),
        frontContent: _frontContentController.text,
        frontImageUrl: _frontImageUrl,
        backContent: _backContentController.text,
        backImageUrl: _backImageUrl,
        additionalInfo: _additionalInfoController.text.isNotEmpty ? _additionalInfoController.text : null,
        tags: List.from(_cardTags),
        position: _cards.length,
      ));
      
      // Clear form
      _frontContentController.clear();
      _backContentController.clear();
      _additionalInfoController.clear();
      _cardTags.clear();
      _frontImageUrl = null;
      _backImageUrl = null;
    });
  }
  
  void _removeCard(int index) {
    setState(() {
      _cards.removeAt(index);
      // Update positions
      for (int i = index; i < _cards.length; i++) {
        _cards[i] = Flashcard(
          id: _cards[i].id,
          frontContent: _cards[i].frontContent,
          frontImageUrl: _cards[i].frontImageUrl,
          backContent: _cards[i].backContent,
          backImageUrl: _cards[i].backImageUrl,
          additionalInfo: _cards[i].additionalInfo,
          tags: _cards[i].tags,
          position: i,
        );
      }
    });
  }
  
  void _moveCard(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final card = _cards.removeAt(oldIndex);
    setState(() {
      _cards.insert(newIndex, Flashcard(
        id: card.id,
        frontContent: card.frontContent,
        frontImageUrl: card.frontImageUrl,
        backContent: card.backContent,
        backImageUrl: card.backImageUrl,
        additionalInfo: card.additionalInfo,
        tags: card.tags,
        position: newIndex,
      ));
      
      // Update positions
      for (int i = 0; i < _cards.length; i++) {
        if (i != newIndex) {
          _cards[i] = Flashcard(
            id: _cards[i].id,
            frontContent: _cards[i].frontContent,
            frontImageUrl: _cards[i].frontImageUrl,
            backContent: _cards[i].backContent,
            backImageUrl: _cards[i].backImageUrl,
            additionalInfo: _cards[i].additionalInfo,
            tags: _cards[i].tags,
            position: i,
          );
        }
      }
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
    if (_cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one flashcard')),
      );
      return false;
    }
    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      final game = FlashcardGame(
        title: title,
        description: description,
        coverImage: null,
        teacherId: teacherId,
        subjectId: subjectId,
        gradeYear: gradeYear,
        createdAt: DateTime.now(),
        dueDate: dueDate,
        isActive: true,
        estimatedDuration: _enableTimeLimit ? _timePerCard * _cards.length ~/ 60 : 0,
        tags: [],
        maxPoints: maxPoints,
        xpReward: xpReward,
        coinReward: coinReward,
        cards: _cards,
        studyMode: _studyMode,
        designSettings: _designSettings,
        timePerCard: _enableTimeLimit ? _timePerCard : null,
        allowSelfAssessment: _allowSelfAssessment,
        showProgress: _showProgress,
        showStatistics: _showStatistics,
        autoAdvance: _autoAdvance,
        flipAnimationStyle: _flipAnimationStyle,
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
          questions: [], // Optionally map flashcards to GameQuestion if needed
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
      type: 'flashcard_game',
      title: 'Flashcard Game',
      icon: Icons.flip_to_front,
      color: Colors.pink,
      contentBuilder: _buildContent,
      saveToFirebase: _saveGame,
    );
  }
  
  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Study mode selection
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Study Mode',
            border: OutlineInputBorder(),
          ),
          value: _studyMode,
          items: const [
            DropdownMenuItem(value: 'sequential', child: Text('Sequential')),
            DropdownMenuItem(value: 'random', child: Text('Random')),
            DropdownMenuItem(value: 'spaced_repetition', child: Text('Spaced Repetition')),
            DropdownMenuItem(value: 'quiz', child: Text('Quiz Mode')),
          ],
          onChanged: (value) {
            setState(() {
              _studyMode = value!;
            });
          },
        ),
        const SizedBox(height: 16),
        
        // Time limit settings
        SwitchListTile(
          title: const Text('Enable Time Limit'),
          value: _enableTimeLimit,
          onChanged: (value) {
            setState(() {
              _enableTimeLimit = value;
            });
          },
        ),
        if (_enableTimeLimit)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text('$_timePerCard seconds per card'),
                ),
                Expanded(
                  flex: 2,
                  child: Slider(
                    value: _timePerCard.toDouble(),
                    min: 5,
                    max: 120,
                    divisions: 23,
                    label: '$_timePerCard seconds',
                    onChanged: (value) {
                      setState(() {
                        _timePerCard = value.toInt();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        
        // Additional settings
        SwitchListTile(
          title: const Text('Allow Self-Assessment'),
          value: _allowSelfAssessment,
          onChanged: (value) {
            setState(() {
              _allowSelfAssessment = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Show Progress'),
          value: _showProgress,
          onChanged: (value) {
            setState(() {
              _showProgress = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Show Statistics'),
          value: _showStatistics,
          onChanged: (value) {
            setState(() {
              _showStatistics = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Auto-Advance'),
          value: _autoAdvance,
          onChanged: (value) {
            setState(() {
              _autoAdvance = value;
            });
          },
        ),
        const SizedBox(height: 16),
        
        // Card creation form
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Card',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Front content
                TextFormField(
                  controller: _frontContentController,
                  decoration: const InputDecoration(
                    labelText: 'Front Content',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                
                // Back content
                TextFormField(
                  controller: _backContentController,
                  decoration: const InputDecoration(
                    labelText: 'Back Content',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                
                // Additional info
                TextFormField(
                  controller: _additionalInfoController,
                  decoration: const InputDecoration(
                    labelText: 'Additional Info (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                // Tags
                Wrap(
                  spacing: 8,
                  children: [
                    ..._cardTags.map((tag) => Chip(
                      label: Text(tag),
                      onDeleted: () {
                        setState(() {
                          _cardTags.remove(tag);
                        });
                      },
                    )),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: _tagController,
                        decoration: const InputDecoration(
                          labelText: 'Add Tag',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty && !_cardTags.contains(value)) {
                            setState(() {
                              _cardTags.add(value);
                              _tagController.clear();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Add card button
                ElevatedButton(
                  onPressed: _addCard,
                  child: const Text('Add Card'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Cards list
        if (_cards.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cards',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  return Card(
                    key: ValueKey(card.id),
                    child: ListTile(
                      title: Text(card.frontContent),
                      subtitle: Text(card.backContent),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeCard(index),
                      ),
                    ),
                  );
                },
                onReorder: _moveCard,
              ),
            ],
          ),
      ],
    );
  }
} 