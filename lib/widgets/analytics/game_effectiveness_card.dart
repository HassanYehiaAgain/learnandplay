import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/models/analytics_models.dart';

/// A card that displays game effectiveness metrics.
class GameEffectivenessCard extends StatelessWidget {
  final GameEffectiveness game;
  final VoidCallback? onTap;
  
  const GameEffectivenessCard({
    super.key,
    required this.game,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Game title and type
              Row(
                children: [
                  // Game icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        _getIconForGameType(game.gameType),
                        color: colorScheme.onPrimaryContainer,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Game title and type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.gameTitle,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatGameType(game.gameType),
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Times played
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        game.timesPlayed.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Times Played',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Metrics grid
              Row(
                children: [
                  // Average score
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      'Average Score',
                      '${game.averageScore.toStringAsFixed(1)}%',
                      Icons.score,
                      _getColorForScore(game.averageScore),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Completion rate
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      'Completion',
                      '${game.completionRate.toStringAsFixed(1)}%',
                      Icons.check_circle,
                      _getColorForCompletion(game.completionRate),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Average duration
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      'Avg. Time',
                      _formatDuration(game.averageDuration),
                      Icons.timer,
                      colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  /// Get icon based on game type.
  IconData _getIconForGameType(String gameType) {
    switch (gameType.toLowerCase()) {
      case 'quiz_show':
        return Icons.quiz;
      case 'word_scramble':
        return Icons.shuffle;
      case 'word_guess':
        return Icons.gesture;
      default:
        return Icons.games;
    }
  }
  
  /// Format game type for display.
  String _formatGameType(String gameType) {
    // Convert snake_case to Title Case
    return gameType
        .split('_')
        .map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
  
  /// Format duration to mm:ss or m:ss format.
  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  /// Get color based on completion rate.
  Color _getColorForCompletion(double completionRate) {
    if (completionRate >= 80) {
      return Colors.green;
    } else if (completionRate >= 60) {
      return Colors.amber;
    } else if (completionRate >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  /// Get color based on score.
  Color _getColorForScore(double score) {
    if (score >= 90) {
      return Colors.green.shade700;
    } else if (score >= 70) {
      return Colors.green;
    } else if (score >= 50) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }
} 