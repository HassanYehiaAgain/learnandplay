import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PixelButtonVariant {
  primary,
  secondary,
  success,
  danger,
  warning,
  info,
}

enum PixelButtonSize {
  small,
  medium,
  large,
}

class PixelButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final PixelButtonVariant variant;
  final PixelButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isFullWidth;
  final bool isLoading;
  final bool enableGlowEffect;
  final bool enableClickAnimation;
  final bool enableSound;

  const PixelButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = PixelButtonVariant.primary,
    this.size = PixelButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isFullWidth = false,
    this.isLoading = false,
    this.enableGlowEffect = true,
    this.enableClickAnimation = true,
    this.enableSound = true,
  });

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );
    
    if (widget.enableGlowEffect) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PixelButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableGlowEffect != oldWidget.enableGlowEffect) {
      if (widget.enableGlowEffect) {
        _glowController.repeat(reverse: true);
      } else {
        _glowController.stop();
      }
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Color _getBaseColor() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    switch (widget.variant) {
      case PixelButtonVariant.primary:
        return colorScheme.primary;
      case PixelButtonVariant.secondary:
        return colorScheme.secondary;
      case PixelButtonVariant.success:
        return colorScheme.tertiaryContainer;
      case PixelButtonVariant.danger:
        return colorScheme.error;
      case PixelButtonVariant.warning:
        return colorScheme.tertiary;
      case PixelButtonVariant.info:
        return colorScheme.primaryContainer;
    }
  }

  Color _getTextColor() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    switch (widget.variant) {
      case PixelButtonVariant.primary:
        return colorScheme.onPrimary;
      case PixelButtonVariant.secondary:
        return colorScheme.onSecondary;
      case PixelButtonVariant.success:
        return colorScheme.onTertiaryContainer;
      case PixelButtonVariant.danger:
        return colorScheme.onError;
      case PixelButtonVariant.warning:
        return colorScheme.onTertiary;
      case PixelButtonVariant.info:
        return colorScheme.onPrimaryContainer;
    }
  }

  // Get dimensions based on button size
  EdgeInsets _getPadding() {
    switch (widget.size) {
      case PixelButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case PixelButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case PixelButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case PixelButtonSize.small:
        return 14.0;
      case PixelButtonSize.medium:
        return 16.0;
      case PixelButtonSize.large:
        return 18.0;
    }
  }

  double _getShadowDepth() {
    return _isPressed ? 1 : (_isHovered ? 5 : 3);
  }

  void _playClickSound() {
    if (widget.enableSound) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _getBaseColor();
    final textColor = _getTextColor();
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final padding = _getPadding();
    final fontSize = _getFontSize();
    
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: widget.isFullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: widget.enableGlowEffect && isEnabled
                ? [
                    BoxShadow(
                      color: baseColor.withOpacity(0.3 * _glowAnimation.value),
                      blurRadius: 15 * _glowAnimation.value,
                      spreadRadius: 2 * _glowAnimation.value,
                    ),
                  ]
                : null,
          ),
          child: MouseRegion(
            cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() {
              _isHovered = false;
              _isPressed = false;
            }),
            child: GestureDetector(
              onTapDown: isEnabled
                  ? (_) {
                      setState(() => _isPressed = true);
                      _playClickSound();
                    }
                  : null,
              onTapUp: isEnabled
                  ? (_) {
                      setState(() => _isPressed = false);
                    }
                  : null,
              onTapCancel: isEnabled
                  ? () {
                      setState(() => _isPressed = false);
                    }
                  : null,
              onTap: isEnabled ? widget.onPressed : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeInOut,
                transform: widget.enableClickAnimation && _isPressed
                    ? Matrix4.translationValues(0, 3, 0)
                    : Matrix4.identity(),
                child: Stack(
                  children: [
                    // Base button (shadow layer)
                    Container(
                      decoration: BoxDecoration(
                        color: baseColor.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      margin: const EdgeInsets.only(top: 4),
                      width: widget.isFullWidth ? double.infinity : null,
                      height: padding.vertical + 24 + (_isPressed ? 0 : 3),
                    ),
                    
                    // Main button
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: isEnabled
                            ? baseColor
                            : baseColor.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: Offset(0, _getShadowDepth()),
                            blurRadius: 0,
                          ),
                        ],
                        border: Border.all(
                          color: baseColor.withOpacity(0.8),
                          width: 2,
                        ),
                      ),
                      padding: padding,
                      margin: EdgeInsets.only(bottom: _isPressed ? 0 : 3),
                      child: Row(
                        mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.leadingIcon != null) ...[
                            Icon(widget.leadingIcon, color: textColor, size: fontSize),
                            const SizedBox(width: 8),
                          ],
                          widget.isLoading
                              ? SizedBox(
                                  height: fontSize,
                                  width: fontSize,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: textColor,
                                  ),
                                )
                              : Text(
                                  widget.text,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: fontSize,
                                    fontFamily: 'PixelifySans',
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                          if (widget.trailingIcon != null && !widget.isLoading) ...[
                            const SizedBox(width: 8),
                            Icon(widget.trailingIcon, color: textColor, size: fontSize),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 