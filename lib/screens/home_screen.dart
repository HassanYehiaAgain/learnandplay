import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/services/tutorial_service.dart';
import 'package:learn_play_level_up_flutter/pages/tutorial/tutorial_welcome_page.dart';
import 'package:learn_play_level_up_flutter/widgets/tutorial/tutorial_sequence_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learn_play_level_up_flutter/components/gamification/xp_animation.dart';
import 'package:learn_play_level_up_flutter/components/gamification/daily_reward.dart';
import 'package:learn_play_level_up_flutter/pages/user_profile_page.dart';
import 'package:learn_play_level_up_flutter/pages/store_page.dart';
import 'package:learn_play_level_up_flutter/pages/leaderboard_page.dart';
import 'package:learn_play_level_up_flutter/services/gamification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TutorialService _tutorialService = TutorialService();
  final Map<String, GlobalKey> _tutorialKeys = {
    'root': GlobalKey(),
    'nav_home': GlobalKey(),
    'nav_games': GlobalKey(),
    'nav_progress': GlobalKey(),
    'nav_profile': GlobalKey(),
    'xp_indicator': GlobalKey(),
    'level_indicator': GlobalKey(),
    'coins_indicator': GlobalKey(),
    'badges_section': GlobalKey(),
    'streak_indicator': GlobalKey(),
    'leaderboard_button': GlobalKey(),
  };
  
  int _selectedIndex = 0;
  bool _isTutorialActive = false;

  @override
  void initState() {
    super.initState();
    
    // Check for tutorials after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTutorial();
    });
    
    // Check for daily login rewards
    _checkForDailyReward();
  }
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  Future<void> _checkAndShowTutorial() async {
    try {
      // Skip for users who aren't logged in
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      final shouldShowTutorials = await _tutorialService.shouldShowTutorials(user.uid);
      
      if (shouldShowTutorials && mounted) {
        // Show tutorial welcome page
        if (!context.mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TutorialWelcomePage(
              onComplete: _onTutorialComplete,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error checking tutorial status: $e');
    }
    
    // Update tutorial active state
    setState(() {
      _isTutorialActive = true;
    });
  }

  void _onTutorialComplete() {
    // Update tutorial active state
    setState(() {
      _isTutorialActive = false;
    });
  }

  Future<void> _checkForDailyReward() async {
    // Skip reward display during tutorial
    if (_isTutorialActive) return;
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final gamificationService = GamificationService();
      
      // Update login streak and get current streak value
      final currentStreak = await gamificationService.updateLoginStreak(userId);
      
      // Only show reward if streak was updated (first login of the day)
      if (currentStreak > 0) {
        // Delay slightly to allow screen to load
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            showDailyReward(
              context,
              userId: userId,
              currentStreak: currentStreak,
              onRewardClaimed: () {
                // Refresh user profile after claiming rewards
                setState(() {});
              },
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Error checking for daily rewards: $e');
    }
  }

  // Add a method to handle XP rewards after completing activities
  Future<void> _awardXpForActivity(int amount, {String? subjectId}) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final gamificationService = GamificationService();
      
      // Add XP and get result
      final result = await gamificationService.addXp(userId, amount, subjectId: subjectId);
      
      if (result['success'] == true) {
        // Show XP gain animation
        if (mounted) {
          // If user leveled up, show level up animation
          if (result['levelUp'] == true) {
            final oldLevel = gamificationService.getLevelByNumber(result['oldLevel']);
            final newLevel = gamificationService.getLevelByNumber(result['newLevel']);
            
            showXpGainOverlay(
              context,
              xpAmount: amount,
              leveledUp: true,
              oldLevel: oldLevel,
              newLevel: newLevel,
            );
          } else {
            // Just show XP gain
            showXpGainOverlay(
              context,
              xpAmount: amount,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error awarding XP: $e');
    }
  }
  
  // Add method to navigate to gamification-related screens
  void _navigateToUserProfile() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfilePage(userId: userId),
      ),
    );
  }
  
  void _navigateToStore() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StorePage(userId: userId),
      ),
    );
  }
  
  void _navigateToLeaderboard() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeaderboardPage(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TutorialSequenceController(
      tutorialType: 'intro',
      elementKeys: _tutorialKeys,
      child: Scaffold(
        // Assign keys to elements for tutorial highlighting
        bottomNavigationBar: BottomNavigationBar(
          key: _tutorialKeys['bottom_navigation'],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, key: _tutorialKeys['nav_home']),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.games, key: _tutorialKeys['nav_games']),
              label: 'Games',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights, key: _tutorialKeys['nav_progress']),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, key: _tutorialKeys['nav_profile']),
              label: 'Profile',
            ),
          ],
        ),
        body: const Center(
          child: Text('Home Screen Content Here'),
        ),
      ),
    );
  }
} 