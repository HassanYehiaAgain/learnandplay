import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/input.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:learn_play_level_up_flutter/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  String _selectedRole = 'student'; // Default role
  int _currentStep = 0;
  String _displayName = '';
  final String _avatarColor = '';
  
  // Updated and reorganized subject list
  final List<Map<String, List<String>>> _subjectGroups = [
    {
      'Language & Literature': [
        'Language Arts',
        'Literature',
      ]
    },
    {
      'Science': [
        'Biology',
        'Chemistry',
        'Physics',
        'Environmental Science',
        'Science',
      ]
    },
    {
      'Mathematics': [
        'Math',
        'Geometry',
        'Algebra',
        'Pre-Calculus',
        'Calculus',
        'Statistics',
      ]
    },
    {
      'Social Sciences': [
        'Social Studies',
        'History',
        'Geography',
        'Sociology',
        'Psychology',
      ]
    },
    {
      'Business & Economics': [
        'Economics',
        'Business & Marketing',
        'Accounting',
      ]
    },
    {
      'Arts & Other': [
        'Foreign Language',
        'IT',
        'Art',
        'Music',
      ]
    },
  ];
  
  final List<String> _selectedSubjects = [];
  
  // Get flattened list of all subjects
  List<String> get _allSubjects {
    final List<String> allSubjects = [];
    for (final group in _subjectGroups) {
      for (final subjects in group.values) {
        allSubjects.addAll(subjects);
      }
    }
    return allSubjects;
  }
  
  final List<Map<String, dynamic>> _avatars = [
    {'icon': Icons.person, 'color': Colors.blue},
    {'icon': Icons.person, 'color': Colors.purple},
    {'icon': Icons.person, 'color': Colors.green},
    {'icon': Icons.person, 'color': Colors.orange},
  ];
  
  // Grade years
  final List<String> _gradeYears = [
    'Kindergarten',
    '1st Grade',
    '2nd Grade',
    '3rd Grade',
    '4th Grade',
    '5th Grade',
    '6th Grade',
    '7th Grade',
    '8th Grade',
    '9th Grade',
    '10th Grade',
    '11th Grade',
    '12th Grade',
  ];
  
  String _selectedGradeYear = ''; // For students
  final List<String> _selectedGradeYears = []; // For teachers
  
  int _selectedAvatar = 0;
  
  @override
  void initState() {
    super.initState();
    // Add listeners to controllers
    _displayNameController.addListener(() {
      setState(() {
        _displayName = _displayNameController.text;
      });
    });
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }
  
  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      // Role selection is always valid
      return true;
    } else if (_currentStep == 1) {
      // Validate basic info form
      return _formKey.currentState!.validate();
    } else if (_currentStep == 2) {
      // Profile customization - ensure display name is set and grade selection
      if (_displayName.isEmpty) {
        return false;
      }
      
      // For students, ensure grade year is selected
      if (_selectedRole == 'student' && _selectedGradeYear.isEmpty) {
        return false;
      }
      
      // For teachers, ensure at least one grade year is selected
      if (_selectedRole == 'teacher' && _selectedGradeYears.isEmpty) {
        return false;
      }
      
      return true;
    }
    
    return true;
  }
  
  void _nextStep() {
    if (_validateCurrentStep()) {
      setState(() {
        if (_currentStep < 3) {
          _currentStep++;
        }
      });
    }
  }
  
  void _prevStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }
  
  Future<void> _handleRegister() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Get the AuthService instance
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Prepare role-specific data
      List<String>? teachingSubjects;
      List<int>? teachingGradeYears;
      int? studentGradeYear;
      
      if (_selectedRole == 'teacher') {
        teachingSubjects = _selectedSubjects;
        teachingGradeYears = _selectedGradeYears.map((grade) {
          // Convert grade year string to int (e.g., "3rd Grade" -> 3)
          if (grade == 'Kindergarten') return 0;
          
          // Extract the number from the grade year string
          final match = RegExp(r'(\d+)').firstMatch(grade);
          if (match != null) {
            return int.parse(match.group(1)!);
          }
          return 1; // Default to 1st grade if parsing fails
        }).toList();
      } else {
        // Extract grade year for student
        if (_selectedGradeYear == 'Kindergarten') {
          studentGradeYear = 0;
        } else {
          final match = RegExp(r'(\d+)').firstMatch(_selectedGradeYear);
          if (match != null) {
            studentGradeYear = int.parse(match.group(1)!);
          }
        }
      }
      
      // Validate required selections
      if (_selectedRole == 'teacher') {
        if (_selectedGradeYears.isEmpty) {
          setState(() {
            _errorMessage = 'Please select at least one grade year you teach.';
            _isLoading = false;
          });
          return;
        }
        
        if (_selectedSubjects.isEmpty) {
          setState(() {
            _errorMessage = 'Please select at least one subject you teach.';
            _isLoading = false;
          });
          return;
        }
      } else if (_selectedGradeYear.isEmpty) {
        setState(() {
          _errorMessage = 'Please select your grade year.';
          _isLoading = false;
        });
        return;
      }
      
      // Call the enhanced register method
      final success = await authService.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        role: _selectedRole,
        teachingSubjects: teachingSubjects,
        teachingGradeYears: teachingGradeYears,
        studentGradeYear: studentGradeYear,
      );
      
      if (!mounted) return;
      
      if (success) {
        // Registration and automatic login successful, navigate to dashboard
        if (_selectedRole == 'teacher') {
          GoRouter.of(context).go('/teacher/dashboard');
        } else {
          GoRouter.of(context).go('/student/dashboard');
        }
      } else {
        // Registration failed, show the error message from auth service
        setState(() {
          _errorMessage = _getFormattedErrorMessage(authService.error ?? 'Failed to register. Please try again.');
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _getFormattedErrorMessage('Registration error: $e');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  String _getFormattedErrorMessage(String error) {
    // Parse Firebase error messages and make them more user-friendly
    if (error.contains('email-already-in-use')) {
      return 'This email is already registered. Please use a different email or sign in.';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email format. Please enter a valid email address.';
    } else if (error.contains('operation-not-allowed')) {
      return 'Registration is temporarily disabled. Please try again later.';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak. Please use a stronger password with at least 6 characters.';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection and try again.';
    }
    return error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 768;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          const Navbar(isAuthenticated: false),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: isSmallScreen ? null : 550,
                  margin: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 20 : 0,
                    vertical: 40,
                  ),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: isDarkMode 
                      ? const LinearGradient(
                          colors: [Color(0xFF362C60), Color(0xFF2D2A3A)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : AppGradients.cardBackground,
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            Icons.videogame_asset,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ).animate()
                       .fadeIn(duration: 600.ms)
                       .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),
                      const SizedBox(height: 24),
                      Text(
                        'Create an Account',
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 22,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                       .fadeIn(duration: 600.ms, delay: 200.ms),
                      const SizedBox(height: 8),
                      Text(
                        'Join the platform to start learning and playing',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                       .fadeIn(duration: 600.ms, delay: 400.ms),
                      const SizedBox(height: 32),
                      
                      // Progress Steps
                      _buildProgressSteps(colorScheme),
                      const SizedBox(height: 32),
                      
                      // Step Content
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: _buildStepContent(context),
                      ),
                      
                      // Error message
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: colorScheme.error.withOpacity(0.3),
                              width: 1,
                            ),
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
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    color: colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 32),
                      
                      // Navigation buttons
                      Row(
                        children: [
                          if (_currentStep > 0)
                            Expanded(
                              child: AppButton(
                                text: 'Back',
                                variant: ButtonVariant.outline,
                                onPressed: _prevStep,
                              ),
                            ),
                          if (_currentStep > 0)
                            const SizedBox(width: 16),
                          Expanded(
                            child: AppButton(
                              text: _currentStep < 3 ? 'Next' : 'Create Account',
                              variant: ButtonVariant.gradient,
                              isLoading: _isLoading,
                              onPressed: _currentStep < 3 ? _nextStep : _handleRegister,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              GoRouter.of(context).go('/signin');
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: colorScheme.primaryContainer.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                fontFamily: 'PixelifySans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressSteps(ColorScheme colorScheme) {
    return Row(
      children: [
        for (int i = 0; i < 4; i++)
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: i <= _currentStep 
                        ? colorScheme.primary 
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: i <= _currentStep 
                          ? colorScheme.primary 
                          : colorScheme.outline.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: i < _currentStep
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontFamily: 'PixelifySans',
                              color: i == _currentStep
                                  ? Colors.white
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getStepTitle(i),
                  style: TextStyle(
                    fontFamily: 'PixelifySans',
                    fontSize: 12,
                    color: i <= _currentStep
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: i == _currentStep
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (i < 3)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Container(
                      height: 2,
                      color: i < _currentStep
                          ? colorScheme.primary
                          : colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
  
  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Role';
      case 1:
        return 'Info';
      case 2:
        return 'Profile';
      case 3:
        return 'Done';
      default:
        return '';
    }
  }
  
  Widget _buildStepContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    switch (_currentStep) {
      case 0:
        return _buildRoleSelectionStep(context);
      case 1:
        return _buildBasicInfoStep(context);
      case 2:
        return _buildProfileCustomizationStep(context);
      case 3:
        return _buildFinalStep(context);
      default:
        return Container();
    }
  }
  
  Widget _buildBasicInfoStep(BuildContext context) {
    return Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppInput(
                              label: 'Full Name',
                              placeholder: 'Enter your full name',
                              controller: _nameController,
                              prefixIcon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            AppInput(
                              label: 'Email',
                              placeholder: 'Enter your email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            AppInput(
                              label: 'Password',
                              placeholder: 'Create a password',
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              onSuffixIconTap: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            AppInput(
                              label: 'Confirm Password',
                              placeholder: 'Confirm your password',
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              onSuffixIconTap: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
        ],
      ),
    );
  }
  
  Widget _buildRoleSelectionStep(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                            Text(
          'Choose your role',
                              style: TextStyle(
            fontFamily: 'PixelifySans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
        Text(
          'Select the role that best describes how you will use the platform',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedRole = 'student';
                                      });
                                    },
                                    child: Container(
            padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
              gradient: _selectedRole == 'student'
                  ? AppGradients.purpleToPink
                  : null,
                                        color: _selectedRole == 'student'
                  ? null
                                            : colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: _selectedRole == 'student'
                    ? Colors.transparent
                                              : colorScheme.outline.withOpacity(0.3),
                width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedRole == 'student'
                        ? Colors.white.withOpacity(0.2)
                        : colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                                            Icons.school,
                    size: 32,
                                            color: _selectedRole == 'student'
                        ? Colors.white
                        : colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                          Text(
                                            'Student',
                                            style: TextStyle(
                          fontFamily: 'PixelifySans',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _selectedRole == 'student'
                              ? Colors.white
                              : colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join classes, play educational games, earn achievements and track your progress',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                                              color: _selectedRole == 'student'
                              ? Colors.white.withOpacity(0.9)
                                                  : colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                Icon(
                  Icons.check_circle,
                  color: _selectedRole == 'student'
                      ? Colors.white
                      : Colors.transparent,
                  size: 24,
                ),
              ],
            ),
          ),
        ).animate()
         .fadeIn(duration: 600.ms, delay: 200.ms)
         .slideY(begin: 0.1, end: 0),
        
        const SizedBox(height: 20),
        
        GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedRole = 'teacher';
                                      });
                                    },
                                    child: Container(
            padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
              gradient: _selectedRole == 'teacher'
                  ? AppGradients.blueToGreen
                  : null,
                                        color: _selectedRole == 'teacher'
                  ? null
                                            : colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: _selectedRole == 'teacher'
                    ? Colors.transparent
                                              : colorScheme.outline.withOpacity(0.3),
                width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedRole == 'teacher'
                        ? Colors.white.withOpacity(0.2)
                        : colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                                            Icons.cast_for_education,
                    size: 32,
                                            color: _selectedRole == 'teacher'
                        ? Colors.white
                        : colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                          Text(
                                            'Teacher',
                                            style: TextStyle(
                          fontFamily: 'PixelifySans',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                                              color: _selectedRole == 'teacher'
                              ? Colors.white
                              : colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create and assign educational games, monitor student progress, and manage classes',
                                        style: TextStyle(
                          fontFamily: 'Inter',
                                          fontSize: 14,
                          color: _selectedRole == 'teacher'
                              ? Colors.white.withOpacity(0.9)
                              : colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                Icon(
                  Icons.check_circle,
                  color: _selectedRole == 'teacher'
                      ? Colors.white
                      : Colors.transparent,
                  size: 24,
                            ),
                          ],
                        ),
                      ),
        ).animate()
         .fadeIn(duration: 600.ms, delay: 400.ms)
         .slideY(begin: 0.1, end: 0),
      ],
    );
  }
  
  Widget _buildProfileCustomizationStep(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Customization',
          style: TextStyle(
            fontFamily: 'PixelifySans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Personalize your account with a display name and avatar',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        
        // Display Name
        AppInput(
          label: 'Display Name',
          placeholder: 'Choose a name to display to others',
          controller: _displayNameController,
          prefixIcon: Icons.badge_outlined,
          onChanged: (value) {
            // No need to update _displayName here since the controller listener handles it
          },
        ),
        const SizedBox(height: 24),
        
        // Avatar selection
        Text(
          'Choose an avatar',
          style: TextStyle(
            fontFamily: 'PixelifySans',
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _avatars.length,
            (index) => GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAvatar = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _avatars[index]['color'].withOpacity(0.1),
                  border: Border.all(
                    color: _selectedAvatar == index
                        ? _avatars[index]['color']
                        : _avatars[index]['color'].withOpacity(0.3),
                    width: _selectedAvatar == index ? 3 : 1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _avatars[index]['icon'],
                  size: 40,
                  color: _avatars[index]['color'],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        
        // Grade selection for students
        if (_selectedRole == 'student') ...[
          Text(
            'Select Your Grade Year',
            style: TextStyle(
              fontFamily: 'PixelifySans',
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 12,
              children: _gradeYears.map((grade) {
                final isSelected = _selectedGradeYear == grade;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGradeYear = grade;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outline.withOpacity(0.3),
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Text(
                      grade,
                      style: TextStyle(
                        fontFamily: 'PixelifySans',
                        fontSize: 14,
                        color: isSelected
                            ? Colors.white
                            : colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        
        // Grade and subject selection for teachers
        if (_selectedRole == 'teacher') ...[
          Text(
            'Select Grade Years You Teach',
            style: TextStyle(
              fontFamily: 'PixelifySans',
              fontSize: 16,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You can select multiple grade years',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 12,
              children: _gradeYears.map((grade) {
                final isSelected = _selectedGradeYears.contains(grade);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedGradeYears.remove(grade);
                      } else {
                        _selectedGradeYears.add(grade);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outline.withOpacity(0.3),
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Text(
                      grade,
                      style: TextStyle(
                        fontFamily: 'PixelifySans',
                        fontSize: 14,
                        color: isSelected
                            ? Colors.white
                            : colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Select Subjects You Teach',
            style: TextStyle(
              fontFamily: 'PixelifySans',
              fontSize: 16,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You can select multiple subjects',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          
          // Organized subject selection by groups
          for (final group in _subjectGroups) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.keys.first,
                    style: TextStyle(
                      fontFamily: 'PixelifySans',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: group.values.first.map((subject) {
                      final isSelected = _selectedSubjects.contains(subject);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedSubjects.remove(subject);
                            } else {
                              _selectedSubjects.add(subject);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline.withOpacity(0.3),
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: colorScheme.shadow.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ] : null,
                          ),
                          child: Text(
                            subject,
                            style: TextStyle(
                              fontFamily: 'PixelifySans',
                              fontSize: 14,
                              color: isSelected
                                  ? Colors.white
                                  : colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
  
  Widget _buildFinalStep(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      children: [
        Icon(
          Icons.check_circle,
          size: 80,
          color: colorScheme.primary,
        ).animate()
         .fadeIn(duration: 600.ms)
         .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0)),
        const SizedBox(height: 24),
        Text(
          'Ready to go!',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 20,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ).animate()
         .fadeIn(duration: 600.ms, delay: 300.ms),
        const SizedBox(height: 16),
        Text(
          'Your account is ready to be created. Click "Create Account" to get started!',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ).animate()
         .fadeIn(duration: 600.ms, delay: 600.ms),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              _buildSummaryItem(
                context,
                'Name',
                _nameController.text,
                Icons.person_outline,
              ),
              const SizedBox(height: 12),
              _buildSummaryItem(
                context,
                'Email',
                _emailController.text,
                Icons.email_outlined,
              ),
              const SizedBox(height: 12),
              _buildSummaryItem(
                context,
                'Role',
                _selectedRole.capitalize(),
                _selectedRole == 'student' ? Icons.school : Icons.cast_for_education,
              ),
              if (_displayName.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildSummaryItem(
                  context,
                  'Display Name',
                  _displayName,
                  Icons.badge_outlined,
                ),
              ],
            ],
          ),
        ).animate()
         .fadeIn(duration: 600.ms, delay: 900.ms),
      ],
    );
  }
  
  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PixelifySans',
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
} 