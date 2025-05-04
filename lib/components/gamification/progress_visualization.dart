import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SubjectProgressCard extends StatelessWidget {
  final String subjectName;
  final String subjectIcon;
  final double completionPercentage;
  final int gamesCompleted;
  final int perfectScores;
  final int xpEarned;

  const SubjectProgressCard({
    super.key,
    required this.subjectName,
    required this.subjectIcon,
    required this.completionPercentage,
    required this.gamesCompleted,
    required this.perfectScores,
    required this.xpEarned,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      subjectIcon,
                      width: 24,
                      height: 24,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Subject info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subjectName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$xpEarned XP earned',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Completion percentage
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primaryContainer.withOpacity(0.2),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: completionPercentage / 100,
                        backgroundColor: colorScheme.surfaceVariant,
                        color: colorScheme.primary,
                        strokeWidth: 5,
                      ),
                      Text(
                        '${completionPercentage.toInt()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard(
                  icon: Icons.videogame_asset,
                  value: gamesCompleted.toString(),
                  label: 'Games',
                ),
                _StatCard(
                  icon: Icons.emoji_events,
                  value: perfectScores.toString(),
                  label: 'Perfect Scores',
                ),
                _StatCard(
                  icon: Icons.auto_graph,
                  value: '${(perfectScores / (gamesCompleted > 0 ? gamesCompleted : 1) * 100).toInt()}%',
                  label: 'Accuracy',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressGraph extends StatelessWidget {
  final List<double> dailyXpValues;
  final List<String> labels;
  final String title;
  final double maxY;

  const ProgressGraph({
    super.key,
    required this.dailyXpValues,
    required this.labels,
    required this.title,
    this.maxY = 200,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your XP earnings over time',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 50,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: colorScheme.outlineVariant.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value.toInt() >= labels.length || value.toInt() < 0) {
                            return const SizedBox();
                          }
                          
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8,
                            child: Text(
                              labels[value.toInt()],
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 50,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8,
                            child: Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  minX: 0,
                  maxX: dailyXpValues.length - 1.toDouble(),
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        dailyXpValues.length,
                        (index) => FlSpot(index.toDouble(), dailyXpValues[index]),
                      ),
                      isCurved: true,
                      color: colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: colorScheme.primary,
                            strokeWidth: 0,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'XP earned',
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
    );
  }
}

class MasteryMap extends StatelessWidget {
  final Map<String, double> subjectMasteryPercentages;
  final Map<String, String> subjectIcons;

  const MasteryMap({
    super.key,
    required this.subjectMasteryPercentages,
    required this.subjectIcons,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Subject Mastery Map',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your progress across different subjects',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: subjectMasteryPercentages.length,
              itemBuilder: (context, index) {
                final subject = subjectMasteryPercentages.keys.elementAt(index);
                final percentage = subjectMasteryPercentages[subject] ?? 0.0;
                final iconPath = subjectIcons[subject] ?? '';
                
                return _SubjectMasteryCell(
                  subjectName: subject,
                  percentage: percentage,
                  iconPath: iconPath,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectMasteryCell extends StatelessWidget {
  final String subjectName;
  final double percentage;
  final String iconPath;
  
  const _SubjectMasteryCell({
    required this.subjectName,
    required this.percentage,
    required this.iconPath,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Calculate color based on mastery level
    Color masteryColor;
    if (percentage < 25) {
      masteryColor = Colors.red.shade300; // Beginner
    } else if (percentage < 50) {
      masteryColor = Colors.orange.shade300; // Intermediate
    } else if (percentage < 75) {
      masteryColor = Colors.blue.shade300; // Advanced
    } else {
      masteryColor = Colors.green.shade300; // Master
    }
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Progress circle
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              child: CircularProgressIndicator(
                value: percentage / 100,
                backgroundColor: colorScheme.surfaceVariant,
                color: masteryColor,
                strokeWidth: 8,
              ),
            ),
            
            // Subject icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: masteryColor.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  color: masteryColor,
                ),
              ),
            ),
            
            // Percentage indicator
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: masteryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: Text(
                  '${percentage.toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subjectName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class LearningPathVisualization extends StatelessWidget {
  final List<Map<String, dynamic>> pathNodes;
  final int currentNodeIndex;

  const LearningPathVisualization({
    super.key,
    required this.pathNodes,
    required this.currentNodeIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Learning Path',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your journey through the curriculum',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            
            // The learning path visualization
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pathNodes.length,
              itemBuilder: (context, index) {
                final node = pathNodes[index];
                final nodeTitle = node['title'] as String;
                final nodeIsComplete = node['isComplete'] as bool;
                final nodePrimarySkill = node['primarySkill'] as String;
                final nodeIcon = node['icon'] as String;
                
                final isActive = index == currentNodeIndex;
                final isPast = index < currentNodeIndex;
                
                return _LearningPathNode(
                  title: nodeTitle,
                  isComplete: nodeIsComplete,
                  primarySkill: nodePrimarySkill,
                  iconPath: nodeIcon,
                  isActive: isActive,
                  isPast: isPast,
                  isLast: index == pathNodes.length - 1,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningPathNode extends StatelessWidget {
  final String title;
  final bool isComplete;
  final String primarySkill;
  final String iconPath;
  final bool isActive;
  final bool isPast;
  final bool isLast;
  
  const _LearningPathNode({
    required this.title,
    required this.isComplete,
    required this.primarySkill,
    required this.iconPath,
    required this.isActive,
    required this.isPast,
    required this.isLast,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color nodeColor;
    if (isComplete) {
      nodeColor = Colors.green;
    } else if (isActive) {
      nodeColor = colorScheme.primary;
    } else {
      nodeColor = colorScheme.outline;
    }
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline with node
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: nodeColor,
                  border: Border.all(
                    color: colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    isComplete ? Icons.check : Icons.circle,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isPast ? Colors.green : colorScheme.outlineVariant.withOpacity(0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          
          // Node content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isActive
                    ? colorScheme.primaryContainer.withOpacity(0.2)
                    : colorScheme.surfaceVariant.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? colorScheme.primary : colorScheme.outlineVariant,
                  width: isActive ? 1 : 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? colorScheme.primaryContainer
                              : colorScheme.surfaceVariant,
                        ),
                        child: Center(
                          child: Image.asset(
                            iconPath,
                            width: 20,
                            height: 20,
                            color: isActive
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Title and skill
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isActive
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Primary Skill: $primarySkill',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isComplete
                              ? Colors.green.withOpacity(0.1)
                              : isActive
                                  ? colorScheme.primary.withOpacity(0.1)
                                  : colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isComplete
                                ? Colors.green
                                : isActive
                                    ? colorScheme.primary
                                    : colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          isComplete
                              ? 'Completed'
                              : isActive
                                  ? 'Current'
                                  : 'Upcoming',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isComplete
                                ? Colors.green
                                : isActive
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 