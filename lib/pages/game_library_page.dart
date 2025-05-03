import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/footer.dart';
import 'package:learn_play_level_up_flutter/components/ui/card.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';

class GameLibraryPage extends StatelessWidget {
  const GameLibraryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 768;

    // Sample game data
    final games = [
      {
        'title': 'Math Quest',
        'description': 'Adventure through math problems with exciting challenges',
        'difficulty': 3.0,
        'tags': ['Math', 'Elementary']
      },
      {
        'title': 'Word Wizards',
        'description': 'Improve vocabulary and spelling through magical word games',
        'difficulty': 2.0,
        'tags': ['Language', 'Spelling']
      },
      {
        'title': 'Science Explorers',
        'description': 'Discover scientific principles through interactive experiments',
        'difficulty': 4.0,
        'tags': ['Science', 'Middle School']
      },
      {
        'title': 'History Heroes',
        'description': 'Travel through time and learn about historical events',
        'difficulty': 3.5,
        'tags': ['History', 'High School']
      },
    ];

    return Scaffold(
      body: Column(
        children: [
          const Navbar(isAuthenticated: false),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 20 : 80,
                      vertical: 40,
                    ),
                    color: colorScheme.primary.withOpacity(0.1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Game Library',
                          style: TextStyle(
                            fontFamily: 'PixelifySans',
                            fontSize: isSmallScreen ? 28 : 36,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Browse our collection of educational games designed to make learning fun and engaging.',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Game Grid
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 20 : 80,
                      vertical: 40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Games',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 24),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isSmallScreen ? 1 : 3,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: games.length,
                          itemBuilder: (context, index) {
                            final game = games[index];
                            return GameTemplateCard(
                              title: game['title'] as String,
                              description: game['description'] as String,
                              difficulty: game['difficulty'] as double,
                              tags: (game['tags'] as List<String>),
                              borderGradient: index % 2 == 0 
                                ? AppGradients.purpleToPink 
                                : AppGradients.orangeToYellow,
                              onTap: () {},
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Footer
                  const Footer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 