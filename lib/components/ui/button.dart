import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';

enum ButtonVariant {
  primary,
  secondary,
  outline,
  destructive,
  ghost,
  link,
  gradient,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isDisabled;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Size styles
    final sizeStyles = {
      ButtonSize.small: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ButtonSize.medium: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ButtonSize.large: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    };
    
    final fontSize = {
      ButtonSize.small: 14.0,
      ButtonSize.medium: 16.0,
      ButtonSize.large: 18.0,
    };

    // Variant styles
    final variantStyles = {
      ButtonVariant.primary: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.primary.withOpacity(0.6);
            }
            return colorScheme.primary;
          },
        ),
        foregroundColor: WidgetStateProperty.all<Color>(colorScheme.onPrimary),
        overlayColor: WidgetStateProperty.all<Color>(colorScheme.onPrimary.withOpacity(0.1)),
        side: WidgetStateProperty.all<BorderSide>(BorderSide.none),
      ),
      ButtonVariant.secondary: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.secondary.withOpacity(0.6);
            }
            return colorScheme.secondary;
          },
        ),
        foregroundColor: WidgetStateProperty.all<Color>(colorScheme.onSecondary),
        overlayColor: WidgetStateProperty.all<Color>(colorScheme.onSecondary.withOpacity(0.1)),
        side: WidgetStateProperty.all<BorderSide>(BorderSide.none),
      ),
      ButtonVariant.outline: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
        foregroundColor: WidgetStateProperty.all<Color>(colorScheme.primary),
        overlayColor: WidgetStateProperty.all<Color>(colorScheme.primary.withOpacity(0.1)),
        side: WidgetStateProperty.all<BorderSide>(BorderSide(color: colorScheme.primary)),
      ),
      ButtonVariant.destructive: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.error.withOpacity(0.6);
            }
            return colorScheme.error;
          },
        ),
        foregroundColor: WidgetStateProperty.all<Color>(colorScheme.onError),
        overlayColor: WidgetStateProperty.all<Color>(colorScheme.onError.withOpacity(0.1)),
        side: WidgetStateProperty.all<BorderSide>(BorderSide.none),
      ),
      ButtonVariant.ghost: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
        foregroundColor: WidgetStateProperty.all<Color>(colorScheme.primary),
        overlayColor: WidgetStateProperty.all<Color>(colorScheme.primary.withOpacity(0.1)),
        side: WidgetStateProperty.all<BorderSide>(BorderSide.none),
      ),
      ButtonVariant.link: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
        foregroundColor: WidgetStateProperty.all<Color>(colorScheme.primary),
        overlayColor: WidgetStateProperty.all<Color>(Colors.transparent),
        side: WidgetStateProperty.all<BorderSide>(BorderSide.none),
        padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.zero),
        minimumSize: WidgetStateProperty.all<Size>(Size.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      ButtonVariant.gradient: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
        foregroundColor: WidgetStateProperty.all<Color>(colorScheme.onPrimary),
        overlayColor: WidgetStateProperty.all<Color>(Colors.white.withOpacity(0.1)),
        side: WidgetStateProperty.all<BorderSide>(BorderSide.none),
      ),
    };
    
    // Common button style
    final buttonStyle = ButtonStyle(
      padding: WidgetStateProperty.all<EdgeInsets>(sizeStyles[size]!),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      elevation: WidgetStateProperty.all<double>(0),
    ).copyWith(
      backgroundColor: variantStyles[variant]!.backgroundColor,
      foregroundColor: variantStyles[variant]!.foregroundColor,
      overlayColor: variantStyles[variant]!.overlayColor,
      side: variantStyles[variant]!.side,
      padding: variant == ButtonVariant.link 
          ? WidgetStateProperty.all<EdgeInsets>(EdgeInsets.zero)
          : WidgetStateProperty.all<EdgeInsets>(sizeStyles[size]!),
      minimumSize: variantStyles[variant]!.minimumSize,
      tapTargetSize: variantStyles[variant]!.tapTargetSize,
    );

    Widget child;
    if (isLoading) {
      child = SizedBox(
        height: fontSize[size],
        width: fontSize[size],
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: variant == ButtonVariant.outline || variant == ButtonVariant.ghost || variant == ButtonVariant.link
              ? colorScheme.primary
              : colorScheme.onPrimary,
        ),
      );
    } else {
      child = Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: fontSize[size]),
            SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize[size],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (trailingIcon != null) ...[
            SizedBox(width: 8),
            Icon(trailingIcon, size: fontSize[size]),
          ],
        ],
      );
    }

    // Special case for gradient button
    if (variant == ButtonVariant.gradient) {
      return GradientButton(
        text: text,
        onPressed: isDisabled || isLoading ? null : onPressed,
        gradient: AppGradients.purpleToPink,
        size: size,
        isFullWidth: isFullWidth,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        isLoading: isLoading,
        fontSize: fontSize[size]!,
        padding: sizeStyles[size]!,
      );
    }

    return variant == ButtonVariant.link
        ? TextButton(
            onPressed: isDisabled ? null : onPressed,
            style: buttonStyle,
            child: child,
          )
        : ElevatedButton(
            onPressed: isDisabled || isLoading ? null : onPressed,
            style: buttonStyle,
            child: child,
          );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final LinearGradient gradient;
  final ButtonSize size;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final double fontSize;
  final EdgeInsets padding;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.gradient,
    required this.size,
    required this.fontSize,
    required this.padding,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    Widget child;
    if (isLoading) {
      child = SizedBox(
        height: fontSize,
        width: fontSize,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
    } else {
      child = Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: fontSize, color: Colors.white),
            SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: 'PixelifySans',
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (trailingIcon != null) ...[
            SizedBox(width: 8),
            Icon(trailingIcon, size: fontSize, color: Colors.white),
          ],
        ],
      );
    }

    return Container(
      width: isFullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        gradient: isEnabled ? gradient : LinearGradient(
          colors: [Colors.grey.shade400, Colors.grey.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isEnabled ? [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(8),
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Padding(
            padding: padding,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
} 