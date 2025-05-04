import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';
import 'package:learn_play_level_up_flutter/services/auth_service.dart';
import 'package:learn_play_level_up_flutter/services/firebase_service.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/models/firebase_models.dart';
import 'package:learn_play_level_up_flutter/services/local_storage_service.dart';

typedef ContentBuilder = Widget Function(BuildContext context);
typedef SaveToFirebaseCallback = Future<bool> Function(
  BuildContext context, {
  required String title,
  required String description,
  required String teacherId,
  required String subjectId,
  required int gradeYear,
  required DateTime dueDate,
  required int maxPoints,
  required int xpReward,
  required int coinReward,
});
typedef ValidateFormCallback = bool Function();

class TemplateCreationBasePage extends StatefulWidget {
  final String type;
  final String title;
  final IconData icon;
  final Color color;
  final ContentBuilder? contentBuilder;
  final SaveToFirebaseCallback? saveToFirebase;
  final ValidateFormCallback? validateForm;
  
  const TemplateCreationBasePage({
    super.key,
    required this.type,
    required this.title,
    required this.icon,
    required this.color,
    this.contentBuilder,
    this.saveToFirebase,
    this.validateForm,
  });

  @override
  State<TemplateCreationBasePage> createState() => _TemplateCreationBasePageState();
}

class _TemplateCreationBasePageState extends State<TemplateCreationBasePage> {
  // Current step in the wizard
  int _currentStep = 0;
  
  // Form data
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // Selected values
  String? _selectedSubject;
  int _selectedGradeYear = 0;
  bool _enableTimeLimit = false;
  int _timeLimit = 10;
  int _maxPoints = 100;
  int _xpReward = 50;
  int _coinReward = 25;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _publishNow = true;
  
  // Loading state
  bool _isSaving = false;
  
  // Track if form has been modified
  bool _isFormModified = false;
  
  // Debug overlay
  bool _showDebugOverlay = false;
  
  // Add teacher data fields
  FirebaseUser? _teacher;
  List<Subject> _teacherSubjects = [];
  List<int> _teachingGradeYears = [];
  
  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }
  
  Future<void> _loadTeacherData() async {
    try {
      setState(() {
        _isSaving = true;
      });
      
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      final localStorageService = Provider.of<LocalStorageService>(context, listen: false);
      
      // Get current user
      final currentUser = await firebaseService.getCurrentUser();
      
      if (currentUser == null || currentUser.role != 'teacher') {
        setState(() {
          _isSaving = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must be logged in as a teacher to create games')),
          );
          GoRouter.of(context).go('/signin');
        }
        return;
      }
      
      // Set teacher data
      _teacher = currentUser;
      
      // Try to load teacher's subjects from Firebase first
      try {
        _teacherSubjects = await firebaseService.getTeacherSubjects(currentUser.id);
        // Save to local storage for offline use
        await localStorageService.saveTeacherSubjects(currentUser.id, _teacherSubjects);
      } catch (e) {
        // If Firebase fails, try local storage
        _teacherSubjects = await localStorageService.getTeacherSubjects(currentUser.id);
      }
      
      // Get teaching grade years
      _teachingGradeYears = List<int>.from(currentUser.teachingGradeYears);
      // Save to local storage for offline use
      await localStorageService.saveTeacherGradeYears(currentUser.id, _teachingGradeYears);
      
      // Set default selected grade year (first one if available)
      if (_teachingGradeYears.isNotEmpty) {
        _selectedGradeYear = _teachingGradeYears.first;
      }
      
      // Set default subject (first one if available)
      if (_teacherSubjects.isNotEmpty) {
        _selectedSubject = _teacherSubjects.first.id;
      }
      
      setState(() {
        _isSaving = false;
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading teacher data: $e')),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  void _markFormAsModified() {
    if (!_isFormModified) {
      setState(() {
        _isFormModified = true;
      });
    }
  }
  
  Future<bool> _onWillPop() async {
    if (!_isFormModified) {
      return true;
    }
    
    // Show confirmation dialog
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to leave this page?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DISCARD'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  void _toggleDebugOverlay() {
    setState(() {
      _showDebugOverlay = !_showDebugOverlay;
      if (_showDebugOverlay) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debug overlay enabled')),
        );
      }
    });
  }
  
  void _nextStep() {
    if (_currentStep < 3) {
      // Validate basic info step
      if (_currentStep == 0) {
        if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
          return;
        }
      }
      
      setState(() {
        _currentStep++;
      });
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }
  
  Future<void> _createGame() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      final localStorageService = Provider.of<LocalStorageService>(context, listen: false);
      
      // Create game instance
      final gameTemplate = _buildGameInstance();
      final game = EducationalGame(
        id: gameTemplate.id,
        title: _titleController.text,
        description: _descriptionController.text,
        coverImage: null,
        teacherId: _teacher!.id,
        subjectId: _selectedSubject ?? 'any',
        gradeYear: _selectedGradeYear,
        createdAt: DateTime.now(),
        dueDate: _dueDate,
        isActive: true,
        questions: [],
        difficulty: 1,
        estimatedDuration: 0,
        tags: [],
        maxPoints: _maxPoints,
      );
      
      // Try to save to Firebase first
      try {
        await widget.saveToFirebase!(
          context,
          title: _titleController.text,
          description: _descriptionController.text,
          teacherId: _teacher!.id,
          subjectId: _selectedSubject ?? 'any',
          gradeYear: _selectedGradeYear,
          dueDate: _dueDate,
          maxPoints: _maxPoints,
          xpReward: _xpReward,
          coinReward: _coinReward,
        );
      } catch (e) {
        // If Firebase fails, save locally
        await localStorageService.saveGame(game);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Game saved locally (offline mode)')),
          );
        }
      }
      
      setState(() {
        _isSaving = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Game created successfully!')),
        );
        
        // Navigate back to teacher dashboard
        GoRouter.of(context).go('/teacher/dashboard');
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating game: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Debug: Show loading indicator if still loading
    if (_isSaving) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // Debug: Show error if teacher/user is missing
    if (_teacher == null) {
      return Scaffold(
        body: Center(child: Text('Error: No teacher user loaded. Please sign in again.', style: TextStyle(color: Colors.red))),
      );
    }
    // Debug: Show error if no subjects
    if (_teacherSubjects.isEmpty) {
      return Scaffold(
        body: Center(child: Text('Error: No subjects found for this teacher. Please add a subject first.', style: TextStyle(color: Colors.red))),
      );
    }
    // Debug: Show error if no grade years
    if (_teachingGradeYears.isEmpty) {
      return Scaffold(
        body: Center(child: Text('Error: No grade years found for this teacher. Please set your teaching grade years in your profile.', style: TextStyle(color: Colors.red))),
      );
    }
    // Defensive: Fallback for step content
    Widget stepContent;
    try {
      stepContent = [
        _buildBasicInfoStep,
        widget.contentBuilder != null ? () => widget.contentBuilder!(context) : _buildDefaultGameContentStep,
        _buildSettingsStep,
        _buildReviewStep,
      ][_currentStep]();
    } catch (e, stack) {
      stepContent = Center(
        child: Text('Error rendering step: $e', style: TextStyle(color: Colors.red)),
      );
    }
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 768;
    
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        floatingActionButton: FloatingActionButton.small(
          onPressed: _toggleDebugOverlay,
          tooltip: 'Toggle debug overlay',
          child: const Icon(Icons.bug_report),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                const Navbar(isAuthenticated: true),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Add back button
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () {
                                GoRouter.of(context).go('/teacher/dashboard');
                              },
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Creating a new game',
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
                        
                        // Stepper indicator
                        Row(
                          children: [
                            for (int i = 0; i < 4; i++) ...[
                              _buildStepIndicator(i),
                              if (i < 3) Expanded(
                                child: Container(
                                  height: 2,
                                  color: i < _currentStep 
                                      ? widget.color
                                      : colorScheme.outline.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Current step content
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height - 300,
                          ),
                          child: SingleChildScrollView(
                            child: stepContent,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Navigation buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (_currentStep > 0) ...[
                              AppButton(
                                text: 'Back',
                                variant: ButtonVariant.outline,
                                onPressed: _previousStep,
                              ),
                              const SizedBox(width: 16),
                            ],
                            
                            AppButton(
                              text: _currentStep < 3 ? 'Next' : 'Create Game',
                              variant: ButtonVariant.gradient,
                              leadingIcon: _currentStep < 3 ? Icons.navigate_next : Icons.check,
                              onPressed: _isSaving ? null : (_currentStep < 3 ? _nextStep : _createGame),
                              isLoading: _isSaving,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Debug overlay
            if (_showDebugOverlay)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                    child: CustomPaint(
                      painter: _DebugOverlayPainter(),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DEBUG MODE - ${widget.title} Creation',
                              style: const TextStyle(
                                backgroundColor: Colors.red,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Current step: $_currentStep'),
                            Text('Form modified: $_isFormModified'),
                            Text('Title: ${_titleController.text}'),
                            Text('Subject: $_selectedSubject'),
                            Text('Grade: $_selectedGradeYear'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStepIndicator(int step) {
    final bool isCompleted = _currentStep > step;
    final bool isCurrent = _currentStep == step;
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isCompleted || isCurrent ? widget.color : Colors.transparent,
        border: Border.all(
          color: isCompleted || isCurrent ? widget.color : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 2,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isCompleted
            ? Icon(
                Icons.check,
                color: Colors.white,
                size: 18,
              )
            : Text(
                '${step + 1}',
                style: TextStyle(
                  color: isCurrent ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
  
  Widget _buildBasicInfoStep() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        onChanged: () => _markFormAsModified(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Game title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Game Title',
                hintText: 'Enter a title for your game',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Game description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter a description for your game',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Subject
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: _selectedSubject,
              items: _teacherSubjects.isNotEmpty 
                ? _teacherSubjects.map((subject) => 
                    DropdownMenuItem<String>(
                      value: subject.id,
                      child: Text(subject.name),
                    )
                  ).toList()
                : [const DropdownMenuItem<String>(value: '', child: Text('No subjects available'))],
              onChanged: (value) {
                setState(() {
                  _selectedSubject = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a subject';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Grade level
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Grade Level',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: _selectedGradeYear,
              items: _teachingGradeYears.map((gradeYear) =>
                DropdownMenuItem<int>(
                  value: gradeYear,
                  child: Text(gradeYear == 0 ? 'Kindergarten' : 'Grade $gradeYear'),
                )
              ).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedGradeYear = value;
                  });
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a grade level';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Due date picker
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    _dueDate = picked;
                  });
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Due Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat('MMMM d, yyyy').format(_dueDate),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDefaultGameContentStep() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Game Content',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'This template (${widget.title}) does not yet have a custom creation form. You can still proceed and set up the basic info, settings, and review steps.',
            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  widget.icon,
                  size: 64,
                  color: widget.color,
                ),
                const SizedBox(height: 16),
                Text(
                  'A custom creation form for "${widget.title}" will be available soon. For now, you can use the basic info and settings to create a placeholder game.',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Example placeholder fields
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Example Field',
                    hintText: 'This is a placeholder field',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Another Example',
                    hintText: 'More placeholder content',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsStep() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Game Settings',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Time limit
          SwitchListTile(
            title: Text(
              'Time Limit',
              style: theme.textTheme.titleMedium,
            ),
            subtitle: const Text('Set a time limit for completing the game'),
            value: _enableTimeLimit,
            activeColor: widget.color,
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
                    child: Text('$_timeLimit minutes'),
                  ),
                  Expanded(
                    flex: 2,
                    child: Slider(
                      value: _timeLimit.toDouble(),
                      min: 1,
                      max: 20,
                      divisions: 19,
                      activeColor: widget.color,
                      label: '$_timeLimit minutes',
                      onChanged: (value) {
                        setState(() {
                          _timeLimit = value.toInt();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          const Divider(),
          
          // Points & Rewards
          ListTile(
            title: Text(
              'Points & Rewards',
              style: theme.textTheme.titleMedium,
            ),
            subtitle: const Text('Set points and rewards for completing the game'),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Max Points',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    initialValue: _maxPoints.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _maxPoints = int.tryParse(value) ?? 100;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'XP Reward',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    initialValue: _xpReward.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _xpReward = int.tryParse(value) ?? 50;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Coin Reward',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    initialValue: _coinReward.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _coinReward = int.tryParse(value) ?? 25;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReviewStep() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Create',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Summary of the game
          Text(
            'Game Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.title, color: widget.color),
            title: const Text('Title'),
            subtitle: Text(_titleController.text.isNotEmpty 
                ? _titleController.text 
                : 'Sample ${widget.title} Game'),
          ),
          ListTile(
            leading: Icon(Icons.description, color: widget.color),
            title: const Text('Description'),
            subtitle: Text(_descriptionController.text.isNotEmpty 
                ? _descriptionController.text 
                : 'This is a sample game created using the ${widget.title} template.'),
          ),
          ListTile(
            leading: Icon(Icons.school, color: widget.color),
            title: const Text('Subject & Grade'),
            subtitle: Text('${_selectedSubject ?? 'Any Subject'} • ${_selectedGradeYear == 0 ? 'Kindergarten' : 'Grade $_selectedGradeYear'}'),
          ),
          if (_enableTimeLimit)
            ListTile(
              leading: Icon(Icons.timer, color: widget.color),
              title: const Text('Time Limit'),
              subtitle: Text('$_timeLimit minutes'),
            ),
          ListTile(
            leading: Icon(Icons.stars, color: widget.color),
            title: const Text('Rewards'),
            subtitle: Text('$_maxPoints points • $_xpReward XP • $_coinReward coins'),
          ),
          ListTile(
            leading: Icon(Icons.calendar_today, color: widget.color),
            title: const Text('Due Date'),
            subtitle: Text(DateFormat('MMMM d, yyyy').format(_dueDate)),
          ),
          
          const Divider(),
          
          // Publish options
          SwitchListTile(
            title: Text(
              'Publish Now',
              style: theme.textTheme.titleMedium,
            ),
            subtitle: const Text('Make this game available to students immediately'),
            value: _publishNow,
            activeColor: widget.color,
            onChanged: (value) {
              setState(() {
                _publishNow = value;
              });
            },
          ),
        ],
      ),
    );
  }
  
  GameTemplate _buildGameInstance() {
    // Create a concrete implementation based on the template type
    switch (widget.type) {
      case 'word_scramble':
        return WordScrambleGame(
          title: _titleController.text,
          description: _descriptionController.text,
          coverImage: null,
          teacherId: _teacher?.id ?? '',
          subjectId: _selectedSubject ?? '',
          gradeYear: _selectedGradeYear,
          createdAt: DateTime.now(),
          dueDate: _dueDate,
          isActive: true,
          estimatedDuration: _enableTimeLimit ? _timeLimit : 0,
          tags: [],
          maxPoints: _maxPoints,
          xpReward: _xpReward,
          coinReward: _coinReward,
          words: [], // Add empty words list to be filled by the specific creator
          caseSensitive: false,
        );
      
      case 'quiz_show':
        return QuizShowGame(
          title: _titleController.text,
          description: _descriptionController.text,
          coverImage: null,
          teacherId: _teacher?.id ?? '',
          subjectId: _selectedSubject ?? '',
          gradeYear: _selectedGradeYear,
          createdAt: DateTime.now(),
          dueDate: _dueDate,
          isActive: true,
          estimatedDuration: _enableTimeLimit ? _timeLimit : 0,
          tags: [],
          maxPoints: _maxPoints,
          xpReward: _xpReward,
          coinReward: _coinReward,
          categories: [], // Empty categories to be filled
          allowPartialPoints: false,
        );
        
      case 'sorting_game':
        return SortingGame(
          title: _titleController.text,
          description: _descriptionController.text,
          coverImage: null,
          teacherId: _teacher?.id ?? '',
          subjectId: _selectedSubject ?? '',
          gradeYear: _selectedGradeYear,
          createdAt: DateTime.now(),
          dueDate: _dueDate,
          isActive: true,
          estimatedDuration: _enableTimeLimit ? _timeLimit : 0,
          tags: [],
          maxPoints: _maxPoints,
          xpReward: _xpReward,
          coinReward: _coinReward,
          gameMode: 'sequence', // Default to sequence mode
          items: [],
          categories: [],
          timeLimit: _enableTimeLimit ? _timeLimit * 60 : null,
          allowMultipleCategories: false,
        );
        
      // Default to a WordScrambleGame for other types
      default:
        return WordScrambleGame(
          title: _titleController.text,
          description: _descriptionController.text,
          coverImage: null,
          teacherId: _teacher?.id ?? '',
          subjectId: _selectedSubject ?? '',
          gradeYear: _selectedGradeYear,
          createdAt: DateTime.now(),
          dueDate: _dueDate,
          isActive: true,
          estimatedDuration: _enableTimeLimit ? _timeLimit : 0,
          tags: [],
          maxPoints: _maxPoints,
          xpReward: _xpReward,
          coinReward: _coinReward,
          words: [], // Empty words list
          caseSensitive: false,
        );
    }
  }
}

class _DebugOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // Draw grid lines
    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }
    
    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DebugOverlayPainter oldDelegate) => false;
} 