import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';

enum ProgressBarStyle {
  standard,
  gradient,
  segmented,
  pixelated,
}

class AnimatedProgressBar extends StatefulWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final ProgressBarStyle style;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final LinearGradient? gradient;
  final bool showPercentage;
  final bool animateChanges;
  final Duration animationDuration;
  final bool showShimmer;
  final int segmentCount;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.height = 16.0,
    this.style = ProgressBarStyle.standard,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.showPercentage = false,
    this.animateChanges = true,
    this.animationDuration = const Duration(milliseconds: 500),
    this.showShimmer = true,
    this.segmentCount = 10,
    this.padding,
    this.borderRadius,
  }) : assert(value >= 0.0 && value <= 1.0, 'Value must be between 0.0 and 1.0');

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar> with SingleTickerProviderStateMixin {
  late double _previousValue;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    if (widget.showShimmer) {
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _previousValue = oldWidget.value;
    
    if (widget.showShimmer != oldWidget.showShimmer) {
      if (widget.showShimmer) {
        _shimmerController.repeat();
      } else {
        _shimmerController.stop();
      }
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final backgroundColor = widget.backgroundColor ?? colorScheme.surfaceContainerHighest;
    final foregroundColor = widget.foregroundColor ?? colorScheme.primary;
    final gradient = widget.gradient ?? AppGradients.purpleToPink;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(8);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showPercentage) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${(widget.value * 100).toInt()}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                fontFamily: 'PixelifySans',
              ),
            ),
          ),
        ],
        
        Container(
          padding: widget.padding,
          child: Stack(
            children: [
              // Background
              Container(
                height: widget.height,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: borderRadius,
                ),
              ),
              
              // Progress fill
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: _previousValue, end: widget.value),
                duration: widget.animateChanges ? widget.animationDuration : Duration.zero,
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return SizedBox(
                    height: widget.height,
                    child: _buildProgressContent(value, foregroundColor, gradient, borderRadius),
                  );
                },
              ),
              
              // Shimmer effect
              if (widget.showShimmer)
                AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return FractionallySizedBox(
                      widthFactor: widget.value,
                      child: Container(
                        height: widget.height,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.0),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            transform: _SlideGradientTransform(_shimmerController.value * 3 - 1),
                          ),
                          borderRadius: borderRadius,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressContent(double value, Color foregroundColor, LinearGradient gradient, BorderRadius borderRadius) {
    switch (widget.style) {
      case ProgressBarStyle.standard:
        return FractionallySizedBox(
          widthFactor: value,
          child: Container(
            decoration: BoxDecoration(
              color: foregroundColor,
              borderRadius: borderRadius,
            ),
          ),
        );
        
      case ProgressBarStyle.gradient:
        return FractionallySizedBox(
          widthFactor: value,
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: borderRadius,
            ),
          ),
        );
        
      case ProgressBarStyle.segmented:
        return _buildSegmentedProgress(value, foregroundColor, gradient, borderRadius);
        
      case ProgressBarStyle.pixelated:
        return _buildPixelatedProgress(value, foregroundColor, gradient, borderRadius);
    }
  }

  Widget _buildSegmentedProgress(double value, Color foregroundColor, LinearGradient gradient, BorderRadius borderRadius) {
    final segmentWidth = 1.0 / widget.segmentCount;
    final filledSegmentCount = (value / segmentWidth).floor();
    const gap = 4.0;
    
    return Row(
      children: List.generate(widget.segmentCount, (index) {
        final isFilled = index < filledSegmentCount;
        final isLast = index == widget.segmentCount - 1;
        
        return Expanded(
          child: Container(
            height: widget.height,
            margin: EdgeInsets.only(right: isLast ? 0 : gap),
            decoration: BoxDecoration(
              color: isFilled ? null : Colors.transparent,
              gradient: isFilled ? gradient : null,
              borderRadius: borderRadius,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPixelatedProgress(double value, Color foregroundColor, LinearGradient gradient, BorderRadius borderRadius) {
    final pixelSize = widget.height;
    final availableWidth = MediaQuery.of(context).size.width;
    final pixelCount = (availableWidth / pixelSize).floor();
    final filledPixelCount = (value * pixelCount).floor();
    
    return Row(
      children: List.generate(pixelCount, (index) {
        final isFilled = index < filledPixelCount;
        
        if (!isFilled) return const SizedBox();
        
        return Container(
          width: pixelSize,
          height: pixelSize,
          decoration: BoxDecoration(
            color: foregroundColor,
            gradient: widget.style == ProgressBarStyle.gradient ? gradient : null,
            borderRadius: BorderRadius.circular(2),
          ),
          margin: const EdgeInsets.only(right: 2),
        );
      }),
    );
  }
}

// Custom transform to move the gradient
class _SlideGradientTransform extends GradientTransform {
  final double slideOffset;

  const _SlideGradientTransform(this.slideOffset);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.identity()..translate(bounds.width * slideOffset);
  }
} 