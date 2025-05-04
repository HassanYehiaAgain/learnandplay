import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';
import 'package:learn_play_level_up_flutter/components/ui/input.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class TimelineGameCreator extends StatefulWidget {
  final Function(TimelineGame) onGameCreated;
  final String teacherId;
  final String subjectId;
  final int gradeYear;
  final TimelineGame? existingGame; // For editing an existing game

  const TimelineGameCreator({
    super.key,
    required this.onGameCreated,
    required this.teacherId,
    required this.subjectId,
    required this.gradeYear,
    this.existingGame,
  });

  @override
  State<TimelineGameCreator> createState() => _TimelineGameCreatorState();
}

class _TimelineGameCreatorState extends State<TimelineGameCreator> {
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
  List<TimelineItem> _items = [];
  bool _showDates = true;
  int? _timeLimit;
  
  bool _isLoading = false;
  final _tagController = TextEditingController();
  
  // Item form controllers
  final _itemTitleController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _itemImageUrlController = TextEditingController();
  final _itemPointsController = TextEditingController();
  DateTime? _selectedDate;
  int _itemOrder = 0;
  
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
      _items = List.from(widget.existingGame!.items);
      _showDates = widget.existingGame!.showDates;
      _timeLimit = widget.existingGame!.timeLimit;
    } else {
      // Add initial empty item
      _addNewItem();
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    _itemTitleController.dispose();
    _itemDescriptionController.dispose();
    _itemImageUrlController.dispose();
    _itemPointsController.dispose();
    super.dispose();
  }
  
  void _addNewItem() {
    setState(() {
      _items.add(
        TimelineItem(
          title: '',
          description: '',
          order: _items.length, // Default order is the current length
          points: 10,
        ),
      );
    });
  }
  
  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() {
        _items.removeAt(index);
        
        // Re-arrange order for remaining items
        for (int i = 0; i < _items.length; i++) {
          _items[i] = TimelineItem(
            id: _items[i].id,
            title: _items[i].title,
            description: _items[i].description,
            date: _items[i].date,
            imageUrl: _items[i].imageUrl,
            order: i,
            points: _items[i].points,
          );
        }
        
        _updateMaxPoints();
      });
    }
  }
  
  void _duplicateItem(int index) {
    setState(() {
      final original = _items[index];
      // Insert after the current item and shift all subsequent items
      _items.insert(index + 1, TimelineItem(
        title: original.title,
        description: original.description,
        date: original.date,
        imageUrl: original.imageUrl,
        order: original.order + 1,
        points: original.points,
      ));
      
      // Re-arrange order for all items after the duplicated one
      for (int i = index + 2; i < _items.length; i++) {
        _items[i] = TimelineItem(
          id: _items[i].id,
          title: _items[i].title,
          description: _items[i].description,
          date: _items[i].date,
          imageUrl: _items[i].imageUrl,
          order: i,
          points: _items[i].points,
        );
      }
      
      _updateMaxPoints();
    });
  }
  
  void _moveItemUp(int index) {
    if (index > 0) {
      setState(() {
        // Swap with the previous item
        final temp = _items[index];
        _items[index] = _items[index - 1];
        _items[index - 1] = temp;
        
        // Update order values
        _items[index] = TimelineItem(
          id: _items[index].id,
          title: _items[index].title,
          description: _items[index].description,
          date: _items[index].date,
          imageUrl: _items[index].imageUrl,
          order: index,
          points: _items[index].points,
        );
        
        _items[index - 1] = TimelineItem(
          id: _items[index - 1].id,
          title: _items[index - 1].title,
          description: _items[index - 1].description,
          date: _items[index - 1].date,
          imageUrl: _items[index - 1].imageUrl,
          order: index - 1,
          points: _items[index - 1].points,
        );
      });
    }
  }
  
  void _moveItemDown(int index) {
    if (index < _items.length - 1) {
      setState(() {
        // Swap with the next item
        final temp = _items[index];
        _items[index] = _items[index + 1];
        _items[index + 1] = temp;
        
        // Update order values
        _items[index] = TimelineItem(
          id: _items[index].id,
          title: _items[index].title,
          description: _items[index].description,
          date: _items[index].date,
          imageUrl: _items[index].imageUrl,
          order: index,
          points: _items[index].points,
        );
        
        _items[index + 1] = TimelineItem(
          id: _items[index + 1].id,
          title: _items[index + 1].title,
          description: _items[index + 1].description,
          date: _items[index + 1].date,
          imageUrl: _items[index + 1].imageUrl,
          order: index + 1,
          points: _items[index + 1].points,
        );
      });
    }
  }
  
  void _editItem(int index) {
    final item = index >= 0 && index < _items.length ? _items[index] : null;
    
    // Set form controllers
    _itemTitleController.text = item?.title ?? '';
    _itemDescriptionController.text = item?.description ?? '';
    _itemImageUrlController.text = item?.imageUrl ?? '';
    _itemPointsController.text = (item?.points ?? 10).toString();
    _selectedDate = item?.date;
    _itemOrder = item?.order ?? _items.length;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(index == -1 ? 'Add Timeline Item' : 'Edit Timeline Item'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppInput(
                    controller: _itemTitleController,
                    label: 'Event Title',
                    placeholder: 'Enter event title',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    controller: _itemDescriptionController,
                    label: 'Description',
                    placeholder: 'Enter event description',
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    controller: _itemImageUrlController,
                    label: 'Image URL (Optional)',
                    placeholder: 'Enter image URL',
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: AppInput(
                        controller: TextEditingController(
                          text: _selectedDate != null 
                            ? DateFormat.yMMMd().format(_selectedDate!) 
                            : '',
                        ),
                        label: 'Date (Optional)',
                        placeholder: 'Select a date',
                        suffixIcon: Icons.calendar_today,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    controller: _itemPointsController,
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
                  if (_itemTitleController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a title')),
                    );
                    return;
                  }
                  if (_itemDescriptionController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a description')),
                    );
                    return;
                  }
                  
                  // Add or update item
                  this.setState(() {
                    final timelineItem = TimelineItem(
                      id: index >= 0 ? _items[index].id : null,
                      title: _itemTitleController.text,
                      description: _itemDescriptionController.text,
                      date: _selectedDate,
                      imageUrl: _itemImageUrlController.text.isEmpty ? null : _itemImageUrlController.text,
                      order: _itemOrder,
                      points: int.tryParse(_itemPointsController.text) ?? 10,
                    );
                    
                    if (index == -1) {
                      _items.add(timelineItem);
                    } else {
                      _items[index] = timelineItem;
                    }
                    
                    _updateMaxPoints();
                  });
                  
                  Navigator.pop(context);
                },
                child: Text(index == -1 ? 'Add' : 'Save'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _updateMaxPoints() {
    int total = 0;
    for (var item in _items) {
      total += item.points;
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
    
    // Validate timeline items
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].title.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item ${i + 1} is missing a title')),
        );
        return;
      }
      if (_items[i].description.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item ${i + 1} is missing a description')),
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
      
      final TimelineGame game = TimelineGame(
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
        items: _items,
        showDates: _showDates,
        timeLimit: _timeLimit,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Easy'),
                      const Text('Medium'),
                      const Text('Hard'),
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
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              'Show Dates',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Switch(
                              value: _showDates,
                              onChanged: (value) {
                                setState(() {
                                  _showDates = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppInput(
                          controller: TextEditingController(text: _timeLimit?.toString() ?? ''),
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
                          onChanged: (value) {
                            setState(() {
                              _timeLimit = value.isEmpty ? null : int.tryParse(value);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Timeline Items Card
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
                        'Timeline Items',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      AppButton(
                        text: '+ Add Item',
                        onPressed: () => _editItem(-1),
                        variant: ButtonVariant.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Arrange the items in the correct order. Students will have to place them in this sequence.',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Display timeline items
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          item.title.isEmpty ? 'Unnamed Event' : item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.description.isEmpty ? 'No description' : item
                                  .description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (item.date != null)
                              Text(
                                'Date: ${DateFormat.yMMMd().format(item.date!)}',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 12,
                                ),
                              ),
                            Text('Points: ${item.points}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_upward),
                              onPressed: index > 0 ? () => _moveItemUp(index) : null,
                              tooltip: 'Move Up',
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_downward),
                              onPressed: index < _items.length - 1 ? () => _moveItemDown(index) : null,
                              tooltip: 'Move Down',
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () => _duplicateItem(index),
                              tooltip: 'Duplicate',
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editItem(index),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeItem(index),
                              tooltip: 'Remove',
                            ),
                          ],
                        ),
                        isThreeLine: item.date != null,
                      );
                    },
                  ),
                  
                  if (_items.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.timeline_outlined,
                              size: 48,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No timeline items added yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AppButton(
                              text: 'Add an Item',
                              onPressed: () => _editItem(-1),
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
                  Text('Timeline Items: ${_items.length}'),
                  Text('XP Reward: $_xpReward'),
                  Text('Coin Reward: $_coinReward'),
                  Text('Show Dates: ${_showDates ? 'Yes' : 'No'}'),
                  if (_timeLimit != null) Text('Time Limit: $_timeLimit seconds'),
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