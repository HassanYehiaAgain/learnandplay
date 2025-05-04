import 'package:flutter/foundation.dart';
import 'package:learn_play_level_up_flutter/services/analytics_service.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/models/analytics_models.dart';

class GameAnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> trackGameCreation(GameTemplate game, String teacherId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _analyticsService.recordGameCreation(
        gameId: game.id,
        gameType: game.type,
        teacherId: teacherId,
        subjectId: game.subjectId,
        metadata: {
          'title': game.title,
          'estimatedDuration': game.estimatedDuration,
          'maxPoints': game.maxPoints,
          'xpReward': game.xpReward,
          'coinReward': game.coinReward,
          'tags': game.tags,
        },
      );
    } catch (e) {
      _error = 'Failed to track game creation: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> trackGameSession(
    String gameId,
    String studentId,
    String subjectId,
    int score,
    int maxScore,
    Duration duration,
    Map<String, dynamic> gameSpecificData,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final session = AnalyticsGameSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: studentId,
        gameId: gameId,
        gameTitle: '', // Will be fetched by the service
        gameType: '', // Will be fetched by the service
        subjectId: subjectId,
        startedAt: DateTime.now().subtract(duration),
        completedAt: DateTime.now(),
        durationSeconds: duration.inSeconds,
        correctAnswers: 0, // Should be provided in gameSpecificData
        totalQuestions: 0, // Should be provided in gameSpecificData
        scorePercentage: (score / maxScore) * 100,
        xpEarned: 0, // Will be calculated by the service
        coinsEarned: 0, // Will be calculated by the service
      );

      await _analyticsService.recordGameSession(
        session,
        studentId,
        subjectId,
      );
    } catch (e) {
      _error = 'Failed to track game session: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getGameAnalytics(String gameId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get various analytics data
      final performance = await _analyticsService.getGamePerformanceAnalytics(gameId);
      final questionStats = await _analyticsService.getQuestionAnalytics(gameId);
      final studentProgress = await _analyticsService.getStudentProgressForGame(gameId);

      return {
        'performance': performance,
        'questionStats': questionStats,
        'studentProgress': studentProgress,
      };
    } catch (e) {
      _error = 'Failed to get game analytics: $e';
      debugPrint(_error);
      return {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 