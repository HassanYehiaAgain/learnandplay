import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double? elevation;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final Border? border;
  final VoidCallback? onTap;
  final bool isHoverable;

  const AppCard({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.elevation,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.border,
    this.onTap,
    this.isHoverable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final cardDecoration = BoxDecoration(
      color: backgroundColor ?? colorScheme.surface,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      border: border ?? Border.all(color: colorScheme.outline.withOpacity(0.2)),
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withOpacity(elevation != null ? elevation! * 0.1 : 0.05),
          blurRadius: elevation != null ? elevation! * 2 : 4,
          offset: const Offset(0, 2),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        hoverColor: isHoverable 
            ? colorScheme.primary.withOpacity(0.05) 
            : Colors.transparent,
        child: Ink(
          decoration: cardDecoration,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      );
    }
    
    return Container(
      decoration: cardDecoration,
      padding: padding,
      child: child,
    );
  }
}

class AppCardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? action;

  const AppCardHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.leading,
    this.action,
  }) : super(key: key);

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
    Key? key,
    required this.actions,
    this.alignment = MainAxisAlignment.end,
  }) : super(key: key);

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
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: child,
    );
  }
} 