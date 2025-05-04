import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:learn_play_level_up_flutter/models/analytics_models.dart';
import 'package:intl/intl.dart';

/// Service for exporting analytics data to various formats like CSV.
class AnalyticsExportService {
  /// Convert teacher analytics to CSV format
  Future<String> exportTeacherAnalyticsToCSV(
    TeacherAnalyticsSummary analytics, 
    String className,
  ) async {
    try {
      final dateFormat = DateFormat('MM-dd-yyyy');
      final now = DateTime.now();
      final formattedDate = dateFormat.format(now);
      
      // Create CSV file for all students
      final List<List<dynamic>> rows = [];
      
      // Header row
      rows.add([
        'Student ID',
        'Student Name',
        'Completion Rate (%)',
        'Average Score (%)',
        'Total Games Completed',
        'Total Time Spent (mins)',
        'Last Activity Date'
      ]);
      
      // Data rows
      for (final classPerformance in analytics.classPerformance) {
        for (final student in classPerformance.studentSummaries) {
          rows.add([
            student.studentId,
            student.studentName,
            student.completionRate.toStringAsFixed(1),
            student.averageScore.toStringAsFixed(1),
            student.gamesCompleted,
            student.totalTimeMins.round(),
            student.lastActivityDate != null 
                ? dateFormat.format(student.lastActivityDate!)
                : 'N/A'
          ]);
        }
      }
      
      // Generate CSV string
      final csvData = const ListToCsvConverter().convert(rows);
      
      // Create a CSV file for subjects
      final List<List<dynamic>> subjectRows = [];
      
      // Header row for subjects
      subjectRows.add([
        'Subject ID',
        'Subject Name',
        'Average Score (%)',
        'Completion Rate (%)',
        'Total Games',
        'Total Students'
      ]);
      
      // Data rows for subjects
      for (final subject in analytics.subjectPerformance.values) {
        subjectRows.add([
          subject.subjectId,
          subject.subjectName,
          subject.averageScore.toStringAsFixed(1),
          subject.completionRate.toStringAsFixed(1),
          subject.totalGames,
          subject.totalStudents
        ]);
      }
      
      // Generate CSV string for subjects
      final subjectCsvData = const ListToCsvConverter().convert(subjectRows);
      
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      
      // Create student performance file
      final studentFile = File(
        '${directory.path}/student_performance_${className.replaceAll(' ', '_')}_$formattedDate.csv'
      );
      await studentFile.writeAsString(csvData);
      
      // Create subject performance file
      final subjectFile = File(
        '${directory.path}/subject_performance_${className.replaceAll(' ', '_')}_$formattedDate.csv'
      );
      await subjectFile.writeAsString(subjectCsvData);
      
      return directory.path;
    } catch (e) {
      debugPrint('Error exporting teacher analytics: $e');
      rethrow;
    }
  }
  
  /// Export a student's performance data to CSV
  Future<String> exportStudentAnalyticsToCSV(
    StudentAnalytics analytics, 
    String studentName,
  ) async {
    try {
      final dateFormat = DateFormat('MM-dd-yyyy');
      final now = DateTime.now();
      final formattedDate = dateFormat.format(now);
      
      // Create CSV file for student subject performance
      final List<List<dynamic>> subjectRows = [];
      
      // Header row
      subjectRows.add([
        'Subject',
        'Mastery (%)',
        'Average Score (%)',
        'Games Completed',
        'Time Spent (mins)',
        'Last Played Date'
      ]);
      
      // Data rows
      for (final subject in analytics.subjectMastery.values) {
        subjectRows.add([
          subject.subjectName,
          subject.masteryPercentage.toStringAsFixed(1),
          subject.averageScore.toStringAsFixed(1),
          subject.gamesCompleted,
          subject.totalTimeMins.round(),
          subject.lastPlayedDate != null 
              ? dateFormat.format(subject.lastPlayedDate!)
              : 'N/A'
        ]);
      }
      
      // Generate CSV string
      final csvData = const ListToCsvConverter().convert(subjectRows);
      
      // Create a CSV file for game history
      final List<List<dynamic>> gameRows = [];
      
      // Header row for game history
      gameRows.add([
        'Game Title',
        'Game Type',
        'Subject',
        'Date Played',
        'Score (%)',
        'Duration (mins)',
        'Correct Answers',
        'Total Questions'
      ]);
      
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      
      // Create subject performance file
      final subjectFile = File(
        '${directory.path}/${studentName.replaceAll(' ', '_')}_performance_$formattedDate.csv'
      );
      await subjectFile.writeAsString(csvData);
      
      return directory.path;
    } catch (e) {
      debugPrint('Error exporting student analytics: $e');
      rethrow;
    }
  }
  
  /// Export game effectiveness data to CSV
  Future<String> exportGameEffectivenessToCSV(
    List<GameEffectiveness> gameEffectiveness,
  ) async {
    try {
      final dateFormat = DateFormat('MM-dd-yyyy');
      final now = DateTime.now();
      final formattedDate = dateFormat.format(now);
      
      // Create CSV file for game effectiveness
      final List<List<dynamic>> rows = [];
      
      // Header row
      rows.add([
        'Game ID',
        'Game Title',
        'Game Type',
        'Subject',
        'Average Score (%)',
        'Average Duration (mins)',
        'Completion Rate (%)',
        'Total Plays',
        'Difficulty Rating'
      ]);
      
      // Data rows
      for (final game in gameEffectiveness) {
        rows.add([
          game.gameId,
          game.gameTitle,
          game.gameType,
          game.subjectName,
          game.averageScore.toStringAsFixed(1),
          game.averageDurationMins.toStringAsFixed(1),
          game.completionRate.toStringAsFixed(1),
          game.totalPlays,
          game.difficultyRating.toStringAsFixed(1)
        ]);
      }
      
      // Generate CSV string
      final csvData = const ListToCsvConverter().convert(rows);
      
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      
      // Create game effectiveness file
      final gameFile = File(
        '${directory.path}/game_effectiveness_$formattedDate.csv'
      );
      await gameFile.writeAsString(csvData);
      
      return gameFile.path;
    } catch (e) {
      debugPrint('Error exporting game effectiveness: $e');
      rethrow;
    }
  }
  
  /// Export question analytics data to CSV
  Future<String> exportQuestionAnalyticsToCSV(
    List<QuestionAnalytics> questionAnalytics,
    String gameTitle,
  ) async {
    try {
      final dateFormat = DateFormat('MM-dd-yyyy');
      final now = DateTime.now();
      final formattedDate = dateFormat.format(now);
      
      // Create CSV file for question analytics
      final List<List<dynamic>> rows = [];
      
      // Header row
      rows.add([
        'Question ID',
        'Question Text',
        'Subject',
        'Difficulty',
        'Correct Answer Rate (%)',
        'Average Time (secs)',
        'Total Attempts'
      ]);
      
      // Data rows
      for (final question in questionAnalytics) {
        rows.add([
          question.questionId,
          question.questionText,
          question.subject,
          question.difficulty,
          question.correctRate.toStringAsFixed(1),
          question.averageTimeSecs.toStringAsFixed(1),
          question.totalAttempts
        ]);
      }
      
      // Generate CSV string
      final csvData = const ListToCsvConverter().convert(rows);
      
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      
      // Create question analytics file
      final questionFile = File(
        '${directory.path}/question_analysis_${gameTitle.replaceAll(' ', '_')}_$formattedDate.csv'
      );
      await questionFile.writeAsString(csvData);
      
      return questionFile.path;
    } catch (e) {
      debugPrint('Error exporting question analytics: $e');
      rethrow;
    }
  }
} 