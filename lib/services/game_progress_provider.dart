import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GameProgress {
  final String gameId;
  final int score;
  final int attempts;
  final int timeSpent;
  final DateTime completedAt;

  GameProgress({
    required this.gameId,
    required this.score,
    required this.attempts,
    required this.timeSpent,
    required this.completedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'gameId': gameId,
      'score': score,
      'attempts': attempts,
      'timeSpent': timeSpent,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }

  factory GameProgress.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return GameProgress(
      gameId: data['gameId'] ?? '',
      score: data['score'] ?? 0,
      attempts: data['attempts'] ?? 0,
      timeSpent: data['timeSpent'] ?? 0,
      completedAt: (data['completedAt'] as Timestamp).toDate(),
    );
  }
}

class GameProgressProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;

  void setUserId(String userId) {
    _userId = userId;
  }

  Future<void> saveProgress(GameProgress progress) async {
    if (_userId == null) {
      throw Exception('User ID not set');
    }

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('game_progress')
        .add(progress.toFirestore());

    notifyListeners();
  }

  Future<List<GameProgress>> getProgressForGame(String gameId) async {
    if (_userId == null) {
      throw Exception('User ID not set');
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('game_progress')
        .where('gameId', isEqualTo: gameId)
        .orderBy('completedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => GameProgress.fromFirestore(doc))
        .toList();
  }

  Future<Map<String, int>> getGameStats(String gameId) async {
    if (_userId == null) {
      throw Exception('User ID not set');
    }

    final progress = await getProgressForGame(gameId);
    
    if (progress.isEmpty) {
      return {
        'highScore': 0,
        'totalAttempts': 0,
        'bestTime': 0,
      };
    }

    final highScore = progress
        .map((p) => p.score)
        .reduce((max, score) => score > max ? score : max);

    final totalAttempts = progress
        .map((p) => p.attempts)
        .reduce((sum, attempts) => sum + attempts);

    final bestTime = progress
        .map((p) => p.timeSpent)
        .reduce((min, time) => time < min ? time : min);

    return {
      'highScore': highScore,
      'totalAttempts': totalAttempts,
      'bestTime': bestTime,
    };
  }
} 