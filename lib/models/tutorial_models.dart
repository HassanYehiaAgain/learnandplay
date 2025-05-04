import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user's progress through the tutorial system
class TutorialProgress {
  final String userId;
  final bool hasCompletedIntro;
  final bool hasCompletedGamification;
  final Map<String, bool> completedGameTutorials;
  final bool tutorialDisabled;
  final DateTime lastUpdated;

  TutorialProgress({
    required this.userId,
    this.hasCompletedIntro = false,
    this.hasCompletedGamification = false,
    required this.completedGameTutorials,
    this.tutorialDisabled = false,
    required this.lastUpdated,
  });

  /// Check if a specific game tutorial has been completed
  bool hasCompletedGameTutorial(String gameType) {
    return completedGameTutorials[gameType] ?? false;
  }

  /// Convert to a map for Firestore storage
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'hasCompletedIntro': hasCompletedIntro,
      'hasCompletedGamification': hasCompletedGamification,
      'completedGameTutorials': completedGameTutorials,
      'tutorialDisabled': tutorialDisabled,
      'lastUpdated': lastUpdated,
    };
  }

  /// Create a new instance with updated fields
  TutorialProgress copyWith({
    String? userId,
    bool? hasCompletedIntro,
    bool? hasCompletedGamification,
    Map<String, bool>? completedGameTutorials,
    bool? tutorialDisabled,
    DateTime? lastUpdated,
  }) {
    return TutorialProgress(
      userId: userId ?? this.userId,
      hasCompletedIntro: hasCompletedIntro ?? this.hasCompletedIntro,
      hasCompletedGamification: hasCompletedGamification ?? this.hasCompletedGamification,
      completedGameTutorials: completedGameTutorials ?? this.completedGameTutorials,
      tutorialDisabled: tutorialDisabled ?? this.tutorialDisabled,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Create from Firestore document
  factory TutorialProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    return TutorialProgress(
      userId: doc.id,
      hasCompletedIntro: data['hasCompletedIntro'] ?? false,
      hasCompletedGamification: data['hasCompletedGamification'] ?? false,
      completedGameTutorials: Map<String, bool>.from(data['completedGameTutorials'] ?? {}),
      tutorialDisabled: data['tutorialDisabled'] ?? false,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// Represents a single tutorial step with instructions and interaction details
class TutorialStep {
  final String id;
  final String title;
  final String description;
  final String imageAsset;
  final String targetElementId;
  final List<String> highlightElements;
  final bool requiresInteraction;
  final String interactionType;

  TutorialStep({
    required this.id,
    required this.title,
    required this.description,
    this.imageAsset = '',
    required this.targetElementId,
    this.highlightElements = const [],
    this.requiresInteraction = false,
    this.interactionType = '',
  });
}

/// Represents a sequence of tutorial steps for app introduction
class TutorialSequence {
  final String id;
  final String title;
  final String description;
  final String type;
  final List<TutorialStep> steps;

  TutorialSequence({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.steps,
  });
}

/// Represents a tutorial for a specific game type
class GameTutorial {
  final String gameType;
  final String title;
  final String description;
  final List<String> instructions;
  final String imageAsset;
  final Map<String, dynamic> sampleGameData;

  GameTutorial({
    required this.gameType,
    required this.title,
    required this.description,
    required this.instructions,
    required this.imageAsset,
    required this.sampleGameData,
  });
} 