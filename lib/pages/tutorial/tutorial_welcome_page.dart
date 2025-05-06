import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/services/tutorial_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Welcome page for first-time users with tutorial introduction
class TutorialWelcomePage extends StatefulWidget {
  final VoidCallback onComplete;
  
  const TutorialWelcomePage({
    super.key,
    required this.onComplete,
  });

  @override
  State<TutorialWelcomePage> createState() => _TutorialWelcomePageState();
}

class _TutorialWelcomePageState extends State<TutorialWelcomePage> {
  final TutorialService _tutorialService = TutorialService();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<Map<String, dynamic>> _welcomeScreens = [
    {
      'title': 'Welcome to Learn & Play!',
      'description': 'Get ready for a fun and interactive learning experience designed to help you master new subjects through games and activities.',
      'image': 'assets/images/tutorial/welcome_start.png',
      'color': Colors.blue,
    },
    {
      'title': 'Learn through Games',
      'description': 'Play different types of games that make learning fun and engaging. Complete challenges, earn points, and track your progress.',
      'image': 'assets/images/tutorial/welcome_games.png',
      'color': Colors.green,
    },
    {
      'title': 'Earn Rewards',
      'description': 'Collect badges, level up, and unlock achievements as you progress. Build streaks by playing every day for extra bonuses!',
      'image': 'assets/images/tutorial/welcome_rewards.png',
      'color': Colors.orange,
    },
    {
      'title': 'Track Your Progress',
      'description': 'See your improvement over time with detailed analytics. Identify strengths and areas you can work on.',
      'image': 'assets/images/tutorial/welcome_progress.png',
      'color': Colors.purple,
    },
    {
      'title': 'Let\'s Get Started!',
      'description': 'We\'ll guide you through the app with a quick tutorial to help you get familiar with everything.',
      'image': 'assets/images/tutorial/welcome_final.png',
      'color': Colors.red,
    },
  ];
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  Future<void> _completeWelcome() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      // Mark intro as viewed but don't fully complete it
      // Full tutorial will still show after this welcome screen
      await _tutorialService.getUserTutorialProgress(userId);
      
      widget.onComplete();
    } catch (e) {
      debugPrint('Error completing welcome: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.4;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _completeWelcome,
                  child: const Text('Skip'),
                ),
              ),
            ),
            
            // Page content (image, title, description)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _welcomeScreens.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final screen = _welcomeScreens[index];
                  final Color color = screen['color'];
                  
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image
                        Expanded(
                          child: Center(
                            child: Image.asset(
                              screen['image'],
                              height: imageHeight,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),
                        
                        const SizedBox(height: 40),
                        
                        // Title
                        Text(
                          screen['title'],
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                          textAlign: TextAlign.center,
                        ).animate(delay: 400.ms).fadeIn().slideX(begin: 0.2, end: 0),
                        
                        const SizedBox(height: 16),
                        
                        // Description
                        Text(
                          screen['description'],
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ).animate(delay: 600.ms).fadeIn(),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _welcomeScreens.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index 
                        ? _welcomeScreens[_currentPage]['color']
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _welcomeScreens.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _completeWelcome();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _welcomeScreens[_currentPage]['color'],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage < _welcomeScreens.length - 1 ? 'Next' : 'Get Started',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 