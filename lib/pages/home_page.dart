import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';
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
          const Navbar(isAuthenticated: false),
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
                  
                  // Ready to Level Up Section
                  _buildReadyToLevelUpSection(context, isSmallScreen),
                  
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
                          'Welcome to Learn & Play',
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
                          'Transform your classroom',
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
                          'Transform classroom education into exciting adventures! A platform combines learning with play, helping students engage with subjects through interactive games, challenges, and rewards.',
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
                        'Welcome to Learn & Play',
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
                        'Transform your classroom',
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
                        'Transform classroom education into exciting adventures! A platform combines learning with play, helping students engage with subjects through interactive games, challenges, and rewards.',
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
            'Core Features',
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
            'Our platform offers powerful tools for both teachers and students to enhance the educational experience',
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
                  _buildFeatureCard(
                context,
                    icon: Icons.emoji_events,
                    iconColor: AppTheme.purple,
                    title: 'Gamified Learning',
                    description: 'Transform traditional lessons into exciting game experiences that students love to play.',
              ),
                  const SizedBox(height: 24),
                  _buildFeatureCard(
                context,
                    icon: Icons.bar_chart,
                    iconColor: AppTheme.teal,
                    title: 'Comprehensive Analytics',
                    description: 'Track student progress and identify areas where additional support might be needed.',
                  ),
                  const SizedBox(height: 24),
                  _buildFeatureCard(
                context,
                    icon: Icons.verified,
                    iconColor: AppTheme.green,
                    title: 'Achievement System',
                    description: 'Motivate students with badges, trophies, and rewards for their accomplishments.',
                  ),
                ],
              ).animate()
               .fadeIn(duration: 800.ms, delay: 400.ms)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildFeatureCard(
                      context,
                      icon: Icons.emoji_events,
                      iconColor: AppTheme.purple,
                      title: 'Gamified Learning',
                      description: 'Transform traditional lessons into exciting game experiences that students love to play.',
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildFeatureCard(
                      context,
                      icon: Icons.bar_chart,
                      iconColor: AppTheme.teal,
                      title: 'Comprehensive Analytics',
                      description: 'Track student progress and identify areas where additional support might be needed.',
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildFeatureCard(
                      context,
                      icon: Icons.verified,
                      iconColor: AppTheme.green,
                      title: 'Achievement System',
                      description: 'Motivate students with badges, trophies, and rewards for their accomplishments.',
                    ),
              ),
            ],
              ).animate()
               .fadeIn(duration: 800.ms, delay: 400.ms),
        ],
      ),
    );
  }
  
  Widget _buildFeatureCard(BuildContext context, {
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
                  'For Teachers',
                  style: TextStyle(
                    fontFamily: 'PixelifySans',
                        color: colorScheme.primary,
                    fontSize: isSmallScreen ? 28 : 32,
                    fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                  'Create interactive educational games tailored to your curriculum. Design engaging quizzes, interactive puzzles, and memory games to reinforce learning concepts.',
                      style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                    height: 1.6,
                      ),
                    ),
                const SizedBox(height: 12),
                    Text(
                  'Track student progress, view detailed analytics, and understand where your students excel or need additional support.',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    AppButton(
                      text: 'Get Started',
                      variant: ButtonVariant.gradient,
                      size: ButtonSize.medium,
                      onPressed: () => GoRouter.of(context).go('/register'),
                      ),
                    const SizedBox(width: 16),
                    AppButton(
                      text: 'Explore More',
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
                  'For Students',
            style: TextStyle(
                    fontFamily: 'PixelifySans',
                    color: colorScheme.secondary,
                    fontSize: isSmallScreen ? 28 : 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
                  'Learn through fun and engaging games designed by your teachers. Master new concepts while collecting achievements and competing with classmates.',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 16,
                    height: 1.6,
            ),
          ),
                const SizedBox(height: 12),
                    Text(
                  'Track your own progress, earn badges for completing challenges, and see how you rank on the leaderboard!',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                    height: 1.6,
                      ),
                    ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    AppButton(
                      text: 'Start Playing',
                      variant: ButtonVariant.gradient,
                      size: ButtonSize.medium,
                      onPressed: () => GoRouter.of(context).go('/register'),
                    ),
                    const SizedBox(width: 16),
                    AppButton(
                      text: 'Explore More',
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
                  color: colorScheme.secondaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    Icons.emoji_events,
                    size: 120,
                    color: colorScheme.secondary.withOpacity(0.5),
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
          colors: [Color(0xFFA855F7), Color(0xFF9333EA)],
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
          Text(
            'Join thousands of teachers and students already transforming the classroom experience.',
            style: const TextStyle(
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

  Widget _buildFooter(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final footerLinks = [
      {'title': 'About Us', 'links': ['Our Story', 'Team', 'Careers', 'Press']},
      {'title': 'Resources', 'links': ['Blog', 'Help Center', 'Contact Us', 'FAQ']},
      {'title': 'Legal', 'links': ['Terms of Service', 'Privacy Policy', 'Cookie Policy']},
    ];
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 20 : 80,
        vertical: 60,
      ),
      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isSmallScreen)
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                      const SizedBox(height: 16),
                      Text(
                        'Transforming education through interactive game-based learning experiences that engage students and empower teachers.',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _buildSocialIcon(context, Icons.facebook, () {}),
                          const SizedBox(width: 12),
                          _buildSocialIcon(context, Icons.public, () {}),
                          const SizedBox(width: 12),
                          _buildSocialIcon(context, Icons.business_center, () {}),
                          const SizedBox(width: 12),
                          _buildSocialIcon(context, Icons.video_library, () {}),
                        ],
                      ),
                    ],
                  ),
                ),
              if (isSmallScreen) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                    const SizedBox(height: 16),
                    Text(
                      'Transforming education through interactive game-based learning experiences that engage students and empower teachers.',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _buildSocialIcon(context, Icons.facebook, () {}),
                        const SizedBox(width: 12),
                        _buildSocialIcon(context, Icons.public, () {}),
                        const SizedBox(width: 12),
                        _buildSocialIcon(context, Icons.business_center, () {}),
                        const SizedBox(width: 12),
                        _buildSocialIcon(context, Icons.video_library, () {}),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ],
              if (!isSmallScreen)
                Expanded(
                  flex: 8,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: footerLinks.map((section) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                section['title'] as String,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ...(section['links'] as List<String>).map((link) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    onTap: () {},
                                    child: Text(
                                      link,
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
          if (isSmallScreen) ...[
            ...footerLinks.map((section) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section['title'] as String,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...(section['links'] as List<String>).map((link) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {},
                        child: Text(
                          link,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              );
            }),
          ],
          const SizedBox(height: 40),
          Divider(color: colorScheme.outline.withOpacity(0.2)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2023 Learn, Play, Level Up. All rights reserved.',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              if (!isSmallScreen)
                Row(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Terms of Service',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(BuildContext context, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
    );
  }
} 