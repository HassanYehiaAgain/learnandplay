import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:learn_play_level_up_flutter/models/analytics_models.dart';

/// A performance chart widget that can display various types of performance metrics.
class PerformanceChart extends StatelessWidget {
  final List<PerformanceTrend> trends;
  final String metricType;
  final String title;
  final String yAxisLabel;
  final Color lineColor;
  final bool showDots;
  final int maxPoints;
  
  const PerformanceChart({
    super.key,
    required this.trends,
    required this.metricType,
    required this.title,
    required this.yAxisLabel,
    this.lineColor = Colors.blue,
    this.showDots = true,
    this.maxPoints = 30,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Filter trends by metric type
    final filteredTrends = trends
        .where((trend) => trend.metricType == metricType)
        .toList();
    
    // Sort by date
    filteredTrends.sort((a, b) => a.date.compareTo(b.date));
    
    // Only take the latest maxPoints
    final displayTrends = filteredTrends.length > maxPoints
        ? filteredTrends.sublist(filteredTrends.length - maxPoints)
        : filteredTrends;
    
    if (displayTrends.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No data available for $title',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    
    // Find min and max values for nice scale
    double minValue = displayTrends.map((t) => t.value).reduce((a, b) => a < b ? a : b);
    double maxValue = displayTrends.map((t) => t.value).reduce((a, b) => a > b ? a : b);
    
    // Add some padding to the min/max
    final padding = (maxValue - minValue) * 0.1;
    minValue = minValue == maxValue ? minValue - 1 : minValue - padding;
    maxValue = minValue == maxValue ? maxValue + 1 : maxValue + padding;
    minValue = minValue < 0 ? 0 : minValue;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: theme.textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: colorScheme.outline.withOpacity(0.3),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: colorScheme.outline.withOpacity(0.3),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: const Text('Date'),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: _calculateXInterval(displayTrends),
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= displayTrends.length) {
                          return const SizedBox();
                        }
                        
                        final date = displayTrends[value.toInt()].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            '${date.month}/${date.day}',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: Text(yAxisLabel),
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _calculateYInterval(minValue, maxValue),
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outline.withOpacity(0.5),
                      width: 1,
                    ),
                    left: BorderSide(
                      color: colorScheme.outline.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                ),
                minX: 0,
                maxX: displayTrends.length - 1.0,
                minY: minValue,
                maxY: maxValue,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: colorScheme.surfaceVariant,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final index = touchedSpot.x.toInt();
                        if (index >= 0 && index < displayTrends.length) {
                          final trend = displayTrends[index];
                          return LineTooltipItem(
                            '${trend.date.month}/${trend.date.day}: ${trend.value.toStringAsFixed(1)}',
                            TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else {
                          return LineTooltipItem(
                            '',
                            TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          );
                        }
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(displayTrends.length, (index) {
                      return FlSpot(index.toDouble(), displayTrends[index].value);
                    }),
                    isCurved: true,
                    color: lineColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: showDots,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: lineColor,
                          strokeWidth: 1,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: lineColor.withOpacity(0.2),
                      gradient: LinearGradient(
                        colors: [
                          lineColor.withOpacity(0.2),
                          lineColor.withOpacity(0.02),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  double _calculateXInterval(List<PerformanceTrend> trends) {
    // Calculate a sensible interval based on the number of data points
    if (trends.length <= 7) {
      return 1; // Show every label if few points
    } else if (trends.length <= 14) {
      return 2; // Show every second label
    } else if (trends.length <= 30) {
      return 3; // Show every third label
    } else {
      return 5; // Show every fifth label for larger datasets
    }
  }
  
  double _calculateYInterval(double min, double max) {
    final range = max - min;
    
    if (range <= 5) {
      return 1;
    } else if (range <= 20) {
      return 5;
    } else if (range <= 100) {
      return 10;
    } else {
      return 20;
    }
  }
} 