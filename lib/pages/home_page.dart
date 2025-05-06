import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
          const Navbar(isAuthenticated: false, isInternal: true),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome Section (Hero Section)
                  _buildWelcomeSection(context, isSmallScreen),
                  
                  // Core Features Section
                  _buildCoreFeaturesSection(context, isSmallScreen),
                  
                  // Teacher Section
                  _buildTeacherSection(context, isSmallScreen),
                  
                  // Student Section
                  _buildStudentSection(context, isSmallScreen),
                  
                  // Footer
                  _buildFooter(context, isSmallScreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 20 : 80,
        vertical: isSmallScreen ? 40 : 80,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.2),
            colorScheme.secondaryContainer.withOpacity(0.2),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (!isSmallScreen)
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          'Join Our Growing Community',
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          color: colorScheme.onSurface,
                            fontSize: isSmallScreen ? 22 : 32,
                          height: 1.4,
                          ),
                        ),
                      ).animate()
                       .fadeIn(duration: 600.ms)
                       .slideX(begin: -0.2, end: 0),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorScheme.secondaryContainer.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          'Join thousands of teachers...',
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                            color: colorScheme.secondary,
                            fontSize: isSmallScreen ? 22 : 32,
                          height: 1.4,
                          ),
                        ),
                      ).animate()
                       .fadeIn(duration: 600.ms, delay: 400.ms)
                       .slideX(begin: -0.2, end: 0),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppGradients.lightTealBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'An interactive platform where teachers create educational games and students learn while having fun. Personalized learning meets gamification for an experience that makes education exciting!',
                        style: TextStyle(
                            fontFamily: 'PixelifySans',
                          color: colorScheme.onSurfaceVariant,
                          fontSize: isSmallScreen ? 16 : 18,
                          height: 1.5,
                          ),
                        ),
                      ).animate()
                       .fadeIn(duration: 600.ms, delay: 800.ms),
                      const SizedBox(height: 40),
                          AppButton(
                            text: 'Get Started',
                            variant: ButtonVariant.gradient,
                            size: ButtonSize.large,
                            leadingIcon: Icons.play_arrow,
                            onPressed: () => GoRouter.of(context).go('/register'),
                          ).animate()
                           .fadeIn(duration: 600.ms, delay: 1200.ms)
                           .slideY(begin: 0.2, end: 0),
                    ],
                  ),
                ),
              if (isSmallScreen)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        'Join Our Growing Community',
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        color: colorScheme.onSurface,
                        fontSize: 22,
                        height: 1.4,
                        ),
                      ),
                    ).animate()
                     .fadeIn(duration: 600.ms)
                     .slideX(begin: -0.2, end: 0),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.secondaryContainer.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        'Join thousands of teachers...',
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                          color: colorScheme.secondary,
                        fontSize: 22,
                        height: 1.4,
                        ),
                      ),
                    ).animate()
                     .fadeIn(duration: 600.ms, delay: 400.ms)
                     .slideX(begin: -0.2, end: 0),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppGradients.lightTealBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'An interactive platform where teachers create educational games and students learn while having fun. Personalized learning meets gamification for an experience that makes education exciting!',
                      style: TextStyle(
                          fontFamily: 'PixelifySans',
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 16,
                        height: 1.5,
                        ),
                      ),
                    ).animate()
                     .fadeIn(duration: 600.ms, delay: 800.ms),
                    const SizedBox(height: 30),
                    AppButton(
                      text: 'Get Started',
                      variant: ButtonVariant.gradient,
                      size: ButtonSize.large,
                      leadingIcon: Icons.play_arrow,
                      isFullWidth: true,
                      onPressed: () => GoRouter.of(context).go('/register'),
                    ).animate()
                     .fadeIn(duration: 600.ms, delay: 1200.ms)
                     .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 40),
                  ],
                ),
              if (!isSmallScreen)
                Expanded(
                  flex: 6,
                  child: Center(
                    child: _buildHeroGraphics(context),
                  ),
                ),
            ],
          ),
          if (isSmallScreen)
            _buildHeroGraphics(context),
        ],
      ),
    );
  }
  
  Widget _buildCoreFeaturesSection(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 20 : 80,
        vertical: 60,
      ),
      color: colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          Text(
            'How It Works',
            style: TextStyle(
              fontFamily: 'PixelifySans',
              color: colorScheme.onSurface,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ).animate()
           .fadeIn(duration: 600.ms),
          const SizedBox(height: 16),
          Text(
            'Our simple 3-step process makes educational gaming accessible for everyone',
            style: TextStyle(
              fontFamily: 'Inter',
              color: colorScheme.onSurfaceVariant,
              fontSize: 18,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate()
           .fadeIn(duration: 600.ms, delay: 200.ms),
          const SizedBox(height: 60),
          
          // Features Grid/Row
          isSmallScreen 
            ? Column(
            children: [
                  _buildProcessCard(
                context,
                    icon: Icons.create,
                    iconColor: colorScheme.primary,
                    title: '1. Teachers Create Games',
                    description: 'Educators design custom educational games tailored to their curriculum and learning objectives.',
              ),
                  const SizedBox(height: 24),
                  _buildProcessCard(
                context,
                    icon: Icons.sports_esports,
                    iconColor: colorScheme.primary,
                    title: '2. Students Play & Learn',
                    description: 'Students engage with the interactive games, mastering concepts while having fun and earning rewards.',
                  ),
                  const SizedBox(height: 24),
                  _buildProcessCard(
                context,
                    icon: Icons.bar_chart,
                    iconColor: colorScheme.primary,
                    title: '3. Everyone Tracks Progress',
                    description: 'Both teachers and students monitor learning achievements and identify areas for improvement.',
                  ),
                ],
              ).animate()
               .fadeIn(duration: 800.ms, delay: 400.ms)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildProcessCard(
                      context,
                      icon: Icons.create,
                      iconColor: colorScheme.primary,
                      title: '1. Teachers Create Games',
                      description: 'Educators design custom educational games tailored to their curriculum and learning objectives.',
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildProcessCard(
                      context,
                      icon: Icons.sports_esports,
                      iconColor: colorScheme.primary,
                      title: '2. Students Play & Learn',
                      description: 'Students engage with the interactive games, mastering concepts while having fun and earning rewards.',
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildProcessCard(
                      context,
                      icon: Icons.bar_chart,
                      iconColor: colorScheme.primary,
                      title: '3. Everyone Tracks Progress',
                      description: 'Both teachers and students monitor learning achievements and identify areas for improvement.',
                    ),
              ),
            ],
              ).animate()
               .fadeIn(duration: 800.ms, delay: 400.ms),
        ],
      ),
    );
  }
  
  Widget _buildProcessCard(BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
        color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
          boxShadow: [
            BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
            width: 80,
            height: 80,
              decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
              ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'PixelifySans',
              color: colorScheme.onSurface,
              fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            textAlign: TextAlign.center,
            ),
          const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontFamily: 'Inter',
              color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              height: 1.6,
              ),
            textAlign: TextAlign.center,
                  ),
                ],
      ),
    );
  }

  Widget _buildTeacherSection(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 20 : 80,
        vertical: 60,
      ),
      color: colorScheme.surface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isSmallScreen)
            Expanded(
              flex: 5,
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    Icons.cast_for_education,
                    size: 120,
                    color: colorScheme.primary.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          if (!isSmallScreen) const SizedBox(width: 40),
          Expanded(
            flex: isSmallScreen ? 12 : 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                  'Empower Your Teaching',
                  style: TextStyle(
                    fontFamily: 'PixelifySans',
                        color: colorScheme.primary,
                    fontSize: isSmallScreen ? 28 : 32,
                    fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Benefit items
                    _buildBenefitItem(
                      context,
                      icon: Icons.admin_panel_settings,
                      text: 'Create custom educational games in minutes with easy templates'
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitItem(
                      context,
                      icon: Icons.insights,
                      text: 'Track student progress with comprehensive analytics'
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitItem(
                      context,
                      icon: Icons.event_available,
                      text: 'Assign games with specific due dates for better organization'
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitItem(
                      context,
                      icon: Icons.dashboard_customize,
                      text: 'Manage multiple subjects and grade years from one dashboard'
                    ),
                    
                const SizedBox(height: 30),
                Row(
                  children: [
                    AppButton(
                      text: 'Teacher Sign Up',
                      variant: ButtonVariant.gradient,
                      size: ButtonSize.medium,
                      onPressed: () => GoRouter.of(context).go('/register'),
                      ),
                    const SizedBox(width: 16),
                    AppButton(
                      text: 'Learn More',
                      variant: ButtonVariant.outline,
                      size: ButtonSize.medium,
                      onPressed: () => GoRouter.of(context).go('/for-teachers'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBenefitItem(BuildContext context, {required IconData icon, required String text}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Inter',
              color: colorScheme.onSurfaceVariant,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentSection(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 20 : 80,
        vertical: 60,
      ),
      color: colorScheme.surfaceContainerLow,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: isSmallScreen ? 12 : 7,
      child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
                  'Learning That Feels Like Play',
            style: TextStyle(
                    fontFamily: 'PixelifySans',
                    color: colorScheme.primary,
                    fontSize: isSmallScreen ? 28 : 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Benefit items
          _buildBenefitItem(
            context,
            icon: Icons.school,
            text: 'Master new concepts through fun interactive games'
          ),
          const SizedBox(height: 12),
          _buildBenefitItem(
            context,
            icon: Icons.emoji_events,
            text: 'Earn XP, badges, and rewards for your achievements'
          ),
          const SizedBox(height: 12),
          _buildBenefitItem(
            context,
            icon: Icons.trending_up,
            text: 'Track your progress and compete on leaderboards'
          ),
          const SizedBox(height: 12),
          _buildBenefitItem(
            context,
            icon: Icons.assignment_turned_in,
            text: 'Access games assigned by your teachers in one place'
          ),
                
                const SizedBox(height: 30),
                Row(
                  children: [
                    AppButton(
                      text: 'Student Sign Up',
                      variant: ButtonVariant.gradient,
                      size: ButtonSize.medium,
                      onPressed: () => GoRouter.of(context).go('/register'),
                    ),
                    const SizedBox(width: 16),
                    AppButton(
                      text: 'Learn More',
                      variant: ButtonVariant.outline,
                      size: ButtonSize.medium,
                      onPressed: () => GoRouter.of(context).go('/for-students'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isSmallScreen) const SizedBox(width: 40),
          if (!isSmallScreen)
            Expanded(
              flex: 5,
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    Icons.emoji_events,
                    size: 120,
                    color: colorScheme.primary.withOpacity(0.5),
                  ),
                ),
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyToLevelUpSection(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 20 : 80,
        vertical: 60,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2BBEAA), Color(0xFF1A8F84)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Ready to Level Up Learning?',
            style: TextStyle(
              fontFamily: 'PixelifySans',
              color: Colors.white,
              fontSize: isSmallScreen ? 28 : 36,
              fontWeight: FontWeight.bold,
            ),
          ).animate()
           .fadeIn(duration: 600.ms),
          const SizedBox(height: 16),
          const Text(
            'Join thousands of teachers and students already transforming the classroom experience.',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 18,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate()
           .fadeIn(duration: 600.ms, delay: 200.ms),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppButton(
                  text: 'Sign Up Free',
                  variant: ButtonVariant.primary,
                  size: ButtonSize.large,
                  onPressed: () => GoRouter.of(context).go('/register'),
                ),
              ).animate()
               .fadeIn(duration: 600.ms, delay: 400.ms),
              const SizedBox(width: 16),
          AppButton(
                text: 'Learn More',
                variant: ButtonVariant.outline,
            size: ButtonSize.large,
            onPressed: () {},
              ).animate()
               .fadeIn(duration: 600.ms, delay: 600.ms),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeroGraphics(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background grid
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.2),
                width: 2,
            ),
            ),
          ).animate()
           .fadeIn(duration: 800.ms, delay: 200.ms),
          
          // Game controller icon
          Positioned(
            top: 60,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.sports_esports,
                size: 64,
                color: colorScheme.primary,
            ),
            ),
          ).animate()
           .fadeIn(duration: 600.ms, delay: 600.ms)
           .slideY(begin: -0.2, end: 0),
          
          // Trophy icon
          Positioned(
            bottom: 40,
            left: 40,
            child: Container(
              padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                color: colorScheme.tertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.tertiary.withOpacity(0.3),
                  width: 2,
                    ),
                ),
              child: Icon(
                Icons.emoji_events,
                size: 32,
                color: colorScheme.tertiary,
                    ),
            ),
          ).animate()
           .fadeIn(duration: 600.ms, delay: 1000.ms)
           .slideX(begin: -0.2, end: 0),
          
          // Chart icon
          Positioned(
            top: 40,
            right: 40,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.secondary.withOpacity(0.3),
                  width: 2,
                      ),
                    ),
              child: Icon(
                Icons.bar_chart,
                size: 28,
                color: colorScheme.secondary,
                ),
              ),
          ).animate()
           .fadeIn(duration: 600.ms, delay: 800.ms)
           .slideX(begin: 0.2, end: 0),
          
          // Book icon
          Positioned(
            bottom: 60,
            right: 60,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.secondaryContainer.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.menu_book,
                size: 30,
                color: colorScheme.secondaryContainer,
                    ),
                ),
          ).animate()
           .fadeIn(duration: 600.ms, delay: 1200.ms)
           .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildGameShowcaseSection(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final games = [
      {
        'title': 'Quiz Games',
        'description': 'Test knowledge with engaging multiple-choice questions',
        'icon': Icons.help_outline,
        'color': colorScheme.primary,
      },
      {
        'title': 'Matching Games',
        'description': 'Connect related concepts and build association skills',
        'icon': Icons.grid_view,
        'color': colorScheme.primary,
      },
      {
        'title': 'Word Scramble',
        'description': 'Strengthen vocabulary and spelling through word games',
        'icon': Icons.text_fields,
        'color': colorScheme.primary,
      },
      {
        'title': 'Memory Games',
        'description': 'Improve retention and recall with pattern recognition',
        'icon': Icons.psychology,
        'color': colorScheme.primary,
      },
    ];
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 20 : 80,
        vertical: 60,
      ),
      color: colorScheme.surface,
      child: Column(
        children: [
          Text(
            'Game Showcase',
            style: TextStyle(
              fontFamily: 'PixelifySans',
              color: colorScheme.onSurface,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ).animate()
           .fadeIn(duration: 600.ms),
          const SizedBox(height: 16),
          Text(
            'Explore our diverse collection of educational game types',
            style: TextStyle(
              fontFamily: 'Inter',
              color: colorScheme.onSurfaceVariant,
              fontSize: 18,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate()
           .fadeIn(duration: 600.ms, delay: 200.ms),
          const SizedBox(height: 40),
          
          // Game grid
          isSmallScreen
              ? Column(
                  children: games.map((game) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildGameCard(context, game),
                    );
                  }).toList(),
                )
              : GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: games.map((game) {
                    return _buildGameCard(context, game);
                  }).toList(),
                ),
        ],
      ),
    );
  }
  
  Widget _buildGameCard(BuildContext context, Map<String, dynamic> game) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: (game['color'] as Color).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                game['icon'] as IconData,
                color: game['color'] as Color,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            game['title'] as String,
            style: TextStyle(
              fontFamily: 'PixelifySans',
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            game['description'] as String,
            style: TextStyle(
              fontFamily: 'Inter',
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Define stats
    final stats = [
      {
        'value': '5,000+',
        'label': 'Active Teachers',
        'icon': Icons.school,
      },
      {
        'value': '50,000+',
        'label': 'Student Users',
        'icon': Icons.people,
      },
      {
        'value': '10,000+',
        'label': 'Educational Games',
        'icon': Icons.gamepad,
      },
      {
        'value': '30+',
        'label': 'Subject Areas',
        'icon': Icons.category,
      },
    ];
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 20 : 80,
        vertical: 60,
      ),
      color: colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          Text(
            'Join Our Growing Community',
            style: TextStyle(
              fontFamily: 'PixelifySans',
              color: colorScheme.onSurface,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ).animate()
           .fadeIn(duration: 600.ms),
          const SizedBox(height: 16),
          Text(
            'Join thousands of teachers and students already transforming education',
            style: TextStyle(
              fontFamily: 'Inter',
              color: colorScheme.onSurfaceVariant,
              fontSize: 18,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate()
           .fadeIn(duration: 600.ms, delay: 200.ms),
          const SizedBox(height: 60),
          
          // Stats in grid or row
          Wrap(
            spacing: isSmallScreen ? 16 : 40,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: stats.map((stat) {
              return SizedBox(
                width: isSmallScreen ? double.infinity : 200,
                child: _buildStatItem(context, stat),
              );
            }).toList(),
          ).animate()
           .fadeIn(duration: 800.ms, delay: 400.ms),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(BuildContext context, Map<String, dynamic> stat) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            stat['icon'] as IconData,
            color: colorScheme.primary,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          stat['value'] as String,
          style: TextStyle(
            fontFamily: 'PixelifySans',
            color: colorScheme.primary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          stat['label'] as String,
          style: TextStyle(
            fontFamily: 'Inter',
            color: colorScheme.onSurfaceVariant,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 20 : 80,
        vertical: isSmallScreen ? 40 : 80,
      ),
      color: colorScheme.surface,
      child: Column(
        children: [
          // Large slogan with Pixelify Sans font
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 30 : 60,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Text(
              'Empowering Teachers Engaging Students',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PixelifySans',
                fontSize: isSmallScreen ? 28 : 42,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                height: 1.3,
              ),
            ),
          ).animate()
           .fadeIn(duration: 600.ms)
           .slideY(begin: 0.2, end: 0),
           
          const SizedBox(height: 32),
          Divider(color: colorScheme.outline.withOpacity(0.2)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '© 2023 Learn, Play, Level Up. All rights reserved.',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 