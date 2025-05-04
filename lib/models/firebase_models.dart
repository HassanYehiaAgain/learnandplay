import 'package:cloud_firestore/cloud_firestore.dart';

// USER MODELS
class FirebaseUser {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final String role; // 'student' or 'teacher'
  final DateTime createdAt;
  final List<String> enrolledClasses;
  final int xp;
  final int coins;
  final int currentStreak;
  final int longestStreak;
  final List<String> badges;
  final Map<String, dynamic> settings;
  
  // New fields for enhanced user management
  final List<String> teachingSubjects; // For teachers only
  final List<int> teachingGradeYears; // For teachers only
  final int? studentGradeYear; // For students only

  FirebaseUser({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    required this.role,
    required this.createdAt,
    required this.enrolledClasses,
    required this.xp,
    required this.coins,
    required this.currentStreak,
    required this.longestStreak,
    required this.badges,
    required this.settings,
    this.teachingSubjects = const [],
    this.teachingGradeYears = const [],
    this.studentGradeYear,
  });

  factory FirebaseUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return FirebaseUser(
      id: snapshot.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      avatar: data['avatar'],
      role: data['role'] ?? 'student',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      enrolledClasses: List<String>.from(data['enrolledClasses'] ?? []),
      xp: data['xp'] ?? 0,
      coins: data['coins'] ?? 0,
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      badges: List<String>.from(data['badges'] ?? []),
      settings: data['settings'] ?? {},
      teachingSubjects: List<String>.from(data['teachingSubjects'] ?? []),
      teachingGradeYears: List<int>.from(data['teachingGradeYears'] ?? []),
      studentGradeYear: data['studentGradeYear'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'avatar': avatar,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'enrolledClasses': enrolledClasses,
      'xp': xp,
      'coins': coins,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'badges': badges,
      'settings': settings,
      'teachingSubjects': teachingSubjects,
      'teachingGradeYears': teachingGradeYears,
      'studentGradeYear': studentGradeYear,
    };
  }
}

// SUBJECT/CLASS MODELS
class Subject {
  final String id;
  final String name;
  final String? description;
  final int gradeYear;
  final String teacherId;
  final List<String> studentIds;
  final DateTime createdAt;

  Subject({
    required this.id,
    required this.name,
    this.description,
    required this.gradeYear,
    required this.teacherId,
    required this.studentIds,
    required this.createdAt,
  });

  factory Subject.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return Subject(
      id: snapshot.id,
      name: data['name'] ?? '',
      description: data['description'] as String?,
      gradeYear: data['gradeYear'] ?? 0,
      teacherId: data['teacherId'] ?? '',
      studentIds: List<String>.from(data['studentIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'gradeYear': gradeYear,
      'teacherId': teacherId,
      'studentIds': studentIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      gradeYear: json['gradeYear'] as int,
      teacherId: json['teacherId'] as String,
      studentIds: List<String>.from(json['studentIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'gradeYear': gradeYear,
      'teacherId': teacherId,
      'studentIds': studentIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// EDUCATIONAL GAME MODELS
class EducationalGame {
  final String id;
  final String title;
  final String description;
  final String? coverImage;
  final String teacherId;
  final String subjectId;
  final int gradeYear;
  final DateTime createdAt;
  final DateTime dueDate;
  final bool isActive;
  final List<GameQuestion> questions;
  final int difficulty; // 1-5
  final int estimatedDuration; // in minutes
  final List<String> tags;
  final int maxPoints;

  EducationalGame({
    required this.id,
    required this.title,
    required this.description,
    this.coverImage,
    required this.teacherId,
    required this.subjectId,
    required this.gradeYear,
    required this.createdAt,
    required this.dueDate,
    required this.isActive,
    required this.questions,
    required this.difficulty,
    required this.estimatedDuration,
    required this.tags,
    required this.maxPoints,
  });

  factory EducationalGame.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    
    return EducationalGame(
      id: snapshot.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      coverImage: data['coverImage'],
      teacherId: data['teacherId'] ?? '',
      subjectId: data['subjectId'] ?? '',
      gradeYear: data['gradeYear'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      questions: (data['questions'] as List?)
          ?.map((q) => GameQuestion.fromMap(q as Map<String, dynamic>))
          .toList() ?? [],
      difficulty: data['difficulty'] ?? 1,
      estimatedDuration: data['estimatedDuration'] ?? 10,
      tags: List<String>.from(data['tags'] ?? []),
      maxPoints: data['maxPoints'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'coverImage': coverImage,
      'teacherId': teacherId,
      'subjectId': subjectId,
      'gradeYear': gradeYear,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': Timestamp.fromDate(dueDate),
      'isActive': isActive,
      'questions': questions.map((q) => q.toMap()).toList(),
      'difficulty': difficulty,
      'estimatedDuration': estimatedDuration,
      'tags': tags,
      'maxPoints': maxPoints,
    };
  }

  factory EducationalGame.fromJson(Map<String, dynamic> json) {
    return EducationalGame(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      coverImage: json['coverImage'] as String?,
      teacherId: json['teacherId'] as String,
      subjectId: json['subjectId'] as String,
      gradeYear: json['gradeYear'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      isActive: json['isActive'] as bool,
      questions: (json['questions'] as List)
          .map((q) => GameQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      difficulty: json['difficulty'] as int,
      estimatedDuration: json['estimatedDuration'] as int,
      tags: (json['tags'] as List).map((t) => t as String).toList(),
      maxPoints: json['maxPoints'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'coverImage': coverImage,
      'teacherId': teacherId,
      'subjectId': subjectId,
      'gradeYear': gradeYear,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'isActive': isActive,
      'questions': questions.map((q) => q.toJson()).toList(),
      'difficulty': difficulty,
      'estimatedDuration': estimatedDuration,
      'tags': tags,
      'maxPoints': maxPoints,
    };
  }
}

class GameQuestion {
  final String id;
  final String text;
  final List<GameOption> options;
  final int points;
  final String? imageUrl;
  final int timeLimit; // in seconds

  GameQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.points,
    this.imageUrl,
    required this.timeLimit,
  });

  factory GameQuestion.fromMap(Map<String, dynamic> map) {
    return GameQuestion(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      options: (map['options'] as List?)
          ?.map((o) => GameOption.fromMap(o as Map<String, dynamic>))
          .toList() ?? [],
      points: map['points'] ?? 1,
      imageUrl: map['imageUrl'],
      timeLimit: map['timeLimit'] ?? 30,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'options': options.map((o) => o.toMap()).toList(),
      'points': points,
      'imageUrl': imageUrl,
      'timeLimit': timeLimit,
    };
  }

  factory GameQuestion.fromJson(Map<String, dynamic> json) {
    return GameQuestion(
      id: json['id'] as String,
      text: json['text'] as String,
      options: (json['options'] as List?)
          ?.map((o) => GameOption.fromJson(o as Map<String, dynamic>))
          .toList() ?? [],
      points: json['points'] as int,
      imageUrl: json['imageUrl'] as String?,
      timeLimit: json['timeLimit'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'options': options.map((o) => o.toJson()).toList(),
      'points': points,
      'imageUrl': imageUrl,
      'timeLimit': timeLimit,
    };
  }
}

class GameOption {
  final String id;
  final String text;
  final bool isCorrect;
  final String? explanation;

  GameOption({
    required this.id,
    required this.text,
    required this.isCorrect,
    this.explanation,
  });

  factory GameOption.fromMap(Map<String, dynamic> map) {
    return GameOption(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      isCorrect: map['isCorrect'] ?? false,
      explanation: map['explanation'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isCorrect': isCorrect,
      'explanation': explanation,
    };
  }

  factory GameOption.fromJson(Map<String, dynamic> json) {
    return GameOption(
      id: json['id'] as String,
      text: json['text'] as String,
      isCorrect: json['isCorrect'] as bool,
      explanation: json['explanation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isCorrect': isCorrect,
      'explanation': explanation,
    };
  }
}

// GAME PROGRESS MODELS
class GameProgress {
  final String id;
  final String gameId;
  final String studentId;
  final String subjectId; 
  final DateTime startedAt;
  final DateTime? completedAt;
  final int score;
  final int totalPossibleScore;
  final double completionPercentage;
  final List<QuestionAnswer> answers;
  final int xpEarned;
  final int coinsEarned;
  final List<String> badgesEarned;

  GameProgress({
    required this.id,
    required this.gameId,
    required this.studentId,
    required this.subjectId,
    required this.startedAt,
    this.completedAt,
    required this.score,
    required this.totalPossibleScore,
    required this.completionPercentage,
    required this.answers,
    required this.xpEarned,
    required this.coinsEarned,
    required this.badgesEarned,
  });

  factory GameProgress.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    
    return GameProgress(
      id: snapshot.id,
      gameId: data['gameId'] ?? '',
      studentId: data['studentId'] ?? '',
      subjectId: data['subjectId'] ?? '',
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      score: data['score'] ?? 0,
      totalPossibleScore: data['totalPossibleScore'] ?? 0,
      completionPercentage: (data['completionPercentage'] ?? 0).toDouble(),
      answers: (data['answers'] as List?)
          ?.map((a) => QuestionAnswer.fromMap(a as Map<String, dynamic>))
          .toList() ?? [],
      xpEarned: data['xpEarned'] ?? 0,
      coinsEarned: data['coinsEarned'] ?? 0,
      badgesEarned: List<String>.from(data['badgesEarned'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'gameId': gameId,
      'studentId': studentId,
      'subjectId': subjectId,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'score': score,
      'totalPossibleScore': totalPossibleScore,
      'completionPercentage': completionPercentage,
      'answers': answers.map((a) => a.toMap()).toList(),
      'xpEarned': xpEarned,
      'coinsEarned': coinsEarned,
      'badgesEarned': badgesEarned,
    };
  }
}

class QuestionAnswer {
  final String questionId;
  final String selectedOptionId;
  final bool isCorrect;
  final int pointsEarned;
  final int timeSpent; // in seconds

  QuestionAnswer({
    required this.questionId,
    required this.selectedOptionId,
    required this.isCorrect,
    required this.pointsEarned,
    required this.timeSpent,
  });

  factory QuestionAnswer.fromMap(Map<String, dynamic> map) {
    return QuestionAnswer(
      questionId: map['questionId'] ?? '',
      selectedOptionId: map['selectedOptionId'] ?? '',
      isCorrect: map['isCorrect'] ?? false,
      pointsEarned: map['pointsEarned'] ?? 0,
      timeSpent: map['timeSpent'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'selectedOptionId': selectedOptionId,
      'isCorrect': isCorrect,
      'pointsEarned': pointsEarned,
      'timeSpent': timeSpent,
    };
  }
} 