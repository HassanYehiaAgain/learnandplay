import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/services/game_templates_provider.dart';
import 'package:learn_play_level_up_flutter/widgets/common/form_fields.dart';
import 'package:learn_play_level_up_flutter/widgets/common/image_upload.dart';
import 'package:uuid/uuid.dart';

class MatchingPairsCreationScreen extends StatefulWidget {
  const MatchingPairsCreationScreen({Key? key}) : super(key: key);

  @override
  _MatchingPairsCreationScreenState createState() => _MatchingPairsCreationScreenState();
}

class _MatchingPairsCreationScreenState extends State<MatchingPairsCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<MatchingPairItem> _pairs = [];
  bool _randomizeOrder = true;
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

  void _addPair() {
    setState(() {
      _pairs.add(MatchingPairItem(
        leftItem: '',
        rightItem: '',
        leftType: 'text',
        rightType: 'text',
      ));
    });
  }

  void _removePair(int index) {
    setState(() {
      _pairs.removeAt(index);
    });
  }

  void _updatePair(int index, MatchingPairItem pair) {
    setState(() {
      _pairs[index] = pair;
    });
  }

  Future<void> _saveGame() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pairs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one pair')),
      );
      return;
    }

    final game = MatchingPairsGame(
      title: _titleController.text,
      description: _descriptionController.text,
      teacherId: Provider.of<GameTemplatesProvider>(context, listen: false).currentUser!.id,
      subjectId: Provider.of<GameTemplatesProvider>(context, listen: false).selectedSubject!.id,
      gradeYear: Provider.of<GameTemplatesProvider>(context, listen: false).selectedGradeYear!,
      createdAt: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 7)),
      estimatedDuration: _estimatedDuration,
      tags: ['matching', 'pairs'],
      maxPoints: _maxPoints,
      xpReward: _xpReward,
      coinReward: _coinReward,
      pairs: _pairs,
      randomizeOrder: _randomizeOrder,
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
        title: const Text('Create Matching Pairs Game'),
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
                    SwitchListTile(
                      title: const Text('Randomize Order'),
                      value: _randomizeOrder,
                      onChanged: (value) {
                        setState(() {
                          _randomizeOrder = value;
                        });
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
                          'Matching Pairs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addPair,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _pairs.length,
                      itemBuilder: (context, index) {
                        return _MatchingPairItem(
                          pair: _pairs[index],
                          onChanged: (pair) => _updatePair(index, pair),
                          onRemove: () => _removePair(index),
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

class _MatchingPairItem extends StatefulWidget {
  final MatchingPairItem pair;
  final Function(MatchingPairItem) onChanged;
  final VoidCallback onRemove;

  const _MatchingPairItem({
    Key? key,
    required this.pair,
    required this.onChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  __MatchingPairItemState createState() => __MatchingPairItemState();
}

class __MatchingPairItemState extends State<_MatchingPairItem> {
  late TextEditingController _leftController;
  late TextEditingController _rightController;
  late String _leftType;
  late String _rightType;

  @override
  void initState() {
    super.initState();
    _leftController = TextEditingController(text: widget.pair.leftItem);
    _rightController = TextEditingController(text: widget.pair.rightItem);
    _leftType = widget.pair.leftType;
    _rightType = widget.pair.rightType;
  }

  @override
  void dispose() {
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  void _updatePair() {
    widget.onChanged(MatchingPairItem(
      id: widget.pair.id,
      leftItem: _leftController.text,
      rightItem: _rightController.text,
      leftType: _leftType,
      rightType: _rightType,
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
                      DropdownButtonFormField<String>(
                        value: _leftType,
                        decoration: const InputDecoration(
                          labelText: 'Left Item Type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'text',
                            child: Text('Text'),
                          ),
                          DropdownMenuItem(
                            value: 'image',
                            child: Text('Image'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _leftType = value!;
                          });
                          _updatePair();
                        },
                      ),
                      const SizedBox(height: 8),
                      if (_leftType == 'text')
                        TextFormField(
                          controller: _leftController,
                          decoration: const InputDecoration(
                            labelText: 'Left Item',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => _updatePair(),
                        )
                      else
                        ImageUploadField(
                          onImageSelected: (url) {
                            _leftController.text = url;
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
                      DropdownButtonFormField<String>(
                        value: _rightType,
                        decoration: const InputDecoration(
                          labelText: 'Right Item Type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'text',
                            child: Text('Text'),
                          ),
                          DropdownMenuItem(
                            value: 'image',
                            child: Text('Image'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _rightType = value!;
                          });
                          _updatePair();
                        },
                      ),
                      const SizedBox(height: 8),
                      if (_rightType == 'text')
                        TextFormField(
                          controller: _rightController,
                          decoration: const InputDecoration(
                            labelText: 'Right Item',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => _updatePair(),
                        )
                      else
                        ImageUploadField(
                          onImageSelected: (url) {
                            _rightController.text = url;
                            _updatePair();
                          },
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