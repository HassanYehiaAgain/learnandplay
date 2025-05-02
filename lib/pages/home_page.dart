import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Section
                  _buildHeroSection(context, isSmallScreen),
                  
                  // Features Section
                  _buildFeaturesSection(context, isSmallScreen),
                  
                  // Game Templates Section
                  _buildGameTemplatesSection(context, isSmallScreen),
                  
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

  Widget _buildHeroSection(BuildContext context, bool isSmallScreen) {
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
          Row(
            children: [
              if (!isSmallScreen)
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Learn through play,\nlevel up your classroom',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: isSmallScreen ? 28 : 48,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Create engaging educational games for your students. Track progress, celebrate achievements, and make learning fun.',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: isSmallScreen ? 16 : 18,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          AppButton(
                            text: 'Get Started',
                            variant: ButtonVariant.primary,
                            size: ButtonSize.large,
                            leadingIcon: Icons.play_arrow,
                            onPressed: () {},
                          ),
                          const SizedBox(width: 16),
                          AppButton(
                            text: 'Learn More',
                            variant: ButtonVariant.outline,
                            size: ButtonSize.large,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              if (isSmallScreen)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Learn through play,\nlevel up your classroom',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Create engaging educational games for your students. Track progress, celebrate achievements, and make learning fun.',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    AppButton(
                      text: 'Get Started',
                      variant: ButtonVariant.primary,
                      size: ButtonSize.large,
                      leadingIcon: Icons.play_arrow,
                      isFullWidth: true,
                      onPressed: () {},
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Learn More',
                      variant: ButtonVariant.outline,
                      size: ButtonSize.large,
                      isFullWidth: true,
                      onPressed: () {},
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              if (!isSmallScreen)
                Expanded(
                  flex: 6,
                  child: Center(
                    child: Container(
                      height: 400,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.gamepad,
                          size: 100,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (isSmallScreen)
            Container(
              height: 240,
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  Icons.gamepad,
                  size: 80,
                  color: colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final features = [
      {
        'icon': Icons.games_outlined,
        'title': 'Interactive Games',
        'description': 'Engage students with fun, interactive educational games that make learning enjoyable.'
      },
      {
        'icon': Icons.bar_chart,
        'title': 'Progress Tracking',
        'description': 'Monitor student progress with detailed analytics and performance metrics.'
      },
      {
        'icon': Icons.emoji_events_outlined,
        'title': 'Achievements & Rewards',
        'description': 'Motivate students with achievement badges and milestone rewards.'
      },
      {
        'icon': Icons.person_outline,
        'title': 'Personalized Learning',
        'description': 'Adapt content to individual student needs and learning styles.'
      },
    ];
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 20 : 80,
        vertical: 60,
      ),
      color: colorScheme.surfaceVariant.withOpacity(0.3),
      child: Column(
        children: [
          Text(
            'Features',
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Everything you need to enhance learning',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: isSmallScreen ? 24 : 36,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Our platform combines powerful educational tools with engaging gameplay elements.',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: features.map((feature) {
              return Container(
                width: isSmallScreen ? double.infinity : 280,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      feature['title'] as String,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feature['description'] as String,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameTemplatesSection(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final gameTemplates = [
      {
        'title': 'Math Challenge',
        'description': 'Fun math puzzles and problems for all grade levels',
        'image': Icons.calculate_outlined,
        'color': colorScheme.primary,
      },
      {
        'title': 'Vocabulary Quest',
        'description': 'Build vocabulary through interactive word games',
        'image': Icons.menu_book_outlined,
        'color': colorScheme.secondary,
      },
      {
        'title': 'Science Explorer',
        'description': 'Discover scientific concepts through virtual experiments',
        'image': Icons.science_outlined,
        'color': colorScheme.tertiary,
      },
      {
        'title': 'History Timeline',
        'description': 'Navigate through history with interactive timelines',
        'image': Icons.history_edu_outlined,
        'color': colorScheme.error,
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
            'Game Templates',
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ready-to-use educational games',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: isSmallScreen ? 24 : 36,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Get started quickly with our pre-designed game templates or create your own.',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: gameTemplates.map((template) {
              return Container(
                width: isSmallScreen ? double.infinity : 280,
                height: 280,
                decoration: BoxDecoration(
                  color: (template['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: (template['color'] as Color).withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      template['image'] as IconData,
                      color: template['color'] as Color,
                      size: 60,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      template['title'] as String,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        template['description'] as String,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: 'Try it',
                      variant: ButtonVariant.outline,
                      size: ButtonSize.small,
                      onPressed: () {},
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          AppButton(
            text: 'View All Templates',
            variant: ButtonVariant.primary,
            size: ButtonSize.large,
            onPressed: () {},
          ),
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
      color: colorScheme.surfaceVariant.withOpacity(0.3),
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
                              }).toList(),
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
                  }).toList(),
                  const SizedBox(height: 24),
                ],
              );
            }).toList(),
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