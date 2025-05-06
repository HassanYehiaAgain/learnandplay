import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/models/game_models.dart' as game_models;
import 'package:learn_play_level_up_flutter/services/game_templates_provider.dart';
import 'package:learn_play_level_up_flutter/widgets/common/image_upload.dart';

class DragDropCategoriesCreationScreen extends StatefulWidget {
  const DragDropCategoriesCreationScreen({Key? key}) : super(key: key);

  @override
  _DragDropCategoriesCreationScreenState createState() => _DragDropCategoriesCreationScreenState();
}

class _DragDropCategoriesCreationScreenState extends State<DragDropCategoriesCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryNameController = TextEditingController();
  final _categoryDescriptionController = TextEditingController();
  final _itemContentController = TextEditingController();
  final List<game_models.CategoryItem> _categories = [];
  final List<game_models.DraggableItem> _items = [];
  bool _showCategoryDescriptions = true;
  bool _immediateCorrectnessFeedback = true;
  int? _timeLimit;
  int _estimatedDuration = 10;
  int _xpReward = 100;
  int _coinReward = 50;
  int _maxPoints = 100;
  Color _selectedColor = Colors.blue;
  String _selectedContentType = 'text';
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedColor = Colors.blue;
    _selectedContentType = 'text';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryNameController.dispose();
    _categoryDescriptionController.dispose();
    _itemContentController.dispose();
    super.dispose();
  }

  void _addCategory() {
    setState(() {
      _categories.add(game_models.CategoryItem(
        name: _categoryNameController.text,
        description: _categoryDescriptionController.text,
        color: _selectedColor,
      ));
      _categoryNameController.clear();
      _categoryDescriptionController.clear();
      _selectedColor = Colors.blue;
    });
  }

  void _removeCategory(int index) {
    setState(() {
      final removedCategory = _categories[index];
      _categories.removeAt(index);
      // Remove items associated with this category
      _items.removeWhere((item) => item.correctCategoryId == removedCategory.id);
    });
  }

  void _updateCategory(int index, game_models.CategoryItem category) {
    setState(() {
      _categories[index] = category;
    });
  }

  void _addItem() {
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one category first')),
      );
      return;
    }

    setState(() {
      _items.add(game_models.DraggableItem(
        content: _itemContentController.text,
        contentType: _selectedContentType,
        correctCategoryId: _selectedCategoryId ?? _categories.first.id,
      ));
      _itemContentController.clear();
      _selectedContentType = 'text';
      _selectedCategoryId = null;
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _updateItem(int index, game_models.DraggableItem item) {
    setState(() {
      _items[index] = item;
    });
  }

  Future<void> _saveGame() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one category')),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    final game = DragDropCategoriesGame(
      title: _titleController.text,
      description: _descriptionController.text,
      teacherId: Provider.of<GameTemplatesProvider>(context, listen: false).currentUser!.id,
      subjectId: Provider.of<GameTemplatesProvider>(context, listen: false).selectedSubject!.id,
      gradeYear: Provider.of<GameTemplatesProvider>(context, listen: false).selectedGradeYear!,
      createdAt: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 7)),
      estimatedDuration: _estimatedDuration,
      tags: ['drag_drop', 'categories'],
      maxPoints: _maxPoints,
      xpReward: _xpReward,
      coinReward: _coinReward,
      categories: _categories,
      items: _items,
      showCategoryDescriptions: _showCategoryDescriptions,
      immediateCorrectnessFeedback: _immediateCorrectnessFeedback,
      timeLimit: _timeLimit,
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
        title: const Text('Create Drag & Drop Categories Game'),
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
                      title: const Text('Show Category Descriptions'),
                      value: _showCategoryDescriptions,
                      onChanged: (value) {
                        setState(() {
                          _showCategoryDescriptions = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Immediate Correctness Feedback'),
                      value: _immediateCorrectnessFeedback,
                      onChanged: (value) {
                        setState(() {
                          _immediateCorrectnessFeedback = value;
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
                          'Categories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addCategory,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        return _CategoryFormItem(
                          category: _categories[index],
                          onChanged: (category) => _updateCategory(index, category),
                          onRemove: () => _removeCategory(index),
                        );
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
                          'Items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addItem,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        return _DraggableItemFormItem(
                          item: _items[index],
                          categories: _categories,
                          onChanged: (item) => _updateItem(index, item),
                          onRemove: () => _removeItem(index),
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

class _CategoryFormItem extends StatefulWidget {
  final game_models.CategoryItem category;
  final Function(game_models.CategoryItem) onChanged;
  final VoidCallback onRemove;

  const _CategoryFormItem({
    Key? key,
    required this.category,
    required this.onChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  __CategoryFormItemState createState() => __CategoryFormItemState();
}

class __CategoryFormItemState extends State<_CategoryFormItem> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _descriptionController = TextEditingController(text: widget.category.description);
    _color = widget.category.color;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateCategory() {
    widget.onChanged(game_models.CategoryItem(
      id: widget.category.id,
      name: _nameController.text,
      description: _descriptionController.text,
      color: _color,
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
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _updateCategory(),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () async {
                    final color = await showDialog<Color>(
                      context: context,
                      builder: (context) => ColorPickerDialog(
                        initialColor: _color,
                      ),
                    );
                    if (color != null) {
                      setState(() {
                        _color = color;
                      });
                      _updateCategory();
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _color,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
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
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _updateCategory(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraggableItemFormItem extends StatefulWidget {
  final game_models.DraggableItem item;
  final List<game_models.CategoryItem> categories;
  final Function(game_models.DraggableItem) onChanged;
  final VoidCallback onRemove;

  const _DraggableItemFormItem({
    Key? key,
    required this.item,
    required this.categories,
    required this.onChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  __DraggableItemFormItemState createState() => __DraggableItemFormItemState();
}

class __DraggableItemFormItemState extends State<_DraggableItemFormItem> {
  late TextEditingController _contentController;
  late TextEditingController _hintController;
  late String _contentType;
  late String _correctCategoryId;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.item.content);
    _hintController = TextEditingController(text: widget.item.hint);
    _contentType = widget.item.contentType;
    _correctCategoryId = widget.item.correctCategoryId;
  }

  @override
  void dispose() {
    _contentController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  void _updateItem() {
    widget.onChanged(game_models.DraggableItem(
      id: widget.item.id,
      content: _contentController.text,
      contentType: _contentType,
      correctCategoryId: _correctCategoryId,
      hint: _hintController.text.isEmpty ? null : _hintController.text,
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
                        value: _contentType,
                        decoration: const InputDecoration(
                          labelText: 'Content Type',
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
                          if (value != null) {
                            setState(() {
                              _contentType = value;
                              _contentController.clear();
                            });
                            _updateItem();
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      if (_contentType == 'text')
                        TextFormField(
                          controller: _contentController,
                          decoration: const InputDecoration(
                            labelText: 'Item Content',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => _updateItem(),
                        )
                      else
                        ImageUploadField(
                          onImageSelected: (url) {
                            _contentController.text = url;
                            _updateItem();
                          },
                        ),
                    ],
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
            DropdownButtonFormField<String>(
              value: _correctCategoryId,
              decoration: const InputDecoration(
                labelText: 'Correct Category',
                border: OutlineInputBorder(),
              ),
              items: widget.categories.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _correctCategoryId = value;
                  });
                  _updateItem();
                }
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _hintController,
              decoration: const InputDecoration(
                labelText: 'Hint (optional)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _updateItem(),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  const ColorPickerDialog({
    Key? key,
    required this.initialColor,
  }) : super(key: key);

  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a Color'),
      content: SingleChildScrollView(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...Colors.primaries.map((color) {
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(
                      color: _selectedColor == color
                          ? Colors.black
                          : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedColor),
          child: const Text('Select'),
        ),
      ],
    );
  }
} 