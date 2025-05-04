import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/models/analytics_models.dart';
import 'package:learn_play_level_up_flutter/widgets/analytics/radar_chart_wrapper.dart';

/// A card that displays a visual summary of a student's progress across different subjects.
class ProgressSummaryCard extends StatelessWidget {
  final StudentAnalytics analytics;
  final String title;
  final Color backgroundColor;
  final Color chartColor;
  
  const ProgressSummaryCard({
    super.key,
    required this.analytics,
    this.title = 'Mastery Breakdown',
    this.backgroundColor = Colors.white,
    this.chartColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Get top 5 subjects for display
    final subjects = analytics.subjectMastery.values.toList();
    subjects.sort((a, b) => b.masteryPercentage.compareTo(a.masteryPercentage));
    final displaySubjects = subjects.take(5).toList();
    
    // Calculate average stats
    final avgScore = analytics.averageScore;
    final totalGames = analytics.totalGamesCompleted;
    final gameTypes = analytics.gameTypePerformance.length;
    
    return Card(
      elevation: 2,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
                Icon(
                  Icons.insights,
                  color: chartColor,
                ),
              ],
            ),
            const Divider(),
            
            // Radar chart and summary
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Radar chart
                if (displaySubjects.isNotEmpty)
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 200,
                      child: MasteryRadarChart(
                        subjects: displaySubjects,
                        color: chartColor,
                      ),
                    ),
                  ),
                
                // Subject labels
                if (displaySubjects.isNotEmpty)
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...displaySubjects.map((subject) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getColorForMastery(subject.masteryPercentage),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    subject.subjectName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                
                if (displaySubjects.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          'No subject data available',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            const Divider(),
            
            // Summary stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  '${avgScore.toStringAsFixed(1)}%',
                  'Average Score',
                ),
                _buildStatItem(
                  context, 
                  totalGames.toString(),
                  'Games Completed',
                ),
                _buildStatItem(
                  context, 
                  gameTypes.toString(),
                  'Game Types Played',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  /// Get color based on mastery percentage.
  Color _getColorForMastery(double mastery) {
    if (mastery >= 90) {
      return Colors.green.shade700;
    } else if (mastery >= 70) {
      return Colors.green;
    } else if (mastery >= 50) {
      return Colors.amber;
    } else if (mastery >= 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
} 