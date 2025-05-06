import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/models/analytics_models.dart';
import 'dart:math' as math;

/// A simpler implementation of a radar/spider chart for showing mastery across subjects
class MasteryRadarChart extends StatelessWidget {
  final List<SubjectMastery> subjects;
  final Color color;
  final double size;
  
  const MasteryRadarChart({
    super.key,
    required this.subjects,
    this.color = Colors.blue,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // If no subjects, show empty state
    if (subjects.isEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            'No subject data',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: RadarChartPainter(
          subjects: subjects,
          color: color,
          backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.2),
          gridColor: colorScheme.outline.withOpacity(0.3),
        ),
        child: const Center(),
      ),
    );
  }
}

class RadarChartPainter extends CustomPainter {
  final List<SubjectMastery> subjects;
  final Color color;
  final Color backgroundColor;
  final Color gridColor;
  
  RadarChartPainter({
    required this.subjects,
    required this.color,
    required this.backgroundColor,
    required this.gridColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    final count = subjects.length;
    
    if (count < 3) return; // Need at least 3 points for a polygon
    
    // Draw background grid
    _drawGrid(canvas, center, radius, count);
    
    // Draw data polygon
    _drawDataPolygon(canvas, center, radius, count);
  }
  
  void _drawGrid(Canvas canvas, Offset center, double radius, int count) {
    // Draw concentric circles for the grid
    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // Draw 4 concentric circles (20%, 40%, 60%, 80%, 100%)
    for (int i = 1; i <= 5; i++) {
      final circleRadius = radius * (i / 5);
      canvas.drawCircle(center, circleRadius, gridPaint);
    }
    
    // Draw radial lines
    for (int i = 0; i < count; i++) {
      final angle = (2 * math.pi * i) / count - math.pi / 2;
      final dx = center.dx + radius * math.cos(angle);
      final dy = center.dy + radius * math.sin(angle);
      
      canvas.drawLine(center, Offset(dx, dy), gridPaint);
    }
  }
  
  void _drawDataPolygon(Canvas canvas, Offset center, double radius, int count) {
    final dataPath = Path();
    final fillPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Draw data polygon
    for (int i = 0; i < count; i++) {
      final angle = (2 * math.pi * i) / count - math.pi / 2;
      final value = subjects[i].masteryPercentage / 100;
      final adjustedRadius = radius * value;
      final dx = center.dx + adjustedRadius * math.cos(angle);
      final dy = center.dy + adjustedRadius * math.sin(angle);
      
      if (i == 0) {
        dataPath.moveTo(dx, dy);
      } else {
        dataPath.lineTo(dx, dy);
      }
      
      // Draw data point
      canvas.drawCircle(Offset(dx, dy), 3, strokePaint);
    }
    
    dataPath.close();
    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);
    
    // Draw subject labels
    final textStyle = TextStyle(
      color: color,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );
    
    for (int i = 0; i < count; i++) {
      final angle = (2 * math.pi * i) / count - math.pi / 2;
      final dx = center.dx + (radius + 15) * math.cos(angle);
      final dy = center.dy + (radius + 15) * math.sin(angle);
      
      final textSpan = TextSpan(
        text: subjects[i].subjectName.length > 8 
            ? '${subjects[i].subjectName.substring(0, 8)}...'
            : subjects[i].subjectName,
        style: textStyle,
      );
      
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      
      textPainter.layout();
      textPainter.paint(canvas, Offset(dx - textPainter.width / 2, dy - textPainter.height / 2));
    }
  }
  
  @override
  bool shouldRepaint(covariant RadarChartPainter oldDelegate) {
    return oldDelegate.subjects != subjects || 
           oldDelegate.color != color ||
           oldDelegate.backgroundColor != backgroundColor ||
           oldDelegate.gridColor != gridColor;
  }
} 