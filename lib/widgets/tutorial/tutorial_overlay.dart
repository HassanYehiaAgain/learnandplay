import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/models/tutorial_models.dart';

/// A widget that displays a tutorial step overlay with target highlighting
class TutorialOverlay extends StatelessWidget {
  final TutorialStep step;
  final VoidCallback onNext;
  final VoidCallback? onSkip;
  final bool showSkip;
  final GlobalKey targetKey;
  
  const TutorialOverlay({
    super.key,
    required this.step,
    required this.onNext,
    required this.targetKey,
    this.onSkip,
    this.showSkip = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent background
        Container(
          color: Colors.black.withOpacity(0.7),
        ),
        
        // Highlight target element
        _buildHighlight(context),
        
        // Tutorial content card
        _buildTutorialCard(context),
      ],
    );
  }
  
  Widget _buildHighlight(BuildContext context) {
    // Use the GlobalKey to find the target element position
    final RenderBox? targetBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (targetBox == null) {
      return const SizedBox();
    }
    
    // Get the target position in global coordinates
    final targetPosition = targetBox.localToGlobal(Offset.zero);
    final targetSize = targetBox.size;
    
    return Positioned(
      left: targetPosition.dx - 8,
      top: targetPosition.dy - 8,
      width: targetSize.width + 16,
      height: targetSize.height + 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTutorialCard(BuildContext context) {
    // Position the card based on target position
    final RenderBox? targetBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (targetBox == null) {
      // Fallback to center position if target not found
      return Center(
        child: _buildCard(context),
      );
    }
    
    // Get the target position in global coordinates
    final targetPosition = targetBox.localToGlobal(Offset.zero);
    final targetSize = targetBox.size;
    final screenSize = MediaQuery.of(context).size;
    
    // Determine if card should be above or below target
    bool showAbove = targetPosition.dy > screenSize.height / 2;
    
    return Positioned(
      left: 16,
      right: 16,
      top: showAbove ? null : targetPosition.dy + targetSize.height + 20,
      bottom: showAbove ? screenSize.height - targetPosition.dy + 20 : null,
      child: _buildCard(context),
    );
  }
  
  Widget _buildCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tutorial step title
            Text(
              step.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Tutorial step image (if available)
            if (step.imageAsset.isNotEmpty) ...[
              Center(
                child: Image.asset(
                  step.imageAsset,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Tutorial step description
            Text(
              step.description,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (showSkip && onSkip != null) ...[
                  TextButton(
                    onPressed: onSkip,
                    child: const Text('Skip Tutorial'),
                  ),
                  const SizedBox(width: 16),
                ],
                
                ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(step.requiresInteraction ? 'Got it!' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 