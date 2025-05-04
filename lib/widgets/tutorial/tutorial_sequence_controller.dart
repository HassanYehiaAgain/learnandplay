import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/models/tutorial_models.dart';
import 'package:learn_play_level_up_flutter/services/tutorial_service.dart';
import 'package:learn_play_level_up_flutter/widgets/tutorial/tutorial_overlay.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A controller widget that manages tutorial sequences and progression
class TutorialSequenceController extends StatefulWidget {
  final Widget child;
  final String tutorialType;
  final VoidCallback? onComplete;
  final Map<String, GlobalKey> elementKeys;
  
  const TutorialSequenceController({
    super.key,
    required this.child,
    required this.tutorialType,
    required this.elementKeys,
    this.onComplete,
  });

  @override
  State<TutorialSequenceController> createState() => _TutorialSequenceControllerState();
}

class _TutorialSequenceControllerState extends State<TutorialSequenceController> {
  final TutorialService _tutorialService = TutorialService();
  TutorialSequence? _sequence;
  int _currentStepIndex = 0;
  bool _isActive = false;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadTutorial();
  }
  
  Future<void> _loadTutorial() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get user ID
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() {
          _isLoading = false;
          _isActive = false;
        });
        return;
      }
      
      // Get tutorial sequence
      final sequence = _tutorialService.getTutorialSequenceByType(widget.tutorialType);
      if (sequence == null) {
        setState(() {
          _isLoading = false;
          _isActive = false;
        });
        return;
      }
      
      // Check if user should see this tutorial
      final progress = await _tutorialService.getUserTutorialProgress(userId);
      
      // If tutorials are disabled or this sequence is already completed, don't show
      bool shouldShow = !progress.tutorialDisabled;
      
      if (widget.tutorialType == 'intro') {
        shouldShow = shouldShow && !progress.hasCompletedIntro;
      } else if (widget.tutorialType == 'gamification') {
        shouldShow = shouldShow && !progress.hasCompletedGamification;
      } else {
        // Game tutorial
        shouldShow = shouldShow && !progress.hasCompletedGameTutorial(widget.tutorialType);
      }
      
      setState(() {
        _sequence = sequence;
        _isLoading = false;
        _isActive = shouldShow;
        _currentStepIndex = 0;
      });
      
    } catch (e) {
      debugPrint('Error loading tutorial: $e');
      setState(() {
        _isLoading = false;
        _isActive = false;
      });
    }
  }
  
  void _nextStep() {
    if (_sequence == null) return;
    
    if (_currentStepIndex < _sequence!.steps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
    } else {
      _completeTutorial();
    }
  }
  
  void _skipTutorial() {
    if (_sequence == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Tutorial?'),
        content: const Text('Are you sure you want to skip this tutorial? You can always access it again from the settings menu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _completeTutorial();
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _completeTutorial() async {
    if (_sequence == null) return;
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      // Mark tutorial as completed
      await _tutorialService.markTutorialSequenceCompleted(userId, _sequence!.type);
      
      setState(() {
        _isActive = false;
      });
      
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    } catch (e) {
      debugPrint('Error completing tutorial: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // If loading or not active, just show the child
    if (_isLoading || !_isActive || _sequence == null) {
      return widget.child;
    }
    
    // Get current step
    final currentStep = _sequence!.steps[_currentStepIndex];
    
    // Find the target key for the current step
    final targetKey = widget.elementKeys[currentStep.targetElementId] ?? 
                     widget.elementKeys['root'] ??
                     GlobalKey();
    
    return Stack(
      children: [
        // Original UI
        widget.child,
        
        // Tutorial overlay
        TutorialOverlay(
          step: currentStep,
          onNext: _nextStep,
          onSkip: _skipTutorial,
          targetKey: targetKey,
          showSkip: _currentStepIndex > 0,
        ),
      ],
    );
  }
} 