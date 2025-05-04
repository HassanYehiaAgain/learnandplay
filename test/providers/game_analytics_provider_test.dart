import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:learn_play_level_up_flutter/providers/game_analytics_provider.dart';
import 'package:learn_play_level_up_flutter/services/analytics_service.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:learn_play_level_up_flutter/models/analytics_models.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late GameAnalyticsProvider provider;
  late MockAnalyticsService mockAnalyticsService;

  setUp(() {
    mockAnalyticsService = MockAnalyticsService();
    provider = GameAnalyticsProvider();
  });

  group('GameAnalyticsProvider', () {
    test('initializes with default values', () {
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('trackGameCreation updates loading state and calls service', () async {
      final game = GameTemplate(
        id: 'test-id',
        title: 'Test Game',
        description: 'Test Description',
        type: 'test-type',
        subjectId: 'subject-id',
        gradeYear: 5,
        coinReward: 100,
        maxPoints: 1000,
        createdAt: DateTime.now(),
        teacherId: 'teacher-id',
        dueDate: DateTime.now().add(const Duration(days: 7)),
        estimatedDuration: 30,
        tags: ['test'],
        xpReward: 200,
      );

      when(mockAnalyticsService.recordGameCreation(
        gameId: game.id,
        gameType: game.type,
        teacherId: 'teacher-id',
        subjectId: game.subjectId,
        metadata: any,
      )).thenAnswer((_) => Future.value());

      expect(provider.isLoading, false);
      
      await provider.trackGameCreation(game, 'teacher-id');
      
      verify(mockAnalyticsService.recordGameCreation(
        gameId: game.id,
        gameType: game.type,
        teacherId: 'teacher-id',
        subjectId: game.subjectId,
        metadata: any,
      )).called(1);
      
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('trackGameSession updates loading state and calls service', () async {
      const gameId = 'test-game';
      const studentId = 'test-student';
      const subjectId = 'test-subject';
      const score = 80;
      const maxScore = 100;
      const duration = Duration(minutes: 5);

      when(mockAnalyticsService.recordGameSession(
        any,
        studentId,
        subjectId,
      )).thenAnswer((_) => Future.value());

      expect(provider.isLoading, false);
      
      await provider.trackGameSession(
        gameId,
        studentId,
        subjectId,
        score,
        maxScore,
        duration,
        {},
      );
      
      verify(mockAnalyticsService.recordGameSession(
        any,
        studentId,
        subjectId,
      )).called(1);
      
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('getGameAnalytics returns analytics data', () async {
      const gameId = 'test-game';
      final mockPerformance = [
        GameEffectiveness(
          gameId: gameId,
          gameTitle: 'Test Game',
          gameType: 'test-type',
          averageScore: 85.0,
          completionRate: 95.0,
          averageDuration: 300.0,
          timesPlayed: 10,
          subjectPerformance: {'test-subject': 85.0},
        ),
      ];

      when(mockAnalyticsService.getGamePerformanceAnalytics(gameId))
          .thenAnswer((_) => Future.value(mockPerformance));
      when(mockAnalyticsService.getQuestionAnalytics(gameId))
          .thenAnswer((_) => Future.value([]));
      when(mockAnalyticsService.getStudentProgressForGame(gameId))
          .thenAnswer((_) => Future.value([]));

      expect(provider.isLoading, false);
      
      final result = await provider.getGameAnalytics(gameId);
      
      verify(mockAnalyticsService.getGamePerformanceAnalytics(gameId))
          .called(1);
      verify(mockAnalyticsService.getQuestionAnalytics(gameId))
          .called(1);
      verify(mockAnalyticsService.getStudentProgressForGame(gameId))
          .called(1);
      
      expect(result.containsKey('performance'), true);
      expect(result.containsKey('questionStats'), true);
      expect(result.containsKey('studentProgress'), true);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('handles errors gracefully', () async {
      const gameId = 'test-game';
      const error = 'Test error';

      when(mockAnalyticsService.getGamePerformanceAnalytics(gameId))
          .thenThrow(error);

      expect(provider.isLoading, false);
      
      final result = await provider.getGameAnalytics(gameId);
      
      expect(result, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.error, contains(error));
    });
  });
} 