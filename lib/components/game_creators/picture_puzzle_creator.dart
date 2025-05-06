import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';
import 'package:learn_play_level_up_flutter/components/ui/input.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class PicturePuzzleGameCreator extends StatefulWidget {
  final Function(PicturePuzzleGame) onGameCreated;
  final String teacherId;
  final String subjectId;
  final int gradeYear;
  final PicturePuzzleGame? existingGame; // For editing an existing game

  const PicturePuzzleGameCreator({
    super.key,
    required this.onGameCreated,
    required this.teacherId,
    required this.subjectId,
    required this.gradeYear,
    this.existingGame,
  });

  @override
  State<PicturePuzzleGameCreator> createState() => _PicturePuzzleGameCreatorState();
}

class _PicturePuzzleGameCreatorState extends State<PicturePuzzleGameCreator> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Form state
  int _difficulty = 3;
  int _estimatedDuration = 10;
  List<String> _tags = [];
  int _maxPoints = 0;
  int _xpReward = 100;
  int _coinReward = 50;
  List<PicturePuzzleItem> _puzzles = [];
  bool _showCompleteImageAsHint = true;
  
  bool _isLoading = false;
  final _tagController = TextEditingController();
  
  // Puzzle form controllers
  final _imageUrlController = TextEditingController();
  final _puzzleDescriptionController = TextEditingController();
  final _piecesController = TextEditingController();
  final _pointsController = TextEditingController();
  final _timeLimitController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    // Populate with existing game data if editing
    if (widget.existingGame != null) {
      _titleController.text = widget.existingGame!.title;
      _descriptionController.text = widget.existingGame!.description;
      _difficulty = widget.existingGame!.difficulty;
      _estimatedDuration = widget.existingGame!.estimatedDuration;
      _tags = List.from(widget.existingGame!.tags);
      _maxPoints = widget.existingGame!.maxPoints;
      _xpReward = widget.existingGame!.xpReward;
      _coinReward = widget.existingGame!.coinReward;
      _puzzles = List.from(widget.existingGame!.puzzles);
      _showCompleteImageAsHint = widget.existingGame!.showCompleteImageAsHint;
    } else {
      // Add initial empty puzzle
      _addNewPuzzle();
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    _imageUrlController.dispose();
    _puzzleDescriptionController.dispose();
    _piecesController.dispose();
    _pointsController.dispose();
    _timeLimitController.dispose();
    super.dispose();
  }
  
  void _addNewPuzzle() {
    setState(() {
      _puzzles.add(
        PicturePuzzleItem(
          imageUrl: '',
          description: '',
          pieces: 9, // Default 3x3 grid
          points: 10,
        ),
      );
    });
  }
  
  void _removePuzzle(int index) {
    if (_puzzles.length > 1) {
      setState(() {
        _puzzles.removeAt(index);
        _updateMaxPoints();
      });
    }
  }
  
  void _duplicatePuzzle(int index) {
    setState(() {
      final original = _puzzles[index];
      _puzzles.insert(index + 1, PicturePuzzleItem(
        imageUrl: original.imageUrl,
        description: original.description,
        pieces: original.pieces,
        points: original.points,
        timeLimit: original.timeLimit,
      ));
      _updateMaxPoints();
    });
  }
  
  void _editPuzzle(int index) {
    final puzzle = _puzzles[index];
    
    // Set form controllers
    _imageUrlController.text = puzzle.imageUrl;
    _puzzleDescriptionController.text = puzzle.description;
    _piecesController.text = puzzle.pieces.toString();
    _pointsController.text = puzzle.points.toString();
    _timeLimitController.text = puzzle.timeLimit?.toString() ?? '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == -1 ? 'Add Puzzle' : 'Edit Puzzle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppInput(
                controller: _imageUrlController,
                label: 'Image URL',
                placeholder: 'Enter image URL',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppInput(
                controller: _puzzleDescriptionController,
                label: 'Description',
                placeholder: 'Enter a description for this puzzle',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppInput(
                      controller: _piecesController,
                      label: 'Pieces (9 = 3x3, 16 = 4x4, etc.)',
                      placeholder: 'Enter number of pieces',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter number of pieces';
                        }
                        final pieces = int.tryParse(value);
                        if (pieces == null) {
                          return 'Please enter a valid number';
                        }
                        if (pieces < 4 || pieces > 36) {
                          return 'Pieces must be between 4 and 36';
                        }
                        // Check if it's a perfect square (2x2, 3x3, etc.)
                        final sqrt = Math.sqrt(pieces);
                        if (sqrt != sqrt.floor()) {
                          return 'Number must be a perfect square (4, 9, 16, 25, 36)';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppInput(
                      controller: _pointsController,
                      label: 'Points',
                      placeholder: 'Enter points',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter points';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppInput(
                controller: _timeLimitController,
                label: 'Time Limit (seconds, optional)',
                placeholder: 'Enter time limit or leave blank for none',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Validate
              if (_imageUrlController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter an image URL')),
                );
                return;
              }
              if (_puzzleDescriptionController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a description')),
                );
                return;
              }
              
              final pieces = int.tryParse(_piecesController.text) ?? 9;
              final sqrt = Math.sqrt(pieces);
              if (sqrt != sqrt.floor() || pieces < 4 || pieces > 36) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Number of pieces must be a perfect square between 4 and 36')),
                );
                return;
              }
              
              // Update or add puzzle
              setState(() {
                final puzzleItem = PicturePuzzleItem(
                  id: index >= 0 ? _puzzles[index].id : null,
                  imageUrl: _imageUrlController.text,
                  description: _puzzleDescriptionController.text,
                  pieces: pieces,
                  points: int.tryParse(_pointsController.text) ?? 10,
                  timeLimit: _timeLimitController.text.isEmpty ? null : int.tryParse(_timeLimitController.text),
                );
                
                if (index == -1) {
                  _puzzles.add(puzzleItem);
                } else {
                  _puzzles[index] = puzzleItem;
                }
                
                _updateMaxPoints();
              });
              
              Navigator.pop(context);
            },
            child: Text(index == -1 ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }
  
  void _updateMaxPoints() {
    int total = 0;
    for (var puzzle in _puzzles) {
      total += puzzle.points;
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
    
    // Validate puzzles
    for (var i = 0; i < _puzzles.length; i++) {
      if (_puzzles[i].imageUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Puzzle ${i + 1} is missing an image URL')),
        );
        return;
      }
      if (_puzzles[i].description.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Puzzle ${i + 1} is missing a description')),
        );
        return;
      }
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Update max points before creating the game
      _updateMaxPoints();
      
      final PicturePuzzleGame game = PicturePuzzleGame(
        title: _titleController.text,
        description: _descriptionController.text,
        teacherId: widget.teacherId,
        subjectId: widget.subjectId,
        gradeYear: widget.gradeYear,
        createdAt: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 7)),
        difficulty: _difficulty,
        estimatedDuration: _estimatedDuration,
        tags: _tags,
        maxPoints: _maxPoints,
        xpReward: _xpReward,
        coinReward: _coinReward,
        puzzles: _puzzles,
        showCompleteImageAsHint: _showCompleteImageAsHint,
      );
      
      // Call the callback to save the game
      widget.onGameCreated(game);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving game: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 768;
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Information Card
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppInput(
                    controller: _titleController,
                    label: 'Game Title',
                    placeholder: 'Enter a title for your game',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    controller: _descriptionController,
                    label: 'Description',
                    placeholder: 'Enter a description of the game',
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tags',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: AppInput(
                          controller: _tagController,
                          placeholder: 'Add a tag',
                          onChanged: (_) {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        text: 'Add',
                        onPressed: _addTag,
                        variant: ButtonVariant.secondary,
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
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeTag(tag),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Difficulty',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _difficulty.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _difficulty.toString(),
                    onChanged: (value) {
                      setState(() {
                        _difficulty = value.toInt();
                      });
                    },
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Easy'),
                      Text('Medium'),
                      Text('Hard'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Duration (minutes)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Slider(
                                    value: _estimatedDuration.toDouble(),
                                    min: 5,
                                    max: 60,
                                    divisions: 11,
                                    label: '$_estimatedDuration min',
                                    onChanged: (value) {
                                      setState(() {
                                        _estimatedDuration = value.toInt();
                                      });
                                    },
                                  ),
                                ),
                                Text('$_estimatedDuration min'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppInput(
                          controller: TextEditingController(text: _xpReward.toString()),
                          label: 'XP Reward',
                          placeholder: 'Enter XP reward',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter XP reward';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _xpReward = int.tryParse(value) ?? 100;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppInput(
                          controller: TextEditingController(text: _coinReward.toString()),
                          label: 'Coin Reward',
                          placeholder: 'Enter coin reward',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter coin reward';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _coinReward = int.tryParse(value) ?? 50;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Show Complete Image as Hint',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Switch(
                        value: _showCompleteImageAsHint,
                        onChanged: (value) {
                          setState(() {
                            _showCompleteImageAsHint = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Puzzles Card
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Puzzles',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      AppButton(
                        text: '+ Add Puzzle',
                        onPressed: () => _editPuzzle(-1),
                        variant: ButtonVariant.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Display puzzles
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _puzzles.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final puzzle = _puzzles[index];
                      final sqrt = Math.sqrt(puzzle.pieces).toInt();
                      
                      return ListTile(
                        leading: puzzle.imageUrl.isNotEmpty
                            ? Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  border: Border.all(color: colorScheme.outline),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    puzzle.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(Icons.image_not_supported),
                                      );
                                    },
                                  ),
                                ),
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  border: Border.all(color: colorScheme.outline),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Icon(Icons.add_photo_alternate),
                                ),
                              ),
                        title: Text(
                          puzzle.description.isEmpty ? 'Unnamed Puzzle' : puzzle.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Grid Size: ${sqrt}x$sqrt'),
                            Text('Points: ${puzzle.points}'),
                            if (puzzle.timeLimit != null)
                              Text('Time Limit: ${puzzle.timeLimit} seconds'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () => _duplicatePuzzle(index),
                              tooltip: 'Duplicate',
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editPuzzle(index),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removePuzzle(index),
                              tooltip: 'Remove',
                            ),
                          ],
                        ),
                        isThreeLine: puzzle.timeLimit != null,
                      );
                    },
                  ),
                  
                  if (_puzzles.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 48,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No puzzles added yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AppButton(
                              text: 'Add a Puzzle',
                              onPressed: () => _editPuzzle(-1),
                              variant: ButtonVariant.secondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Game points summary
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Game Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total Maximum Points: $_maxPoints',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Puzzles: ${_puzzles.length}'),
                  Text('XP Reward: $_xpReward'),
                  Text('Coin Reward: $_coinReward'),
                  Text('Show Complete Image as Hint: ${_showCompleteImageAsHint ? 'Yes' : 'No'}'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Save button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppButton(
                text: 'Save Game',
                onPressed: _isLoading ? null : _saveGame,
                isLoading: _isLoading,
                variant: ButtonVariant.primary,
                size: ButtonSize.large,
              ),
            ],
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// Add Math for sqrt function
class Math {
  static double sqrt(num value) {
    return math.sqrt(value);
  }
} 