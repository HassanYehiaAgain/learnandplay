import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';
import 'package:learn_play_level_up_flutter/components/ui/pixel_button.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learn_play_level_up_flutter/models/user.dart';

/// A simplified Navbar component that doesn't use Provider or Riverpod
/// It accepts all necessary props directly to avoid dependency conflicts
class Navbar extends StatelessWidget {
  final bool isAuthenticated;
  final bool isInternal;
  final String? username;
  final String? userRole;
  final VoidCallback? onSignOut;
  
  const Navbar({
    super.key, 
    this.isAuthenticated = false,
    this.isInternal = false,
    this.username,
    this.userRole,
    this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 768;
    
    return Container(
      height: isSmallScreen ? 80 : 100,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 32,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo and title
          GestureDetector(
            onTap: () {
              // If authenticated, go to dashboard, otherwise go to home
              if (isAuthenticated) {
                if (userRole == 'teacher') {
                  GoRouter.of(context).go('/teacher/dashboard');
                } else {
                  GoRouter.of(context).go('/student/dashboard');
                }
              } else {
                GoRouter.of(context).go('/');
              }
            },
            child: Row(
              children: [
                // Logo without background color, larger size
                Image.asset(
                  'assets/logo/logo.png',
                  width: isSmallScreen ? 64 : 80,
                  height: isSmallScreen ? 64 : 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 16),
                Text(
                  'Learn & Play',
                  style: TextStyle(
                    fontFamily: 'PixelifySans',
                    fontSize: isSmallScreen ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          
          // Navigation links - only show on non-internal pages if not authenticated
          if (!isInternal) ...[
            if (!isSmallScreen && !isAuthenticated)
              Row(
                children: [
                  _buildNavLink(context, 'Home', '/'),
                ],
              ),
          ],
          
          // Auth buttons or user menu
          if (isAuthenticated && username != null)
            _buildUserMenu(context)
          else if (!isInternal && !isAuthenticated) // Only show Sign In/Register on non-internal pages when not authenticated
            Row(
              children: [
                TextButton(
                  onPressed: () => GoRouter.of(context).go('/signin'),
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => GoRouter.of(context).go('/register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Register'),
                ),
              ],
            ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }
  
  Widget _buildNavLink(BuildContext context, String title, String route) {
    return TextButton(
      onPressed: () => GoRouter.of(context).go(route),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
      child: Text(title),
    );
  }
  
  Widget _buildUserMenu(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      children: [
        // Edit Profile Button
        OutlinedButton.icon(
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profile'),
          onPressed: () {
            if (userRole == 'teacher') {
              GoRouter.of(context).go('/teacher/profile/edit');
            } else {
              GoRouter.of(context).go('/student/profile/edit');
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.primary,
            side: BorderSide(color: colorScheme.primary),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // User Info Button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primary.withOpacity(0.2),
                radius: 16,
                child: Text(
                  username?.isNotEmpty == true
                      ? username![0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                username ?? 'User',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Logout Button
        ElevatedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          onPressed: onSignOut ?? () => GoRouter.of(context).go('/'),
          style: ElevatedButton.styleFrom(
            foregroundColor: colorScheme.onError,
            backgroundColor: colorScheme.error,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }
} 