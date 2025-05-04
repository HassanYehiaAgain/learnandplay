import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/models/analytics_models.dart';

/// A card that displays progress information for a specific subject.
class SubjectProgressCard extends StatelessWidget {
  final SubjectCompletionRate subject;
  final VoidCallback? onTap;
  
  const SubjectProgressCard({
    super.key,
    required this.subject,
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
              // Subject name and completion rate
              Row(
                children: [
                  // Subject icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.book,
                        color: colorScheme.onSecondaryContainer,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Subject name
                  Expanded(
                    child: Text(
                      subject.subjectName,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Completion rate
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${subject.completionRate.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getColorForCompletion(subject.completionRate),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Completion',
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
              
              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Games: ${subject.gamesCompleted}/${subject.gamesAssigned}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${(subject.gamesCompleted / subject.gamesAssigned * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: subject.gamesAssigned > 0 
                          ? subject.gamesCompleted / subject.gamesAssigned 
                          : 0,
                      minHeight: 8,
                      backgroundColor: colorScheme.surfaceVariant,
                      color: _getColorForCompletion(subject.completionRate),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // View details button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.analytics, size: 18),
                    label: const Text('View Details'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
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
} 