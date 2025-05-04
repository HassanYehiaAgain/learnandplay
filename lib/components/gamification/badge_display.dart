import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/models/gamification_models.dart' as gamification;

class BadgeDisplay extends StatelessWidget {
  final gamification.Badge badge;
  final bool isEarned;
  final bool isNew;
  final VoidCallback? onTap;
  final double size;

  const BadgeDisplay({
    super.key,
    required this.badge,
    this.isEarned = true,
    this.isNew = false,
    this.onTap,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Badge container
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEarned
                  ? colorScheme.surface
                  : colorScheme.surfaceVariant.withOpacity(0.5),
              boxShadow: isEarned
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
              border: Border.all(
                color: isEarned
                    ? colorScheme.primary
                    : colorScheme.outline.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(size * 0.15),
              child: isEarned
                  ? Image.asset(
                      badge.iconPath,
                      fit: BoxFit.contain,
                    )
                  : ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0, 0, 0, 0.5, 0,
                      ]),
                      child: Image.asset(
                        badge.iconPath,
                        fit: BoxFit.contain,
                      ),
                    ),
            ),
          ),
          
          // "New" indicator
          if (isNew)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BadgeGrid extends StatelessWidget {
  final List<gamification.Badge> badges;
  final List<String> earnedBadgeIds;
  final List<String> newBadgeIds;
  final Function(gamification.Badge) onBadgeTap;
  final String? categoryFilter;
  final bool showLocked;

  const BadgeGrid({
    super.key,
    required this.badges,
    required this.earnedBadgeIds,
    this.newBadgeIds = const [],
    required this.onBadgeTap,
    this.categoryFilter,
    this.showLocked = true,
  });

  @override
  Widget build(BuildContext context) {
    // Filter badges by category if needed
    final filteredBadges = categoryFilter != null
        ? badges.where((b) => b.category == categoryFilter).toList()
        : badges;
    
    // Filter out locked badges if not showing them
    final displayBadges = showLocked
        ? filteredBadges
        : filteredBadges.where((b) => earnedBadgeIds.contains(b.id)).toList();
    
    if (displayBadges.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No badges available in this category',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: displayBadges.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final badge = displayBadges[index];
        final isEarned = earnedBadgeIds.contains(badge.id);
        final isNew = newBadgeIds.contains(badge.id);
        
        return Column(
          children: [
            Expanded(
              child: BadgeDisplay(
                badge: badge,
                isEarned: isEarned,
                isNew: isNew,
                onTap: () => onBadgeTap(badge),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              badge.name,
              style: TextStyle(
                fontWeight: isEarned ? FontWeight.bold : FontWeight.normal,
                color: isEarned 
                  ? Theme.of(context).colorScheme.onBackground
                  : Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}

class BadgeDetailDialog extends StatelessWidget {
  final gamification.Badge badge;
  final bool isEarned;
  final DateTime? earnedDate;

  const BadgeDetailDialog({
    super.key,
    required this.badge,
    required this.isEarned,
    this.earnedDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surface,
                boxShadow: isEarned
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
                border: Border.all(
                  color: isEarned
                      ? colorScheme.primary
                      : colorScheme.outline.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: isEarned
                    ? Image.asset(
                        badge.iconPath,
                        fit: BoxFit.contain,
                      )
                    : ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0, 0, 0, 0.5, 0,
                        ]),
                        child: Image.asset(
                          badge.iconPath,
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Badge name
            Text(
              badge.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isEarned ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Badge description
            Text(
              badge.description,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Earned status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isEarned ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isEarned ? Colors.green : Colors.grey,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isEarned ? Icons.check_circle : Icons.lock,
                    color: isEarned ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEarned
                        ? earnedDate != null
                            ? 'Earned on ${_formatDate(earnedDate!)}'
                            : 'Earned'
                        : 'Locked',
                    style: TextStyle(
                      color: isEarned ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Close button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class BadgeEarnedAnimation extends StatefulWidget {
  final gamification.Badge badge;
  final VoidCallback? onComplete;

  const BadgeEarnedAnimation({
    super.key,
    required this.badge,
    this.onComplete,
  });

  @override
  State<BadgeEarnedAnimation> createState() => _BadgeEarnedAnimationState();
}

class _BadgeEarnedAnimationState extends State<BadgeEarnedAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _shineAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 40,
      ),
    ]).animate(_controller);
    
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 20,
      ),
    ]).animate(_controller);
    
    _rotateAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.1, end: 0.1).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);
    
    _shineAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.8, curve: Curves.easeInOut),
    ));
    
    _controller.forward();
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.onComplete != null) {
          widget.onComplete!();
        }
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'NEW BADGE EARNED!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotateAnimation.value,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.7),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                        border: Border.all(
                          color: Colors.amber,
                          width: 4,
                        ),
                      ),
                      child: ClipOval(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Image.asset(
                                  widget.badge.iconPath,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            // Shine effect
                            Positioned.fill(
                              child: Transform.translate(
                                offset: Offset(
                                  200 * _shineAnimation.value,
                                  0,
                                ),
                                child: Transform.rotate(
                                  angle: 0.3,
                                  child: Container(
                                    width: 50,
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.badge.name,
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.badge.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  onPressed: widget.onComplete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Continue'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 