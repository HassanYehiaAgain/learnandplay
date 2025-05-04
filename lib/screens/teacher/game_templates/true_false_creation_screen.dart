import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/services/game_templates_provider.dart';
import 'package:learn_play_level_up_flutter/widgets/common/form_fields.dart';
import 'package:learn_play_level_up_flutter/widgets/common/image_upload.dart';

class TrueFalseCreationScreen extends StatefulWidget {
  const TrueFalseCreationScreen({Key? key}) : super(key: key);

  @override
  _TrueFalseCreationScreenState createState() => _TrueFalseCreationScreenState();
}

class _TrueFalseCreationScreenState extends State<TrueFalseCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TrueFalseStatement> _statements = [];
  bool _randomizeOrder = true;
  bool _allowSkipping = true;
  int? _timeLimit;
  int? _timePerStatement;
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

  void _addStatement() {
    setState(() {
      _statements.add(TrueFalseStatement(
        statement: '',
        isTrue: true,
        explanation: '',
      ));
    });
  }

  void _removeStatement(int index) {
    setState(() {
      _statements.removeAt(index);
    });
  }

  void _updateStatement(int index, TrueFalseStatement statement) {
    setState(() {
      _statements[index] = statement;
    });
  }

  Future<void> _saveGame() async {
    if (!_formKey.currentState!.validate()) return;
    if (_statements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one statement')),
      );
      return;
    }

    final game = TrueFalseGame(
      title: _titleController.text,
      description: _descriptionController.text,
      teacherId: Provider.of<GameTemplatesProvider>(context, listen: false).currentUser!.id,
      subjectId: Provider.of<GameTemplatesProvider>(context, listen: false).selectedSubject!.id,
      gradeYear: Provider.of<GameTemplatesProvider>(context, listen: false).selectedGradeYear!,
      createdAt: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 7)),
      estimatedDuration: _estimatedDuration,
      tags: ['true_false', 'quiz'],
      maxPoints: _maxPoints,
      xpReward: _xpReward,
      coinReward: _coinReward,
      statements: _statements,
      randomizeOrder: _randomizeOrder,
      allowSkipping: _allowSkipping,
      timeLimit: _timeLimit,
      timePerStatement: _timePerStatement,
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
        title: const Text('Create True/False Challenge'),
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
                      title: const Text('Randomize Statement Order'),
                      value: _randomizeOrder,
                      onChanged: (value) {
                        setState(() {
                          _randomizeOrder = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Allow Skipping Statements'),
                      value: _allowSkipping,
                      onChanged: (value) {
                        setState(() {
                          _allowSkipping = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Overall Time Limit (seconds)',
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
                        labelText: 'Time Per Statement (seconds)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _timePerStatement = int.tryParse(value);
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
                          'Statements',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addStatement,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _statements.length,
                      itemBuilder: (context, index) {
                        return _StatementFormItem(
                          statement: _statements[index],
                          onChanged: (statement) => _updateStatement(index, statement),
                          onRemove: () => _removeStatement(index),
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

class _StatementFormItem extends StatefulWidget {
  final TrueFalseStatement statement;
  final Function(TrueFalseStatement) onChanged;
  final VoidCallback onRemove;

  const _StatementFormItem({
    Key? key,
    required this.statement,
    required this.onChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  __StatementFormItemState createState() => __StatementFormItemState();
}

class __StatementFormItemState extends State<_StatementFormItem> {
  late TextEditingController _statementController;
  late TextEditingController _explanationController;
  late bool _isTrue;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _statementController = TextEditingController(text: widget.statement.statement);
    _explanationController = TextEditingController(text: widget.statement.explanation);
    _isTrue = widget.statement.isTrue;
    _imageUrl = widget.statement.imageUrl;
  }

  @override
  void dispose() {
    _statementController.dispose();
    _explanationController.dispose();
    super.dispose();
  }

  void _updateStatement() {
    widget.onChanged(TrueFalseStatement(
      id: widget.statement.id,
      statement: _statementController.text,
      isTrue: _isTrue,
      explanation: _explanationController.text,
      imageUrl: _imageUrl,
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
                  child: TextFormField(
                    controller: _statementController,
                    decoration: const InputDecoration(
                      labelText: 'Statement',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _updateStatement(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('True'),
                Switch(
                  value: _isTrue,
                  onChanged: (value) {
                    setState(() {
                      _isTrue = value;
                    });
                    _updateStatement();
                  },
                ),
                const Text('False'),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _explanationController,
              decoration: const InputDecoration(
                labelText: 'Explanation',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (_) => _updateStatement(),
            ),
            const SizedBox(height: 8),
            ImageUploadField(
              initialValue: _imageUrl,
              onImageSelected: (url) {
                setState(() {
                  _imageUrl = url;
                });
                _updateStatement();
              },
            ),
          ],
        ),
      ),
    );
  }
} 