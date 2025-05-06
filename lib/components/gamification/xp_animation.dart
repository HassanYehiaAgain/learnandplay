import 'dart:math';
import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/models/gamification_models.dart' as gamification;

class XpGainAnimation extends StatefulWidget {
  final int xpAmount;
  final VoidCallback? onComplete;
  final bool showLevelUp;
  final gamification.XpLevel? oldLevel;
  final gamification.XpLevel? newLevel;

  const XpGainAnimation({
    super.key,
    required this.xpAmount,
    this.onComplete,
    this.showLevelUp = false,
    this.oldLevel,
    this.newLevel,
  });

  @override
  State<XpGainAnimation> createState() => _XpGainAnimationState();
}

class _XpGainAnimationState extends State<XpGainAnimation> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  // For particle effects
  final List<_XpParticle> _particles = [];
  final Random _random = Random();
  static const int _particleCount = 20;
  
  @override
  void initState() {
    super.initState();
    
    // Setup fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));
    
    // Setup scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    // Setup particle animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Generate particles
    _generateParticles();
    
    // Start animations
    _fadeController.forward().then((_) {
      _fadeController.reverse().then((_) {
        if (widget.onComplete != null) {
          widget.onComplete!();
        }
      });
    });
    
    _scaleController.forward();
    _particleController.forward();
  }
  
  void _generateParticles() {
    for (int i = 0; i < _particleCount; i++) {
      final double angle = _random.nextDouble() * 2 * pi;
      final double distance = _random.nextDouble() * 100 + 50;
      final double size = _random.nextDouble() * 10 + 5;
      final double speed = _random.nextDouble() * 0.5 + 0.5;
      
      _particles.add(_XpParticle(
        angle: angle,
        distance: distance,
        size: size,
        speed: speed,
        color: _getRandomXpColor(),
      ));
    }
  }
  
  Color _getRandomXpColor() {
    final colors = [
      Colors.yellow.shade700,
      Colors.amber.shade500,
      Colors.orange.shade500,
      Colors.yellow.shade500,
    ];
    return colors[_random.nextInt(colors.length)];
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Particles
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(300, 300),
              painter: _ParticlePainter(
                particles: _particles,
                progress: _particleController.value,
              ),
            );
          },
        ),
        
        // XP Text
        ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // XP Amount
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.yellow],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+${widget.xpAmount} XP',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Level Up (if applicable)
                if (widget.showLevelUp && widget.oldLevel != null && widget.newLevel != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [widget.oldLevel!.color, widget.newLevel!.color],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.newLevel!.color.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Text(
                            'LEVEL UP!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            children: [
                              TextSpan(
                                text: 'Level ${widget.oldLevel!.level}',
                                style: TextStyle(
                                  color: widget.oldLevel!.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(text: ' → '),
                              TextSpan(
                                text: 'Level ${widget.newLevel!.level}',
                                style: TextStyle(
                                  color: widget.newLevel!.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.newLevel!.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.newLevel!.color,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _XpParticle {
  final double angle;
  final double distance;
  final double size;
  final double speed;
  final Color color;
  
  _XpParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.speed,
    required this.color,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_XpParticle> particles;
  final double progress;
  
  _ParticlePainter({
    required this.particles,
    required this.progress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    for (final particle in particles) {
      final adjustedProgress = progress * particle.speed;
      
      // Particle position based on angle and distance
      final double x = center.dx + cos(particle.angle) * particle.distance * adjustedProgress;
      final double y = center.dy + sin(particle.angle) * particle.distance * adjustedProgress;
      
      // Fade out as they travel
      final opacity = 1.0 - adjustedProgress;
      
      // Size changes over time
      final currentSize = particle.size * (1.0 - adjustedProgress * 0.5);
      
      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      
      // Draw particle
      canvas.drawCircle(Offset(x, y), currentSize, paint);
    }
  }
  
  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class XpRewardOverlay extends StatelessWidget {
  final int xpAmount;
  final bool leveledUp;
  final gamification.XpLevel? oldLevel;
  final gamification.XpLevel? newLevel;
  final VoidCallback onDismiss;

  const XpRewardOverlay({
    super.key,
    required this.xpAmount,
    this.leveledUp = false,
    this.oldLevel,
    this.newLevel,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: InkWell(
        onTap: onDismiss,
        child: Center(
          child: XpGainAnimation(
            xpAmount: xpAmount,
            showLevelUp: leveledUp,
            oldLevel: oldLevel,
            newLevel: newLevel,
          ),
        ),
      ),
    );
  }
}

// Helper method to show XP gain as an overlay
void showXpGainOverlay(
  BuildContext context, {
  required int xpAmount,
  bool leveledUp = false,
  gamification.XpLevel? oldLevel,
  gamification.XpLevel? newLevel,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'XP Gain',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return XpRewardOverlay(
        xpAmount: xpAmount,
        leveledUp: leveledUp,
        oldLevel: oldLevel,
        newLevel: newLevel,
        onDismiss: () => Navigator.of(context).pop(),
      );
    },
  );
} 