import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? routePath;
  final Map<String, String>? queryParams;
  final bool useLargeFont;
  final TextStyle? subtitleStyle;

  const SectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.routePath,
    this.queryParams,
    this.useLargeFont = false,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: InkWell(
        onTap: routePath != null
            ? () {
                final uri = Uri(
                  path: routePath,
                  queryParameters: queryParams,
                );
                context.go(uri.toString());
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null)
                Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
              const SizedBox(height: 8),
              Text(
                title,
                style: useLargeFont
                    ? Theme.of(context).textTheme.headlineLarge
                    : Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: subtitleStyle ?? Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 