import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learn_play_level_up_flutter/services/auth_service.dart';
import 'package:learn_play_level_up_flutter/services/firebase_service.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';
import 'package:learn_play_level_up_flutter/models/firebase_models.dart';
import 'package:go_router/go_router.dart';

class StudentProfileEditPage extends StatefulWidget {
  const StudentProfileEditPage({super.key});

  @override
  State<StudentProfileEditPage> createState() => _StudentProfileEditPageState();
}

class _StudentProfileEditPageState extends State<StudentProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Student data
  FirebaseUser? _student;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  int _selectedGradeYear = 0;
  
  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
  
  Future<void> _loadStudentData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final authService = Provider.of<AuthService>(context, listen: false);
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      
      // Get current user
      final currentUser = await firebaseService.getCurrentUser();
      
      if (currentUser == null || currentUser.role != 'student') {
        setState(() {
          _errorMessage = 'You must be logged in as a student to edit your profile';
          _isLoading = false;
        });
        return;
      }
      
      // Set form values
      _nameController.text = currentUser.name;
      _emailController.text = currentUser.email;
      _selectedGradeYear = currentUser.studentGradeYear ?? 0;
      
      setState(() {
        _student = currentUser;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading student data: $e';
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
      
      await firebaseService.updateStudentProfile(
        studentId: _student!.id,
        name: _nameController.text.trim(),
        studentGradeYear: _selectedGradeYear,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        
        // Navigate back to student dashboard
        GoRouter.of(context).go('/student/dashboard');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating profile: $e';
        _isLoading = false;
      });
    }
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
            isAuthenticated: _student != null,
            username: _student?.name,
            userRole: 'student',
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
                              'Edit Student Profile',
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
                                    
                                    // Grade Year Selection
                                    Text(
                                      'Grade Level',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    Text(
                                      'Select Your Current Grade',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    DropdownButtonFormField<int>(
                                      value: _selectedGradeYear,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                      ),
                                      items: List.generate(13, (index) {
                                        return DropdownMenuItem<int>(
                                          value: index,
                                          child: Text(
                                            index == 0 ? 'Kindergarten' : 'Grade $index',
                                          ),
                                        );
                                      }),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() {
                                            _selectedGradeYear = value;
                                          });
                                        }
                                      },
                                    ),
                                    
                                    const SizedBox(height: 32),
                                    
                                    // Save Button
                                    Center(
                                      child: AppButton(
                                        text: 'Save Profile',
                                        leadingIcon: Icons.save,
                                        isLoading: _isLoading,
                                        onPressed: _saveProfile,
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