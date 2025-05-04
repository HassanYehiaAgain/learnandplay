import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/models/tutorial_models.dart';

/// Service to manage tutorial content and user progress
class TutorialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Singleton pattern
  static final TutorialService _instance = TutorialService._internal();
  
  factory TutorialService() {
    return _instance;
  }
  
  TutorialService._internal() {
    _initTutorials();
  }
  
  // Collection names
  final _tutorialProgressCollection = 'tutorial_progress';
  
  // Cache tutorial sequences and game tutorials
  final List<TutorialSequence> _tutorialSequences = [];
  final List<GameTutorial> _gameTutorials = [];
  
  /// Initialize all tutorial content
  void _initTutorials() {
    // Initialize introduction tutorial sequence
    _tutorialSequences.add(
      TutorialSequence(
        id: 'app_introduction',
        title: 'Welcome to Learn & Play',
        description: 'Let\'s learn how to use the app!',
        type: 'intro',
        steps: [
          TutorialStep(
            id: 'welcome',
            title: 'Welcome!',
            description: 'This app helps you learn through fun games and activities. Let\'s get started!',
            imageAsset: 'assets/images/tutorial/welcome.png',
            targetElementId: 'root',
          ),
          TutorialStep(
            id: 'navigation',
            title: 'Navigation',
            description: 'Use the bottom navigation bar to explore different sections of the app.',
            imageAsset: 'assets/images/tutorial/navigation.png',
            targetElementId: 'bottom_navigation',
            highlightElements: ['nav_home', 'nav_games', 'nav_progress', 'nav_profile'],
          ),
          TutorialStep(
            id: 'games_library',
            title: 'Games Library',
            description: 'Tap on the Games tab to see all available learning games.',
            imageAsset: 'assets/images/tutorial/games_library.png',
            targetElementId: 'nav_games',
            requiresInteraction: true,
            interactionType: 'tap',
          ),
          TutorialStep(
            id: 'profile',
            title: 'Your Profile',
            description: 'Check your profile to see your progress, achievements, and rewards.',
            imageAsset: 'assets/images/tutorial/profile.png',
            targetElementId: 'nav_profile',
            requiresInteraction: true,
            interactionType: 'tap',
          ),
        ],
      ),
    );
    
    // Initialize gamification tutorial sequence
    _tutorialSequences.add(
      TutorialSequence(
        id: 'gamification_intro',
        title: 'Rewards & Progress',
        description: 'Learn about XP, levels, and rewards!',
        type: 'gamification',
        steps: [
          TutorialStep(
            id: 'xp_intro',
            title: 'Experience Points (XP)',
            description: 'You earn XP by completing games and activities. The better you perform, the more XP you\'ll earn!',
            imageAsset: 'assets/images/tutorial/xp.png',
            targetElementId: 'xp_indicator',
          ),
          TutorialStep(
            id: 'levels_intro',
            title: 'Levels',
            description: 'As you earn XP, you\'ll level up! Each level unlocks new content and rewards.',
            imageAsset: 'assets/images/tutorial/levels.png',
            targetElementId: 'level_indicator',
          ),
          TutorialStep(
            id: 'coins_intro',
            title: 'Coins',
            description: 'Earn coins by completing games and daily challenges. Spend them in the store for cool items!',
            imageAsset: 'assets/images/tutorial/coins.png',
            targetElementId: 'coins_indicator',
          ),
          TutorialStep(
            id: 'badges_intro',
            title: 'Badges & Achievements',
            description: 'Earn badges by completing special challenges and milestones. Collect them all!',
            imageAsset: 'assets/images/tutorial/badges.png',
            targetElementId: 'badges_section',
            requiresInteraction: true,
            interactionType: 'tap',
          ),
          TutorialStep(
            id: 'streaks_intro',
            title: 'Daily Streaks',
            description: 'Login and play every day to build your streak. Longer streaks give bigger rewards!',
            imageAsset: 'assets/images/tutorial/streaks.png',
            targetElementId: 'streak_indicator',
          ),
          TutorialStep(
            id: 'leaderboard_intro',
            title: 'Leaderboards',
            description: 'Compete with friends and classmates to see who can earn the highest scores!',
            imageAsset: 'assets/images/tutorial/leaderboard.png',
            targetElementId: 'leaderboard_button',
            requiresInteraction: true,
            interactionType: 'tap',
          ),
        ],
      ),
    );
    
    // Initialize game tutorials
    _initGameTutorials();
  }
  
  /// Initialize game-specific tutorials
  void _initGameTutorials() {
    // Quiz game tutorial
    _gameTutorials.add(
      GameTutorial(
        gameType: 'quiz',
        title: 'Quiz Games',
        description: 'Test your knowledge by answering questions correctly!',
        instructions: [
          'Read each question carefully',
          'Select the correct answer from the options',
          'Submit your answer to continue',
          'Try to answer quickly for bonus points!',
        ],
        imageAsset: 'assets/images/tutorial/quiz_game.png',
        sampleGameData: {
          'question': 'What is the capital of France?',
          'options': ['London', 'Berlin', 'Paris', 'Madrid'],
          'correctAnswer': 'Paris',
        },
      ),
    );
    
    // Matching game tutorial
    _gameTutorials.add(
      GameTutorial(
        gameType: 'matching',
        title: 'Matching Games',
        description: 'Match related items to test your memory and knowledge!',
        instructions: [
          'Tap on a card to reveal it',
          'Find and tap the matching card',
          'Match all pairs to complete the game',
          'Try to finish with as few attempts as possible!',
        ],
        imageAsset: 'assets/images/tutorial/matching_game.png',
        sampleGameData: {
          'pairs': [
            {'id': '1', 'content': 'Dog', 'matchId': '2', 'matchContent': 'Canine'},
            {'id': '3', 'content': 'Cat', 'matchId': '4', 'matchContent': 'Feline'},
          ],
        },
      ),
    );
    
    // Flashcard game tutorial
    _gameTutorials.add(
      GameTutorial(
        gameType: 'flashcard',
        title: 'Flashcard Games',
        description: 'Review and memorize concepts with interactive flashcards!',
        instructions: [
          'Study the front side of the card',
          'Tap to flip and check your answer',
          'Mark if you got it right or wrong',
          'Cards you struggle with will appear more frequently',
        ],
        imageAsset: 'assets/images/tutorial/flashcard_game.png',
        sampleGameData: {
          'front': 'Photosynthesis',
          'back': 'The process by which plants convert light energy into chemical energy',
        },
      ),
    );
    
    // Sorting game tutorial
    _gameTutorials.add(
      GameTutorial(
        gameType: 'sorting',
        title: 'Sorting Games',
        description: 'Sort items into the correct categories!',
        instructions: [
          'Look at each item carefully',
          'Drag and drop it into the correct category',
          'Complete all items to finish the game',
          'Try to sort quickly for time bonuses!',
        ],
        imageAsset: 'assets/images/tutorial/sorting_game.png',
        sampleGameData: {
          'categories': ['Mammals', 'Birds', 'Reptiles'],
          'items': [
            {'content': 'Eagle', 'correctCategory': 'Birds'},
            {'content': 'Dolphin', 'correctCategory': 'Mammals'},
            {'content': 'Snake', 'correctCategory': 'Reptiles'},
          ],
        },
      ),
    );
  }
  
  /// Get all tutorial sequences
  List<TutorialSequence> getTutorialSequences() {
    return _tutorialSequences;
  }
  
  /// Get all game tutorials
  List<GameTutorial> getGameTutorials() {
    return _gameTutorials;
  }
  
  /// Get a specific game tutorial by type
  GameTutorial? getGameTutorialByType(String gameType) {
    try {
      return _gameTutorials.firstWhere((tutorial) => tutorial.gameType == gameType);
    } catch (e) {
      debugPrint('Game tutorial not found for type: $gameType');
      return null;
    }
  }
  
  /// Get tutorial sequence by type
  TutorialSequence? getTutorialSequenceByType(String type) {
    try {
      return _tutorialSequences.firstWhere((sequence) => sequence.type == type);
    } catch (e) {
      debugPrint('Tutorial sequence not found for type: $type');
      return null;
    }
  }
  
  /// Get user's tutorial progress
  Future<TutorialProgress> getUserTutorialProgress(String userId) async {
    try {
      final doc = await _firestore.collection(_tutorialProgressCollection).doc(userId).get();
      
      if (doc.exists) {
        return TutorialProgress.fromFirestore(doc);
      } else {
        // Create new progress for new users
        final defaultProgress = TutorialProgress(
          userId: userId,
          completedGameTutorials: {},
          lastUpdated: DateTime.now(),
        );
        
        await _firestore.collection(_tutorialProgressCollection).doc(userId).set(
          defaultProgress.toFirestore()
        );
        
        return defaultProgress;
      }
    } catch (e) {
      debugPrint('Error getting tutorial progress: $e');
      
      // Return default progress on error
      return TutorialProgress(
        userId: userId,
        completedGameTutorials: {},
        lastUpdated: DateTime.now(),
      );
    }
  }
  
  /// Update tutorial progress
  Future<void> updateTutorialProgress(TutorialProgress progress) async {
    try {
      final updatedProgress = progress.copyWith(
        lastUpdated: DateTime.now(),
      );
      
      await _firestore.collection(_tutorialProgressCollection).doc(progress.userId).set(
        updatedProgress.toFirestore()
      );
    } catch (e) {
      debugPrint('Error updating tutorial progress: $e');
      throw Exception('Failed to update tutorial progress: $e');
    }
  }
  
  /// Mark a tutorial sequence as completed
  Future<void> markTutorialSequenceCompleted(String userId, String type) async {
    try {
      final progress = await getUserTutorialProgress(userId);
      
      TutorialProgress updatedProgress;
      if (type == 'intro') {
        updatedProgress = progress.copyWith(
          hasCompletedIntro: true,
          lastUpdated: DateTime.now(),
        );
      } else if (type == 'gamification') {
        updatedProgress = progress.copyWith(
          hasCompletedGamification: true,
          lastUpdated: DateTime.now(),
        );
      } else {
        // Update game tutorial completion
        final completedGames = Map<String, bool>.from(progress.completedGameTutorials);
        completedGames[type] = true;
        
        updatedProgress = progress.copyWith(
          completedGameTutorials: completedGames,
          lastUpdated: DateTime.now(),
        );
      }
      
      await updateTutorialProgress(updatedProgress);
    } catch (e) {
      debugPrint('Error marking tutorial as completed: $e');
      throw Exception('Failed to mark tutorial as completed: $e');
    }
  }
  
  /// Disable all tutorials for a user
  Future<void> disableTutorials(String userId) async {
    try {
      final progress = await getUserTutorialProgress(userId);
      
      final updatedProgress = progress.copyWith(
        tutorialDisabled: true,
        lastUpdated: DateTime.now(),
      );
      
      await updateTutorialProgress(updatedProgress);
    } catch (e) {
      debugPrint('Error disabling tutorials: $e');
      throw Exception('Failed to disable tutorials: $e');
    }
  }
  
  /// Re-enable tutorials for a user
  Future<void> enableTutorials(String userId) async {
    try {
      final progress = await getUserTutorialProgress(userId);
      
      final updatedProgress = progress.copyWith(
        tutorialDisabled: false,
        lastUpdated: DateTime.now(),
      );
      
      await updateTutorialProgress(updatedProgress);
    } catch (e) {
      debugPrint('Error enabling tutorials: $e');
      throw Exception('Failed to enable tutorials: $e');
    }
  }
  
  /// Reset all tutorial progress for a user
  Future<void> resetTutorialProgress(String userId) async {
    try {
      final defaultProgress = TutorialProgress(
        userId: userId,
        completedGameTutorials: {},
        lastUpdated: DateTime.now(),
      );
      
      await updateTutorialProgress(defaultProgress);
    } catch (e) {
      debugPrint('Error resetting tutorial progress: $e');
      throw Exception('Failed to reset tutorial progress: $e');
    }
  }
  
  /// Check if a user should see tutorials (new user or explicitly enabled)
  Future<bool> shouldShowTutorials(String userId) async {
    try {
      final progress = await getUserTutorialProgress(userId);
      
      // Don't show if tutorials are disabled
      if (progress.tutorialDisabled) {
        return false;
      }
      
      // Show if intro tutorial not completed
      if (!progress.hasCompletedIntro) {
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error checking tutorial status: $e');
      return true; // Default to showing tutorials on error
    }
  }
} 