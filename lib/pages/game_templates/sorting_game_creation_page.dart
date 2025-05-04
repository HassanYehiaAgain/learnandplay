import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/pages/game_templates/template_creation_base_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class SortingGameCreationPage extends StatefulWidget {
  const SortingGameCreationPage({super.key});

  @override
  State<SortingGameCreationPage> createState() => _SortingGameCreationPageState();
}

class _SortingGameCreationPageState extends State<SortingGameCreationPage> {
  final List<SortingGameItem> _items = [];
  final List<SortingGameCategory> _categories = [];
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _categoryDescriptionController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Game settings
  String _gameMode = 'sequence';
  bool _randomizeOrder = true;
  bool _showPositionNumbers = true;
  int _timeLimit = 300; // 5 minutes in seconds
  int _maxAttempts = 3;
  String? _instructions;
  
  @override
  void initState() {
    super.initState();
    _positionController.text = '1';
  }
  
  @override
  void dispose() {
    _itemController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _categoryDescriptionController.dispose();
    _positionController.dispose();
    super.dispose();
  }
  
  void _addItem() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _items.add(
          SortingGameItem(
            id: const Uuid().v4(),
            content: _itemController.text.trim(),
            correctPosition: int.tryParse(_positionController.text) ?? 1,
            description: _descriptionController.text.trim(),
          ),
        );
        
        // Clear the form
        _itemController.clear();
        _descriptionController.clear();
        _positionController.text = (_items.length + 1).toString();
      });
    }
  }
  
  void _addCategory() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _categories.add(
          SortingGameCategory(
            id: const Uuid().v4(),
            name: _categoryController.text.trim(),
            description: _categoryDescriptionController.text.trim(),
          ),
        );
        
        // Clear the form
        _categoryController.clear();
        _categoryDescriptionController.clear();
      });
    }
  }
  
  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      // Update position numbers
      for (var i = 0; i < _items.length; i++) {
        _items[i] = SortingGameItem(
          id: _items[i].id,
          content: _items[i].content,
          correctPosition: i + 1,
          description: _items[i].description,
        );
      }
    });
  }
  
  void _removeCategory(int index) {
    setState(() {
      _categories.removeAt(index);
    });
  }
  
  Future<bool> _saveToFirebase(BuildContext context, {
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
    try {
      // Create the game object
      final game = SortingGame(
        title: title,
        description: description,
        teacherId: teacherId,
        subjectId: subjectId,
        gradeYear: gradeYear,
        createdAt: DateTime.now(),
        dueDate: dueDate,
        isActive: true,
        estimatedDuration: (_timeLimit / 60).ceil(),
        tags: ['sorting', _gameMode == 'sequence' ? 'sequence' : 'categorization'],
        maxPoints: maxPoints,
        xpReward: xpReward,
        coinReward: coinReward,
        gameMode: _gameMode,
        items: _items,
        categories: _gameMode == 'category' ? _categories : null,
        randomizeOrder: _randomizeOrder,
        showPositionNumbers: _showPositionNumbers,
        timeLimit: _timeLimit,
        maxAttempts: _maxAttempts,
        instructions: _instructions,
        coverImage: null,
      );
      
      // Save to Firestore
      await FirebaseFirestore.instance.collection('games').add(game.toFirestore());
      return true;
    } catch (e) {
      print('Error saving game: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving game: $e')),
      );
      return false;
    }
  }
  
  Widget _buildSortingGameContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sorting Game Content',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Game mode selection
          Text(
            'Game Mode',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment<String>(
                value: 'sequence',
                label: Text('Sequence'),
                icon: Icon(Icons.sort),
              ),
              ButtonSegment<String>(
                value: 'category',
                label: Text('Categories'),
                icon: Icon(Icons.category),
              ),
            ],
            selected: {_gameMode},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _gameMode = newSelection.first;
              });
            },
          ),
          const SizedBox(height: 24),
          
          // Game settings
          Text(
            'Game Settings',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text('Randomize Order'),
            subtitle: const Text('Items will appear in random order to students'),
            value: _randomizeOrder,
            onChanged: (value) {
              setState(() {
                _randomizeOrder = value;
              });
            },
          ),
          
          if (_gameMode == 'sequence')
            SwitchListTile(
              title: const Text('Show Position Numbers'),
              subtitle: const Text('Display position numbers in the sequence'),
              value: _showPositionNumbers,
              onChanged: (value) {
                setState(() {
                  _showPositionNumbers = value;
                });
              },
            ),
          
          ListTile(
            title: const Text('Time Limit'),
            subtitle: Text('${(_timeLimit / 60).floor()} minutes'),
          ),
          Slider(
            value: _timeLimit.toDouble(),
            min: 60,
            max: 1800,
            divisions: 29,
            label: '${(_timeLimit / 60).floor()} minutes',
            onChanged: (value) {
              setState(() {
                _timeLimit = value.toInt();
              });
            },
          ),
          
          ListTile(
            title: const Text('Maximum Attempts'),
            subtitle: Text('$_maxAttempts attempts'),
          ),
          Slider(
            value: _maxAttempts.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: '$_maxAttempts attempts',
            onChanged: (value) {
              setState(() {
                _maxAttempts = value.toInt();
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // Categories form (only for category mode)
          if (_gameMode == 'category') ...[
            Text(
              'Categories',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      hintText: 'Enter a category name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a category name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _categoryDescriptionController,
                    decoration: InputDecoration(
                      labelText: 'Category Description (Optional)',
                      hintText: 'Enter a description for this category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Category'),
                    onPressed: _addCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Categories list
            if (_categories.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(category.name),
                      subtitle: category.description != null
                          ? Text(category.description!)
                          : null,
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: colorScheme.error),
                        onPressed: () => _removeCategory(index),
                      ),
                    ),
                  );
                },
              ),
            
            const SizedBox(height: 24),
          ],
          
          // Items form
          Text(
            _gameMode == 'sequence' ? 'Sequence Items' : 'Items to Categorize',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _itemController,
                  decoration: InputDecoration(
                    labelText: 'Item Text',
                    hintText: 'Enter the item text',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter item text';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                if (_gameMode == 'sequence')
                  TextFormField(
                    controller: _positionController,
                    decoration: InputDecoration(
                      labelText: 'Correct Position',
                      hintText: 'Enter the correct position number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a position number';
                      }
                      final position = int.tryParse(value);
                      if (position == null || position <= 0) {
                        return 'Please enter a valid position number';
                      }
                      return null;
                    },
                  ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description/Explanation (Optional)',
                    hintText: 'Enter a description or explanation for this item',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Items list
          if (_items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No items added yet. Add at least one item to create a game.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primary.withOpacity(0.2),
                      child: Text(
                        _gameMode == 'sequence'
                            ? item.correctPosition.toString()
                            : item.content.substring(0, 1).toUpperCase(),
                      ),
                    ),
                    title: Text(item.content),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.description != null)
                          Text(item.description!),
                        if (_gameMode == 'sequence')
                          Text(
                            'Position: ${item.correctPosition}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: colorScheme.error),
                      onPressed: () => _removeItem(index),
                    ),
                  ),
                );
              },
            ),
          
          const SizedBox(height: 24),
          
          // Instructions
          Text(
            'Instructions (Optional)',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Enter game instructions for students',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 3,
            onChanged: (value) {
              setState(() {
                _instructions = value.trim();
              });
            },
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return TemplateCreationBasePage(
      type: 'sorting_game',
      title: 'Sorting Game',
      icon: Icons.sort,
      color: Colors.orange,
      contentBuilder: _buildSortingGameContent,
      saveToFirebase: _saveToFirebase,
      validateForm: () {
        if (_items.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please add at least one item')),
          );
          return false;
        }
        if (_gameMode == 'category' && _categories.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please add at least one category')),
          );
          return false;
        }
        return true;
      },
    );
  }
} 