import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';

class GameProgress extends StatelessWidget {
  final List<Map<String, dynamic>> assignedGames;
  final List<Map<String, dynamic>> inProgressGames;
  final bool isLoading;

  const GameProgress({
    super.key,
    required this.assignedGames,
    required this.inProgressGames,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return _buildLoadingState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Assigned Games Section
        Text(
          'Assigned Games',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        assignedGames.isEmpty
            ? _buildEmptyAssignedGames(context)
            : _buildAssignedGamesList(context),
        
        const SizedBox(height: 32),
        
        // In Progress Games Section
        Text(
          'In Progress',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        inProgressGames.isEmpty
            ? _buildEmptyInProgressGames(context)
            : _buildInProgressGamesList(context),
      ],
    );
  }

  Widget _buildAssignedGamesList(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: assignedGames.length,
        itemBuilder: (context, index) {
          return _buildAssignedGameCard(context, assignedGames[index], index);
        },
      ),
    );
  }

  Widget _buildAssignedGameCard(BuildContext context, Map<String, dynamic> game, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Color gameColor = game['color'] as Color? ?? colorScheme.primary;

    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gameColor.withOpacity(0.8),
            gameColor.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gameColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Pixelated decoration
          Positioned(
            top: 16,
            right: 16,
            child: _buildPixelatedIcon(24, Colors.white.withOpacity(0.1)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Due date indicator
                if (game['dueDate'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: game['isOverdue'] == true
                          ? Colors.red.shade300
                          : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      game['isOverdue'] == true
                          ? 'Overdue'
                          : 'Due ${game['dueDate']}',
                      style: TextStyle(
                        fontFamily: 'PixelifySans',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: game['isOverdue'] == true
                            ? Colors.white
                            : Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                // Game icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    game['icon'] as IconData,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                // Game title
                Text(
                  game['title'] as String,
                  style: const TextStyle(
                    fontFamily: 'PixelifySans',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Subject
                Text(
                  game['subject'] as String,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const Spacer(),
                // Start button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Start',
                        style: TextStyle(
                          fontFamily: 'PixelifySans',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (game['isNew'] == true)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'NEW',
                    style: TextStyle(
                      fontFamily: 'PixelifySans',
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
     .fadeIn(duration: 400.ms)
     .slideX(begin: 0.2, end: 0);
  }

  Widget _buildInProgressGamesList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: inProgressGames.length,
      itemBuilder: (context, index) {
        return _buildInProgressGameItem(context, inProgressGames[index], index);
      },
    );
  }

  Widget _buildInProgressGameItem(BuildContext context, Map<String, dynamic> game, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = game['progress'] as double;
    final Color gameColor = game['color'] as Color? ?? colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Game icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: gameColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              game['icon'] as IconData,
              color: gameColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game['title'] as String,
                  style: TextStyle(
                    fontFamily: 'PixelifySans',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last played: ${game['lastPlayed']}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                // Pixelated progress bar
                Stack(
                  children: [
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    Container(
                      height: 12,
                      width: MediaQuery.of(context).size.width * 0.5 * progress,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            gameColor,
                            gameColor.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          (progress * 10).floor(),
                          (i) => Container(
                            width: 2,
                            height: 6,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).toInt()}% Complete',
                  style: TextStyle(
                    fontFamily: 'PixelifySans',
                    fontSize: 12,
                    color: gameColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppButton(
            text: 'Continue',
            variant: ButtonVariant.gradient,
            size: ButtonSize.small,
            onPressed: () {},
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
     .fadeIn(duration: 300.ms)
     .slideY(begin: 0.1, end: 0);
  }

  Widget _buildEmptyAssignedGames(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 180,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No assigned games',
              style: TextStyle(
                fontFamily: 'PixelifySans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ll see games assigned by your teacher here',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyInProgressGames(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_esports_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No games in progress',
              style: TextStyle(
                fontFamily: 'PixelifySans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start playing to see your progress',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Browse Games',
              variant: ButtonVariant.gradient,
              leadingIcon: Icons.search,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Assigned Games Section
        Text(
          'Assigned Games',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
              ).animate(delay: Duration(milliseconds: 200 * index))
                .shimmer(duration: 1200.ms, color: colorScheme.primary.withOpacity(0.1));
            },
          ),
        ),
        
        const SizedBox(height: 32),
        
        // In Progress Games Section
        Text(
          'In Progress',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 2,
          itemBuilder: (context, index) {
            return Container(
              height: 100,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ).animate(delay: Duration(milliseconds: 200 * index))
              .shimmer(duration: 1200.ms, color: colorScheme.primary.withOpacity(0.1));
          },
        ),
      ],
    );
  }

  Widget _buildPixelatedIcon(double size, Color color) {
    return Container(
      width: size,
      height: size,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: 9,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (index == 0 || index == 2 || index == 6 || index == 8) {
            return Container();
          }
          return Container(
            color: color,
          );
        },
      ),
    );
  }
} 