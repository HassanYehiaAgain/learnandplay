class Game {
  final String id;
  final String title;
  final String description;
  final String? coverImage;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final String category;
  final int difficultyLevel; // 1-5 scale
  final int minAge;
  final int maxAge;
  final int estimatedDuration; // in minutes
  final List<GameQuestion> questions;
  final bool isPublished;
  final int playCount;
  final double averageRating;
  final List<GameReview>? reviews;

  Game({
    required this.id,
    required this.title,
    required this.description,
    this.coverImage,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.updatedAt,
    required this.tags,
    required this.category,
    required this.difficultyLevel,
    required this.minAge,
    required this.maxAge,
    required this.estimatedDuration,
    required this.questions,
    required this.isPublished,
    required this.playCount,
    required this.averageRating,
    this.reviews,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    final List<dynamic> questionsJson = json['questions'] ?? [];
    final List<GameQuestion> questionsList = questionsJson
        .map((q) => GameQuestion.fromJson(q))
        .toList();

    final List<dynamic> reviewsJson = json['reviews'] ?? [];
    final List<GameReview> reviewsList = reviewsJson
        .map((r) => GameReview.fromJson(r))
        .toList();

    return Game(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      coverImage: json['coverImage'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'],
      difficultyLevel: json['difficultyLevel'],
      minAge: json['minAge'],
      maxAge: json['maxAge'],
      estimatedDuration: json['estimatedDuration'],
      questions: questionsList,
      isPublished: json['isPublished'] ?? false,
      playCount: json['playCount'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      reviews: reviewsList.isEmpty ? null : reviewsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'coverImage': coverImage,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'category': category,
      'difficultyLevel': difficultyLevel,
      'minAge': minAge,
      'maxAge': maxAge,
      'estimatedDuration': estimatedDuration,
      'questions': questions.map((q) => q.toJson()).toList(),
      'isPublished': isPublished,
      'playCount': playCount,
      'averageRating': averageRating,
      'reviews': reviews?.map((r) => r.toJson()).toList(),
    };
  }
}

class GameQuestion {
  final String id;
  final String text;
  final List<GameQuestionOption> options;
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

  factory GameQuestion.fromJson(Map<String, dynamic> json) {
    final List<dynamic> optionsJson = json['options'] ?? [];
    final List<GameQuestionOption> optionsList = optionsJson
        .map((o) => GameQuestionOption.fromJson(o))
        .toList();

    return GameQuestion(
      id: json['id'],
      text: json['text'],
      options: optionsList,
      points: json['points'] ?? 1,
      imageUrl: json['imageUrl'],
      timeLimit: json['timeLimit'] ?? 30,
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

class GameQuestionOption {
  final String id;
  final String text;
  final bool isCorrect;
  final String? explanation;

  GameQuestionOption({
    required this.id,
    required this.text,
    required this.isCorrect,
    this.explanation,
  });

  factory GameQuestionOption.fromJson(Map<String, dynamic> json) {
    return GameQuestionOption(
      id: json['id'],
      text: json['text'],
      isCorrect: json['isCorrect'] ?? false,
      explanation: json['explanation'],
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

class GameReview {
  final String id;
  final String userId;
  final String userName;
  final int rating; // 1-5 scale
  final String? comment;
  final DateTime createdAt;

  GameReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory GameReview.fromJson(Map<String, dynamic> json) {
    return GameReview(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
} 