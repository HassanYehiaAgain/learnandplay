import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:learn_play_level_up_flutter/services/auth_service.dart';

class UnauthorizedPage extends StatelessWidget {
  const UnauthorizedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 768;
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          const Navbar(isAuthenticated: true),
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
                    gradient: AppGradients.warningGradient,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.error.withOpacity(0.3),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.gpp_bad_outlined,
                        size: 80,
                        color: colorScheme.error,
                      ).animate()
                       .fadeIn(duration: 600.ms)
                       .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),
                      const SizedBox(height: 24),
                      Text(
                        'Access Denied',
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 24,
                          color: colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                       .fadeIn(duration: 600.ms, delay: 200.ms),
                      const SizedBox(height: 16),
                      Text(
                        'You don\'t have permission to access this area',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: colorScheme.onErrorContainer,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                       .fadeIn(duration: 600.ms, delay: 400.ms),
                      const SizedBox(height: 32),
                      
                      Text(
                        authService.currentUser?.role == 'teacher' 
                            ? 'This page is for students only' 
                            : 'This page is for teachers only',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: colorScheme.onErrorContainer.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      AppButton(
                        text: 'Go to Dashboard',
                        variant: ButtonVariant.gradient,
                        onPressed: () {
                          if (authService.currentUser?.role == 'teacher') {
                            GoRouter.of(context).go('/teacher/dashboard');
                          } else {
                            GoRouter.of(context).go('/student/dashboard');
                          }
                        },
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