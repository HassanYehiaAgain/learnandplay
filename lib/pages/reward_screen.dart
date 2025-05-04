import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/services/gamification_service.dart';

class RewardScreen extends StatefulWidget {
  final String gameTitle;
  final int score;
  final int maxScore;
  
  const RewardScreen({
    super.key, 
    required this.gameTitle,
    required this.score,
    required this.maxScore,
  });

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _xpAnimationController;
  late AnimationController _coinAnimationController;
  late Animation<double> _xpAnimation;
  late Animation<double> _coinAnimation;
  
  int _displayXp = 0;
  int _displayCoins = 0;
  late double _percentScore;
  
  @override
  void initState() {
    super.initState();
    
    // Calculate percentage score
    _percentScore = widget.score / widget.maxScore * 100;
    
    // Initialize animation controllers
    _confettiController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 3),
    );
    
    _xpAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _coinAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // XP animation
    _xpAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _xpAnimationController,
      curve: Curves.easeOut,
    ));
    
    // Coin animation
    _coinAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _coinAnimationController,
      curve: Curves.easeOut,
    ));
    
    // Add animation listeners
    _xpAnimation.addListener(() {
      final baseXp = _calculateXpReward();
      setState(() {
        _displayXp = (baseXp * _xpAnimation.value).round();
      });
    });
    
    _coinAnimation.addListener(() {
      final baseCoins = _calculateCoinReward();
      setState(() {
        _displayCoins = (baseCoins * _coinAnimation.value).round();
      });
    });
    
    // Start animations in sequence
    _confettiController.forward();
    
    Future.delayed(const Duration(milliseconds: 500), () {
      _xpAnimationController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      _coinAnimationController.forward();
    });
  }
  
  @override
  void dispose() {
    _confettiController.dispose();
    _xpAnimationController.dispose();
    _coinAnimationController.dispose();
    super.dispose();
  }
  
  int _calculateXpReward() {
    // Base XP from percentage score (0-100)
    int baseXp = _percentScore.round();
    
    // Perfect score bonus
    int perfectBonus = _percentScore >= 95 ? 50 : 0;
    
    return baseXp + perfectBonus;
  }
  
  int _calculateCoinReward() {
    // Base coins from percentage score (0-10)
    int baseCoins = (_percentScore / 10).round();
    
    // Perfect score bonus
    int perfectBonus = _percentScore >= 95 ? 5 : 0;
    
    return baseCoins + perfectBonus;
  }
  
  String _getPerformanceMessage() {
    if (_percentScore >= 95) {
      return 'Outstanding!';
    } else if (_percentScore >= 80) {
      return 'Excellent!';
    } else if (_percentScore >= 60) {
      return 'Good job!';
    } else if (_percentScore >= 40) {
      return 'Nice try!';
    } else {
      return 'Keep practicing!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primary.withOpacity(0.8),
                  colorScheme.surface,
                ],
              ),
            ),
          ),
          
          // Confetti animation (use Container instead of Lottie until package is added)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return Opacity(
                  opacity: _confettiController.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue.withOpacity(0.3 * _confettiController.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.celebration,
                        size: 100 * _confettiController.value,
                        color: Colors.amber.withOpacity(0.8),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Game completion title
                  Text(
                    'Game Complete!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.gameTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Performance message
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getPerformanceMessage(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Score: ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.score}/${widget.maxScore}',
                        style: TextStyle(
                          fontSize: 18,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${_percentScore.round()}%)',
                        style: TextStyle(
                          fontSize: 18,
                          color: colorScheme.primary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: widget.score / widget.maxScore,
                      backgroundColor: colorScheme.surfaceVariant,
                      color: _getProgressColor(colorScheme),
                      minHeight: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Rewards section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Rewards',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // XP reward
                        _buildReward(
                          icon: Icons.emoji_events,
                          color: Colors.amber,
                          title: 'XP Earned',
                          value: _displayXp.toString(),
                          size: 64,
                        ),
                        const SizedBox(height: 24),
                        
                        // Coin reward
                        _buildReward(
                          icon: Icons.monetization_on,
                          color: Colors.amber,
                          title: 'Coins Earned',
                          value: _displayCoins.toString(),
                          size: 64,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Continue button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Continue'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: colorScheme.onPrimary,
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReward({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required double size,
  }) {
    return Row(
      children: [
        // Icon
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: size * 0.6,
          ),
        ),
        const SizedBox(width: 20),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Color _getProgressColor(ColorScheme colorScheme) {
    if (_percentScore >= 95) {
      return Colors.green;
    } else if (_percentScore >= 80) {
      return Colors.lightGreen;
    } else if (_percentScore >= 60) {
      return Colors.amber;
    } else if (_percentScore >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
} 