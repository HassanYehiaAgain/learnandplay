import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/input.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  String _selectedRole = 'student'; // Default role
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // TODO: Implement actual registration with AuthService
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // For demonstration, navigate to student/teacher dashboard based on role
      if (!mounted) return;
      
      if (_selectedRole == 'teacher') {
        Navigator.pushReplacementNamed(context, '/teacher/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/student/dashboard');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to register. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 768;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          const Navbar(isAuthenticated: false),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: isSmallScreen ? null : 500,
                  margin: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 20 : 0,
                    vertical: 40,
                  ),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
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
                            color: colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_add_outlined,
                            color: colorScheme.primary,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Create an Account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join the platform to start learning and playing',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Form
                      Form(
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
                            const SizedBox(height: 24),
                            
                            // Role selection
                            Text(
                              'I am a:',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedRole = 'student';
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _selectedRole == 'student'
                                            ? colorScheme.primary.withOpacity(0.1)
                                            : colorScheme.surfaceVariant.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _selectedRole == 'student'
                                              ? colorScheme.primary
                                              : colorScheme.outline.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.school,
                                            color: _selectedRole == 'student'
                                                ? colorScheme.primary
                                                : colorScheme.onSurfaceVariant,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Student',
                                            style: TextStyle(
                                              color: _selectedRole == 'student'
                                                  ? colorScheme.primary
                                                  : colorScheme.onSurfaceVariant,
                                              fontWeight: _selectedRole == 'student'
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedRole = 'teacher';
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _selectedRole == 'teacher'
                                            ? colorScheme.primary.withOpacity(0.1)
                                            : colorScheme.surfaceVariant.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _selectedRole == 'teacher'
                                              ? colorScheme.primary
                                              : colorScheme.outline.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.cast_for_education,
                                            color: _selectedRole == 'teacher'
                                                ? colorScheme.primary
                                                : colorScheme.onSurfaceVariant,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Teacher',
                                            style: TextStyle(
                                              color: _selectedRole == 'teacher'
                                                  ? colorScheme.primary
                                                  : colorScheme.onSurfaceVariant,
                                              fontWeight: _selectedRole == 'teacher'
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
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
                            AppButton(
                              text: 'Create Account',
                              variant: ButtonVariant.primary,
                              isFullWidth: true,
                              isLoading: _isLoading,
                              onPressed: _handleRegister,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/signin');
                            },
                            child: Text(
                              'Sign In',
                              style: TextStyle(
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
} 