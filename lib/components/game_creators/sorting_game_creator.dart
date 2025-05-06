import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';
import 'package:learn_play_level_up_flutter/components/ui/input.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class SortingGameCreator extends StatefulWidget {
  final Function(SortingGame) onGameCreated;
  final String teacherId;
  final String subjectId;
  final int gradeYear;
  final SortingGame? existingGame; // For editing an existing game

  const SortingGameCreator({
    super.key,
    required this.onGameCreated,
    required this.teacherId,
    required this.subjectId,
    required this.gradeYear,
    this.existingGame,
  });

  @override
  State<SortingGameCreator> createState() => _SortingGameCreatorState();
}

class _SortingGameCreatorState extends State<SortingGameCreator> {
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
  int? _timeLimit;
  bool _allowMultipleCategories = false;
  
  // Categories and items
  List<SortingCategory> _categories = [];
  List<SortingItem> _items = [];
  
  bool _isLoading = false;
  final _tagController = TextEditingController();
  
  // Category form controllers
  final _categoryNameController = TextEditingController();
  final _categoryDescriptionController = TextEditingController();
  Color _selectedColor = Colors.blue;
  
  // Item form controllers
  final _itemTextController = TextEditingController();
  final _itemPointsController = TextEditingController();
  final _itemImageUrlController = TextEditingController();
  List<String> _selectedCategoryIds = [];
  
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
      _categories = List.from(widget.existingGame!.categories);
      _items = List.from(widget.existingGame!.items);
      _timeLimit = widget.existingGame!.timeLimit;
      _allowMultipleCategories = widget.existingGame!.allowMultipleCategories;
    } else {
      // Add initial empty category
      _addNewCategory();
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    _categoryNameController.dispose();
    _categoryDescriptionController.dispose();
    _itemTextController.dispose();
    _itemPointsController.dispose();
    _itemImageUrlController.dispose();
    super.dispose();
  }
  
  void _addNewCategory() {
    setState(() {
      _categories.add(
        SortingCategory(
          name: '',
          description: '',
          color: _getRandomColor(),
        ),
      );
    });
  }
  
  Color _getRandomColor() {
    final List<Color> colors = [
      Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
      Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
      Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
      Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    ];
    return colors[DateTime.now().millisecondsSinceEpoch % colors.length];
  }
  
  void _removeCategory(int index) {
    final categoryId = _categories[index].id;
    
    // Remove category and update items that reference it
    setState(() {
      _categories.removeAt(index);
      
      // Update items that reference this category
      for (int i = 0; i < _items.length; i++) {
        if (_items[i].correctCategoryIds.contains(categoryId)) {
          List<String> updatedCategoryIds = List.from(_items[i].correctCategoryIds);
          updatedCategoryIds.remove(categoryId);
          
          _items[i] = SortingItem(
            id: _items[i].id,
            text: _items[i].text,
            imageUrl: _items[i].imageUrl,
            correctCategoryIds: updatedCategoryIds,
            points: _items[i].points,
          );
        }
      }
      
      _updateMaxPoints();
    });
  }
  
  void _editCategory(int index) {
    _categoryNameController.text = _categories[index].name;
    _categoryDescriptionController.text = _categories[index].description;
    _selectedColor = _categories[index].color;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == -1 ? 'Add Category' : 'Edit Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppInput(
                controller: _categoryNameController,
                label: 'Category Name',
                placeholder: 'Enter category name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppInput(
                controller: _categoryDescriptionController,
                label: 'Description',
                placeholder: 'Enter category description',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text('Category Color', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildColorPicker(),
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
              setState(() {
                if (index == -1) {
                  // Adding new category
                  _categories.add(
                    SortingCategory(
                      name: _categoryNameController.text,
                      description: _categoryDescriptionController.text,
                      color: _selectedColor,
                    ),
                  );
                } else {
                  // Updating existing category
                  _categories[index] = SortingCategory(
                    id: _categories[index].id,
                    name: _categoryNameController.text,
                    description: _categoryDescriptionController.text,
                    color: _selectedColor,
                  );
                }
              });
              
              // Clear controllers
              _categoryNameController.clear();
              _categoryDescriptionController.clear();
              
              Navigator.pop(context);
            },
            child: Text(index == -1 ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildColorPicker() {
    final List<Color> colors = [
      Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
      Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
      Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
      Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    ];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
            Navigator.pop(context);
            _editCategory(-1); // Re-open dialog with selected color
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: _selectedColor == color ? Colors.white : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  void _addNewItem() {
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one category first')),
      );
      return;
    }
    
    // Reset form controllers
    _itemTextController.clear();
    _itemPointsController.text = '10';
    _itemImageUrlController.clear();
    _selectedCategoryIds = [];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Item'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppInput(
                    controller: _itemTextController,
                    label: 'Item Text',
                    placeholder: 'Enter item text',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter item text';
                      }
                      return null;
                    },
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
                  const SizedBox(height: 16),
                  AppInput(
                    controller: _itemImageUrlController,
                    label: 'Image URL (Optional)',
                    placeholder: 'Enter image URL',
                  ),
                  const SizedBox(height: 16),
                  Text('Correct Categories', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ..._categories.map((category) {
                    return CheckboxListTile(
                      title: Text(category.name),
                      value: _selectedCategoryIds.contains(category.id),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedCategoryIds.add(category.id);
                          } else {
                            _selectedCategoryIds.remove(category.id);
                          }
                        });
                      },
                      activeColor: category.color,
                    );
                  }).toList(),
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
                  if (_itemTextController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter item text')),
                    );
                    return;
                  }
                  if (_selectedCategoryIds.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select at least one category')),
                    );
                    return;
                  }
                  
                  // Add new item
                  this.setState(() {
                    _items.add(
                      SortingItem(
                        text: _itemTextController.text,
                        imageUrl: _itemImageUrlController.text.isEmpty ? null : _itemImageUrlController.text,
                        correctCategoryIds: List.from(_selectedCategoryIds),
                        points: int.tryParse(_itemPointsController.text) ?? 10,
                      ),
                    );
                    _updateMaxPoints();
                  });
                  
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _editItem(int index) {
    final item = _items[index];
    
    // Set form controllers
    _itemTextController.text = item.text;
    _itemPointsController.text = item.points.toString();
    _itemImageUrlController.text = item.imageUrl ?? '';
    _selectedCategoryIds = List.from(item.correctCategoryIds);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Item'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppInput(
                    controller: _itemTextController,
                    label: 'Item Text',
                    placeholder: 'Enter item text',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter item text';
                      }
                      return null;
                    },
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
                  const SizedBox(height: 16),
                  AppInput(
                    controller: _itemImageUrlController,
                    label: 'Image URL (Optional)',
                    placeholder: 'Enter image URL',
                  ),
                  const SizedBox(height: 16),
                  Text('Correct Categories', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ..._categories.map((category) {
                    return CheckboxListTile(
                      title: Text(category.name),
                      value: _selectedCategoryIds.contains(category.id),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedCategoryIds.add(category.id);
                          } else {
                            _selectedCategoryIds.remove(category.id);
                          }
                        });
                      },
                      activeColor: category.color,
                    );
                  }).toList(),
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
                  if (_itemTextController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter item text')),
                    );
                    return;
                  }
                  if (_selectedCategoryIds.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select at least one category')),
                    );
                    return;
                  }
                  
                  // Update item
                  this.setState(() {
                    _items[index] = SortingItem(
                      id: item.id,
                      text: _itemTextController.text,
                      imageUrl: _itemImageUrlController.text.isEmpty ? null : _itemImageUrlController.text,
                      correctCategoryIds: List.from(_selectedCategoryIds),
                      points: int.tryParse(_itemPointsController.text) ?? 10,
                    );
                    _updateMaxPoints();
                  });
                  
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _updateMaxPoints();
    });
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
    
    // Validate categories
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one category')),
      );
      return;
    }
    
    // Validate categories have names
    for (var i = 0; i < _categories.length; i++) {
      if (_categories[i].name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category ${i + 1} needs a name')),
        );
        return;
      }
    }
    
    // Validate items
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Update max points before creating the game
      _updateMaxPoints();
      
      final SortingGame game = SortingGame(
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
        categories: _categories,
        items: _items,
        timeLimit: _timeLimit,
        allowMultipleCategories: _allowMultipleCategories,
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Allow Multiple Categories',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Switch(
                              value: _allowMultipleCategories,
                              onChanged: (value) {
                                setState(() {
                                  _allowMultipleCategories = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Categories Card
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
                        'Categories',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      AppButton(
                        text: '+ Add Category',
                        onPressed: () => _editCategory(-1),
                        variant: ButtonVariant.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_categories.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Add categories for your sorting game',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: category.color,
                            child: const Icon(Icons.category, color: Colors.white),
                          ),
                          title: Text(category.name.isEmpty ? 'Unnamed Category' : category.name),
                          subtitle: Text(category.description.isEmpty ? 'No description' : category.description),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editCategory(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _removeCategory(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Items Card
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
                        'Items to Sort',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      AppButton(
                        text: '+ Add Item',
                        onPressed: _addNewItem,
                        variant: ButtonVariant.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_items.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Add items for students to sort into categories',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _items.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        final itemCategories = _categories
                            .where((c) => item.correctCategoryIds.contains(c.id))
                            .toList();
                        
                        return ListTile(
                          leading: item.imageUrl != null && item.imageUrl!.isNotEmpty
                              ? Image.network(
                                  item.imageUrl!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image_not_supported);
                                  },
                                )
                              : const Icon(Icons.text_fields),
                          title: Text(item.text),
                          subtitle: Row(
                            children: [
                              Text('${item.points} points'),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: itemCategories.map((category) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: category.color.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        category.name,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: category.color,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editItem(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _removeItem(index),
                              ),
                            ],
                          ),
                        );
                      },
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
                  Text('Categories: ${_categories.length}'),
                  Text('Items: ${_items.length}'),
                  Text('XP Reward: $_xpReward'),
                  Text('Coin Reward: $_coinReward'),
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