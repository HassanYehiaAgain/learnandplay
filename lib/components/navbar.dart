import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';

class Navbar extends StatefulWidget {
  final bool isAuthenticated;
  final String? userRole;
  
  const Navbar({
    Key? key, 
    this.isAuthenticated = false,
    this.userRole,
  }) : super(key: key);

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  bool _isMobileMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSmallScreen = MediaQuery.of(context).size.width < 768;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo / Home link
                  GestureDetector(
                    onTap: () => context.go('/'),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: colorScheme.primary,
                          ),
                          child: Icon(
                            Icons.gamepad,
                            color: colorScheme.onPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Learn, Play, Level Up',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Desktop navigation
                  if (!isSmallScreen) ...[
                    Row(
                      children: [
                        _buildNavItem(context, 'Home', '/'),
                        _buildNavItem(context, 'Games', '#games'),
                        _buildNavItem(context, 'Features', '#features'),
                        if (widget.isAuthenticated && widget.userRole != null) ...[
                          _buildNavItem(
                            context, 
                            'Dashboard', 
                            widget.userRole == 'teacher' 
                                ? '/teacher/dashboard' 
                                : '/student/dashboard'
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(width: 16),
                    _buildAuthButtons(context),
                  ],
                  
                  // Mobile menu toggle
                  if (isSmallScreen)
                    IconButton(
                      icon: Icon(
                        _isMobileMenuOpen ? Icons.close : Icons.menu,
                        color: colorScheme.onSurface,
                      ),
                      onPressed: () {
                        setState(() {
                          _isMobileMenuOpen = !_isMobileMenuOpen;
                        });
                        HapticFeedback.lightImpact();
                      },
                    ),
                ],
              ),
              
              // Mobile menu
              if (isSmallScreen && _isMobileMenuOpen)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: _isMobileMenuOpen ? null : 0,
                  margin: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: [
                      _buildMobileNavItem(context, 'Home', '/'),
                      _buildMobileNavItem(context, 'Games', '#games'),
                      _buildMobileNavItem(context, 'Features', '#features'),
                      if (widget.isAuthenticated && widget.userRole != null)
                        _buildMobileNavItem(
                          context, 
                          'Dashboard', 
                          widget.userRole == 'teacher' 
                              ? '/teacher/dashboard' 
                              : '/student/dashboard'
                        ),
                      const SizedBox(height: 16),
                      _buildMobileAuthButtons(context),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem(BuildContext context, String title, String path) {
    final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    final isActive = currentRoute == path;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: () {
          if (path.startsWith('#')) {
            // Handle fragment navigation
          } else {
            context.go(path);
          }
        },
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(
            isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
          overlayColor: MaterialStateProperty.all(
            colorScheme.primary.withOpacity(0.05),
          ),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  Widget _buildMobileNavItem(BuildContext context, String title, String path) {
    final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    final isActive = currentRoute == path;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: TextButton(
        onPressed: () {
          if (path.startsWith('#')) {
            // Handle fragment navigation
          } else {
            context.go(path);
          }
          // Close mobile menu
          setState(() {
            _isMobileMenuOpen = false;
          });
        },
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(
            isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
          backgroundColor: MaterialStateProperty.all(
            isActive ? colorScheme.primaryContainer : Colors.transparent,
          ),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          alignment: Alignment.centerLeft,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
  
  Widget _buildAuthButtons(BuildContext context) {
    if (widget.isAuthenticated) {
      return Row(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          _buildUserAvatar(context),
        ],
      );
    } else {
      return Row(
        children: [
          AppButton(
            text: 'Sign In',
            variant: ButtonVariant.outline,
            size: ButtonSize.small,
            onPressed: () => context.go('/signin'),
          ),
          const SizedBox(width: 8),
          AppButton(
            text: 'Register',
            variant: ButtonVariant.primary,
            size: ButtonSize.small,
            onPressed: () => context.go('/register'),
          ),
        ],
      );
    }
  }
  
  Widget _buildMobileAuthButtons(BuildContext context) {
    if (widget.isAuthenticated) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildUserAvatar(context),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            text: 'Sign In',
            variant: ButtonVariant.outline,
            isFullWidth: true,
            onPressed: () {
              context.go('/signin');
              setState(() {
                _isMobileMenuOpen = false;
              });
            },
          ),
          const SizedBox(height: 8),
          AppButton(
            text: 'Register',
            variant: ButtonVariant.primary,
            isFullWidth: true,
            onPressed: () {
              context.go('/register');
              setState(() {
                _isMobileMenuOpen = false;
              });
            },
          ),
        ],
      );
    }
  }
  
  Widget _buildUserAvatar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return PopupMenuButton(
      offset: const Offset(0, 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline),
              SizedBox(width: 8),
              Text('Profile'),
            ],
          ),
        ),
        if (widget.userRole == 'teacher')
          const PopupMenuItem(
            value: 'create_game',
            child: Row(
              children: [
                Icon(Icons.add_circle_outline),
                SizedBox(width: 8),
                Text('Create Game'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'profile':
            break;
          case 'create_game':
            context.go('/teacher/games/create');
            break;
          case 'logout':
            // Handle logout
            break;
        }
      },
      child: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        child: Text(
          'U',
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} 