import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';

class TrophyCase extends StatelessWidget {
  final List<Map<String, dynamic>> trophies;
  final bool isLoading;

  const TrophyCase({
    super.key,
    required this.trophies,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trophy Case',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: TextStyle(
                  fontFamily: 'PixelifySans',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 220,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: trophies.isEmpty
              ? _buildEmptyShelf(context)
              : _buildTrophyShelf(context),
        ),
      ],
    );
  }

  Widget _buildTrophyShelf(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int i = 0; i < trophies.length.clamp(0, 5); i++)
          _buildTrophy(context, trophies[i], i),
      ],
    );
  }

  Widget _buildTrophy(BuildContext context, Map<String, dynamic> trophy, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLocked = trophy['isLocked'] == true;

    return GestureDetector(
      onTap: () {
        // Show trophy details
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 80,
            decoration: BoxDecoration(
              gradient: isLocked
                  ? null
                  : AppGradients.orangeToYellow,
              color: isLocked ? colorScheme.surfaceContainerHighest : null,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isLocked
                    ? colorScheme.outline.withOpacity(0.3)
                    : Colors.orange.shade300,
                width: 2,
              ),
            ),
            child: isLocked
                ? Center(
                    child: Icon(
                      Icons.lock,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                      size: 24,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        trophy['icon'] as IconData,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          trophy['level'] as String,
                          style: const TextStyle(
                            fontFamily: 'PixelifySans',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
          ).animate(delay: Duration(milliseconds: 100 * index))
           .fadeIn(duration: 600.ms)
           .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          SizedBox(
            width: 64,
            child: Text(
              trophy['title'] as String,
              style: TextStyle(
                fontFamily: 'PixelifySans',
                fontSize: 12,
                color: isLocked
                    ? colorScheme.onSurfaceVariant.withOpacity(0.7)
                    : colorScheme.onSurface,
                fontWeight: isLocked ? FontWeight.normal : FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyShelf(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Your Trophy Case is Empty',
            style: TextStyle(
              fontFamily: 'PixelifySans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete achievements to earn trophies',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trophy Case',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: null,
              child: Text(
                'View All',
                style: TextStyle(
                  fontFamily: 'PixelifySans',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 220,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              4,
              (index) => Container(
                width: 56,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ).animate(delay: Duration(milliseconds: 200 * index))
               .shimmer(duration: 1200.ms, color: colorScheme.primary.withOpacity(0.1)),
            ),
          ),
        ),
      ],
    );
  }
} 