import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';
import 'package:learn_play_level_up_flutter/components/ui/pixel_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_play_level_up_flutter/theme/theme_provider.dart';

// Backward compatibility class for existing pages
class Navbar extends StatelessWidget {
  final bool isAuthenticated;
  final String? userRole;

  const Navbar({
    Key? key,
    this.isAuthenticated = false,
    this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use GoRouter for navigation
    return AppNavbar(
      isAuthenticated: isAuthenticated,
      username: userRole != null ? '${userRole![0].toUpperCase()}${userRole!.substring(1)}' : null,
      onLoginPressed: () => GoRouter.of(context).go('/signin'),
      onRegisterPressed: () => GoRouter.of(context).go('/register'),
      onProfilePressed: () {
        if (userRole == 'teacher') {
          GoRouter.of(context).go('/teacher/dashboard');
        } else {
          GoRouter.of(context).go('/student/dashboard');
        }
      },
      onLogoutPressed: () {
        // Add logout handling here if needed
        GoRouter.of(context).go('/');
      },
    );
  }
}

class AppNavbar extends ConsumerStatefulWidget {
  final bool isAuthenticated;
  final String? username;
  final String? userAvatarUrl;
  final VoidCallback? onLoginPressed;
  final VoidCallback? onRegisterPressed;
  final VoidCallback? onLogoutPressed;
  final VoidCallback? onProfilePressed;

  const AppNavbar({
    Key? key,
    this.isAuthenticated = false,
    this.username,
    this.userAvatarUrl,
    this.onLoginPressed,
    this.onRegisterPressed,
    this.onLogoutPressed,
    this.onProfilePressed,
  }) : super(key: key);

  @override
  ConsumerState<AppNavbar> createState() => _AppNavbarState();
}

class _AppNavbarState extends ConsumerState<AppNavbar> with SingleTickerProviderStateMixin {
  bool _isMobileMenuOpen = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMobileMenu() {
    setState(() {
      _isMobileMenuOpen = !_isMobileMenuOpen;
      if (_isMobileMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 768;
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return Column(
      children: [
        Container(
          height: 70,
          color: colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Logo
              InkWell(
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
                      'Learn & Play',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'PixelifySans',
                      ),
                    ),
                  ],
                ),
              ),
              
              // Desktop navigation
              if (!isSmallScreen) ...[
                const SizedBox(width: 40),
                Expanded(
                  child: Row(
                    children: [
                      _buildNavItem(context, 'Home', '/'),
                      _buildNavItem(context, 'For Teachers', '/for-teachers'),
                      _buildNavItem(context, 'For Students', '/for-students'),
                    ],
                  ),
                ),
                
                // Theme toggle button
                IconButton(
                  onPressed: () {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                  icon: Icon(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: colorScheme.onSurface,
                    size: 24,
                  ),
                  tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                ),
                
                // Auth buttons or user profile
                if (widget.isAuthenticated) ...[
                  _buildUserProfile(context),
                ] else ...[
                  PixelButton(
                    text: 'Login',
                    variant: PixelButtonVariant.secondary,
                    size: PixelButtonSize.small,
                    onPressed: widget.onLoginPressed,
                    enableGlowEffect: false,
                  ),
                  const SizedBox(width: 12),
                  PixelButton(
                    text: 'Register',
                    variant: PixelButtonVariant.primary,
                    size: PixelButtonSize.small,
                    onPressed: widget.onRegisterPressed,
                  ),
                ],
              ] else ...[
                // Mobile hamburger menu
                const Spacer(),
                // Theme toggle button
                IconButton(
                  onPressed: () {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                  icon: Icon(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: colorScheme.onSurface,
                    size: 24,
                  ),
                  tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                ),
                IconButton(
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: _animation,
                    color: colorScheme.onSurface,
                  ),
                  onPressed: _toggleMobileMenu,
                ),
              ],
            ],
          ),
        ),
        
        // Mobile menu
        if (isSmallScreen)
          SizeTransition(
            sizeFactor: _animation,
            axisAlignment: -1.0,
            child: Container(
              color: colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _buildMobileNavItem(context, 'Home', '/', Icons.home),
                  _buildMobileNavItem(context, 'For Teachers', '/for-teachers', Icons.school),
                  _buildMobileNavItem(context, 'For Students', '/for-students', Icons.person),
                  const Divider(),
                  if (widget.isAuthenticated) ...[
                    _buildMobileUserProfile(context),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: PixelButton(
                              text: 'Login',
                              variant: PixelButtonVariant.secondary,
                              size: PixelButtonSize.small,
                              onPressed: widget.onLoginPressed,
                              isFullWidth: true,
                              enableGlowEffect: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PixelButton(
                              text: 'Register',
                              variant: PixelButtonVariant.primary,
                              size: PixelButtonSize.small,
                              onPressed: widget.onRegisterPressed,
                              isFullWidth: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNavItem(BuildContext context, String title, String path) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Use GoRouter to check current location
    final router = GoRouter.of(context);
    final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
    final isActive = currentLocation == path;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => GoRouter.of(context).go(path),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? colorScheme.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNavItem(BuildContext context, String title, String path, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Use GoRouter to check current location
    final router = GoRouter.of(context);
    final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
    final isActive = currentLocation == path;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? colorScheme.primary : colorScheme.onSurface,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        GoRouter.of(context).go(path);
        _toggleMobileMenu();
      },
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return PopupMenuButton<String>(
      offset: const Offset(0, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'profile',
          onTap: widget.onProfilePressed,
          child: Row(
            children: [
              const Icon(Icons.person),
              const SizedBox(width: 8),
              const Text('My Profile'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          onTap: widget.onLogoutPressed,
          child: Row(
            children: [
              const Icon(Icons.logout),
              const SizedBox(width: 8),
              const Text('Logout'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.outline,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.primary,
              backgroundImage: widget.userAvatarUrl != null
                  ? NetworkImage(widget.userAvatarUrl!)
                  : null,
              child: widget.userAvatarUrl == null
                  ? Text(
                      widget.username?.isNotEmpty == true
                          ? widget.username![0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              widget.username ?? 'User',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileUserProfile(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: colorScheme.primary,
            backgroundImage: widget.userAvatarUrl != null
                ? NetworkImage(widget.userAvatarUrl!)
                : null,
            child: widget.userAvatarUrl == null
                ? Text(
                    widget.username?.isNotEmpty == true
                        ? widget.username![0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          title: Text(
            widget.username ?? 'User',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: const Text('View profile'),
          onTap: () {
            widget.onProfilePressed?.call();
            _toggleMobileMenu();
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () {
            widget.onLogoutPressed?.call();
            _toggleMobileMenu();
          },
        ),
      ],
    );
  }
} 