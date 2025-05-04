import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:learn_play_level_up_flutter/services/auth_service.dart';
import 'package:learn_play_level_up_flutter/services/firebase_service.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';
import 'package:learn_play_level_up_flutter/models/firebase_models.dart';
import 'package:go_router/go_router.dart';

class TeacherProfileEditPage extends StatefulWidget {
  const TeacherProfileEditPage({super.key});

  @override
  State<TeacherProfileEditPage> createState() => _TeacherProfileEditPageState();
}

class _TeacherProfileEditPageState extends State<TeacherProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Teacher data
  FirebaseUser? _teacher;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  List<int> _selectedGradeYears = [];
  List<String> _subjects = [];
  final TextEditingController _newSubjectController = TextEditingController();
  
  // Add a list of all available subjects
  final List<String> _allSubjects = [
    'Language Arts',
    'Literature',
    'Science',
    'Biology',
    'Chemistry',
    'Physics',
    'Environmental Science',
    'Math',
    'Geometry',
    'Algebra',
    'Pre-Calculus',
    'Calculus',
    'Statistics',
    'Social Studies',
    'History',
    'Geography',
    'Sociology',
    'Psychology',
    'Economics',
    'Business & Marketing',
    'Accounting',
    'Foreign Language',
    'IT',
    'Art',
    'Music',
  ];
  
  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _newSubjectController.dispose();
    super.dispose();
  }
  
  Future<void> _loadTeacherData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final authService = Provider.of<AuthService>(context, listen: false);
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      
      // Get current user
      final currentUser = await firebaseService.getCurrentUser();
      
      if (currentUser == null || currentUser.role != 'teacher') {
        setState(() {
          _errorMessage = 'You must be logged in as a teacher to edit your profile';
          _isLoading = false;
        });
        return;
      }
      
      // Set form values
      _nameController.text = currentUser.name;
      _emailController.text = currentUser.email;
      _selectedGradeYears = List<int>.from(currentUser.teachingGradeYears);
      _subjects = List<String>.from(currentUser.teachingSubjects);
      
      setState(() {
        _teacher = currentUser;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading teacher data: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Using the FirebaseService to update the profile
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      
      await firebaseService.updateTeacherProfile(
        teacherId: _teacher!.id,
        name: _nameController.text.trim(),
        teachingGradeYears: _selectedGradeYears,
        teachingSubjects: _subjects,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        
        // Navigate back to teacher dashboard
        GoRouter.of(context).go('/teacher/dashboard');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating profile: $e';
        _isLoading = false;
      });
    }
  }
  
  void _addSubject() {
    final newSubject = _newSubjectController.text.trim();
    if (newSubject.isNotEmpty && !_subjects.contains(newSubject)) {
      setState(() {
        _subjects.add(newSubject);
        _newSubjectController.clear();
      });
    }
  }
  
  void _removeSubject(String subject) {
    setState(() {
      _subjects.remove(subject);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          Navbar(
            isAuthenticated: _teacher != null,
            username: _teacher?.name,
            userRole: 'teacher',
            onSignOut: () async {
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.signOut();
              if (mounted) {
                GoRouter.of(context).go('/');
              }
            },
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _errorMessage!,
                              style: TextStyle(color: colorScheme.error),
                            ),
                            const SizedBox(height: 16),
                            AppButton(
                              text: 'Go to Home',
                              onPressed: () => GoRouter.of(context).go('/'),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Teacher Profile',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            AppCard(
                              padding: const EdgeInsets.all(24),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Personal Information
                                    Text(
                                      'Personal Information',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Name field
                                    TextFormField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                        labelText: 'Full Name',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Please enter your name';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Email field (readonly)
                                    TextFormField(
                                      controller: _emailController,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        labelText: 'Email (cannot be changed)',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: colorScheme.surfaceContainerHighest,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    
                                    // Teaching Information
                                    Text(
                                      'Teaching Information',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Grade years
                                    Text(
                                      'Grade Levels You Teach',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    Wrap(
                                      spacing: 8,
                                      children: List.generate(13, (index) {
                                        final gradeYear = index;
                                        final isSelected = _selectedGradeYears.contains(gradeYear);
                                        
                                        return FilterChip(
                                          label: Text(
                                            gradeYear == 0 ? 'K' : gradeYear.toString(),
                                          ),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            setState(() {
                                              if (selected) {
                                                _selectedGradeYears.add(gradeYear);
                                              } else {
                                                _selectedGradeYears.remove(gradeYear);
                                              }
                                            });
                                          },
                                          backgroundColor: colorScheme.surfaceContainerHighest,
                                          selectedColor: colorScheme.primaryContainer,
                                          checkmarkColor: colorScheme.primary,
                                        );
                                      }),
                                    ),
                                    
                                    if (_selectedGradeYears.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          'Please select at least one grade level',
                                          style: TextStyle(
                                            color: colorScheme.error,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    
                                    const SizedBox(height: 24),
                                    
                                    // Subjects
                                    Text(
                                      'Subjects You Teach',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Dropdown for subject selection
                                    DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: 'Select a Subject',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      items: _allSubjects
                                          .map((subject) => DropdownMenuItem<String>(
                                                value: subject,
                                                enabled: !_subjects.contains(subject),
                                                child: Text(
                                                  subject,
                                                  style: TextStyle(
                                                    color: _subjects.contains(subject)
                                                        ? colorScheme.onSurface.withOpacity(0.5)
                                                        : null,
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        if (value != null && !_subjects.contains(value)) {
                                          setState(() {
                                            _subjects.add(value);
                                          });
                                        }
                                      },
                                      hint: const Text('Select a subject to add'),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Subject list
                                    if (_subjects.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: Text(
                                          'Please add at least one subject',
                                          style: TextStyle(
                                            color: colorScheme.error,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    
                                    // Existing subjects
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _subjects.map((subject) {
                                        return Chip(
                                          label: Text(subject),
                                          deleteIcon: const Icon(Icons.close, size: 18),
                                          onDeleted: () => _removeSubject(subject),
                                        );
                                      }).toList(),
                                    ),
                                    
                                    const SizedBox(height: 32),
                                    
                                    // Save Button
                                    Center(
                                      child: AppButton(
                                        text: 'Save Profile',
                                        leadingIcon: Icons.save,
                                        isLoading: _isLoading,
                                        onPressed: _selectedGradeYears.isEmpty || _subjects.isEmpty
                                            ? null
                                            : _saveProfile,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
} 