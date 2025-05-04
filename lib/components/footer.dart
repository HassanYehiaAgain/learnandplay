import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 768;

    return Container(
      color: colorScheme.surfaceContainerHighest,
      padding: EdgeInsets.symmetric(
        horizontal: 24, 
        vertical: isSmallScreen ? 32 : 48
      ),
      child: Column(
        children: [
          isSmallScreen
              ? _buildMobileFooter(context)
              : _buildDesktopFooter(context),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),
          _buildCopyright(context),
        ],
      ),
    );
  }

  Widget _buildDesktopFooter(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo and description
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: colorScheme.primary,
                    ),
                    child: Image.asset(
                      'assets/logo/logo.png',
                      width: 32,
                      height: 32,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Learn, Play, Level Up',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'PixelifySans',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'A fun educational platform where students can learn through interactive games while teachers create and track custom learning materials.',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildSocialIcon(context, Icons.facebook, () {}),
                  _buildSocialIcon(context, Icons.public, () {}),
                  _buildSocialIcon(context, Icons.youtube_searched_for, () {}),
                  _buildSocialIcon(context, Icons.photo_camera, () {}),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        // Links section 1
        Expanded(
          child: _buildFooterLinks(
            context,
            'Navigate',
            [
              FooterLink('Home', '/'),
              FooterLink('Games Library', '/games'),
              FooterLink('For Teachers', '/for-teachers'),
              FooterLink('For Students', '/for-students'),
            ],
          ),
        ),
        const SizedBox(width: 40),
        // Links section 2
        Expanded(
          child: _buildFooterLinks(
            context,
            'Resources',
            [
              FooterLink('Teaching Tools', '/resources/teaching-tools'),
              FooterLink('Lesson Plans', '/resources/lesson-plans'),
              FooterLink('Educational Blog', '/blog'),
              FooterLink('Documentation', '/docs'),
            ],
          ),
        ),
        const SizedBox(width: 40),
        // Links section 3
        Expanded(
          child: _buildFooterLinks(
            context,
            'Company',
            [
              FooterLink('About Us', '/about'),
              FooterLink('Contact', '/contact'),
              FooterLink('Privacy Policy', '/privacy'),
              FooterLink('Terms of Service', '/terms'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFooter(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo and description
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: colorScheme.primary,
              ),
              child: Image.asset(
                'assets/logo/logo.png',
                width: 32,
                height: 32,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Learn, Play, Level Up',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'PixelifySans',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'A fun educational platform where students can learn through interactive games while teachers create and track custom learning materials.',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        // Social icons
        Row(
          children: [
            _buildSocialIcon(context, Icons.facebook, () {}),
            _buildSocialIcon(context, Icons.public, () {}),
            _buildSocialIcon(context, Icons.youtube_searched_for, () {}),
            _buildSocialIcon(context, Icons.photo_camera, () {}),
          ],
        ),
        const SizedBox(height: 32),
        // Accordion sections for mobile
        _buildMobileAccordion(
          context, 
          'Navigate',
          [
            FooterLink('Home', '/'),
            FooterLink('Games Library', '/games'),
            FooterLink('For Teachers', '/for-teachers'),
            FooterLink('For Students', '/for-students'),
          ],
        ),
        const Divider(),
        _buildMobileAccordion(
          context, 
          'Resources',
          [
            FooterLink('Teaching Tools', '/resources/teaching-tools'),
            FooterLink('Lesson Plans', '/resources/lesson-plans'),
            FooterLink('Educational Blog', '/blog'),
            FooterLink('Documentation', '/docs'),
          ],
        ),
        const Divider(),
        _buildMobileAccordion(
          context, 
          'Company',
          [
            FooterLink('About Us', '/about'),
            FooterLink('Contact', '/contact'),
            FooterLink('Privacy Policy', '/privacy'),
            FooterLink('Terms of Service', '/terms'),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterLinks(BuildContext context, String title, List<FooterLink> links) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'PixelifySans',
          ),
        ),
        const SizedBox(height: 16),
        ...links.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              if (link.path.startsWith('http')) {
                // Handle external link
              } else {
                context.go(link.path);
              }
            },
            child: Text(
              link.title,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildMobileAccordion(BuildContext context, String title, List<FooterLink> links) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'PixelifySans',
        ),
      ),
      children: links.map((link) => ListTile(
        title: Text(
          link.title,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        onTap: () {
          if (link.path.startsWith('http')) {
            // Handle external link
          } else {
            context.go(link.path);
          }
        },
      )).toList(),
    );
  }

  Widget _buildSocialIcon(BuildContext context, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: colorScheme.onSurfaceVariant,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildCopyright(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final year = DateTime.now().year;

    return Column(
      children: [
        Text(
          '© $year Learn & Play. All rights reserved.',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Made with ♥ for education',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class FooterLink {
  final String title;
  final String path;

  FooterLink(this.title, this.path);
} 