import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';

class AchievementBadge extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color? color;
  final LinearGradient? gradient;
  final bool isUnlocked;
  final bool showGlow;
  final double size;
  final VoidCallback? onTap;
  final String? tooltipMessage;

  const AchievementBadge({
    super.key,
    required this.title,
    required this.icon,
    this.color,
    this.gradient,
    this.isUnlocked = true,
    this.showGlow = true,
    this.size = 80.0,
    this.onTap,
    this.tooltipMessage,
  });

  @override
  State<AchievementBadge> createState() => _AchievementBadgeState();
}

class _AchievementBadgeState extends State<AchievementBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.08)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _rotateAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isUnlocked && widget.showGlow) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AchievementBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isUnlocked != oldWidget.isUnlocked ||
        widget.showGlow != oldWidget.showGlow) {
      if (widget.isUnlocked && widget.showGlow) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final badge = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _isHovered && widget.isUnlocked 
                  ? 1.1 
                  : (widget.showGlow && widget.isUnlocked ? _pulseAnimation.value : 1.0),
              child: Transform.rotate(
                angle: widget.isUnlocked && _isHovered ? _rotateAnimation.value : 0.0,
                child: child,
              ),
            );
          },
          child: _buildBadge(colorScheme),
        ),
      ),
    );
    
    // Add tooltip if provided
    if (widget.tooltipMessage != null) {
      return Tooltip(
        message: widget.tooltipMessage!,
        verticalOffset: 20,
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          color: colorScheme.onInverseSurface,
          fontSize: 12,
        ),
        child: badge,
      );
    }
    
    return badge;
  }

  Widget _buildBadge(ColorScheme colorScheme) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: widget.isUnlocked
            ? (widget.gradient ?? AppGradients.orangeToYellow)
            : LinearGradient(
                colors: [Colors.grey.shade700, Colors.grey.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: widget.isUnlocked && widget.showGlow
            ? [
                BoxShadow(
                  color: (widget.gradient?.colors.first ?? widget.color ?? colorScheme.primary)
                      .withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Badge content
          Center(
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: widget.size / 2.5,
            ),
          ),
          
          // Lock overlay for locked badges
          if (!widget.isUnlocked)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: Center(
                child: Icon(
                  Icons.lock,
                  color: Colors.white.withOpacity(0.7),
                  size: widget.size / 3,
                ),
              ),
            ),
            
          // Pixel border
          LayoutBuilder(
            builder: (context, constraints) {
              return CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: PixelBorderPainter(
                  color: Colors.white.withOpacity(0.8),
                  pixelSize: widget.size / 25,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Painter for pixel-style border
class PixelBorderPainter extends CustomPainter {
  final Color color;
  final double pixelSize;

  PixelBorderPainter({
    required this.color,
    this.pixelSize = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;
    
    // Draw pixels around the circle border
    final totalPixels = (2 * math.pi * radius / pixelSize).round();
    final anglePerPixel = 2 * math.pi / totalPixels;
    
    for (int i = 0; i < totalPixels; i++) {
      final angle = i * anglePerPixel;
      final x = centerX + radius * 0.9 * math.cos(angle);
      final y = centerY + radius * 0.9 * math.sin(angle);
      
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, y),
          width: pixelSize,
          height: pixelSize,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(PixelBorderPainter oldDelegate) =>
      color != oldDelegate.color || pixelSize != oldDelegate.pixelSize;
}

// Grid of achievement badges
class AchievementBadgeGrid extends StatelessWidget {
  final List<AchievementBadgeData> badges;
  final String title;
  final String? subtitle;
  final int crossAxisCount;
  final double spacing;
  final bool showLabels;
  final VoidCallback? onSeeAllPressed;

  const AchievementBadgeGrid({
    super.key,
    required this.badges,
    this.title = 'Achievements',
    this.subtitle,
    this.crossAxisCount = 4,
    this.spacing = 16.0,
    this.showLabels = true,
    this.onSeeAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and see all button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'PixelifySans',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
            if (onSeeAllPressed != null)
              TextButton(
                onPressed: onSeeAllPressed,
                child: Row(
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Grid of badges
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: showLabels ? 0.75 : 1.0,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            
            return Column(
              children: [
                AchievementBadge(
                  title: badge.title,
                  icon: badge.icon,
                  color: badge.color,
                  gradient: badge.gradient,
                  isUnlocked: badge.isUnlocked,
                  tooltipMessage: badge.description,
                  onTap: badge.onTap,
                ),
                if (showLabels) ...[
                  const SizedBox(height: 8),
                  Text(
                    badge.title,
                    style: TextStyle(
                      fontFamily: 'PixelifySans',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: badge.isUnlocked 
                          ? colorScheme.onSurface 
                          : colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class AchievementBadgeData {
  final String title;
  final String description;
  final IconData icon;
  final Color? color;
  final LinearGradient? gradient;
  final bool isUnlocked;
  final VoidCallback? onTap;

  AchievementBadgeData({
    required this.title,
    required this.description,
    required this.icon,
    this.color,
    this.gradient,
    this.isUnlocked = true,
    this.onTap,
  });
} 