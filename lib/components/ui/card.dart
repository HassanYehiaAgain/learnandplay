import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';

/// A custom card component with various styles and configurations
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final bool hasShadow;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final double borderWidth;
  final VoidCallback? onTap;
  final bool isInteractive;
  final bool isHoverable;
  
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.hasShadow = true,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 16,
    this.borderWidth = 1,
    this.onTap,
    this.isInteractive = false,
    this.isHoverable = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;
    final effectiveBorderColor = borderColor ?? colorScheme.outline.withOpacity(0.2);
    
    final cardDecoration = BoxDecoration(
      color: effectiveBackgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: effectiveBorderColor,
        width: borderWidth,
      ),
      boxShadow: hasShadow
          ? [
              BoxShadow(
                color: colorScheme.shadow,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
    
    Widget cardContent = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: cardDecoration,
      child: child,
    );
    
    if (isInteractive || onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: colorScheme.primary.withOpacity(0.1),
          highlightColor: colorScheme.primary.withOpacity(0.05),
          child: cardContent,
        ),
      );
    } else if (isHoverable) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: cardContent,
      );
    } else {
      return cardContent;
    }
  }
}

class AppCardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? action;

  const AppCardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
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
        ),
        if (action != null) action!,
      ],
    );
  }
}

class AppCardFooter extends StatelessWidget {
  final List<Widget> actions;
  final MainAxisAlignment alignment;

  const AppCardFooter({
    super.key,
    required this.actions,
    this.alignment = MainAxisAlignment.end,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: actions.asMap().entries.map((entry) {
        final index = entry.key;
        final action = entry.value;
        
        return Padding(
          padding: EdgeInsets.only(
            left: index > 0 ? 8 : 0,
          ),
          child: action,
        );
      }).toList(),
    );
  }
}

class AppCardContent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AppCardContent({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: child,
    );
  }
}

class AchievementCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final LinearGradient? gradient;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient ?? AppGradients.purpleToPink,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (gradient?.colors.first ?? theme.colorScheme.primary).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'PixelifySans',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrophyCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool isLocked;
  final VoidCallback? onTap;

  const TrophyCard({
    super.key,
    required this.title,
    required this.imageUrl,
    this.isLocked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: isLocked 
              ? LinearGradient(
                  colors: [Colors.grey.shade700, Colors.grey.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ) 
              : AppGradients.orangeToYellow,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isLocked 
                  ? Colors.black.withOpacity(0.2)
                  : const Color(0xFFF97316).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLocked)
                Icon(
                  Icons.lock,
                  color: Colors.white.withOpacity(0.7),
                  size: 48,
                )
              else
                Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 48,
                    );
                  },
                ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PixelifySans',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GradientBorderCard extends StatefulWidget {
  final Widget child;
  final LinearGradient gradient;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool enableHoverAnimation;
  final bool enablePulseEffect;

  const GradientBorderCard({
    super.key,
    required this.child,
    required this.gradient,
    this.borderWidth = 2.0,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.backgroundColor,
    this.onTap,
    this.enableHoverAnimation = true,
    this.enablePulseEffect = false,
  });

  @override
  State<GradientBorderCard> createState() => _GradientBorderCardState();
}

class _GradientBorderCardState extends State<GradientBorderCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.enablePulseEffect) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GradientBorderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enablePulseEffect != oldWidget.enablePulseEffect) {
      if (widget.enablePulseEffect) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final defaultRadius = widget.borderRadius ?? BorderRadius.circular(12);
    
    return MouseRegion(
      onEnter: (_) => widget.enableHoverAnimation ? setState(() => _isHovered = true) : null,
      onExit: (_) => widget.enableHoverAnimation ? setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              transform: widget.enableHoverAnimation && _isHovered
                  ? Matrix4.translationValues(0, -8, 0)
                  : Matrix4.identity(),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: defaultRadius,
                boxShadow: widget.enableHoverAnimation && _isHovered || widget.enablePulseEffect
                    ? [
                        BoxShadow(
                          color: widget.gradient.colors.first.withOpacity(0.3),
                          blurRadius: widget.enablePulseEffect 
                              ? 15 * _pulseAnimation.value
                              : 10,
                          spreadRadius: widget.enablePulseEffect 
                              ? 2 * _pulseAnimation.value
                              : 1,
                        ),
                      ]
                    : [],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: defaultRadius,
                  gradient: widget.gradient,
                ),
                child: Container(
                  margin: EdgeInsets.all(widget.borderWidth),
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? colorScheme.surface,
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        defaultRadius.topLeft.y - widget.borderWidth,
                      ),
                    ),
                  ),
                  child: widget.child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class GameTemplateCard extends StatelessWidget {
  final String title;
  final String description;
  final String? imagePath;
  final IconData? icon;
  final VoidCallback? onTap;
  final LinearGradient? borderGradient;
  final bool animate;
  final double difficulty;
  final List<String>? tags;

  const GameTemplateCard({
    super.key,
    required this.title,
    required this.description,
    this.imagePath,
    this.icon,
    this.onTap,
    this.borderGradient,
    this.animate = true,
    this.difficulty = 1, // 1-5 scale
    this.tags,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return GradientBorderCard(
      gradient: borderGradient ?? AppGradients.purpleToPink,
      onTap: onTap,
      enableHoverAnimation: animate,
      enablePulseEffect: animate,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game image or icon
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
              ),
              child: imagePath != null
                  ? Image.asset(
                      imagePath!,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Icon(
                        icon ?? Icons.games,
                        size: 64,
                        color: colorScheme.primary,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Title and difficulty stars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'PixelifySans',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < difficulty ? Icons.star : Icons.star_border,
                    color: index < difficulty 
                        ? colorScheme.secondary 
                        : colorScheme.onSurfaceVariant.withOpacity(0.3),
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Description
          Text(
            description,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Tags
          if (tags != null && tags!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags!.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
} 