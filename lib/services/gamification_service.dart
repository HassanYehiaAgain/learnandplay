import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/models/gamification_models.dart' as gamification;
import 'package:learn_play_level_up_flutter/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class GamificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collections
  final _userProgressCollection = 'user_progress';
  final _badgesCollection = 'badges';
  final _userBadgesCollection = 'user_badges';
  final _storeItemsCollection = 'store_items';
  final _userInventoryCollection = 'user_inventory';
  final _leaderboardsCollection = 'leaderboards';
  final _gameSessionsCollection = 'game_sessions';
  
  // Cached data
  List<gamification.XpLevel> _levels = [];
  List<gamification.Badge> _badges = [];
  
  // Singleton pattern
  static final GamificationService _instance = GamificationService._internal();
  
  factory GamificationService() {
    return _instance;
  }
  
  GamificationService._internal() {
    _initializeLevels();
    _loadBadges();
  }
  
  // Define XP levels
  void _initializeLevels() {
    _levels = [
      gamification.XpLevel(level: 1, requiredXp: 0, title: 'Novice', color: Colors.grey.shade400),
      gamification.XpLevel(level: 2, requiredXp: 100, title: 'Beginner', color: Colors.lightBlue.shade300),
      gamification.XpLevel(level: 3, requiredXp: 300, title: 'Apprentice', color: Colors.green.shade300),
      gamification.XpLevel(level: 4, requiredXp: 600, title: 'Explorer', color: Colors.amber.shade300),
      gamification.XpLevel(level: 5, requiredXp: 1000, title: 'Scholar', color: Colors.orange.shade300),
      gamification.XpLevel(level: 6, requiredXp: 1500, title: 'Expert', color: Colors.red.shade300),
      gamification.XpLevel(level: 7, requiredXp: 2100, title: 'Master', color: Colors.purple.shade300),
      gamification.XpLevel(level: 8, requiredXp: 2800, title: 'Champion', color: Colors.indigo.shade300),
      gamification.XpLevel(level: 9, requiredXp: 3600, title: 'Hero', color: Colors.cyan.shade300),
      gamification.XpLevel(level: 10, requiredXp: 4500, title: 'Legend', color: Colors.pinkAccent.shade100),
    ];
  }
  
  // Load all badge definitions from Firebase
  Future<void> _loadBadges() async {
    try {
      final snapshot = await _firestore.collection(_badgesCollection).get();
      _badges = snapshot.docs.map((doc) => gamification.Badge.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error loading badges: $e');
    }
  }
  
  // Get levels
  List<gamification.XpLevel> getLevels() {
    return _levels;
  }
  
  // Get specific level by level number
  gamification.XpLevel? getLevelByNumber(int level) {
    try {
      return _levels.firstWhere((l) => l.level == level);
    } catch (e) {
      return null;
    }
  }
  
  // Get current level based on XP
  gamification.XpLevel getCurrentLevel(int xp) {
    for (int i = _levels.length - 1; i >= 0; i--) {
      if (xp >= _levels[i].requiredXp) {
        return _levels[i];
      }
    }
    return _levels.first;
  }
  
  // Calculate progress to next level
  double getProgressToNextLevel(int xp) {
    gamification.XpLevel currentLevel = getCurrentLevel(xp);
    int currentLevelIndex = _levels.indexWhere((l) => l.level == currentLevel.level);
    
    // If at max level, return 100%
    if (currentLevelIndex == _levels.length - 1) {
      return 1.0;
    }
    
    gamification.XpLevel nextLevel = _levels[currentLevelIndex + 1];
    int xpForCurrentLevel = currentLevel.requiredXp;
    int xpNeededForNextLevel = nextLevel.requiredXp - xpForCurrentLevel;
    int xpProgress = xp - xpForCurrentLevel;
    
    return xpNeededForNextLevel > 0 ? xpProgress / xpNeededForNextLevel : 1.0;
  }
  
  // Get XP needed for next level
  int getXpNeededForNextLevel(int xp) {
    gamification.XpLevel currentLevel = getCurrentLevel(xp);
    int currentLevelIndex = _levels.indexWhere((l) => l.level == currentLevel.level);
    
    // If at max level, return 0
    if (currentLevelIndex == _levels.length - 1) {
      return 0;
    }
    
    gamification.XpLevel nextLevel = _levels[currentLevelIndex + 1];
    return nextLevel.requiredXp - xp;
  }
  
  // Get User Progress
  Future<gamification.UserProgress?> getUserProgress(String userId) async {
    try {
      final doc = await _firestore.collection(_userProgressCollection).doc(userId).get();
      
      if (doc.exists) {
        return gamification.UserProgress.fromFirestore(doc);
      } else {
        // Create a new progress record if none exists
        final newProgress = gamification.UserProgress(
          userId: userId,
          lastLogin: DateTime.now(),
          subjectProgress: {},
        );
        
        await _firestore.collection(_userProgressCollection).doc(userId).set(
          newProgress.toFirestore()
        );
        
        return newProgress;
      }
    } catch (e) {
      debugPrint('Error getting user progress: $e');
      return null;
    }
  }
  
  // Update user login streak
  Future<int> updateLoginStreak(String userId) async {
    try {
      final progress = await getUserProgress(userId);
      
      if (progress != null) {
        progress.updateLoginStreak();
        
        await _firestore.collection(_userProgressCollection).doc(userId).update({
          'lastLogin': Timestamp.fromDate(progress.lastLogin),
          'loginStreak': progress.loginStreak,
        });
        
        // Check for streak badges
        _checkForStreakBadges(userId, progress.loginStreak);
        
        return progress.loginStreak;
      }
      
      return 0;
    } catch (e) {
      debugPrint('Error updating login streak: $e');
      return 0;
    }
  }
  
  // Add XP to user
  Future<Map<String, dynamic>> addXp(String userId, int amount, {String? subjectId}) async {
    try {
      final result = {
        'success': false,
        'newXp': 0,
        'oldLevel': 0,
        'newLevel': 0,
        'levelUp': false,
      };
      
      final progress = await getUserProgress(userId);
      
      if (progress != null) {
        final oldLevel = progress.level;
        final oldXp = progress.totalXp;
        
        // Add XP and update level
        progress.addXp(amount, _levels);
        
        // Update in Firestore
        final batch = _firestore.batch();
        
        // Update total XP and level
        batch.update(
          _firestore.collection(_userProgressCollection).doc(userId),
          {
            'totalXp': progress.totalXp,
            'level': progress.level,
          }
        );
        
        // If subject provided, update subject XP
        if (subjectId != null) {
          if (!progress.subjectProgress.containsKey(subjectId)) {
            progress.subjectProgress[subjectId] = gamification.SubjectProgress(
              subjectId: subjectId,
              personalBests: {},
            );
          }
          
          progress.subjectProgress[subjectId]!.xpEarned += amount;
          
          batch.update(
            _firestore.collection(_userProgressCollection).doc(userId),
            {
              'subjectProgress.$subjectId.xpEarned': progress.subjectProgress[subjectId]!.xpEarned,
            }
          );
          
          // Check for subject mastery badges
          _checkForSubjectBadges(userId, subjectId, progress.subjectProgress[subjectId]!.xpEarned);
        }
        
        await batch.commit();
        
        // Check for level-based badges
        if (progress.level > oldLevel) {
          _checkForLevelBadges(userId, progress.level);
        }
        
        // Check for XP-based badges
        _checkForXpBadges(userId, progress.totalXp);
        
        // Return results
        result['success'] = true;
        result['newXp'] = progress.totalXp;
        result['oldLevel'] = oldLevel;
        result['newLevel'] = progress.level;
        result['levelUp'] = progress.level > oldLevel;
        result['xpGained'] = amount;
        result['xpNeededForNextLevel'] = getXpNeededForNextLevel(progress.totalXp);
        result['progressToNextLevel'] = getProgressToNextLevel(progress.totalXp);
      }
      
      return result;
    } catch (e) {
      debugPrint('Error adding XP: $e');
      return {'success': false};
    }
  }
  
  // Add coins to user
  Future<bool> addCoins(String userId, int amount) async {
    try {
      final progress = await getUserProgress(userId);
      
      if (progress != null) {
        progress.addCoins(amount);
        
        // Update in Firestore
        await _firestore.collection(_userProgressCollection).doc(userId).update({
          'coins': progress.coins,
        });
        
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error adding coins: $e');
      return false;
    }
  }
  
  // Spend coins
  Future<bool> spendCoins(String userId, int amount) async {
    try {
      final progress = await getUserProgress(userId);
      
      if (progress != null) {
        if (progress.coins >= amount) {
          progress.coins -= amount;
          
          // Update in Firestore
          await _firestore.collection(_userProgressCollection).doc(userId).update({
            'coins': progress.coins,
          });
          
          return true;
        }
      }
      
      return false;
    } catch (e) {
      debugPrint('Error spending coins: $e');
      return false;
    }
  }
  
  // Record game session
  Future<gamification.GameSession?> recordGameSession({
    required String gameId,
    required String userId,
    required String gameType,
    required int score,
    required int maxScore,
    required Duration duration,
    int? xpEarned,
    int? coinsEarned,
    Map<String, dynamic>? details,
    String? subjectId,
  }) async {
    try {
      // Calculate rewards if not provided
      final calculatedXp = xpEarned ?? _calculateXpReward(score, maxScore, duration);
      final calculatedCoins = coinsEarned ?? _calculateCoinReward(score, maxScore, duration);
      
      final String id = const Uuid().v4();
      
      // Create game data map first
      final Map<String, dynamic> gameData = {
        'gameId': gameId,
        'userId': userId,
        'gameType': gameType,
        'score': score,
        'maxScore': maxScore,
        'xpEarned': calculatedXp,
        'coinsEarned': calculatedCoins,
        'duration': duration.inSeconds,
        'completedAt': DateTime.now(),
        'details': details,
      };
      
      // Create the session using the correct constructor pattern
      final session = gamification.GameSession.fromFirestore(gameData, id);
      
      // Save to Firestore
      await _firestore.collection(_gameSessionsCollection).doc(session.id).set(
        session.toFirestore()
      );
      
      // Update user progress
      await addXp(userId, calculatedXp, subjectId: subjectId);
      await addCoins(userId, calculatedCoins);
      
      // Update subject-specific progress
      if (subjectId != null) {
        await _updateSubjectProgress(
          userId: userId,
          subjectId: subjectId,
          gameId: gameId,
          score: score,
          maxScore: maxScore,
          isPerfect: score >= maxScore,
        );
      }
      
      // Update leaderboards
      if (subjectId != null) {
        await _updateLeaderboard('subject_$subjectId', userId, score);
      }
      await _updateLeaderboard('game_$gameId', userId, score);
      await _updateLeaderboard('global', userId, score);
      
      return session;
    } catch (e) {
      debugPrint('Error recording game session: $e');
      return null;
    }
  }
  
  // Calculate XP reward based on performance
  int _calculateXpReward(int score, int maxScore, Duration duration) {
    double percentageScore = maxScore > 0 ? score / maxScore : 0;
    
    // Base XP from percentage score (0-100)
    int baseXp = (percentageScore * 100).round();
    
    // Bonus for quick completion
    int timeBonus = 0;
    if (duration.inSeconds < 60) {
      timeBonus = 25; // Very fast
    } else if (duration.inSeconds < 120) {
      timeBonus = 15; // Fast
    } else if (duration.inSeconds < 180) {
      timeBonus = 5; // Normal
    }
    
    // Perfect score bonus
    int perfectBonus = score >= maxScore ? 50 : 0;
    
    return baseXp + timeBonus + perfectBonus;
  }
  
  // Calculate coin reward based on performance
  int _calculateCoinReward(int score, int maxScore, Duration duration) {
    double percentageScore = maxScore > 0 ? score / maxScore : 0;
    
    // Base coins from percentage score (0-10)
    int baseCoins = (percentageScore * 10).round();
    
    // Perfect score bonus
    int perfectBonus = score >= maxScore ? 5 : 0;
    
    return baseCoins + perfectBonus;
  }
  
  // Update subject-specific progress
  Future<void> _updateSubjectProgress({
    required String userId,
    required String subjectId,
    required String gameId,
    required int score,
    required int maxScore,
    required bool isPerfect,
  }) async {
    try {
      final progress = await getUserProgress(userId);
      
      if (progress != null) {
        if (!progress.subjectProgress.containsKey(subjectId)) {
          progress.subjectProgress[subjectId] = gamification.SubjectProgress(
            subjectId: subjectId,
            personalBests: {},
          );
        }
        
        final subject = progress.subjectProgress[subjectId]!;
        
        // Update game completion count
        subject.gamesCompleted++;
        
        // Update perfect score count
        if (isPerfect) {
          subject.perfectScores++;
        }
        
        // Update streak
        subject.updateStreak(isPerfect);
        
        // Update personal best
        subject.updatePersonalBest(gameId, score);
        
        // Update in Firestore
        final Map<String, dynamic> updates = {
          'subjectProgress.$subjectId.gamesCompleted': subject.gamesCompleted,
          'subjectProgress.$subjectId.perfectScores': subject.perfectScores,
          'subjectProgress.$subjectId.currentStreak': subject.currentStreak,
          'subjectProgress.$subjectId.highestStreak': subject.highestStreak,
          'subjectProgress.$subjectId.personalBests.$gameId': subject.personalBests[gameId],
        };
        
        await _firestore.collection(_userProgressCollection).doc(userId).update(updates);
        
        // Check for streak badges
        _checkForGameStreakBadges(userId, subject.currentStreak);
        
        // Check for perfect score badges
        if (isPerfect) {
          _checkForPerfectScoreBadges(userId, subject.perfectScores);
        }
      }
    } catch (e) {
      debugPrint('Error updating subject progress: $e');
    }
  }
  
  // Get user's badges
  Future<List<gamification.UserBadge>> getUserBadges(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_userBadgesCollection)
          .where('userId', isEqualTo: userId)
          .get();
      
      return snapshot.docs.map((doc) => gamification.UserBadge.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Error getting user badges: $e');
      return [];
    }
  }
  
  // Add a badge to user
  Future<bool> awardBadge(String userId, String badgeId) async {
    try {
      // Check if user already has this badge
      final existingQuery = await _firestore
          .collection(_userBadgesCollection)
          .where('userId', isEqualTo: userId)
          .where('badgeId', isEqualTo: badgeId)
          .limit(1)
          .get();
      
      if (existingQuery.docs.isNotEmpty) {
        return false; // User already has this badge
      }
      
      // Add new badge
      final userBadge = gamification.UserBadge(
        badgeId: badgeId,
        earnedAt: DateTime.now(),
      );
      
      await _firestore.collection(_userBadgesCollection).add({
        'userId': userId,
        'badgeId': badgeId,
        'earnedAt': Timestamp.fromDate(userBadge.earnedAt),
        'isNew': true,
      });
      
      return true;
    } catch (e) {
      debugPrint('Error awarding badge: $e');
      return false;
    }
  }
  
  // Mark a badge as viewed (not new)
  Future<void> markBadgeAsViewed(String userId, String badgeId) async {
    try {
      final query = await _firestore
          .collection(_userBadgesCollection)
          .where('userId', isEqualTo: userId)
          .where('badgeId', isEqualTo: badgeId)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        await _firestore.collection(_userBadgesCollection)
            .doc(query.docs.first.id)
            .update({'isNew': false});
      }
    } catch (e) {
      debugPrint('Error marking badge as viewed: $e');
    }
  }
  
  // Get store items
  Future<List<gamification.StoreItem>> getStoreItems() async {
    try {
      final snapshot = await _firestore.collection(_storeItemsCollection).get();
      return snapshot.docs.map((doc) => gamification.StoreItem.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting store items: $e');
      return [];
    }
  }
  
  // Get user inventory
  Future<gamification.UserInventory?> getUserInventory(String userId) async {
    try {
      final doc = await _firestore.collection(_userInventoryCollection).doc(userId).get();
      
      if (doc.exists) {
        return gamification.UserInventory.fromFirestore(doc);
      } else {
        // Create new inventory if none exists
        final newInventory = gamification.UserInventory(
          userId: userId,
          ownedItems: [],
          equipped: {},
        );
        
        await _firestore.collection(_userInventoryCollection).doc(userId).set(
          newInventory.toFirestore()
        );
        
        return newInventory;
      }
    } catch (e) {
      debugPrint('Error getting user inventory: $e');
      return null;
    }
  }
  
  // Purchase an item
  Future<bool> purchaseItem(String userId, String itemId) async {
    try {
      // Get item price
      final itemDoc = await _firestore.collection(_storeItemsCollection).doc(itemId).get();
      if (!itemDoc.exists) {
        return false;
      }
      
      final item = gamification.StoreItem.fromFirestore(itemDoc);
      
      // Check if user already owns this item
      final inventory = await getUserInventory(userId);
      if (inventory == null || inventory.ownedItems.contains(itemId)) {
        return false;
      }
      
      // Check if user has enough coins
      final progress = await getUserProgress(userId);
      if (progress == null || progress.coins < item.price) {
        return false;
      }
      
      // Process purchase
      final batch = _firestore.batch();
      
      // Deduct coins
      batch.update(
        _firestore.collection(_userProgressCollection).doc(userId),
        {'coins': progress.coins - item.price}
      );
      
      // Add to inventory
      inventory.ownedItems.add(itemId);
      batch.update(
        _firestore.collection(_userInventoryCollection).doc(userId),
        {'ownedItems': inventory.ownedItems}
      );
      
      await batch.commit();
      
      return true;
    } catch (e) {
      debugPrint('Error purchasing item: $e');
      return false;
    }
  }
  
  // Equip an item
  Future<bool> equipItem(String userId, String category, String itemId) async {
    try {
      // Check if user owns this item
      final inventory = await getUserInventory(userId);
      if (inventory == null || !inventory.ownedItems.contains(itemId)) {
        return false;
      }
      
      // Equip item
      inventory.equipItem(category, itemId);
      
      await _firestore.collection(_userInventoryCollection).doc(userId).update({
        'equipped.$category': itemId,
      });
      
      return true;
    } catch (e) {
      debugPrint('Error equipping item: $e');
      return false;
    }
  }
  
  // Get leaderboard entries
  Future<List<gamification.LeaderboardEntry>> getLeaderboard(String leaderboardId, {int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(_leaderboardsCollection)
          .doc(leaderboardId)
          .collection('entries')
          .orderBy('value', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) => gamification.LeaderboardEntry.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Error getting leaderboard: $e');
      return [];
    }
  }
  
  // Get user's rank in a leaderboard
  Future<int> getUserLeaderboardRank(String leaderboardId, String userId) async {
    try {
      final userEntry = await _firestore
          .collection(_leaderboardsCollection)
          .doc(leaderboardId)
          .collection('entries')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      
      if (userEntry.docs.isEmpty) {
        return -1; // User not on leaderboard
      }
      
      final userValue = userEntry.docs.first.data()['value'] as int;
      
      // Count entries with higher values
      final higherEntries = await _firestore
          .collection(_leaderboardsCollection)
          .doc(leaderboardId)
          .collection('entries')
          .where('value', isGreaterThan: userValue)
          .count()
          .get();
      
      return higherEntries.count + 1; // Rank is 1-based
    } catch (e) {
      debugPrint('Error getting user leaderboard rank: $e');
      return -1;
    }
  }
  
  // Update leaderboard entry
  Future<void> _updateLeaderboard(String leaderboardId, String userId, int value) async {
    try {
      // Get user data for display
      final user = await _firestore.collection('users').doc(userId).get();
      final userData = user.data();
      
      if (userData == null) {
        return;
      }
      
      final entry = gamification.LeaderboardEntry(
        userId: userId,
        userName: userData['name'] ?? 'Unknown',
        avatar: userData['avatar'],
        value: value,
        updatedAt: DateTime.now(),
      );
      
      // Check if user already has an entry
      final existingEntry = await _firestore
          .collection(_leaderboardsCollection)
          .doc(leaderboardId)
          .collection('entries')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      
      if (existingEntry.docs.isNotEmpty) {
        final currentValue = existingEntry.docs.first.data()['value'] as int;
        
        // Only update if new value is higher
        if (value > currentValue) {
          await _firestore
              .collection(_leaderboardsCollection)
              .doc(leaderboardId)
              .collection('entries')
              .doc(existingEntry.docs.first.id)
              .update(entry.toMap());
        }
      } else {
        // Create new entry
        await _firestore
            .collection(_leaderboardsCollection)
            .doc(leaderboardId)
            .collection('entries')
            .add(entry.toMap());
      }
    } catch (e) {
      debugPrint('Error updating leaderboard: $e');
    }
  }
  
  // Get user's game history
  Future<List<gamification.GameSession>> getUserGameHistory(String userId, {int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(_gameSessionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) => 
        gamification.GameSession.fromFirestore(doc.data(), doc.id)
      ).toList();
    } catch (e) {
      debugPrint('Error getting user game history: $e');
      return [];
    }
  }
  
  // Get user's subject statistics
  Future<Map<String, dynamic>> getUserSubjectStats(String userId, String subjectId) async {
    try {
      final progress = await getUserProgress(userId);
      if (progress == null || !progress.subjectProgress.containsKey(subjectId)) {
        return {};
      }
      
      final subject = progress.subjectProgress[subjectId]!;
      
      // Get game sessions for this subject
      final sessions = await _firestore
          .collection(_gameSessionsCollection)
          .where('userId', isEqualTo: userId)
          .where('details.subjectId', isEqualTo: subjectId)
          .orderBy('completedAt', descending: true)
          .get();
      
      final gameSessions = sessions.docs.map((doc) => 
        gamification.GameSession.fromFirestore(doc.data(), doc.id)
      ).toList();
      
      // Calculate average score
      double averageScore = 0;
      if (gameSessions.isNotEmpty) {
        double totalPercentage = 0;
        for (var session in gameSessions) {
          totalPercentage += session.scorePercentage;
        }
        averageScore = totalPercentage / gameSessions.length;
      }
      
      return {
        'xpEarned': subject.xpEarned,
        'gamesCompleted': subject.gamesCompleted,
        'perfectScores': subject.perfectScores,
        'currentStreak': subject.currentStreak,
        'highestStreak': subject.highestStreak,
        'personalBests': subject.personalBests,
        'averageScore': averageScore,
        'recentSessions': gameSessions,
      };
    } catch (e) {
      debugPrint('Error getting user subject stats: $e');
      return {};
    }
  }
  
  // Check and award badges for level achievements
  Future<void> _checkForLevelBadges(String userId, int level) async {
    // Get level badges
    final levelBadges = _badges.where((b) => 
      b.category == 'level' && b.requiredValue <= level
    ).toList();
    
    // Award badges
    for (var badge in levelBadges) {
      await awardBadge(userId, badge.id);
    }
  }
  
  // Check and award badges for XP achievements
  Future<void> _checkForXpBadges(String userId, int xp) async {
    // Get XP badges
    final xpBadges = _badges.where((b) => 
      b.category == 'xp' && b.requiredValue <= xp
    ).toList();
    
    // Award badges
    for (var badge in xpBadges) {
      await awardBadge(userId, badge.id);
    }
  }
  
  // Check and award badges for login streak achievements
  Future<void> _checkForStreakBadges(String userId, int streak) async {
    // Get streak badges
    final streakBadges = _badges.where((b) => 
      b.category == 'login_streak' && b.requiredValue <= streak
    ).toList();
    
    // Award badges
    for (var badge in streakBadges) {
      await awardBadge(userId, badge.id);
    }
  }
  
  // Check and award badges for game streak achievements
  Future<void> _checkForGameStreakBadges(String userId, int streak) async {
    // Get streak badges
    final streakBadges = _badges.where((b) => 
      b.category == 'game_streak' && b.requiredValue <= streak
    ).toList();
    
    // Award badges
    for (var badge in streakBadges) {
      await awardBadge(userId, badge.id);
    }
  }
  
  // Check and award badges for perfect score achievements
  Future<void> _checkForPerfectScoreBadges(String userId, int perfectScores) async {
    // Get perfect score badges
    final perfectBadges = _badges.where((b) => 
      b.category == 'perfect_score' && b.requiredValue <= perfectScores
    ).toList();
    
    // Award badges
    for (var badge in perfectBadges) {
      await awardBadge(userId, badge.id);
    }
  }
  
  // Check and award badges for subject mastery
  Future<void> _checkForSubjectBadges(String userId, String subjectId, int xp) async {
    // Get subject badges for this subject
    final subjectBadges = _badges.where((b) => 
      b.category == 'subject_mastery' && 
      b.subjectId == subjectId && 
      b.requiredValue <= xp
    ).toList();
    
    // Award badges
    for (var badge in subjectBadges) {
      await awardBadge(userId, badge.id);
    }
  }

  // Get badge details by IDs
  Future<List<gamification.Badge>> getBadgesByIds(List<String> badgeIds) async {
    try {
      if (badgeIds.isEmpty) return [];
      
      // Firestore only allows batching in groups of 10
      final batches = <List<String>>[];
      for (var i = 0; i < badgeIds.length; i += 10) {
        final end = (i + 10 < badgeIds.length) ? i + 10 : badgeIds.length;
        batches.add(badgeIds.sublist(i, end));
      }
      
      final badgesList = <gamification.Badge>[];
      
      for (final batch in batches) {
        final snapshot = await _firestore
            .collection(_badgesCollection)
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        
        badgesList.addAll(snapshot.docs
            .map((doc) => gamification.Badge.fromFirestore(doc))
            .toList());
      }
      
      return badgesList;
    } catch (e) {
      debugPrint('Error getting badges by IDs: $e');
      return [];
    }
  }
} 