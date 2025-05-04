import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// XP and Level System
class XpLevel {
  final int level;
  final int requiredXp;
  final String title;
  final String? icon;
  final Color color;
  
  XpLevel({
    required this.level,
    required this.requiredXp,
    required this.title,
    this.icon,
    required this.color,
  });
  
  factory XpLevel.fromMap(Map<String, dynamic> map) {
    return XpLevel(
      level: map['level'] ?? 1,
      requiredXp: map['requiredXp'] ?? 0,
      title: map['title'] ?? 'Novice',
      icon: map['icon'],
      color: Color(map['color'] ?? Colors.blue.value),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'requiredXp': requiredXp,
      'title': title,
      'icon': icon,
      'color': color.value,
    };
  }
}

/// User Progress and Levels
class UserProgress {
  final String userId;
  int totalXp;
  int level;
  int coins;
  DateTime lastLogin;
  int loginStreak;
  Map<String, SubjectProgress> subjectProgress;
  
  UserProgress({
    required this.userId,
    this.totalXp = 0,
    this.level = 1,
    this.coins = 0,
    required this.lastLogin,
    this.loginStreak = 0,
    required this.subjectProgress,
  });
  
  factory UserProgress.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    Map<String, SubjectProgress> subjects = {};
    
    if (data['subjectProgress'] != null) {
      (data['subjectProgress'] as Map<String, dynamic>).forEach((key, value) {
        subjects[key] = SubjectProgress.fromMap(value);
      });
    }
    
    return UserProgress(
      userId: data['userId'] ?? '',
      totalXp: data['totalXp'] ?? 0,
      level: data['level'] ?? 1,
      coins: data['coins'] ?? 0,
      lastLogin: (data['lastLogin'] as Timestamp).toDate(),
      loginStreak: data['loginStreak'] ?? 0,
      subjectProgress: subjects,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    Map<String, dynamic> subjectProgressMap = {};
    subjectProgress.forEach((key, value) {
      subjectProgressMap[key] = value.toMap();
    });
    
    return {
      'userId': userId,
      'totalXp': totalXp,
      'level': level,
      'coins': coins,
      'lastLogin': Timestamp.fromDate(lastLogin),
      'loginStreak': loginStreak,
      'subjectProgress': subjectProgressMap,
    };
  }
  
  // Add XP and update level
  void addXp(int amount, List<XpLevel> levels) {
    totalXp += amount;
    // Update level based on XP thresholds
    for (int i = levels.length - 1; i >= 0; i--) {
      if (totalXp >= levels[i].requiredXp) {
        level = levels[i].level;
        break;
      }
    }
  }
  
  // Add coins
  void addCoins(int amount) {
    coins += amount;
  }
  
  // Update login streak
  void updateLoginStreak() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    // If last login was yesterday, increment streak
    if (lastLogin.year == yesterday.year && 
        lastLogin.month == yesterday.month && 
        lastLogin.day == yesterday.day) {
      loginStreak++;
    } 
    // If last login was today, do nothing
    else if (lastLogin.year == now.year && 
             lastLogin.month == now.month && 
             lastLogin.day == now.day) {
      // Do nothing
    } 
    // Otherwise reset streak
    else {
      loginStreak = 1;
    }
    
    lastLogin = now;
  }
}

/// Subject-specific Progress
class SubjectProgress {
  String subjectId;
  int xpEarned;
  int gamesCompleted;
  int perfectScores;
  int highestStreak;
  int currentStreak;
  Map<String, int> personalBests; // Game ID -> Score
  
  SubjectProgress({
    required this.subjectId,
    this.xpEarned = 0,
    this.gamesCompleted = 0,
    this.perfectScores = 0,
    this.highestStreak = 0,
    this.currentStreak = 0,
    required this.personalBests,
  });
  
  factory SubjectProgress.fromMap(Map<String, dynamic> map) {
    Map<String, int> bests = {};
    if (map['personalBests'] != null) {
      (map['personalBests'] as Map<String, dynamic>).forEach((key, value) {
        bests[key] = value as int;
      });
    }
    
    return SubjectProgress(
      subjectId: map['subjectId'] ?? '',
      xpEarned: map['xpEarned'] ?? 0,
      gamesCompleted: map['gamesCompleted'] ?? 0,
      perfectScores: map['perfectScores'] ?? 0,
      highestStreak: map['highestStreak'] ?? 0,
      currentStreak: map['currentStreak'] ?? 0,
      personalBests: bests,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'subjectId': subjectId,
      'xpEarned': xpEarned,
      'gamesCompleted': gamesCompleted,
      'perfectScores': perfectScores,
      'highestStreak': highestStreak,
      'currentStreak': currentStreak,
      'personalBests': personalBests,
    };
  }
  
  // Update streak
  void updateStreak(bool success) {
    if (success) {
      currentStreak++;
      if (currentStreak > highestStreak) {
        highestStreak = currentStreak;
      }
    } else {
      currentStreak = 0;
    }
  }
  
  // Update personal best
  void updatePersonalBest(String gameId, int score) {
    if (!personalBests.containsKey(gameId) || score > personalBests[gameId]!) {
      personalBests[gameId] = score;
    }
  }
}

/// Badges and Achievements
class Badge {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final String category; // 'subject', 'achievement', 'streak', etc.
  final String type; // For compatibility with error messages
  final int requiredValue; // XP, streak count, etc.
  final String? subjectId; // For subject-specific badges
  final Map<String, dynamic>? conditions; // Additional conditions
  
  Badge({
    String? id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.category,
    this.type = '', // Added type property with default value
    required this.requiredValue,
    this.subjectId,
    this.conditions,
  }) : id = id ?? const Uuid().v4();
  
  factory Badge.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    
    return Badge(
      id: snapshot.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      iconPath: data['iconPath'] ?? '',
      category: data['category'] ?? '',
      type: data['type'] ?? '',
      requiredValue: data['requiredValue'] ?? 0,
      subjectId: data['subjectId'],
      conditions: data['conditions'] as Map<String, dynamic>?,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'iconPath': iconPath,
      'category': category,
      'type': type,
      'requiredValue': requiredValue,
      'subjectId': subjectId,
      'conditions': conditions,
    };
  }
}

/// User Badge Collection
class UserBadge {
  final String badgeId;
  final DateTime earnedAt;
  final bool isNew; // For UI notification purposes
  final bool isCompleted; // Added to fix error
  final int progress; // Added to fix error - progress percentage 0-100
  
  UserBadge({
    required this.badgeId,
    required this.earnedAt,
    this.isNew = true,
    this.isCompleted = false,
    this.progress = 0,
  });
  
  factory UserBadge.fromMap(Map<String, dynamic> map) {
    return UserBadge(
      badgeId: map['badgeId'] ?? '',
      earnedAt: (map['earnedAt'] as Timestamp).toDate(),
      isNew: map['isNew'] ?? true,
      isCompleted: map['isCompleted'] ?? false,
      progress: map['progress'] ?? 0,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'badgeId': badgeId,
      'earnedAt': Timestamp.fromDate(earnedAt),
      'isNew': isNew,
      'isCompleted': isCompleted,
      'progress': progress,
    };
  }
}

/// Store Items
class StoreItem {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final int price;
  final String category; // 'avatar', 'theme', 'powerup', etc.
  final Map<String, dynamic>? properties; // Additional item properties
  
  StoreItem({
    String? id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.price,
    required this.category,
    this.properties,
  }) : id = id ?? const Uuid().v4();
  
  factory StoreItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    
    return StoreItem(
      id: snapshot.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imagePath: data['imagePath'] ?? '',
      price: data['price'] ?? 0,
      category: data['category'] ?? '',
      properties: data['properties'] as Map<String, dynamic>?,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imagePath': imagePath,
      'price': price,
      'category': category,
      'properties': properties,
    };
  }
}

/// User Inventory
class UserInventory {
  final String userId;
  final List<String> ownedItems;
  final Map<String, dynamic> equipped; // category -> itemId
  
  UserInventory({
    required this.userId,
    required this.ownedItems,
    required this.equipped,
  });
  
  factory UserInventory.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    
    return UserInventory(
      userId: data['userId'] ?? '',
      ownedItems: List<String>.from(data['ownedItems'] ?? []),
      equipped: data['equipped'] as Map<String, dynamic>? ?? {},
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'ownedItems': ownedItems,
      'equipped': equipped,
    };
  }
  
  // Add an item to the inventory
  void addItem(String itemId) {
    if (!ownedItems.contains(itemId)) {
      ownedItems.add(itemId);
    }
  }
  
  // Equip an item
  void equipItem(String category, String itemId) {
    equipped[category] = itemId;
  }
}

/// Leaderboard Entry
class LeaderboardEntry {
  final String userId;
  final String userName;
  final String? avatar;
  final int value; // Score, XP, etc.
  final DateTime updatedAt;
  
  LeaderboardEntry({
    required this.userId,
    required this.userName,
    this.avatar,
    required this.value,
    required this.updatedAt,
  });
  
  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      avatar: map['avatar'],
      value: map['value'] ?? 0,
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'avatar': avatar,
      'value': value,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

/// Game Session Record
class GameSession {
  final String id;
  final String gameId;
  final String gameTitle;
  final String gameType;
  final DateTime startedAt;
  final DateTime completedAt;
  final int durationSeconds;
  final int correctAnswers;
  final int totalQuestions;
  final double scorePercentage;
  final int xpEarned;
  final int coinsEarned;
  final List<QuestionResult>? questionResults;
  
  GameSession({
    required this.id,
    required this.gameId,
    required this.gameTitle,
    required this.gameType,
    required this.startedAt,
    required this.completedAt,
    required this.durationSeconds,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.scorePercentage,
    required this.xpEarned,
    required this.coinsEarned,
    this.questionResults,
  });
  
  factory GameSession.fromFirestore(Map<String, dynamic> data, String id) {
    return GameSession(
      id: id,
      gameId: data['gameId'] ?? '',
      gameTitle: data['gameTitle'] ?? '',
      gameType: data['gameType'] ?? '',
      startedAt: (data['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durationSeconds: data['durationSeconds'] ?? 0,
      correctAnswers: data['correctAnswers'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      scorePercentage: data['scorePercentage']?.toDouble() ?? 0.0,
      xpEarned: data['xpEarned'] ?? 0,
      coinsEarned: data['coinsEarned'] ?? 0,
      questionResults: (data['questionResults'] as List<dynamic>?)
          ?.map((q) => QuestionResult.fromFirestore(q))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'gameId': gameId,
      'gameTitle': gameTitle,
      'gameType': gameType,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': Timestamp.fromDate(completedAt),
      'durationSeconds': durationSeconds,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'scorePercentage': scorePercentage,
      'xpEarned': xpEarned,
      'coinsEarned': coinsEarned,
      'questionResults': questionResults?.map((q) => q.toFirestore()).toList(),
    };
  }
}

class QuestionResult {
  final String questionId;
  final bool isCorrect;
  final double timeSpentSeconds;
  final String? answerGiven;
  
  QuestionResult({
    required this.questionId,
    required this.isCorrect,
    required this.timeSpentSeconds,
    this.answerGiven,
  });
  
  factory QuestionResult.fromFirestore(Map<String, dynamic> data) {
    return QuestionResult(
      questionId: data['questionId'] ?? '',
      isCorrect: data['isCorrect'] ?? false,
      timeSpentSeconds: data['timeSpentSeconds']?.toDouble() ?? 0.0,
      answerGiven: data['answerGiven'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'questionId': questionId,
      'isCorrect': isCorrect,
      'timeSpentSeconds': timeSpentSeconds,
      'answerGiven': answerGiven,
    };
  }
} 