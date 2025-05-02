import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/input.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // TODO: Implement actual authentication with AuthService
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // For demonstration, navigate to student dashboard
      if (!mounted) return;
      
      Navigator.pushReplacementNamed(context, '/student/dashboard');
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign in. Please check your credentials.';
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
                  width: isSmallScreen ? null : 450,
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
                            Icons.lock_outline,
                            color: colorScheme.primary,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your credentials to access your account',
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
                              placeholder: 'Enter your password',
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
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    // TODO: Navigate to forgot password page
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.primary,
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
                              text: 'Sign In',
                              variant: ButtonVariant.primary,
                              isFullWidth: true,
                              isLoading: _isLoading,
                              onPressed: _handleSignIn,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account?',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/register');
                            },
                            child: Text(
                              'Register',
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