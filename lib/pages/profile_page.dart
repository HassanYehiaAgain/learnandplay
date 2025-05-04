import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/input.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:learn_play_level_up_flutter/services/auth_service.dart';
import 'package:learn_play_level_up_flutter/services/firebase_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String _role = 'student';
  
  // For teacher profiles
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
  
  List<String> _selectedSubjects = [];
  
  // Grade years
  final List<int> _allGradeYears = List<int>.generate(13, (index) => index + 1);
  int? _studentGradeYear;
  List<int> _teachingGradeYears = [];
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Load user data
  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);

    if (authService.currentUser == null) {
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final firebaseUser = await firebaseService.getCurrentUser();
      
      if (firebaseUser != null) {
        setState(() {
          _nameController.text = firebaseUser.name;
          _role = firebaseUser.role;
          
          if (_role == 'teacher') {
            _selectedSubjects = List<String>.from(firebaseUser.teachingSubjects);
            _teachingGradeYears = List<int>.from(firebaseUser.teachingGradeYears);
          } else {
            _studentGradeYear = firebaseUser.studentGradeYear;
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Save profile updates
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    
    final authService = Provider.of<AuthService>(context, listen: false);
    
    try {
      final Map<String, dynamic> userData = {
        'name': _nameController.text,
      };
      
      if (_role == 'teacher') {
        userData['teachingSubjects'] = _selectedSubjects;
        userData['teachingGradeYears'] = _teachingGradeYears;
      } else if (_role == 'student' && _studentGradeYear != null) {
        // Handle student grade year update
        await authService.updateStudentGradeYear(
          authService.currentUser!.id, 
          _studentGradeYear!
        );
      }
      
      final success = await authService.updateProfile(userData);
      
      if (success) {
        setState(() {
          _successMessage = 'Profile updated successfully!';
        });
      } else {
        setState(() {
          _errorMessage = authService.error ?? 'Failed to update profile.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating profile: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 768;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          const Navbar(isAuthenticated: true),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: isSmallScreen ? null : 600,
                  margin: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 20 : 0,
                    vertical: 40,
                  ),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: AppGradients.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: AppGradients.purpleToPink,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ).animate()
                         .fadeIn(duration: 600.ms)
                         .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),
                        const SizedBox(height: 24),
                        Text(
                          'Profile Settings',
                          style: TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 22,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ).animate()
                         .fadeIn(duration: 600.ms, delay: 200.ms),
                        const SizedBox(height: 32),
                        
                        // Name field
                        AppInput(
                          controller: _nameController,
                          label: 'Full Name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Role specific fields
                        if (_role == 'student') _buildStudentFields(),
                        if (_role == 'teacher') _buildTeacherFields(),
                        
                        // Error message
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: colorScheme.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        // Success message
                        if (_successMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _successMessage!,
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 32),
                        
                        // Submit button
                        AppButton(
                          text: 'Save Changes',
                          variant: ButtonVariant.gradient,
                          isLoading: _isLoading,
                          onPressed: _saveProfile,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Student-specific fields
  Widget _buildStudentFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grade Year',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        
        DropdownButtonFormField<int>(
          value: _studentGradeYear,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          items: _allGradeYears.map((grade) {
            return DropdownMenuItem<int>(
              value: grade,
              child: Text(
                grade == 1 ? '1st Grade' :
                grade == 2 ? '2nd Grade' :
                grade == 3 ? '3rd Grade' :
                '$grade\th Grade',
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _studentGradeYear = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a grade year';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
  
  // Teacher-specific fields
  Widget _buildTeacherFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subjects You Teach',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        
        // Multi-select chips for subjects
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allSubjects.map((subject) {
            final isSelected = _selectedSubjects.contains(subject);
            return FilterChip(
              label: Text(subject),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSubjects.add(subject);
                  } else {
                    _selectedSubjects.remove(subject);
                  }
                });
              },
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.primary,
            );
          }).toList(),
        ),
        
        if (_selectedSubjects.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Please select at least one subject',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],
        
        const SizedBox(height: 24),
        
        Text(
          'Grade Years You Teach',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        
        // Multi-select chips for grade years
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allGradeYears.map((grade) {
            final isSelected = _teachingGradeYears.contains(grade);
            return FilterChip(
              label: Text(
                grade == 1 ? '1st Grade' :
                grade == 2 ? '2nd Grade' :
                grade == 3 ? '3rd Grade' :
                '$grade\th Grade',
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _teachingGradeYears.add(grade);
                  } else {
                    _teachingGradeYears.remove(grade);
                  }
                });
              },
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.primary,
            );
          }).toList(),
        ),
        
        if (_teachingGradeYears.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Please select at least one grade year',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],
        
        const SizedBox(height: 24),
      ],
    );
  }
} 