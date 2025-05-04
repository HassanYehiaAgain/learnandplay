import 'dart:math';
import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/services/gamification_service.dart';

class DailyRewardDialog extends StatefulWidget {
  final String userId;
  final int currentStreak;
  final VoidCallback? onRewardClaimed;

  const DailyRewardDialog({
    super.key,
    required this.userId,
    required this.currentStreak,
    this.onRewardClaimed,
  });

  @override
  State<DailyRewardDialog> createState() => _DailyRewardDialogState();
}

class _DailyRewardDialogState extends State<DailyRewardDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  bool _isOpening = true;
  bool _isRevealed = false;
  bool _isClaimingReward = false;
  int _coinsAwarded = 0;
  int _xpAwarded = 0;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _calculateRewards();
    _animationController.forward();
  }
  
  void _calculateRewards() {
    // Base rewards
    int baseCoins = 10;
    int baseXp = 25;
    
    // Streak multiplier (increases with consecutive days)
    double streakMultiplier = 1.0;
    
    if (widget.currentStreak >= 30) {
      streakMultiplier = 3.0; // 30+ days: 3x rewards
    } else if (widget.currentStreak >= 14) {
      streakMultiplier = 2.0; // 14+ days: 2x rewards
    } else if (widget.currentStreak >= 7) {
      streakMultiplier = 1.5; // 7+ days: 1.5x rewards
    } else if (widget.currentStreak >= 3) {
      streakMultiplier = 1.2; // 3+ days: 1.2x rewards
    }
    
    // Special rewards for milestone days
    if (widget.currentStreak == 7 || 
        widget.currentStreak == 14 || 
        widget.currentStreak == 30 ||
        widget.currentStreak == 60 ||
        widget.currentStreak == 100) {
      // Extra bonus on milestone days
      streakMultiplier += 1.0;
    }
    
    // Add a small random bonus (to make it more exciting)
    final random = Random();
    final randomBonus = random.nextInt(5) + 1;
    
    // Calculate final rewards
    _coinsAwarded = (baseCoins * streakMultiplier).round() + randomBonus;
    _xpAwarded = (baseXp * streakMultiplier).round();
  }
  
  Future<void> _claimReward() async {
    if (_isClaimingReward) return;
    
    setState(() {
      _isClaimingReward = true;
    });
    
    try {
      final gamificationService = GamificationService();
      
      // Award coins
      await gamificationService.addCoins(widget.userId, _coinsAwarded);
      
      // Award XP
      await gamificationService.addXp(widget.userId, _xpAwarded);
      
      if (widget.onRewardClaimed != null) {
        widget.onRewardClaimed!();
      }
      
      // Close dialog after a small delay
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pop();
      });
    } catch (e) {
      setState(() {
        _isClaimingReward = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to claim rewards: $e')),
      );
    }
  }
  
  void _handleTapChest() {
    if (_isRevealed) return;
    
    setState(() {
      _isOpening = true;
      _isRevealed = true;
    });
    
    // Play animation
    _animationController.reset();
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildDialogContent(),
          );
        },
      ),
    );
  }
  
  Widget _buildDialogContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade900,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: Colors.amber.shade600,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            _isRevealed 
                ? 'Daily Reward!' 
                : 'Your Daily Reward',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          
          // Streak indicator
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.shade600,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.currentStreak} Day Streak',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Chest or rewards
          if (_isRevealed) 
            _buildRewardReveal()
          else 
            _buildChest(),
          
          const SizedBox(height: 20),
          
          // Action button
          ElevatedButton(
            onPressed: _isRevealed 
                ? (_isClaimingReward ? null : _claimReward)
                : _handleTapChest,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              minimumSize: const Size(200, 50),
            ),
            child: Text(
              _isRevealed 
                  ? (_isClaimingReward ? 'Claiming...' : 'Claim Rewards')
                  : 'Open Chest',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          // Info text
          if (!_isRevealed)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Tap to open your daily reward chest',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildChest() {
    return GestureDetector(
      onTap: _handleTapChest,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.brown.shade700,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Chest graphic
            Icon(
              Icons.inventory_2,
              size: 80,
              color: Colors.amber.shade800,
            ),
            
            // Shine effect
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRewardReveal() {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade700, Colors.amber.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Coins reward
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.monetization_on,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                '$_coinsAwarded Coins',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // XP reward
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                '$_xpAwarded XP',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Show daily reward dialog
Future<void> showDailyReward(
  BuildContext context, {
  required String userId,
  required int currentStreak,
  VoidCallback? onRewardClaimed,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => DailyRewardDialog(
      userId: userId,
      currentStreak: currentStreak,
      onRewardClaimed: onRewardClaimed,
    ),
  );
} 