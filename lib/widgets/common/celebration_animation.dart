import 'package:flutter/material.dart';

class CelebrationAnimation extends StatefulWidget {
  const CelebrationAnimation({Key? key}) : super(key: key);

  @override
  _CelebrationAnimationState createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<CelebrationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.star,
                  size: 120,
                  color: Colors.amber.shade300,
                ),
                const Icon(
                  Icons.star,
                  size: 100,
                  color: Colors.amber,
                ),
                Icon(
                  Icons.star,
                  size: 80,
                  color: Colors.amber.shade600,
                ),
                const Icon(
                  Icons.emoji_events,
                  size: 48,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 