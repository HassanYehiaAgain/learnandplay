import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/models/analytics_models.dart';

/// A card that displays a student's progress information.
class StudentProgressCard extends StatelessWidget {
  final StudentPerformanceSummary student;
  final VoidCallback? onTap;
  
  const StudentProgressCard({
    super.key,
    required this.student,
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
            children: [
              // Student info and completion rate
              Row(
                children: [
                  // Student avatar/icon
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    radius: 24,
                    child: student.avatar != null && student.avatar!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              student.avatar!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                  Text(student.studentName.substring(0, 1).toUpperCase()),
                            ),
                          )
                        : Text(student.studentName.substring(0, 1).toUpperCase()),
                  ),
                  const SizedBox(width: 16),
                  
                  // Student name and last active date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.studentName,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last active: ${_formatDate(student.lastActive)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Completion rate
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${student.completionRate.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getColorForCompletion(student.completionRate),
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
              
              // Progress bar and stats
              Row(
                children: [
                  // Games completed indicator
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Games: ${student.gamesCompleted}/${student.gamesAssigned}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: student.gamesAssigned > 0 
                                ? student.gamesCompleted / student.gamesAssigned 
                                : 0,
                            minHeight: 8,
                            backgroundColor: colorScheme.surfaceVariant,
                            color: _getColorForCompletion(student.completionRate),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Average score
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.score,
                              size: 16,
                              color: _getColorForScore(student.averageScore),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Avg. Score: ${student.averageScore.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              student.gamesAssigned > 0 &&
                                      student.gamesCompleted == student.gamesAssigned
                                  ? Icons.check_circle
                                  : student.gamesCompleted > 0
                                      ? Icons.incomplete_circle
                                      : Icons.cancel,
                              size: 16,
                              color: student.gamesAssigned > 0 &&
                                      student.gamesCompleted == student.gamesAssigned
                                  ? Colors.green
                                  : student.gamesCompleted > 0
                                      ? Colors.orange
                                      : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              student.gamesAssigned > 0 &&
                                      student.gamesCompleted == student.gamesAssigned
                                  ? 'Completed'
                                  : student.gamesCompleted > 0
                                      ? 'In Progress'
                                      : 'Not Started',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
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
  
  /// Format the date to a readable string.
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
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