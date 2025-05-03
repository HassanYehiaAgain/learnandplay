import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/input.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:learn_play_level_up_flutter/services/auth_service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

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
      // Get the AuthService instance
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Call the sign in method
      final success = await authService.signIn(
        _emailController.text,
        _passwordController.text,
      );
      
      if (!mounted) return;
      
      if (success) {
        // Login successful, navigate to dashboard based on user role
        if (authService.currentUser?.role == 'teacher') {
          GoRouter.of(context).go('/teacher/dashboard');
        } else {
          GoRouter.of(context).go('/student/dashboard');
        }
      } else {
        // Login failed, show the error message from auth service
        setState(() {
          _errorMessage = authService.error ?? 'Failed to sign in. Please check your credentials.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Sign in error: $e';
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
                  width: isSmallScreen ? null : 450,
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
                      // Header with pixel art style
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppGradients.purpleToPink,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.gamepad,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ).animate()
                       .fadeIn(duration: 600.ms)
                       .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),
                      const SizedBox(height: 24),
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 24,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                       .fadeIn(duration: 600.ms, delay: 200.ms),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your credentials to access your account',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                       .fadeIn(duration: 600.ms, delay: 400.ms),
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
                            ).animate()
                             .fadeIn(duration: 600.ms, delay: 600.ms)
                             .slideY(begin: 0.2, end: 0),
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
                            ).animate()
                             .fadeIn(duration: 600.ms, delay: 800.ms)
                             .slideY(begin: 0.2, end: 0),
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
                                      fontFamily: 'PixelifySans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ).animate()
                             .fadeIn(duration: 600.ms, delay: 1000.ms),
                            
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
                            AppButton(
                              text: 'Sign In',
                              variant: ButtonVariant.gradient,
                              isFullWidth: true,
                              isLoading: _isLoading,
                              onPressed: _handleSignIn,
                            ).animate()
                             .fadeIn(duration: 600.ms, delay: 1200.ms),
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
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              GoRouter.of(context).go('/register');
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
                              'Register',
                              style: TextStyle(
                                fontFamily: 'PixelifySans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ).animate()
                       .fadeIn(duration: 600.ms, delay: 1400.ms),
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