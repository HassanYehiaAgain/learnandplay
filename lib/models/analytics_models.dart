import 'package:cloud_firestore/cloud_firestore.dart';

/// A class representing analytics data for teachers
class TeacherAnalyticsSummary {
  final String teacherId;
  final int totalStudents;
  final int activeStudents; // Students active in last 7 days
  final int totalGamesAssigned;
  final int totalGamesCompleted;
  final double averageCompletionRate; // Percentage
  final Map<String, SubjectCompletionRate> subjectCompletionRates;
  final List<GameEffectiveness> topPerformingGames;
  final List<GameEffectiveness> lowestPerformingGames;
  final List<ClassPerformance> classPerformance;
  final Map<String, SubjectMastery> subjectPerformance;
  
  TeacherAnalyticsSummary({
    required this.teacherId,
    this.totalStudents = 0,
    this.activeStudents = 0,
    this.totalGamesAssigned = 0,
    this.totalGamesCompleted = 0,
    this.averageCompletionRate = 0.0,
    this.subjectCompletionRates = const {},
    this.topPerformingGames = const [],
    this.lowestPerformingGames = const [],
    this.classPerformance = const [],
    this.subjectPerformance = const {},
  });
  
  factory TeacherAnalyticsSummary.fromFirestore(Map<String, dynamic> data) {
    return TeacherAnalyticsSummary(
      teacherId: data['teacherId'] ?? '',
      totalStudents: data['totalStudents'] ?? 0,
      activeStudents: data['activeStudents'] ?? 0,
      totalGamesAssigned: data['totalGamesAssigned'] ?? 0,
      totalGamesCompleted: data['totalGamesCompleted'] ?? 0,
      averageCompletionRate: data['averageCompletionRate']?.toDouble() ?? 0.0,
      subjectCompletionRates: (data['subjectCompletionRates'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, SubjectCompletionRate.fromFirestore(value)),
          ) ??
          {},
      topPerformingGames: (data['topPerformingGames'] as List<dynamic>?)
              ?.map((game) => GameEffectiveness.fromFirestore(game))
              .toList() ??
          [],
      lowestPerformingGames: (data['lowestPerformingGames'] as List<dynamic>?)
              ?.map((game) => GameEffectiveness.fromFirestore(game))
              .toList() ??
          [],
      classPerformance: (data['classPerformance'] as List<dynamic>?)
              ?.map((cls) => ClassPerformance.fromFirestore(cls))
              .toList() ??
          [],
      subjectPerformance: (data['subjectPerformance'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, SubjectMastery.fromFirestore(value)),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'teacherId': teacherId,
      'totalStudents': totalStudents,
      'activeStudents': activeStudents,
      'totalGamesAssigned': totalGamesAssigned,
      'totalGamesCompleted': totalGamesCompleted,
      'averageCompletionRate': averageCompletionRate,
      'subjectCompletionRates': subjectCompletionRates.map(
        (key, value) => MapEntry(key, value.toFirestore()),
      ),
      'topPerformingGames': topPerformingGames.map((game) => game.toFirestore()).toList(),
      'lowestPerformingGames': lowestPerformingGames.map((game) => game.toFirestore()).toList(),
      'classPerformance': classPerformance.map((cls) => cls.toFirestore()).toList(),
      'subjectPerformance': subjectPerformance.map(
        (key, value) => MapEntry(key, value.toFirestore()),
      ),
    };
  }
}

/// A class representing completion rate for a specific subject
class SubjectCompletionRate {
  final String subjectId;
  final String subjectName;
  final int gamesAssigned;
  final int gamesCompleted;
  final double completionRate; // Percentage
  
  SubjectCompletionRate({
    required this.subjectId,
    required this.subjectName,
    this.gamesAssigned = 0,
    this.gamesCompleted = 0,
    this.completionRate = 0.0,
  });
  
  factory SubjectCompletionRate.fromFirestore(Map<String, dynamic> data) {
    return SubjectCompletionRate(
      subjectId: data['subjectId'] ?? '',
      subjectName: data['subjectName'] ?? '',
      gamesAssigned: data['gamesAssigned'] ?? 0,
      gamesCompleted: data['gamesCompleted'] ?? 0,
      completionRate: data['completionRate']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'subjectId': subjectId,
      'subjectName': subjectName,
      'gamesAssigned': gamesAssigned,
      'gamesCompleted': gamesCompleted,
      'completionRate': completionRate,
    };
  }
}

/// A class representing the effectiveness of a game based on student performance
class GameEffectiveness {
  final String gameId;
  final String gameTitle;
  final String gameType;
  final double averageScore;
  final double completionRate; // Percentage of students who completed the game
  final double averageDuration; // Average time in seconds
  final int timesPlayed;
  final Map<String, double> subjectPerformance; // Subject ID to average score
  final String subjectName;
  final double averageDurationMins;
  final int totalPlays;
  final double difficultyRating;
  
  GameEffectiveness({
    required this.gameId,
    required this.gameTitle,
    required this.gameType,
    this.averageScore = 0.0,
    this.completionRate = 0.0,
    this.averageDuration = 0.0,
    this.timesPlayed = 0,
    this.subjectPerformance = const {},
    this.subjectName = '',
    this.averageDurationMins = 0.0,
    this.totalPlays = 0,
    this.difficultyRating = 0.0,
  });
  
  factory GameEffectiveness.fromFirestore(Map<String, dynamic> data) {
    return GameEffectiveness(
      gameId: data['gameId'] ?? '',
      gameTitle: data['gameTitle'] ?? '',
      gameType: data['gameType'] ?? '',
      averageScore: data['averageScore']?.toDouble() ?? 0.0,
      completionRate: data['completionRate']?.toDouble() ?? 0.0,
      averageDuration: data['averageDuration']?.toDouble() ?? 0.0,
      timesPlayed: data['timesPlayed'] ?? 0,
      subjectPerformance: (data['subjectPerformance'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value.toDouble()),
          ) ??
          {},
      subjectName: data['subjectName'] ?? '',
      averageDurationMins: data['averageDurationMins']?.toDouble() ?? 0.0,
      totalPlays: data['totalPlays'] ?? 0,
      difficultyRating: data['difficultyRating']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'gameId': gameId,
      'gameTitle': gameTitle,
      'gameType': gameType,
      'averageScore': averageScore,
      'completionRate': completionRate,
      'averageDuration': averageDuration,
      'timesPlayed': timesPlayed,
      'subjectPerformance': subjectPerformance,
      'subjectName': subjectName,
      'averageDurationMins': averageDurationMins,
      'totalPlays': totalPlays,
      'difficultyRating': difficultyRating,
    };
  }
}

/// A class representing performance data for a class
class ClassPerformance {
  final String classId;
  final String className;
  final String teacherId;
  final int totalStudents;
  final int activeStudents;
  final double averageCompletionRate;
  final double averageScore;
  final Map<String, SubjectCompletionRate> subjectCompletionRates;
  final List<StudentPerformanceSummary> studentSummaries;
  
  ClassPerformance({
    required this.classId,
    required this.className,
    required this.teacherId,
    this.totalStudents = 0,
    this.activeStudents = 0,
    this.averageCompletionRate = 0.0,
    this.averageScore = 0.0,
    this.subjectCompletionRates = const {},
    this.studentSummaries = const [],
  });
  
  factory ClassPerformance.fromFirestore(Map<String, dynamic> data) {
    return ClassPerformance(
      classId: data['classId'] ?? '',
      className: data['className'] ?? '',
      teacherId: data['teacherId'] ?? '',
      totalStudents: data['totalStudents'] ?? 0,
      activeStudents: data['activeStudents'] ?? 0,
      averageCompletionRate: data['averageCompletionRate']?.toDouble() ?? 0.0,
      averageScore: data['averageScore']?.toDouble() ?? 0.0,
      subjectCompletionRates: (data['subjectCompletionRates'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, SubjectCompletionRate.fromFirestore(value)),
          ) ??
          {},
      studentSummaries: (data['studentSummaries'] as List<dynamic>?)
              ?.map((student) => StudentPerformanceSummary.fromFirestore(student))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'classId': classId,
      'className': className,
      'teacherId': teacherId,
      'totalStudents': totalStudents,
      'activeStudents': activeStudents,
      'averageCompletionRate': averageCompletionRate,
      'averageScore': averageScore,
      'subjectCompletionRates': subjectCompletionRates.map(
        (key, value) => MapEntry(key, value.toFirestore()),
      ),
      'studentSummaries': studentSummaries.map((student) => student.toFirestore()).toList(),
    };
  }
}

/// A class representing performance summary for an individual student
class StudentPerformanceSummary {
  final String studentId;
  final String studentName;
  final String? avatar;
  final DateTime lastActive;
  final int gamesAssigned;
  final int gamesCompleted;
  final double completionRate;
  final double averageScore;
  final Map<String, double> subjectPerformance; // Subject ID to score
  final int totalTimeMins;
  final DateTime? lastActivityDate;
  
  StudentPerformanceSummary({
    required this.studentId,
    required this.studentName,
    this.avatar,
    required this.lastActive,
    this.gamesAssigned = 0,
    this.gamesCompleted = 0,
    this.completionRate = 0.0,
    this.averageScore = 0.0,
    this.subjectPerformance = const {},
    this.totalTimeMins = 0,
    this.lastActivityDate,
  });
  
  factory StudentPerformanceSummary.fromFirestore(Map<String, dynamic> data) {
    return StudentPerformanceSummary(
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      avatar: data['avatar'],
      lastActive: (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
      gamesAssigned: data['gamesAssigned'] ?? 0,
      gamesCompleted: data['gamesCompleted'] ?? 0,
      completionRate: data['completionRate']?.toDouble() ?? 0.0,
      averageScore: data['averageScore']?.toDouble() ?? 0.0,
      subjectPerformance: (data['subjectPerformance'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value.toDouble()),
          ) ??
          {},
      totalTimeMins: data['totalTimeMins'] ?? 0,
      lastActivityDate: (data['lastActivityDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'avatar': avatar,
      'lastActive': Timestamp.fromDate(lastActive),
      'gamesAssigned': gamesAssigned,
      'gamesCompleted': gamesCompleted,
      'completionRate': completionRate,
      'averageScore': averageScore,
      'subjectPerformance': subjectPerformance,
      'totalTimeMins': totalTimeMins,
      'lastActivityDate': lastActivityDate != null ? Timestamp.fromDate(lastActivityDate!) : null,
    };
  }
}

/// A class representing analytics data for students
class StudentAnalytics {
  final String studentId;
  final int totalGamesPlayed;
  final int totalGamesCompleted;
  final double averageScore;
  final double totalTimeSpentMinutes;
  final Map<String, SubjectMastery> subjectMastery;
  final Map<String, GameTypePerformance> gameTypePerformance;
  
  StudentAnalytics({
    required this.studentId,
    this.totalGamesPlayed = 0,
    this.totalGamesCompleted = 0,
    this.averageScore = 0.0,
    this.totalTimeSpentMinutes = 0.0,
    this.subjectMastery = const {},
    this.gameTypePerformance = const {},
  });
  
  factory StudentAnalytics.fromFirestore(Map<String, dynamic> data) {
    return StudentAnalytics(
      studentId: data['studentId'] ?? '',
      totalGamesPlayed: data['totalGamesPlayed'] ?? 0,
      totalGamesCompleted: data['totalGamesCompleted'] ?? 0,
      averageScore: data['averageScore']?.toDouble() ?? 0.0,
      totalTimeSpentMinutes: data['totalTimeSpentMinutes']?.toDouble() ?? 0.0,
      subjectMastery: (data['subjectMastery'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, SubjectMastery.fromFirestore(value)),
          ) ??
          {},
      gameTypePerformance: (data['gameTypePerformance'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, GameTypePerformance.fromFirestore(value)),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'totalGamesPlayed': totalGamesPlayed,
      'totalGamesCompleted': totalGamesCompleted,
      'averageScore': averageScore,
      'totalTimeSpentMinutes': totalTimeSpentMinutes,
      'subjectMastery': subjectMastery.map(
        (key, value) => MapEntry(key, value.toFirestore()),
      ),
      'gameTypePerformance': gameTypePerformance.map(
        (key, value) => MapEntry(key, value.toFirestore()),
      ),
    };
  }
}

/// A class representing a student's mastery of a specific subject
class SubjectMastery {
  final String subjectId;
  final String subjectName;
  final int gamesCompleted;
  final double masteryPercentage;
  final double averageScore;
  final int totalTimeMins;
  final DateTime? lastPlayedDate;
  final double completionRate;
  final int totalGames;
  final int totalStudents;
  
  SubjectMastery({
    required this.subjectId,
    required this.subjectName,
    this.gamesCompleted = 0,
    this.masteryPercentage = 0.0,
    this.averageScore = 0.0,
    this.totalTimeMins = 0,
    this.lastPlayedDate,
    this.completionRate = 0.0,
    this.totalGames = 0,
    this.totalStudents = 0,
  });
  
  factory SubjectMastery.fromFirestore(Map<String, dynamic> data) {
    return SubjectMastery(
      subjectId: data['subjectId'] ?? '',
      subjectName: data['subjectName'] ?? '',
      gamesCompleted: data['gamesCompleted'] ?? 0,
      masteryPercentage: data['masteryPercentage']?.toDouble() ?? 0.0,
      averageScore: data['averageScore']?.toDouble() ?? 0.0,
      totalTimeMins: data['totalTimeMins'] ?? 0,
      lastPlayedDate: (data['lastPlayedDate'] as Timestamp?)?.toDate(),
      completionRate: data['completionRate']?.toDouble() ?? 0.0,
      totalGames: data['totalGames'] ?? 0,
      totalStudents: data['totalStudents'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'subjectId': subjectId,
      'subjectName': subjectName,
      'gamesCompleted': gamesCompleted,
      'masteryPercentage': masteryPercentage,
      'averageScore': averageScore,
      'totalTimeMins': totalTimeMins,
      'lastPlayedDate': lastPlayedDate != null ? Timestamp.fromDate(lastPlayedDate!) : null,
      'completionRate': completionRate,
      'totalGames': totalGames,
      'totalStudents': totalStudents,
    };
  }
}

/// A class representing a student's performance in a specific game type
class GameTypePerformance {
  final String gameType;
  final int gamesPlayed;
  final double averageScore;
  final double averageDuration; // In seconds
  
  GameTypePerformance({
    required this.gameType,
    this.gamesPlayed = 0,
    this.averageScore = 0.0,
    this.averageDuration = 0.0,
  });
  
  factory GameTypePerformance.fromFirestore(Map<String, dynamic> data) {
    return GameTypePerformance(
      gameType: data['gameType'] ?? '',
      gamesPlayed: data['gamesPlayed'] ?? 0,
      averageScore: data['averageScore']?.toDouble() ?? 0.0,
      averageDuration: data['averageDuration']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'gameType': gameType,
      'gamesPlayed': gamesPlayed,
      'averageScore': averageScore,
      'averageDuration': averageDuration,
    };
  }
}

/// A class representing a game session played by a student
class AnalyticsGameSession {
  final String id;
  final String studentId;
  final String gameId;
  final String gameTitle;
  final String gameType;
  final String subjectId;
  final DateTime startedAt;
  final DateTime completedAt;
  final int durationSeconds;
  final int correctAnswers;
  final int totalQuestions;
  final double scorePercentage;
  final int xpEarned;
  final int coinsEarned;
  
  AnalyticsGameSession({
    required this.id,
    required this.studentId,
    required this.gameId,
    required this.gameTitle,
    required this.gameType,
    required this.subjectId,
    required this.startedAt,
    required this.completedAt,
    required this.durationSeconds,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.scorePercentage,
    required this.xpEarned,
    required this.coinsEarned,
  });
  
  factory AnalyticsGameSession.fromFirestore(Map<String, dynamic> data, String id) {
    return AnalyticsGameSession(
      id: id,
      studentId: data['studentId'] ?? '',
      gameId: data['gameId'] ?? '',
      gameTitle: data['gameTitle'] ?? '',
      gameType: data['gameType'] ?? '',
      subjectId: data['subjectId'] ?? '',
      startedAt: (data['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durationSeconds: data['durationSeconds'] ?? 0,
      correctAnswers: data['correctAnswers'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      scorePercentage: data['scorePercentage']?.toDouble() ?? 0.0,
      xpEarned: data['xpEarned'] ?? 0,
      coinsEarned: data['coinsEarned'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'gameId': gameId,
      'gameTitle': gameTitle,
      'gameType': gameType,
      'subjectId': subjectId,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': Timestamp.fromDate(completedAt),
      'durationSeconds': durationSeconds,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'scorePercentage': scorePercentage,
      'xpEarned': xpEarned,
      'coinsEarned': coinsEarned,
    };
  }
}

/// A class representing question-level analytics for identifying difficult questions
class QuestionAnalytics {
  final String questionId;
  final String questionText;
  final String subject;
  final int difficulty;
  final double correctRate;
  final double averageTimeSecs;
  final int totalAttempts;
  final int timesAttempted;
  final int timesCorrect;
  final double averageTimeSeconds;
  final String gameId;
  
  QuestionAnalytics({
    required this.questionId,
    required this.questionText,
    required this.subject,
    this.difficulty = 1,
    this.correctRate = 0.0,
    this.averageTimeSecs = 0.0,
    this.totalAttempts = 0,
    this.timesAttempted = 0,
    this.timesCorrect = 0,
    this.averageTimeSeconds = 0.0,
    this.gameId = '',
  });
  
  factory QuestionAnalytics.fromFirestore(Map<String, dynamic> data) {
    return QuestionAnalytics(
      questionId: data['questionId'] ?? '',
      questionText: data['questionText'] ?? '',
      subject: data['subject'] ?? '',
      difficulty: data['difficulty'] ?? 1,
      correctRate: data['correctRate']?.toDouble() ?? 0.0,
      averageTimeSecs: data['averageTimeSecs']?.toDouble() ?? 0.0,
      totalAttempts: data['totalAttempts'] ?? 0,
      timesAttempted: data['timesAttempted'] ?? 0,
      timesCorrect: data['timesCorrect'] ?? 0,
      averageTimeSeconds: data['averageTimeSeconds']?.toDouble() ?? 0.0,
      gameId: data['gameId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'subject': subject,
      'difficulty': difficulty,
      'correctRate': correctRate,
      'averageTimeSecs': averageTimeSecs,
      'totalAttempts': totalAttempts,
      'timesAttempted': timesAttempted,
      'timesCorrect': timesCorrect,
      'averageTimeSeconds': averageTimeSeconds,
      'gameId': gameId,
    };
  }
}

/// A class representing a trend of performance over time
class PerformanceTrend {
  final String studentId;
  final String metricType; // 'score', 'time', 'games_completed', etc.
  final DateTime date;
  final double value;
  final String? subjectId;
  final String? gameType;
  
  PerformanceTrend({
    required this.studentId,
    required this.metricType,
    required this.date,
    required this.value,
    this.subjectId,
    this.gameType,
  });
  
  factory PerformanceTrend.fromFirestore(Map<String, dynamic> data) {
    return PerformanceTrend(
      studentId: data['studentId'] ?? '',
      metricType: data['metricType'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      value: data['value']?.toDouble() ?? 0.0,
      subjectId: data['subjectId'],
      gameType: data['gameType'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'metricType': metricType,
      'date': Timestamp.fromDate(date),
      'value': value,
      'subjectId': subjectId,
      'gameType': gameType,
    };
  }
} 