import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learn_play_level_up_flutter/models/analytics_models.dart';
import 'package:learn_play_level_up_flutter/models/gamification_models.dart' as gamification;

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collections
  final _gameSessionsCollection = 'game_sessions';
  final _studentAnalyticsCollection = 'student_analytics';
  final _teacherAnalyticsCollection = 'teacher_analytics';
  final _classPerformanceCollection = 'class_performance';
  final _questionAnalyticsCollection = 'question_analytics';
  final _userProgressCollection = 'user_progress';
  final _gamesCollection = 'games';
  final _userCollection = 'users';
  final _classesCollection = 'classes';
  final _performanceTrendsCollection = 'performance_trends';
  
  // Date formatter for analytics
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');
  
  // Singleton pattern
  static final AnalyticsService _instance = AnalyticsService._internal();
  
  factory AnalyticsService() {
    return _instance;
  }
  
  AnalyticsService._internal();
  
  // Record a completed game session
  Future<void> recordGameSession(gamification.GameSession session, String studentId, String subjectId) async {
    try {
      // Create analytics game session
      final analyticsSession = AnalyticsGameSession(
        id: session.id,
        studentId: studentId,
        gameId: session.gameId,
        gameTitle: session.gameTitle,
        gameType: session.gameType,
        subjectId: subjectId,
        startedAt: session.startedAt,
        completedAt: session.completedAt,
        durationSeconds: session.durationSeconds,
        correctAnswers: session.correctAnswers,
        totalQuestions: session.totalQuestions,
        scorePercentage: session.scorePercentage,
        xpEarned: session.xpEarned,
        coinsEarned: session.coinsEarned,
      );
      
      // Save the session
      await _firestore
          .collection(_gameSessionsCollection)
          .doc(session.id)
          .set(analyticsSession.toFirestore());
      
      // Update student analytics
      await _updateStudentAnalytics(studentId, analyticsSession);
      
      // Record performance trends
      await _recordPerformanceTrends(studentId, analyticsSession);
      
      // Update question analytics
      if (session.questionResults != null && session.questionResults!.isNotEmpty) {
        await _updateQuestionAnalytics(session.questionResults!, analyticsSession);
      }
      
      // If there's a class ID, update class analytics
      final userDoc = await _firestore.collection('users').doc(studentId).get();
      final classId = userDoc.data()?['classId'];
      
      if (classId != null) {
        await _updateClassAnalytics(classId, analyticsSession);
      }
      
      // Update teacher analytics
      final classDoc = classId != null ? await _firestore.collection('classes').doc(classId).get() : null;
      final teacherId = classDoc?.data()?['teacherId'];
      
      if (teacherId != null) {
        await _updateTeacherAnalytics(teacherId, analyticsSession, classId);
      }
    } catch (e) {
      debugPrint('Error recording game session: $e');
      throw Exception('Failed to record game session: $e');
    }
  }
  
  // Get analytics summary for a teacher
  Future<TeacherAnalyticsSummary?> getTeacherAnalyticsSummary(String teacherId) async {
    try {
      final doc = await _firestore
          .collection(_teacherAnalyticsCollection)
          .doc(teacherId)
          .get();
      
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      
      return TeacherAnalyticsSummary.fromFirestore(doc.data()!);
    } catch (e) {
      debugPrint('Error getting teacher analytics summary: $e');
      return null;
    }
  }
  
  // Get performance data for a class
  Future<ClassPerformance?> getClassPerformance(String classId) async {
    try {
      final doc = await _firestore
          .collection(_classPerformanceCollection)
          .doc(classId)
          .get();
      
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      
      return ClassPerformance.fromFirestore(doc.data()!);
    } catch (e) {
      debugPrint('Error getting class performance: $e');
      return null;
    }
  }
  
  // Get analytics data for a student
  Future<StudentAnalytics?> getStudentAnalytics(String studentId) async {
    try {
      final doc = await _firestore
          .collection(_studentAnalyticsCollection)
          .doc(studentId)
          .get();
      
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      
      return StudentAnalytics.fromFirestore(doc.data()!);
    } catch (e) {
      debugPrint('Error getting student analytics: $e');
      return null;
    }
  }
  
  // Get game history for a student
  Future<List<AnalyticsGameSession>> getStudentGameHistory(String studentId, {int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection(_gameSessionsCollection)
          .where('studentId', isEqualTo: studentId)
          .orderBy('completedAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => AnalyticsGameSession.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting student game history: $e');
      return [];
    }
  }
  
  // Get performance trends for a student
  Future<List<PerformanceTrend>> getStudentPerformanceTrends(String studentId, {int limit = 100}) async {
    try {
      final snapshot = await _firestore
          .collection(_performanceTrendsCollection)
          .where('studentId', isEqualTo: studentId)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => PerformanceTrend.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting student performance trends: $e');
      return [];
    }
  }
  
  // Get game performance analytics for a teacher
  Future<List<GameEffectiveness>> getGamePerformanceAnalytics(String teacherId, {int limit = 20}) async {
    try {
      // First get the classes for this teacher
      final classesSnapshot = await _firestore
          .collection('classes')
          .where('teacherId', isEqualTo: teacherId)
          .get();
      
      final classIds = classesSnapshot.docs.map((doc) => doc.id).toList();
      
      // No classes means no analytics
      if (classIds.isEmpty) {
        return [];
      }
      
      // Get students for these classes
      final studentsSnapshot = await _firestore
          .collection('users')
          .where('classId', whereIn: classIds)
          .where('role', isEqualTo: 'student')
          .get();
      
      final studentIds = studentsSnapshot.docs.map((doc) => doc.id).toList();
      
      // No students means no analytics
      if (studentIds.isEmpty) {
        return [];
      }
      
      // Get game sessions for these students
      final sessionsSnapshot = await _firestore
          .collection(_gameSessionsCollection)
          .where('studentId', whereIn: studentIds)
          .orderBy('completedAt', descending: true)
          .get();
      
      // Group sessions by game
      final Map<String, List<AnalyticsGameSession>> gameSessionsMap = {};
      
      for (var doc in sessionsSnapshot.docs) {
        final session = AnalyticsGameSession.fromFirestore(doc.data(), doc.id);
        
        if (!gameSessionsMap.containsKey(session.gameId)) {
          gameSessionsMap[session.gameId] = [];
        }
        
        gameSessionsMap[session.gameId]!.add(session);
      }
      
      // Calculate game effectiveness for each game
      List<GameEffectiveness> result = [];
      
      gameSessionsMap.forEach((gameId, sessions) {
        if (sessions.isEmpty) return;
        
        final firstSession = sessions.first;
        
        // Calculate averages
        double totalScore = 0;
        double totalDuration = 0;
        Map<String, List<double>> subjectScores = {};
        
        for (var session in sessions) {
          totalScore += session.scorePercentage;
          totalDuration += session.durationSeconds;
          
          if (!subjectScores.containsKey(session.subjectId)) {
            subjectScores[session.subjectId] = [];
          }
          
          subjectScores[session.subjectId]!.add(session.scorePercentage);
        }
        
        // Calculate subject performance
        Map<String, double> subjectPerformance = {};
        
        subjectScores.forEach((subjectId, scores) {
          subjectPerformance[subjectId] = scores.isEmpty 
              ? 0.0 
              : scores.reduce((a, b) => a + b) / scores.length;
        });
        
        // Create game effectiveness object
        result.add(GameEffectiveness(
          gameId: gameId,
          gameTitle: firstSession.gameTitle,
          gameType: firstSession.gameType,
          averageScore: sessions.isEmpty ? 0.0 : totalScore / sessions.length,
          completionRate: 100.0, // This is a placeholder - would need more data to calculate this
          averageDuration: sessions.isEmpty ? 0.0 : totalDuration / sessions.length,
          timesPlayed: sessions.length,
          subjectPerformance: subjectPerformance,
        ));
      });
      
      // Sort by effectiveness (average score) and limit
      result.sort((a, b) => b.averageScore.compareTo(a.averageScore));
      
      if (result.length > limit) {
        result = result.sublist(0, limit);
      }
      
      return result;
    } catch (e) {
      debugPrint('Error getting game performance analytics: $e');
      return [];
    }
  }
  
  // Get question analytics for a game
  Future<List<QuestionAnalytics>> getQuestionAnalytics(String gameId) async {
    try {
      final snapshot = await _firestore
          .collection(_questionAnalyticsCollection)
          .where('gameId', isEqualTo: gameId)
          .get();
      
      return snapshot.docs
          .map((doc) => QuestionAnalytics.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting question analytics: $e');
      return [];
    }
  }
  
  // Get a list of students requiring attention (low completion rates or scores)
  Future<List<StudentPerformanceSummary>> getStudentsRequiringAttention(
    String teacherId, 
    {double completionThreshold = 60.0, double scoreThreshold = 60.0}
  ) async {
    try {
      // Get classes for this teacher
      final classesSnapshot = await _firestore
          .collection('classes')
          .where('teacherId', isEqualTo: teacherId)
          .get();
      
      final classIds = classesSnapshot.docs.map((doc) => doc.id).toList();
      
      List<StudentPerformanceSummary> result = [];
      
      // For each class, get the class performance data
      for (var classId in classIds) {
        final classPerformance = await getClassPerformance(classId);
        
        if (classPerformance != null) {
          // Filter students who need attention
          final needAttention = classPerformance.studentSummaries.where((student) {
            return student.completionRate < completionThreshold || 
                   student.averageScore < scoreThreshold;
          }).toList();
          
          result.addAll(needAttention);
        }
      }
      
      // Sort by completion rate (ascending)
      result.sort((a, b) => a.completionRate.compareTo(b.completionRate));
      
      return result;
    } catch (e) {
      debugPrint('Error getting students requiring attention: $e');
      return [];
    }
  }
  
  // ---- Private methods ----
  
  // Update student analytics with a new game session
  Future<void> _updateStudentAnalytics(String studentId, AnalyticsGameSession session) async {
    try {
      final docRef = _firestore.collection(_studentAnalyticsCollection).doc(studentId);
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists && docSnapshot.data() != null) {
        // Update existing analytics
        await _firestore.runTransaction((transaction) async {
          StudentAnalytics analytics = StudentAnalytics.fromFirestore(docSnapshot.data()!);
          
          // Update total counts
          final totalGamesPlayed = analytics.totalGamesPlayed + 1;
          final totalGamesCompleted = analytics.totalGamesCompleted + 1;
          
          // Calculate new average score
          final totalScorePoints = analytics.averageScore * analytics.totalGamesCompleted;
          final newTotalScorePoints = totalScorePoints + session.scorePercentage;
          final newAverageScore = newTotalScorePoints / totalGamesCompleted;
          
          // Update total time spent
          final newTotalTimeSpentMinutes = analytics.totalTimeSpentMinutes + (session.durationSeconds / 60);
          
          // Update subject mastery
          final subjectMastery = Map<String, SubjectMastery>.from(analytics.subjectMastery);
          
          if (subjectMastery.containsKey(session.subjectId)) {
            // Update existing subject mastery
            final existing = subjectMastery[session.subjectId]!;
            
            final newGamesCompleted = existing.gamesCompleted + 1;
            
            // Calculate new average score for subject
            final totalSubjectPoints = existing.averageScore * existing.gamesCompleted;
            final newTotalSubjectPoints = totalSubjectPoints + session.scorePercentage;
            final newSubjectAverage = newTotalSubjectPoints / newGamesCompleted;
            
            // Mastery percentage is a function of average score and games completed
            // This is a simple formula that could be made more sophisticated
            final newMasteryPercentage = (newSubjectAverage * 0.7) + 
                (newGamesCompleted > 10 ? 30 : newGamesCompleted * 3);
            
            subjectMastery[session.subjectId] = SubjectMastery(
              subjectId: existing.subjectId,
              subjectName: existing.subjectName,
              gamesCompleted: newGamesCompleted,
              masteryPercentage: newMasteryPercentage,
              averageScore: newSubjectAverage,
            );
          } else {
            // Create new subject mastery
            // Fetch subject name
            final subjectDoc = await _firestore.collection('subjects').doc(session.subjectId).get();
            final subjectName = subjectDoc.data()?['name'] ?? 'Unknown Subject';
            
            subjectMastery[session.subjectId] = SubjectMastery(
              subjectId: session.subjectId,
              subjectName: subjectName,
              gamesCompleted: 1,
              masteryPercentage: session.scorePercentage * 0.7, // Initial mastery based on score
              averageScore: session.scorePercentage,
            );
          }
          
          // Update game type performance
          final gameTypePerformance = Map<String, GameTypePerformance>.from(analytics.gameTypePerformance);
          
          if (gameTypePerformance.containsKey(session.gameType)) {
            // Update existing game type performance
            final existing = gameTypePerformance[session.gameType]!;
            
            final newGamesPlayed = existing.gamesPlayed + 1;
            
            // Calculate new average score for game type
            final totalTypePoints = existing.averageScore * existing.gamesPlayed;
            final newTotalTypePoints = totalTypePoints + session.scorePercentage;
            final newTypeAverage = newTotalTypePoints / newGamesPlayed;
            
            // Calculate new average duration
            final totalDuration = existing.averageDuration * existing.gamesPlayed;
            final newTotalDuration = totalDuration + session.durationSeconds;
            final newAverageDuration = newTotalDuration / newGamesPlayed;
            
            gameTypePerformance[session.gameType] = GameTypePerformance(
              gameType: session.gameType,
              gamesPlayed: newGamesPlayed,
              averageScore: newTypeAverage,
              averageDuration: newAverageDuration,
            );
          } else {
            // Create new game type performance
            gameTypePerformance[session.gameType] = GameTypePerformance(
              gameType: session.gameType,
              gamesPlayed: 1,
              averageScore: session.scorePercentage,
              averageDuration: session.durationSeconds.toDouble(),
            );
          }
          
          // Update the document
          transaction.update(docRef, {
            'totalGamesPlayed': totalGamesPlayed,
            'totalGamesCompleted': totalGamesCompleted,
            'averageScore': newAverageScore,
            'totalTimeSpentMinutes': newTotalTimeSpentMinutes,
            'subjectMastery': subjectMastery.map((key, value) => MapEntry(key, value.toFirestore())),
            'gameTypePerformance': gameTypePerformance.map((key, value) => MapEntry(key, value.toFirestore())),
          });
        });
      } else {
        // Create new student analytics
        
        // Get subject name
        final subjectDoc = await _firestore.collection('subjects').doc(session.subjectId).get();
        final subjectName = subjectDoc.data()?['name'] ?? 'Unknown Subject';
        
        // Create subject mastery
        final subjectMastery = {
          session.subjectId: SubjectMastery(
            subjectId: session.subjectId,
            subjectName: subjectName,
            gamesCompleted: 1,
            masteryPercentage: session.scorePercentage * 0.7, // Initial mastery based on score
            averageScore: session.scorePercentage,
          ),
        };
        
        // Create game type performance
        final gameTypePerformance = {
          session.gameType: GameTypePerformance(
            gameType: session.gameType,
            gamesPlayed: 1,
            averageScore: session.scorePercentage,
            averageDuration: session.durationSeconds.toDouble(),
          ),
        };
        
        // Create new analytics
        final newAnalytics = StudentAnalytics(
          studentId: studentId,
          totalGamesPlayed: 1,
          totalGamesCompleted: 1,
          averageScore: session.scorePercentage,
          totalTimeSpentMinutes: session.durationSeconds / 60,
          subjectMastery: subjectMastery,
          gameTypePerformance: gameTypePerformance,
        );
        
        // Save to Firestore
        await docRef.set(newAnalytics.toFirestore());
      }
    } catch (e) {
      debugPrint('Error updating student analytics: $e');
      throw Exception('Failed to update student analytics: $e');
    }
  }
  
  // Record performance trends
  Future<void> _recordPerformanceTrends(String studentId, AnalyticsGameSession session) async {
    try {
      // Create trends for today's date
      final today = DateTime(
        DateTime.now().year, 
        DateTime.now().month, 
        DateTime.now().day
      );
      
      // Trends to record
      List<PerformanceTrend> trends = [
        // Score trend
        PerformanceTrend(
          studentId: studentId,
          metricType: 'score',
          date: today,
          value: session.scorePercentage,
          subjectId: session.subjectId,
          gameType: session.gameType,
        ),
        
        // Time spent trend
        PerformanceTrend(
          studentId: studentId,
          metricType: 'time',
          date: today,
          value: session.durationSeconds / 60, // Convert to minutes
          subjectId: session.subjectId,
          gameType: session.gameType,
        ),
        
        // Games completed trend
        PerformanceTrend(
          studentId: studentId,
          metricType: 'games_completed',
          date: today,
          value: 1, // One game completed
          subjectId: session.subjectId,
          gameType: session.gameType,
        ),
      ];
      
      // Check if trends for today already exist
      for (var trend in trends) {
        final existingQuery = await _firestore
            .collection(_performanceTrendsCollection)
            .where('studentId', isEqualTo: studentId)
            .where('metricType', isEqualTo: trend.metricType)
            .where('date', isEqualTo: Timestamp.fromDate(today))
            .get();
        
        if (existingQuery.docs.isNotEmpty) {
          // Update existing trend
          final existingDoc = existingQuery.docs.first;
          final existingData = existingDoc.data();
          final existingValue = existingData['value'] ?? 0.0;
          
          double newValue;
          
          // For score, we want to average
          if (trend.metricType == 'score') {
            final existingCount = existingData['count'] ?? 1;
            final newCount = existingCount + 1;
            final totalScore = existingValue * existingCount + trend.value;
            newValue = totalScore / newCount;
            
            await existingDoc.reference.update({
              'value': newValue,
              'count': newCount,
            });
          } 
          // For time and games completed, we want to add
          else {
            newValue = existingValue + trend.value;
            
            await existingDoc.reference.update({
              'value': newValue,
            });
          }
        } else {
          // Create new trend
          final newData = trend.toFirestore();
          
          // For score, track count for averaging
          if (trend.metricType == 'score') {
            newData['count'] = 1;
          }
          
          await _firestore
              .collection(_performanceTrendsCollection)
              .add(newData);
        }
      }
    } catch (e) {
      debugPrint('Error recording performance trends: $e');
      // Don't throw here to avoid breaking the main flow
    }
  }
  
  // Update question analytics
  Future<void> _updateQuestionAnalytics(
    List<gamification.QuestionResult> questionResults, 
    AnalyticsGameSession session
  ) async {
    try {
      // Update each question's analytics
      for (var result in questionResults) {
        final questionId = result.questionId;
        final docRef = _firestore
            .collection(_questionAnalyticsCollection)
            .doc(questionId);
        
        final docSnapshot = await docRef.get();
        
        if (docSnapshot.exists && docSnapshot.data() != null) {
          // Update existing question analytics
          await _firestore.runTransaction((transaction) async {
            QuestionAnalytics analytics = QuestionAnalytics.fromFirestore(docSnapshot.data()!);
            
            // Update counts
            final timesAttempted = analytics.timesAttempted + 1;
            final timesCorrect = analytics.timesCorrect + (result.isCorrect ? 1 : 0);
            final correctPercentage = (timesCorrect / timesAttempted) * 100;
            
            // Update average time
            final totalTime = analytics.averageTimeSeconds * analytics.timesAttempted;
            final newTotalTime = totalTime + result.timeSpentSeconds;
            final averageTimeSeconds = newTotalTime / timesAttempted;
            
            // Update the document
            transaction.update(docRef, {
              'timesAttempted': timesAttempted,
              'timesCorrect': timesCorrect,
              'correctPercentage': correctPercentage,
              'averageTimeSeconds': averageTimeSeconds,
            });
          });
        } else {
          // Create new question analytics
          final newAnalytics = QuestionAnalytics(
            questionId: questionId,
            questionText: 'Question #$questionId', // Adding default text
            subject: session.subjectId, // Using subjectId as subject
            gameId: session.gameId,
            timesAttempted: 1,
            timesCorrect: result.isCorrect ? 1 : 0,
            averageTimeSeconds: result.timeSpentSeconds,
            correctRate: result.isCorrect ? 100.0 : 0.0, // Using correctRate instead of correctPercentage
          );
          
          // Save to Firestore
          await docRef.set(newAnalytics.toFirestore());
        }
      }
    } catch (e) {
      debugPrint('Error updating question analytics: $e');
      // Don't throw here to avoid breaking the main flow
    }
  }
  
  // Update class analytics with a new game session
  Future<void> _updateClassAnalytics(String classId, AnalyticsGameSession session) async {
    try {
      final docRef = _firestore.collection(_classPerformanceCollection).doc(classId);
      final docSnapshot = await docRef.get();
      
      // Get student data
      final studentDoc = await _firestore.collection('users').doc(session.studentId).get();
      final studentName = studentDoc.data()?['name'] ?? 'Unknown Student';
      final studentAvatar = studentDoc.data()?['avatar'];
      
      if (docSnapshot.exists && docSnapshot.data() != null) {
        // Update existing class performance
        await _firestore.runTransaction((transaction) async {
          ClassPerformance classPerf = ClassPerformance.fromFirestore(docSnapshot.data()!);
          
          // Find student in existing summaries or create new
          int studentIndex = classPerf.studentSummaries.indexWhere(
            (s) => s.studentId == session.studentId
          );
          
          if (studentIndex >= 0) {
            // Update existing student summary
            final student = classPerf.studentSummaries[studentIndex];
            
            // Calculate new completion rate and average score
            final gamesCompleted = student.gamesCompleted + 1;
            final totalScore = student.averageScore * student.gamesCompleted;
            final newTotalScore = totalScore + session.scorePercentage;
            final newAverageScore = newTotalScore / gamesCompleted;
            
            // Update subject performance
            final subjectPerformance = Map<String, double>.from(student.subjectPerformance);
            
            if (subjectPerformance.containsKey(session.subjectId)) {
              // Get previous score count for this subject
              final subjectScoreCount = classPerf.studentSummaries[studentIndex]
                  .subjectPerformance[session.subjectId] ?? 0;
              
              // Update existing subject score
              final previousSubjectTotalScore = subjectPerformance[session.subjectId]! * subjectScoreCount;
              final newSubjectTotalScore = previousSubjectTotalScore + session.scorePercentage;
              subjectPerformance[session.subjectId] = newSubjectTotalScore / (subjectScoreCount + 1);
            } else {
              // Add new subject score
              subjectPerformance[session.subjectId] = session.scorePercentage;
            }
            
            // Create updated student summary
            final updatedStudent = StudentPerformanceSummary(
              studentId: student.studentId,
              studentName: student.studentName,
              avatar: student.avatar,
              lastActive: session.completedAt,
              gamesAssigned: student.gamesAssigned,
              gamesCompleted: gamesCompleted,
              completionRate: (gamesCompleted / student.gamesAssigned) * 100,
              averageScore: newAverageScore,
              subjectPerformance: subjectPerformance,
            );
            
            // Update the list
            List<StudentPerformanceSummary> updatedSummaries = List.from(classPerf.studentSummaries);
            updatedSummaries[studentIndex] = updatedStudent;
            
            // Update class stats
            final totalStudents = classPerf.totalStudents;
            final activeStudents = classPerf.activeStudents;
            
            // Calculate new class averages
            double totalClassScore = 0;
            double totalClassCompletion = 0;
            
            for (var student in updatedSummaries) {
              totalClassScore += student.averageScore;
              totalClassCompletion += student.completionRate;
            }
            
            final newClassAvgScore = totalClassScore / totalStudents;
            final newClassAvgCompletion = totalClassCompletion / totalStudents;
            
            // Update subject completion rates
            final subjectRates = Map<String, SubjectCompletionRate>.from(classPerf.subjectCompletionRates);
            
            if (subjectRates.containsKey(session.subjectId)) {
              // Update existing subject completion rate
              final subject = subjectRates[session.subjectId]!;
              
              final newGamesCompleted = subject.gamesCompleted + 1;
              final newCompletionRate = (newGamesCompleted / subject.gamesAssigned) * 100;
              
              subjectRates[session.subjectId] = SubjectCompletionRate(
                subjectId: subject.subjectId,
                subjectName: subject.subjectName,
                gamesAssigned: subject.gamesAssigned,
                gamesCompleted: newGamesCompleted,
                completionRate: newCompletionRate,
              );
            }
            
            // Update the document
            transaction.update(docRef, {
              'studentSummaries': updatedSummaries.map((s) => s.toFirestore()).toList(),
              'averageScore': newClassAvgScore,
              'averageCompletionRate': newClassAvgCompletion,
              'subjectCompletionRates': subjectRates.map(
                (key, value) => MapEntry(key, value.toFirestore()),
              ),
            });
          } else {
            // Student not found, this should not happen in normal flow
            // Would need to add student to class performance
            debugPrint('Student not found in class performance: ${session.studentId}');
          }
        });
      } else {
        // Create new class performance (this should not happen in normal flow)
        // Would need class data and student data
        debugPrint('Class performance not found: $classId');
      }
    } catch (e) {
      debugPrint('Error updating class analytics: $e');
      // Don't throw here to avoid breaking the main flow
    }
  }
  
  // Update teacher analytics with a new game session
  Future<void> _updateTeacherAnalytics(String teacherId, AnalyticsGameSession session, String classId) async {
    try {
      final docRef = _firestore.collection(_teacherAnalyticsCollection).doc(teacherId);
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists && docSnapshot.data() != null) {
        // Update existing teacher analytics
        await _firestore.runTransaction((transaction) async {
          TeacherAnalyticsSummary analytics = TeacherAnalyticsSummary.fromFirestore(docSnapshot.data()!);
          
          // Update completion counts
          final totalGamesCompleted = analytics.totalGamesCompleted + 1;
          final totalGamesAssigned = analytics.totalGamesAssigned;
          final averageCompletionRate = (totalGamesCompleted / totalGamesAssigned) * 100;
          
          // Update subject completion rates
          final subjectRates = Map<String, SubjectCompletionRate>.from(analytics.subjectCompletionRates);
          
          if (subjectRates.containsKey(session.subjectId)) {
            // Update existing subject rate
            final subject = subjectRates[session.subjectId]!;
            
            final newGamesCompleted = subject.gamesCompleted + 1;
            final newCompletionRate = (newGamesCompleted / subject.gamesAssigned) * 100;
            
            subjectRates[session.subjectId] = SubjectCompletionRate(
              subjectId: subject.subjectId,
              subjectName: subject.subjectName,
              gamesAssigned: subject.gamesAssigned,
              gamesCompleted: newGamesCompleted,
              completionRate: newCompletionRate,
            );
          }
          
          // Update the document (just the basic stats, game effectiveness would be updated in a separate process)
          transaction.update(docRef, {
            'totalGamesCompleted': totalGamesCompleted,
            'averageCompletionRate': averageCompletionRate,
            'subjectCompletionRates': subjectRates.map(
              (key, value) => MapEntry(key, value.toFirestore()),
            ),
          });
        });
      } else {
        // Create new teacher analytics (this should be done during teacher onboarding)
        debugPrint('Teacher analytics not found: $teacherId');
      }
    } catch (e) {
      debugPrint('Error updating teacher analytics: $e');
      // Don't throw here to avoid breaking the main flow
    }
  }
  
  // Helper method to get display date for UI
  String getDisplayDate(DateTime date) {
    // Compare with today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
} 