import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/services/game_templates_provider.dart';
import 'package:learn_play_level_up_flutter/widgets/common/form_fields.dart';
import 'package:learn_play_level_up_flutter/widgets/common/image_upload.dart';
import 'package:uuid/uuid.dart';

class MemoryFlipCardsCreationScreen extends StatefulWidget {
  const MemoryFlipCardsCreationScreen({Key? key}) : super(key: key);

  @override
  _MemoryFlipCardsCreationScreenState createState() => _MemoryFlipCardsCreationScreenState();
}

class _MemoryFlipCardsCreationScreenState extends State<MemoryFlipCardsCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<MemoryCardPair> _cardPairs = [];
  String _gameMode = 'word_pairs';
  int _gridSize = 4;
  int? _timeLimit;
  int _maxAttempts = 3;
  int _estimatedDuration = 10;
  int _xpReward = 100;
  int _coinReward = 50;
  int _maxPoints = 100;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addCardPair() {
    setState(() {
      _cardPairs.add(MemoryCardPair(
        item1: '',
        item2: '',
        item1Type: _gameMode == 'image_pairs' ? 'image' : 'text',
        item2Type: _gameMode == 'image_pairs' ? 'image' : 'text',
      ));
    });
  }

  void _removeCardPair(int index) {
    setState(() {
      _cardPairs.removeAt(index);
    });
  }

  void _updateCardPair(int index, MemoryCardPair pair) {
    setState(() {
      _cardPairs[index] = pair;
    });
  }

  void _updateGameMode(String mode) {
    setState(() {
      _gameMode = mode;
      // Update all card pairs to match the new mode
      for (var i = 0; i < _cardPairs.length; i++) {
        _cardPairs[i] = MemoryCardPair(
          id: _cardPairs[i].id,
          item1: _cardPairs[i].item1,
          item2: _cardPairs[i].item2,
          item1Type: mode == 'image_pairs' ? 'image' : 'text',
          item2Type: mode == 'image_pairs' ? 'image' : 'text',
        );
      }
    });
  }

  Future<void> _saveGame() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cardPairs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one card pair')),
      );
      return;
    }

    final game = MemoryFlipCardsGame(
      title: _titleController.text,
      description: _descriptionController.text,
      teacherId: Provider.of<GameTemplatesProvider>(context, listen: false).currentUser!.id,
      subjectId: Provider.of<GameTemplatesProvider>(context, listen: false).selectedSubject!.id,
      gradeYear: Provider.of<GameTemplatesProvider>(context, listen: false).selectedGradeYear!,
      createdAt: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 7)),
      estimatedDuration: _estimatedDuration,
      tags: ['memory', 'flip_cards'],
      maxPoints: _maxPoints,
      xpReward: _xpReward,
      coinReward: _coinReward,
      cardPairs: _cardPairs,
      gameMode: _gameMode,
      gridSize: _gridSize,
      timeLimit: _timeLimit,
      maxAttempts: _maxAttempts,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Memory Flip-Cards Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveGame,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Game Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Game Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _gameMode,
                      decoration: const InputDecoration(
                        labelText: 'Game Mode',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'word_pairs',
                          child: Text('Word Pairs'),
                        ),
                        DropdownMenuItem(
                          value: 'image_pairs',
                          child: Text('Image Pairs'),
                        ),
                        DropdownMenuItem(
                          value: 'image_word_pairs',
                          child: Text('Image-Word Pairs'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          _updateGameMode(value);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _gridSize,
                      decoration: const InputDecoration(
                        labelText: 'Grid Size',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 4,
                          child: Text('4x4 (8 pairs)'),
                        ),
                        DropdownMenuItem(
                          value: 5,
                          child: Text('5x5 (12 pairs)'),
                        ),
                        DropdownMenuItem(
                          value: 6,
                          child: Text('6x6 (18 pairs)'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _gridSize = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Time Limit (seconds)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _timeLimit = int.tryParse(value);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Maximum Attempts',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: '3',
                      onChanged: (value) {
                        _maxAttempts = int.tryParse(value) ?? 3;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Estimated Duration (minutes)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: '10',
                      onChanged: (value) {
                        _estimatedDuration = int.tryParse(value) ?? 10;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'XP Reward',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: '100',
                      onChanged: (value) {
                        _xpReward = int.tryParse(value) ?? 100;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Coin Reward',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: '50',
                      onChanged: (value) {
                        _coinReward = int.tryParse(value) ?? 50;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Maximum Points',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: '100',
                      onChanged: (value) {
                        _maxPoints = int.tryParse(value) ?? 100;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                          'Card Pairs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addCardPair,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _cardPairs.length,
                      itemBuilder: (context, index) {
                        return _MemoryCardPairItem(
                          pair: _cardPairs[index],
                          gameMode: _gameMode,
                          onChanged: (pair) => _updateCardPair(index, pair),
                          onRemove: () => _removeCardPair(index),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryCardPairItem extends StatefulWidget {
  final MemoryCardPair pair;
  final String gameMode;
  final Function(MemoryCardPair) onChanged;
  final VoidCallback onRemove;

  const _MemoryCardPairItem({
    Key? key,
    required this.pair,
    required this.gameMode,
    required this.onChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  __MemoryCardPairItemState createState() => __MemoryCardPairItemState();
}

class __MemoryCardPairItemState extends State<_MemoryCardPairItem> {
  late TextEditingController _item1Controller;
  late TextEditingController _item2Controller;
  late String _item1Type;
  late String _item2Type;

  @override
  void initState() {
    super.initState();
    _item1Controller = TextEditingController(text: widget.pair.item1);
    _item2Controller = TextEditingController(text: widget.pair.item2);
    _item1Type = widget.pair.item1Type;
    _item2Type = widget.pair.item2Type;
  }

  @override
  void dispose() {
    _item1Controller.dispose();
    _item2Controller.dispose();
    super.dispose();
  }

  void _updatePair() {
    widget.onChanged(MemoryCardPair(
      id: widget.pair.id,
      item1: _item1Controller.text,
      item2: _item2Controller.text,
      item1Type: _item1Type,
      item2Type: _item2Type,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      if (widget.gameMode == 'image_word_pairs')
                        const Text(
                          'Image',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      else if (widget.gameMode == 'word_pairs')
                        const Text(
                          'Word 1',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      else
                        const Text(
                          'Image 1',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(height: 8),
                      if (widget.gameMode == 'word_pairs')
                        TextFormField(
                          controller: _item1Controller,
                          decoration: const InputDecoration(
                            labelText: 'First Item',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => _updatePair(),
                        )
                      else
                        ImageUploadField(
                          onImageSelected: (url) {
                            _item1Controller.text = url;
                            _updatePair();
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      if (widget.gameMode == 'image_word_pairs')
                        const Text(
                          'Word',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      else if (widget.gameMode == 'word_pairs')
                        const Text(
                          'Word 2',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      else
                        const Text(
                          'Image 2',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(height: 8),
                      if (widget.gameMode == 'image_pairs')
                        ImageUploadField(
                          onImageSelected: (url) {
                            _item2Controller.text = url;
                            _updatePair();
                          },
                        )
                      else
                        TextFormField(
                          controller: _item2Controller,
                          decoration: const InputDecoration(
                            labelText: 'Second Item',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => _updatePair(),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 