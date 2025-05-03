import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';

class Trophy {
  final String name;
  final String description;
  final IconData icon;
  final DateTime achievedDate;
  final String? imagePath;
  final LinearGradient? gradient;
  final bool isLocked;

  Trophy({
    required this.name,
    required this.description,
    required this.icon,
    required this.achievedDate,
    this.imagePath,
    this.gradient,
    this.isLocked = false,
  });
}

class TrophyCase extends StatefulWidget {
  final List<Trophy> trophies;
  final String title;
  final String? subtitle;
  final bool showSeeAllButton;
  final VoidCallback? onSeeAllPressed;

  const TrophyCase({
    super.key,
    required this.trophies,
    this.title = 'Trophy Case',
    this.subtitle,
    this.showSeeAllButton = true,
    this.onSeeAllPressed,
  });

  @override
  State<TrophyCase> createState() => _TrophyCaseState();
}

class _TrophyCaseState extends State<TrophyCase> with TickerProviderStateMixin {
  late AnimationController _shineController;
  late List<AnimationController> _bounceControllers = [];
  late List<Animation<double>> _bounceAnimations = [];

  @override
  void initState() {
    super.initState();
    
    // Initialize shine animation controller
    _shineController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _shineController.repeat(reverse: false);
    
    // Initialize bounce animations for each trophy
    _initializeBounceAnimations();
  }

  void _initializeBounceAnimations() {
    _bounceControllers = List.generate(
      widget.trophies.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );
    
    _bounceAnimations = _bounceControllers.map((controller) {
      return Tween<double>(begin: 0, end: -10).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        ),
      );
    }).toList();
  }
  
  @override
  void didUpdateWidget(TrophyCase oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trophies.length != oldWidget.trophies.length) {
      // Dispose old controllers first
      for (var controller in _bounceControllers) {
        controller.dispose();
      }
      
      // Initialize with new count
      _initializeBounceAnimations();
    }
  }

  @override
  void dispose() {
    _shineController.dispose();
    for (var controller in _bounceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _animateTrophy(int index) {
    _bounceControllers[index].forward().then((_) {
      _bounceControllers[index].reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontFamily: 'PixelifySans',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
            if (widget.showSeeAllButton && widget.onSeeAllPressed != null)
              TextButton(
                onPressed: widget.onSeeAllPressed,
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
        
        // Trophy grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: widget.trophies.length,
          itemBuilder: (context, index) {
            final trophy = widget.trophies[index];
            
            return AnimatedBuilder(
              animation: _bounceAnimations[index],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, trophy.isLocked ? 0 : _bounceAnimations[index].value),
                  child: child,
                );
              },
              child: MouseRegion(
                onEnter: trophy.isLocked 
                    ? null 
                    : (_) => _animateTrophy(index),
                child: _buildTrophyItem(context, trophy, index),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTrophyItem(BuildContext context, Trophy trophy, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: trophy.isLocked 
            ? null 
            : (trophy.gradient ?? AppGradients.purpleToPink),
        color: trophy.isLocked ? colorScheme.surfaceContainerHighest : null,
        boxShadow: trophy.isLocked
            ? null
            : [
                BoxShadow(
                  color: (trophy.gradient?.colors.first ?? colorScheme.primary).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: AnimatedBuilder(
        animation: _shineController,
        builder: (context, child) {
          return trophy.isLocked
              ? _buildLockedTrophy(trophy)
              : ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.5),
                        Colors.white,
                        Colors.white.withOpacity(0.5),
                      ],
                      stops: const [0.35, 0.5, 0.65],
                      transform: _GradientRotation(
                        2.0 * 3.14 * _shineController.value,
                      ),
                    ).createShader(bounds);
                  },
                  child: child,
                );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                trophy.icon,
                size: 36,
                color: trophy.isLocked
                    ? colorScheme.onSurface.withOpacity(0.3)
                    : Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                trophy.name,
                style: TextStyle(
                  fontFamily: 'PixelifySans',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: trophy.isLocked
                      ? colorScheme.onSurface.withOpacity(0.5)
                      : Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (!trophy.isLocked) ...[
                const SizedBox(height: 8),
                Text(
                  'Achieved ${_formatDate(trophy.achievedDate)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockedTrophy(Trophy trophy) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          trophy.icon,
          size: 36,
          color: colorScheme.onSurface.withOpacity(0.3),
        ),
        const Icon(
          Icons.lock,
          size: 24,
          color: Colors.grey,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Custom transform to rotate the gradient
class _GradientRotation extends GradientTransform {
  final double radians;

  const _GradientRotation(this.radians);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final double sinRotation = math.sin(radians);
    final double cosRotation = math.cos(radians);

    final double dx = bounds.center.dx;
    final double dy = bounds.center.dy;

    return Matrix4.identity()
      ..translate(dx, dy)
      ..rotateZ(radians)
      ..translate(-dx, -dy);
  }
} 