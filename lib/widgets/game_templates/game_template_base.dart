import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learn_play_level_up_flutter/providers/accessibility_provider.dart';
import 'package:learn_play_level_up_flutter/providers/game_analytics_provider.dart';
import 'package:learn_play_level_up_flutter/widgets/common/loading_indicator.dart';
import 'package:learn_play_level_up_flutter/widgets/common/error_display.dart';

class GameTemplateBase extends StatelessWidget {
  final Widget child;
  final String title;
  final String description;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool showAppBar;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  const GameTemplateBase({
    Key? key,
    required this.child,
    required this.title,
    this.description = '',
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.showAppBar = true,
    this.actions,
    this.floatingActionButton,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accessibility = Provider.of<AccessibilityProvider>(context);
    
    return Semantics(
      label: title,
      hint: description,
      child: Scaffold(
        backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
        appBar: showAppBar ? AppBar(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 20 * accessibility.textScaleFactor,
            ),
          ),
          actions: actions,
        ) : null,
        body: SafeArea(
          child: Builder(
            builder: (context) {
              if (isLoading) {
                return const Center(
                  child: LoadingIndicator(),
                );
              }
              
              if (errorMessage != null) {
                return Center(
                  child: ErrorDisplay(
                    message: errorMessage!,
                    onRetry: onRetry,
                  ),
                );
              }
              
              return ExcludeSemantics(
                excluding: accessibility.screenReaderEnabled,
                child: AnimatedSwitcher(
                  duration: accessibility.getAnimationDuration(
                    const Duration(milliseconds: 300),
                  ),
                  child: child,
                ),
              );
            },
          ),
        ),
        floatingActionButton: floatingActionButton != null
            ? ExcludeSemantics(
                excluding: accessibility.screenReaderEnabled,
                child: floatingActionButton,
              )
            : null,
      ),
    );
  }
} 