import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:learn_play_level_up_flutter/models/game_models.dart' as game_models;

// Base class for all game templates
class GameTemplate {
  final String id;
  final String title;
  final String description;
  final String type;
  final String subjectId;
  final int gradeYear;
  final int coinReward;
  final int maxPoints;
  final DateTime createdAt;
  final String teacherId;
  final String? coverImage;
  final DateTime dueDate;
  final bool isActive;
  final int estimatedDuration;
  final List<String> tags;
  final int xpReward;

  GameTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.subjectId,
    required this.gradeYear,
    required this.coinReward,
    required this.maxPoints,
    required this.createdAt,
    required this.teacherId,
    this.coverImage,
    required this.dueDate,
    this.isActive = true,
    required this.estimatedDuration,
    required this.tags,
    required this.xpReward,
  });

  // Convert to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'subjectId': subjectId,
      'gradeYear': gradeYear,
      'coinReward': coinReward,
      'maxPoints': maxPoints,
      'createdAt': Timestamp.fromDate(createdAt),
      'teacherId': teacherId,
      'coverImage': coverImage,
      'dueDate': Timestamp.fromDate(dueDate),
      'isActive': isActive,
      'estimatedDuration': estimatedDuration,
      'tags': tags,
      'xpReward': xpReward,
    };
  }

  // Factory method to create a GameTemplate from Firestore data
  factory GameTemplate.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameTemplate(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String,
      type: data['type'] as String,
      subjectId: data['subjectId'] as String,
      gradeYear: data['gradeYear'] as int,
      coinReward: data['coinReward'] as int,
      maxPoints: data['maxPoints'] as int,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      teacherId: data['teacherId'] as String,
      coverImage: data['coverImage'] as String?,
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isActive: data['isActive'] as bool? ?? true,
      estimatedDuration: data['estimatedDuration'] as int,
      tags: List<String>.from(data['tags'] as List),
      xpReward: data['xpReward'] as int,
    );
  }

  @override
  String toString() {
    return '$type - $title';
  }

  // Get icon based on template type
  IconData getIcon() {
    switch (type) {
      case 'word_scramble':
        return Icons.shuffle;
      case 'matching_pairs':
        return Icons.compare_arrows;
      case 'memory_flip_cards':
        return Icons.flip;
      case 'drag_drop_categories':
        return Icons.drag_indicator;
      case 'sorting':
        return Icons.sort;
      default:
        return Icons.games;
    }
  }
  
  // Get color based on template type
  Color getColor() {
    switch (type) {
      case 'word_scramble':
        return Colors.purple;
      case 'matching_pairs':
        return Colors.blue;
      case 'memory_flip_cards':
        return Colors.green;
      case 'drag_drop_categories':
        return Colors.orange;
      case 'sorting':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// 1. Word Scramble / Anagrams Game
class WordScrambleGame extends GameTemplate {
  final List<WordScrambleItem> words;
  final bool caseSensitive;
  final int? timeLimit;
  
  WordScrambleGame({
    String? id,
    required String title,
    required String description,
    required String subjectId,
    required int gradeYear,
    required int coinReward,
    required int maxPoints,
    required DateTime createdAt,
    required String teacherId,
    String? coverImage,
    required DateTime dueDate,
    bool isActive = true,
    required int estimatedDuration,
    required List<String> tags,
    required int xpReward,
    required this.words,
    this.caseSensitive = false,
    this.timeLimit,
  }) : super(
    id: id ?? const Uuid().v4(),
    title: title,
    description: description,
    type: 'word_scramble',
    subjectId: subjectId,
    gradeYear: gradeYear,
    coinReward: coinReward,
    maxPoints: maxPoints,
    createdAt: createdAt,
    teacherId: teacherId,
    coverImage: coverImage,
    dueDate: dueDate,
    isActive: isActive,
    estimatedDuration: estimatedDuration,
    tags: tags,
    xpReward: xpReward,
  );
  
  @override
  Map<String, dynamic> toFirestore() {
    return {
      ...super.toFirestore(),
      'words': words.map((w) => w.toMap()).toList(),
      'caseSensitive': caseSensitive,
      'timeLimit': timeLimit,
    };
  }

  factory WordScrambleGame.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return WordScrambleGame(
      id: snapshot.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      subjectId: data['subjectId'] ?? '',
      gradeYear: data['gradeYear'] ?? 0,
      coinReward: data['coinReward'] ?? 0,
      maxPoints: data['maxPoints'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      teacherId: data['teacherId'] ?? '',
      coverImage: data['coverImage'],
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      estimatedDuration: data['estimatedDuration'] ?? 10,
      tags: List<String>.from(data['tags'] ?? []),
      xpReward: data['xpReward'] ?? 0,
      words: (data['words'] as List?)
              ?.map((w) => WordScrambleItem.fromMap(w as Map<String, dynamic>))
              .toList() ??
          [],
      caseSensitive: data['caseSensitive'] ?? false,
      timeLimit: data['timeLimit'],
    );
  }
}

class WordScrambleItem {
  final String id;
  final String word;
  final String hint;
  final int points;
  
  WordScrambleItem({
    String? id,
    required this.word,
    required this.hint,
    required this.points,
  }) : id = id ?? const Uuid().v4();
  
  factory WordScrambleItem.fromMap(Map<String, dynamic> map) {
    return WordScrambleItem(
      id: map['id'] ?? const Uuid().v4(),
      word: map['word'] ?? '',
      hint: map['hint'] ?? '',
      points: map['points'] ?? 1,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'hint': hint,
      'points': points,
    };
  }
  
  // Method to scramble the word
  String getScrambledWord() {
    List<String> characters = word.split('');
    characters.shuffle();
    return characters.join('');
  }
}

// 2. Quiz Show (Jeopardy-style)
class QuizShowGame extends GameTemplate {
  List<QuizCategory> categories;
  bool allowPartialPoints;
  
  QuizShowGame({
    required String title,
    required String description,
    String? coverImage,
    required String teacherId,
    required String subjectId,
    required int gradeYear,
    required DateTime createdAt,
    required DateTime dueDate,
    bool isActive = true,
    required int estimatedDuration,
    required List<String> tags,
    required int maxPoints,
    required int xpReward,
    required int coinReward,
    required this.categories,
    this.allowPartialPoints = false,
  }) : super(
    id: '',
    title: title,
    description: description,
    type: 'quiz_show',
    subjectId: subjectId,
    gradeYear: gradeYear,
    coinReward: coinReward,
    maxPoints: maxPoints,
    createdAt: createdAt,
    teacherId: teacherId,
    coverImage: coverImage,
    dueDate: dueDate,
    isActive: isActive,
    estimatedDuration: estimatedDuration,
    tags: tags,
    xpReward: xpReward,
  );
  
  factory QuizShowGame.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    
    return QuizShowGame(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      coverImage: data['coverImage'],
      teacherId: data['teacherId'] ?? '',
      subjectId: data['subjectId'] ?? '',
      gradeYear: data['gradeYear'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      estimatedDuration: data['estimatedDuration'] ?? 10,
      tags: List<String>.from(data['tags'] ?? []),
      maxPoints: data['maxPoints'] ?? 0,
      xpReward: data['xpReward'] ?? 0,
      coinReward: data['coinReward'] ?? 0,
      categories: (data['categories'] as List?)
          ?.map((c) => QuizCategory.fromMap(c as Map<String, dynamic>))
          .toList() ?? [],
      allowPartialPoints: data['allowPartialPoints'] ?? false,
    );
  }
  
  @override
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'coverImage': coverImage,
      'teacherId': teacherId,
      'subjectId': subjectId,
      'gradeYear': gradeYear,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': Timestamp.fromDate(dueDate),
      'isActive': isActive,
      'estimatedDuration': estimatedDuration,
      'tags': tags,
      'maxPoints': maxPoints,
      'xpReward': xpReward,
      'coinReward': coinReward,
      'categories': categories.map((c) => c.toMap()).toList(),
      'allowPartialPoints': allowPartialPoints,
    };
  }
}

class QuizQuestion {
  final String id;
  final String type; // 'multiple_choice', 'multiple_select', 'true_false', 'short_answer', 'essay', 'matching', 'numerical'
  final String questionText;
  final String? imageUrl;
  final List<String>? options;
  final List<String>? correctAnswers;
  final int points;
  final int? difficulty;
  final String? explanation;
  final List<String> tags;
  final int position;
  final Map<String, dynamic>? additionalData; // For type-specific data
  final String? answer; // For quiz show style questions
  final int? timeLimit; // For quiz show style questions

  QuizQuestion({
    required this.id,
    required this.type,
    required this.questionText,
    this.imageUrl,
    this.options,
    this.correctAnswers,
    required this.points,
    this.difficulty,
    this.explanation,
    this.tags = const [],
    required this.position,
    this.additionalData,
    this.answer,
    this.timeLimit,
  });

  // For quiz show style questions
  String get question => questionText;
  int get pointValue => points;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'questionText': questionText,
      'imageUrl': imageUrl,
      'options': options,
      'correctAnswers': correctAnswers,
      'points': points,
      'difficulty': difficulty,
      'explanation': explanation,
      'tags': tags,
      'position': position,
      'additionalData': additionalData,
      'answer': answer,
      'timeLimit': timeLimit,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] as String,
      type: map['type'] as String,
      questionText: map['questionText'] as String,
      imageUrl: map['imageUrl'] as String?,
      options: map['options'] != null ? List<String>.from(map['options']) : null,
      correctAnswers: map['correctAnswers'] != null ? List<String>.from(map['correctAnswers']) : null,
      points: map['points'] as int,
      difficulty: map['difficulty'] as int?,
      explanation: map['explanation'] as String?,
      tags: List<String>.from(map['tags'] ?? []),
      position: map['position'] as int,
      additionalData: map['additionalData'] as Map<String, dynamic>?,
      answer: map['answer'] as String?,
      timeLimit: map['timeLimit'] as int?,
    );
  }
}

class QuizCategory {
  final String id;
  final String name;
  final List<QuizQuestion> questions;
  
  QuizCategory({
    String? id,
    required this.name,
    required this.questions,
  }) : id = id ?? const Uuid().v4();
  
  factory QuizCategory.fromMap(Map<String, dynamic> map) {
    return QuizCategory(
      id: map['id'] ?? const Uuid().v4(),
      name: map['name'] ?? '',
      questions: (map['questions'] as List?)
          ?.map((q) => QuizQuestion.fromMap(q as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }
}

// 3. Hangman / Word Guess Game
class WordGuessGame extends GameTemplate {
  List<WordGuessItem> puzzles;
  int maxWrongGuesses;
  bool showHintAutomatically;
  String? category;
  
  WordGuessGame({
    required String title,
    required String description,
    String? coverImage,
    required String teacherId,
    required String subjectId,
    required int gradeYear,
    required DateTime createdAt,
    required DateTime dueDate,
    bool isActive = true,
    required int estimatedDuration,
    required List<String> tags,
    required int maxPoints,
    required int xpReward,
    required int coinReward,
    required this.puzzles,
    this.maxWrongGuesses = 6,
    this.showHintAutomatically = false,
    this.category,
  }) : super(
    id: '',
    title: title,
    description: description,
    type: 'word_guess',
    subjectId: subjectId,
    gradeYear: gradeYear,
    coinReward: coinReward,
    maxPoints: maxPoints,
    createdAt: createdAt,
    teacherId: teacherId,
    coverImage: coverImage,
    dueDate: dueDate,
    isActive: isActive,
    estimatedDuration: estimatedDuration,
    tags: tags,
    xpReward: xpReward,
  );
  
  factory WordGuessGame.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    
    return WordGuessGame(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      coverImage: data['coverImage'],
      teacherId: data['teacherId'] ?? '',
      subjectId: data['subjectId'] ?? '',
      gradeYear: data['gradeYear'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      estimatedDuration: data['estimatedDuration'] ?? 10,
      tags: List<String>.from(data['tags'] ?? []),
      maxPoints: data['maxPoints'] ?? 0,
      xpReward: data['xpReward'] ?? 0,
      coinReward: data['coinReward'] ?? 0,
      puzzles: (data['puzzles'] as List?)
          ?.map((p) => WordGuessItem.fromMap(p as Map<String, dynamic>))
          .toList() ?? [],
      maxWrongGuesses: data['maxWrongGuesses'] ?? 6,
      showHintAutomatically: data['showHintAutomatically'] ?? false,
      category: data['category'],
    );
  }
  
  @override
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'coverImage': coverImage,
      'teacherId': teacherId,
      'subjectId': subjectId,
      'gradeYear': gradeYear,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': Timestamp.fromDate(dueDate),
      'isActive': isActive,
      'estimatedDuration': estimatedDuration,
      'tags': tags,
      'maxPoints': maxPoints,
      'xpReward': xpReward,
      'coinReward': coinReward,
      'puzzles': puzzles.map((p) => p.toMap()).toList(),
      'maxWrongGuesses': maxWrongGuesses,
      'showHintAutomatically': showHintAutomatically,
      'category': category,
    };
  }
}

class WordGuessItem {
  final String id;
  final String word;
  final String hint;
  final int points;
  
  WordGuessItem({
    String? id,
    required this.word,
    required this.hint,
    required this.points,
  }) : id = id ?? const Uuid().v4();
  
  factory WordGuessItem.fromMap(Map<String, dynamic> map) {
    return WordGuessItem(
      id: map['id'] ?? const Uuid().v4(),
      word: map['word'] ?? '',
      hint: map['hint'] ?? '',
      points: map['points'] ?? 10,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'hint': hint,
      'points': points,
    };
  }
  
  // Get masked word (e.g., "apple" becomes "_ _ _ _ _")
  String getMaskedWord() {
    return word.split('').map((_) => '_').join(' ');
  }
}

// 4. Sorting Game
class SortingGame extends GameTemplate {
  final String gameMode; // 'sequence' or 'category'
  final List<SortingGameItem> items;
  final List<SortingGameCategory>? categories; // Only for category mode
  final bool randomizeOrder;
  final bool showPositionNumbers;
  final int? timeLimit;
  final int maxAttempts;
  final String? instructions;
  final bool allowMultipleCategories;

  SortingGame({
    required super.title,
    required super.description,
    required super.teacherId,
    required super.subjectId,
    required super.gradeYear,
    required super.createdAt,
    required super.dueDate,
    required super.isActive,
    required super.estimatedDuration,
    required super.tags,
    required super.maxPoints,
    required super.xpReward,
    required super.coinReward,
    super.coverImage,
    required this.gameMode,
    required this.items,
    this.categories,
    this.randomizeOrder = true,
    this.showPositionNumbers = true,
    this.timeLimit,
    this.maxAttempts = 3,
    this.instructions,
    this.allowMultipleCategories = false,
  }) : super(
    id: const Uuid().v4(),
    type: 'sorting_game',
  );

  @override
  Map<String, dynamic> toFirestore() {
    final data = super.toFirestore();
    data.addAll({
      'gameMode': gameMode,
      'items': items.map((item) => item.toJson()).toList(),
      'categories': categories?.map((cat) => cat.toJson()).toList(),
      'randomizeOrder': randomizeOrder,
      'showPositionNumbers': showPositionNumbers,
      'timeLimit': timeLimit,
      'maxAttempts': maxAttempts,
      'instructions': instructions,
      'allowMultipleCategories': allowMultipleCategories,
    });
    return data;
  }

  factory SortingGame.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final base = GameTemplate.fromFirestore(doc);
    
    return SortingGame(
      title: base.title,
      description: base.description,
      teacherId: base.teacherId,
      subjectId: base.subjectId,
      gradeYear: base.gradeYear,
      createdAt: base.createdAt,
      dueDate: base.dueDate,
      isActive: base.isActive,
      estimatedDuration: base.estimatedDuration,
      tags: base.tags,
      maxPoints: base.maxPoints,
      xpReward: base.xpReward,
      coinReward: base.coinReward,
      coverImage: base.coverImage,
      gameMode: data['gameMode'] as String,
      items: (data['items'] as List)
          .map((item) => SortingGameItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      categories: data['categories'] != null
          ? (data['categories'] as List)
              .map((cat) => SortingGameCategory.fromJson(cat as Map<String, dynamic>))
              .toList()
          : null,
      randomizeOrder: data['randomizeOrder'] as bool? ?? true,
      showPositionNumbers: data['showPositionNumbers'] as bool? ?? true,
      timeLimit: data['timeLimit'] as int?,
      maxAttempts: data['maxAttempts'] as int? ?? 3,
      instructions: data['instructions'] as String?,
      allowMultipleCategories: data['allowMultipleCategories'] as bool? ?? false,
    );
  }
}

// Sorting Game Models
class SortingGameItem {
  final String id;
  final String content;
  final String? imageUrl;
  final int correctPosition;
  final String? description;
  final String? categoryId; // For category mode only

  SortingGameItem({
    required this.id,
    required this.content,
    this.imageUrl,
    required this.correctPosition,
    this.description,
    this.categoryId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'imageUrl': imageUrl,
    'correctPosition': correctPosition,
    'description': description,
    'categoryId': categoryId,
  };

  factory SortingGameItem.fromJson(Map<String, dynamic> json) => SortingGameItem(
    id: json['id'] as String,
    content: json['content'] as String,
    imageUrl: json['imageUrl'] as String?,
    correctPosition: json['correctPosition'] as int,
    description: json['description'] as String?,
    categoryId: json['categoryId'] as String?,
  );
}

class SortingGameCategory {
  final String id;
  final String name;
  final String? description;

  SortingGameCategory({
    required this.id,
    required this.name,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
  };

  factory SortingGameCategory.fromJson(Map<String, dynamic> json) => SortingGameCategory(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
  );
}

class TrueFalseGame extends GameTemplate {
  List<TrueFalseStatement> statements;
  bool randomizeOrder;
  bool allowSkipping;
  int? timeLimit; // in seconds for whole game
  int? timePerStatement; // in seconds per statement
  
  TrueFalseGame({
    String? id,
    required String title,
    required String description,
    String? coverImage,
    required String teacherId,
    required String subjectId,
    required int gradeYear,
    required DateTime createdAt,
    required DateTime dueDate,
    bool isActive = true,
    required int estimatedDuration,
    required List<String> tags,
    required int maxPoints,
    required int xpReward,
    required int coinReward,
    required this.statements,
    this.randomizeOrder = true,
    this.allowSkipping = true,
    this.timeLimit,
    this.timePerStatement,
  }) : super(
    id: id ?? const Uuid().v4(),
    title: title,
    description: description,
    type: 'true_false',
    subjectId: subjectId,
    gradeYear: gradeYear,
    coinReward: coinReward,
    maxPoints: maxPoints,
    createdAt: createdAt,
    teacherId: teacherId,
    coverImage: coverImage,
    dueDate: dueDate,
    isActive: isActive,
    estimatedDuration: estimatedDuration,
    tags: tags,
    xpReward: xpReward,
  );
  
  factory TrueFalseGame.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    
    return TrueFalseGame(
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
      estimatedDuration: data['estimatedDuration'] ?? 10,
      tags: List<String>.from(data['tags'] ?? []),
      maxPoints: data['maxPoints'] ?? 0,
      xpReward: data['xpReward'] ?? 0,
      coinReward: data['coinReward'] ?? 0,
      statements: (data['statements'] as List?)
          ?.map((s) => TrueFalseStatement.fromMap(s as Map<String, dynamic>))
          .toList() ?? [],
      randomizeOrder: data['randomizeOrder'] ?? true,
      allowSkipping: data['allowSkipping'] ?? true,
      timeLimit: data['timeLimit'],
      timePerStatement: data['timePerStatement'],
    );
  }
  
  @override
  Map<String, dynamic> toFirestore() {
    final baseMap = super.toFirestore();
    return {
      ...baseMap,
      'statements': statements.map((s) => s.toMap()).toList(),
      'randomizeOrder': randomizeOrder,
      'allowSkipping': allowSkipping,
      'timeLimit': timeLimit,
      'timePerStatement': timePerStatement,
    };
  }
}

class TrueFalseStatement {
  final String id;
  final String statement;
  final bool isTrue;
  final String explanation;
  final String? imageUrl;
  final int points;
  
  TrueFalseStatement({
    String? id,
    required this.statement,
    required this.isTrue,
    required this.explanation,
    this.imageUrl,
    this.points = 10,
  }) : id = id ?? const Uuid().v4();
  
  factory TrueFalseStatement.fromMap(Map<String, dynamic> map) {
    return TrueFalseStatement(
      id: map['id'] ?? const Uuid().v4(),
      statement: map['statement'] ?? '',
      isTrue: map['isTrue'] ?? false,
      explanation: map['explanation'] ?? '',
      imageUrl: map['imageUrl'],
      points: map['points'] ?? 10,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'statement': statement,
      'isTrue': isTrue,
      'explanation': explanation,
      'imageUrl': imageUrl,
      'points': points,
    };
  }
}

class DragDropCategoriesGame extends GameTemplate {
  final List<game_models.CategoryItem> categories;
  final List<game_models.DraggableItem> items;
  final bool showCategoryDescriptions;
  final bool immediateCorrectnessFeedback;
  final int? timeLimit;

  DragDropCategoriesGame({
    String? id,
    required String title,
    required String description,
    required String subjectId,
    required int gradeYear,
    required int coinReward,
    required int maxPoints,
    required DateTime createdAt,
    required String teacherId,
    String? coverImage,
    required DateTime dueDate,
    bool isActive = true,
    required int estimatedDuration,
    required List<String> tags,
    required int xpReward,
    required this.categories,
    required this.items,
    this.showCategoryDescriptions = true,
    this.immediateCorrectnessFeedback = true,
    this.timeLimit,
  }) : super(
    id: id ?? const Uuid().v4(),
    title: title,
    description: description,
    type: 'drag_drop_categories',
    subjectId: subjectId,
    gradeYear: gradeYear,
    coinReward: coinReward,
    maxPoints: maxPoints,
    createdAt: createdAt,
    teacherId: teacherId,
    coverImage: coverImage,
    dueDate: dueDate,
    isActive: isActive,
    estimatedDuration: estimatedDuration,
    tags: tags,
    xpReward: xpReward,
  );
  
  @override
  Map<String, dynamic> toFirestore() {
    return {
      ...super.toFirestore(),
      'categories': categories.map((c) => c.toMap()).toList(),
      'items': items.map((i) => i.toMap()).toList(),
      'showCategoryDescriptions': showCategoryDescriptions,
      'immediateCorrectnessFeedback': immediateCorrectnessFeedback,
      'timeLimit': timeLimit,
    };
  }

  factory DragDropCategoriesGame.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return DragDropCategoriesGame(
      id: snapshot.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      subjectId: data['subjectId'] ?? '',
      gradeYear: data['gradeYear'] ?? 0,
      coinReward: data['coinReward'] ?? 0,
      maxPoints: data['maxPoints'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      teacherId: data['teacherId'] ?? '',
      coverImage: data['coverImage'],
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      estimatedDuration: data['estimatedDuration'] ?? 10,
      tags: List<String>.from(data['tags'] ?? []),
      xpReward: data['xpReward'] ?? 0,
      categories: (data['categories'] as List<dynamic>?)
              ?.map((c) => game_models.CategoryItem.fromMap(c))
              .toList() ??
          [],
      items: (data['items'] as List<dynamic>?)
              ?.map((i) => game_models.DraggableItem.fromMap(i))
              .toList() ??
          [],
      showCategoryDescriptions: data['showCategoryDescriptions'] ?? true,
      immediateCorrectnessFeedback: data['immediateCorrectnessFeedback'] ?? true,
      timeLimit: data['timeLimit'],
    );
  }
}

// Universal Game Template Info class for template selection screen
class UniversalGameTemplateInfo {
  final String type;
  final String title;
  final String description;
  final String? coverImage;
  final IconData icon;
  final Color color;
  final List<String> tags;
  final int estimatedDuration;
  final int maxPoints;
  final int xpReward;
  final int coinReward;
  final String routePath;

  String get templateType => type;

  UniversalGameTemplateInfo({
    required this.type,
    required this.title,
    required this.description,
    this.coverImage,
    required this.icon,
    required this.color,
    required this.tags,
    required this.estimatedDuration,
    required this.maxPoints,
    required this.xpReward,
    required this.coinReward,
    required this.routePath,
  });

  factory UniversalGameTemplateInfo.fromGameTemplate(GameTemplate template) {
    return UniversalGameTemplateInfo(
      type: template.type,
      title: template.title,
      description: template.description,
      coverImage: template.coverImage,
      icon: template.getIcon(),
      color: template.getColor(),
      tags: template.tags,
      estimatedDuration: template.estimatedDuration,
      maxPoints: template.maxPoints,
      xpReward: template.xpReward,
      coinReward: template.coinReward,
      routePath: '/teacher/games/templates/${template.type}',
    );
  }

  static List<UniversalGameTemplateInfo> getAllTemplates() {
    return [
      UniversalGameTemplateInfo(
        type: 'word_scramble',
        title: 'Word Scramble',
        description: 'Unscramble words to test your vocabulary',
        icon: Icons.shuffle,
        color: Colors.purple,
        tags: ['vocabulary', 'spelling'],
        estimatedDuration: 10,
        maxPoints: 100,
        xpReward: 50,
        coinReward: 25,
        routePath: '/teacher/games/templates/word_scramble',
      ),
      UniversalGameTemplateInfo(
        type: 'matching_pairs',
        title: 'Matching Pairs',
        description: 'Match related items to test your knowledge',
        icon: Icons.compare_arrows,
        color: Colors.blue,
        tags: ['memory', 'association'],
        estimatedDuration: 15,
        maxPoints: 100,
        xpReward: 50,
        coinReward: 25,
        routePath: '/teacher/games/templates/matching_pairs',
      ),
      UniversalGameTemplateInfo(
        type: 'memory_flip_cards',
        title: 'Memory Flip Cards',
        description: 'Flip cards to find matching pairs',
        icon: Icons.flip,
        color: Colors.green,
        tags: ['memory', 'concentration'],
        estimatedDuration: 15,
        maxPoints: 100,
        xpReward: 50,
        coinReward: 25,
        routePath: '/teacher/games/templates/memory_flip_cards',
      ),
      UniversalGameTemplateInfo(
        type: 'drag_drop_categories',
        title: 'Drag & Drop Categories',
        description: 'Sort items into their correct categories',
        icon: Icons.drag_indicator,
        color: Colors.orange,
        tags: ['sorting', 'classification'],
        estimatedDuration: 20,
        maxPoints: 100,
        xpReward: 50,
        coinReward: 25,
        routePath: '/teacher/games/templates/drag_drop_categories',
      ),
      UniversalGameTemplateInfo(
        type: 'word_search',
        title: 'Word Search',
        description: 'Find hidden words in a grid',
        icon: Icons.search,
        color: Colors.red,
        tags: ['vocabulary', 'pattern recognition'],
        estimatedDuration: 15,
        maxPoints: 100,
        xpReward: 50,
        coinReward: 25,
        routePath: '/teacher/games/templates/word_search',
      ),
      UniversalGameTemplateInfo(
        type: 'quiz_show',
        title: 'Quiz Show',
        description: 'Jeopardy-style quiz with categories and point values',
        icon: Icons.quiz,
        color: Colors.indigo,
        tags: ['quiz', 'jeopardy', 'competition'],
        estimatedDuration: 20,
        maxPoints: 1000,
        xpReward: 200,
        coinReward: 100,
        routePath: '/teacher/games/templates/quiz_show',
      ),
      UniversalGameTemplateInfo(
        type: 'word_guess',
        title: 'Word Guess',
        description: 'Hangman-style word guessing game',
        icon: Icons.abc,
        color: Colors.teal,
        tags: ['vocabulary', 'spelling', 'hangman'],
        estimatedDuration: 15,
        maxPoints: 100,
        xpReward: 100,
        coinReward: 50,
        routePath: '/teacher/games/templates/word_guess',
      ),
      UniversalGameTemplateInfo(
        type: 'true_false',
        title: 'True or False',
        description: 'Test knowledge with true/false statements',
        icon: Icons.check_circle_outline,
        color: Colors.amber,
        tags: ['quiz', 'true_false'],
        estimatedDuration: 10,
        maxPoints: 100,
        xpReward: 50,
        coinReward: 25,
        routePath: '/teacher/games/templates/true_false',
      ),
      UniversalGameTemplateInfo(
        type: 'fill_in_the_blank',
        title: 'Fill in the Blank',
        description: 'Complete sentences with missing words',
        icon: Icons.edit_note,
        color: Colors.deepPurple,
        tags: ['vocabulary', 'comprehension'],
        estimatedDuration: 15,
        maxPoints: 100,
        xpReward: 50,
        coinReward: 25,
        routePath: '/teacher/games/templates/fill_in_the_blank',
      ),
      UniversalGameTemplateInfo(
        type: 'flashcard_game',
        title: 'Flashcards',
        description: 'Study with interactive flashcards',
        icon: Icons.flip_to_back,
        color: Colors.pink,
        tags: ['study', 'memory'],
        estimatedDuration: 15,
        maxPoints: 100,
        xpReward: 50,
        coinReward: 25,
        routePath: '/teacher/games/templates/flashcard_game',
      ),
      UniversalGameTemplateInfo(
        type: 'general_quiz',
        title: 'General Quiz',
        description: 'Create custom quizzes with various question types',
        icon: Icons.assignment,
        color: Colors.brown,
        tags: ['quiz', 'assessment'],
        estimatedDuration: 20,
        maxPoints: 100,
        xpReward: 50,
        coinReward: 25,
        routePath: '/teacher/games/templates/general_quiz',
      ),
    ];
  }
}

class WordSearchItem {
  final String id;
  final String word;
  final String hint;
  final int points;
  
  WordSearchItem({
    String? id,
    required this.word,
    required this.hint,
    required this.points,
  }) : id = id ?? const Uuid().v4();
  
  factory WordSearchItem.fromMap(Map<String, dynamic> map) {
    return WordSearchItem(
      id: map['id'] ?? const Uuid().v4(),
      word: map['word'] ?? '',
      hint: map['hint'] ?? '',
      points: map['points'] ?? 10,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'hint': hint,
      'points': points,
    };
  }
}

class WordSearchGame extends GameTemplate {
  final List<WordSearchItem> words;
  final int gridSize;
  final bool allowDiagonal;
  final bool allowBackwards;
  final bool enableDiagonal;
  final bool enableReverse;
  final int? timeLimit;
  
  WordSearchGame({
    String? id,
    required String title,
    required String description,
    required String subjectId,
    required int gradeYear,
    required int coinReward,
    required int maxPoints,
    required DateTime createdAt,
    required String teacherId,
    String? coverImage,
    required DateTime dueDate,
    bool isActive = true,
    required int estimatedDuration,
    required List<String> tags,
    required int xpReward,
    required this.words,
    this.gridSize = 10,
    this.allowDiagonal = true,
    this.allowBackwards = true,
    this.enableDiagonal = true,
    this.enableReverse = true,
    this.timeLimit,
  }) : super(
    id: id ?? const Uuid().v4(),
    title: title,
    description: description,
    type: 'word_search',
    subjectId: subjectId,
    gradeYear: gradeYear,
    coinReward: coinReward,
    maxPoints: maxPoints,
    createdAt: createdAt,
    teacherId: teacherId,
    coverImage: coverImage,
    dueDate: dueDate,
    isActive: isActive,
    estimatedDuration: estimatedDuration,
    tags: tags,
    xpReward: xpReward,
  );
  
  @override
  Map<String, dynamic> toFirestore() {
    return {
      ...super.toFirestore(),
      'words': words.map((w) => w.toMap()).toList(),
      'gridSize': gridSize,
      'allowDiagonal': allowDiagonal,
      'allowBackwards': allowBackwards,
      'enableDiagonal': enableDiagonal,
      'enableReverse': enableReverse,
      'timeLimit': timeLimit,
    };
  }

  factory WordSearchGame.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return WordSearchGame(
      id: snapshot.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      subjectId: data['subjectId'] ?? '',
      gradeYear: data['gradeYear'] ?? 0,
      coinReward: data['coinReward'] ?? 0,
      maxPoints: data['maxPoints'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      teacherId: data['teacherId'] ?? '',
      coverImage: data['coverImage'],
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      estimatedDuration: data['estimatedDuration'] ?? 10,
      tags: List<String>.from(data['tags'] ?? []),
      xpReward: data['xpReward'] ?? 0,
      words: (data['words'] as List<dynamic>?)
              ?.map((w) => WordSearchItem.fromMap(w))
              .toList() ??
          [],
      gridSize: data['gridSize'] ?? 10,
      allowDiagonal: data['allowDiagonal'] ?? true,
      allowBackwards: data['allowBackwards'] ?? true,
      enableDiagonal: data['enableDiagonal'] ?? true,
      enableReverse: data['enableReverse'] ?? true,
      timeLimit: data['timeLimit'],
    );
  }
}

class GamificationTutorialGame extends GameTemplate {
  final List<String> steps;
  final Map<String, dynamic>? tutorialData;
  
  GamificationTutorialGame({
    String? id,
    required String title,
    required String description,
    required String subjectId,
    required int gradeYear,
    required int coinReward,
    required int maxPoints,
    required DateTime createdAt,
    required String teacherId,
    String? coverImage,
    required DateTime dueDate,
    bool isActive = true,
    required int estimatedDuration,
    required List<String> tags,
    required int xpReward,
    required this.steps,
    this.tutorialData,
  }) : super(
    id: id ?? const Uuid().v4(),
    title: title,
    description: description,
    type: 'gamification_tutorial',
    subjectId: subjectId,
    gradeYear: gradeYear,
    coinReward: coinReward,
    maxPoints: maxPoints,
    createdAt: createdAt,
    teacherId: teacherId,
    coverImage: coverImage,
    dueDate: dueDate,
    isActive: isActive,
    estimatedDuration: estimatedDuration,
    tags: tags,
    xpReward: xpReward,
  );
  
  factory GamificationTutorialGame.createDefault() {
    return GamificationTutorialGame(
      title: 'Gamification Tutorial',
      description: 'Learn how to use the gamification features',
      subjectId: 'tutorial',
      gradeYear: 0,
      coinReward: 0,
      maxPoints: 0,
      createdAt: DateTime.now(),
      teacherId: 'system',
      dueDate: DateTime.now().add(const Duration(days: 365)),
      estimatedDuration: 10,
      tags: ['tutorial', 'gamification'],
      xpReward: 0,
      steps: [
        'Welcome to the tutorial!',
        'Learn about points and rewards',
        'Understand the game mechanics',
        'Complete your first challenge',
      ],
      tutorialData: {
        'welcomeMessage': 'Welcome to the gamification tutorial!',
        'steps': [
          {'title': 'Introduction', 'description': 'Learn the basics'},
          {'title': 'Points System', 'description': 'Understand how points work'},
          {'title': 'Rewards', 'description': 'Learn about available rewards'},
          {'title': 'Gameplay', 'description': 'Try your first challenge'},
        ],
      },
    );
  }
  
  @override
  Map<String, dynamic> toFirestore() {
    return {
      ...super.toFirestore(),
      'steps': steps,
      'tutorialData': tutorialData,
    };
  }

  factory GamificationTutorialGame.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return GamificationTutorialGame(
      id: snapshot.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      subjectId: data['subjectId'] ?? '',
      gradeYear: data['gradeYear'] ?? 0,
      coinReward: data['coinReward'] ?? 0,
      maxPoints: data['maxPoints'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      teacherId: data['teacherId'] ?? '',
      coverImage: data['coverImage'],
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      estimatedDuration: data['estimatedDuration'] ?? 10,
      tags: List<String>.from(data['tags'] ?? []),
      xpReward: data['xpReward'] ?? 0,
      steps: List<String>.from(data['steps'] ?? []),
      tutorialData: data['tutorialData'],
    );
  }
}

// Fill-in-the-Blank Game Models
class FillInTheBlankItem {
  final String id;
  final String correctAnswer;
  final List<String> alternativeAnswers;
  final String? hint;
  final int position;
  final bool caseSensitive;

  FillInTheBlankItem({
    required this.id,
    required this.correctAnswer,
    this.alternativeAnswers = const [],
    this.hint,
    required this.position,
    this.caseSensitive = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'correctAnswer': correctAnswer,
    'alternativeAnswers': alternativeAnswers,
    'hint': hint,
    'position': position,
    'caseSensitive': caseSensitive,
  };

  factory FillInTheBlankItem.fromJson(Map<String, dynamic> json) => FillInTheBlankItem(
    id: json['id'] as String,
    correctAnswer: json['correctAnswer'] as String,
    alternativeAnswers: (json['alternativeAnswers'] as List?)?.cast<String>() ?? [],
    hint: json['hint'] as String?,
    position: json['position'] as int,
    caseSensitive: json['caseSensitive'] as bool? ?? false,
  );
}

class FillInTheBlankGame extends GameTemplate {
  final String passage;
  final List<FillInTheBlankItem> blanks;
  final List<String>? wordBank;
  final bool showHints;
  final bool autoCheck;
  final int? timeLimit;
  final String? instructions;
  final bool caseSensitive;

  FillInTheBlankGame({
    required super.title,
    required super.description,
    required super.teacherId,
    required super.subjectId,
    required super.gradeYear,
    required super.createdAt,
    required super.dueDate,
    required super.isActive,
    required super.estimatedDuration,
    required super.tags,
    required super.maxPoints,
    required super.xpReward,
    required super.coinReward,
    super.coverImage,
    required this.passage,
    required this.blanks,
    this.wordBank,
    this.showHints = true,
    this.autoCheck = false,
    this.timeLimit,
    this.instructions,
    this.caseSensitive = false,
  }) : super(
    id: const Uuid().v4(),
    type: 'fill_in_the_blank',
  );

  @override
  Map<String, dynamic> toFirestore() {
    final data = super.toFirestore();
    data.addAll({
      'passage': passage,
      'blanks': blanks.map((blank) => blank.toJson()).toList(),
      'wordBank': wordBank,
      'showHints': showHints,
      'autoCheck': autoCheck,
      'timeLimit': timeLimit,
      'instructions': instructions,
      'caseSensitive': caseSensitive,
    });
    return data;
  }

  factory FillInTheBlankGame.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final base = GameTemplate.fromFirestore(doc);
    
    return FillInTheBlankGame(
      title: base.title,
      description: base.description,
      teacherId: base.teacherId,
      subjectId: base.subjectId,
      gradeYear: base.gradeYear,
      createdAt: base.createdAt,
      dueDate: base.dueDate,
      isActive: base.isActive,
      estimatedDuration: base.estimatedDuration,
      tags: base.tags,
      maxPoints: base.maxPoints,
      xpReward: base.xpReward,
      coinReward: base.coinReward,
      coverImage: base.coverImage,
      passage: data['passage'] as String,
      blanks: (data['blanks'] as List)
          .map((blank) => FillInTheBlankItem.fromJson(blank as Map<String, dynamic>))
          .toList(),
      wordBank: (data['wordBank'] as List?)?.cast<String>(),
      showHints: data['showHints'] as bool? ?? true,
      autoCheck: data['autoCheck'] as bool? ?? false,
      timeLimit: data['timeLimit'] as int?,
      instructions: data['instructions'] as String?,
      caseSensitive: data['caseSensitive'] as bool? ?? false,
    );
  }
}

class Flashcard {
  final String id;
  final String frontContent;
  final String? frontImageUrl;
  final String backContent;
  final String? backImageUrl;
  final String? additionalInfo;
  final List<String> tags;
  final int position;

  Flashcard({
    required this.id,
    required this.frontContent,
    this.frontImageUrl,
    required this.backContent,
    this.backImageUrl,
    this.additionalInfo,
    this.tags = const [],
    required this.position,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'frontContent': frontContent,
      'frontImageUrl': frontImageUrl,
      'backContent': backContent,
      'backImageUrl': backImageUrl,
      'additionalInfo': additionalInfo,
      'tags': tags,
      'position': position,
    };
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] as String,
      frontContent: map['frontContent'] as String,
      frontImageUrl: map['frontImageUrl'] as String?,
      backContent: map['backContent'] as String,
      backImageUrl: map['backImageUrl'] as String?,
      additionalInfo: map['additionalInfo'] as String?,
      tags: List<String>.from(map['tags'] ?? []),
      position: map['position'] as int,
    );
  }
}

class FlashcardGame extends GameTemplate {
  final List<Flashcard> cards;
  final String studyMode; // 'sequential', 'random', 'spaced_repetition', 'quiz'
  final Map<String, dynamic> designSettings;
  final int? timePerCard;
  final bool allowSelfAssessment;
  final bool showProgress;
  final bool showStatistics;
  final bool autoAdvance;
  final String flipAnimationStyle;

  FlashcardGame({
    required String title,
    required String description,
    required String teacherId,
    required String subjectId,
    required int gradeYear,
    required DateTime createdAt,
    required DateTime dueDate,
    required bool isActive,
    required int estimatedDuration,
    required List<String> tags,
    required int maxPoints,
    required int xpReward,
    required int coinReward,
    String? coverImage,
    required this.cards,
    required this.studyMode,
    required this.designSettings,
    this.timePerCard,
    this.allowSelfAssessment = true,
    this.showProgress = true,
    this.showStatistics = true,
    this.autoAdvance = false,
    this.flipAnimationStyle = 'flip',
  }) : super(
    id: const Uuid().v4(),
    title: title,
    description: description,
    type: 'flashcard_game',
    subjectId: subjectId,
    gradeYear: gradeYear,
    coinReward: coinReward,
    maxPoints: maxPoints,
    createdAt: createdAt,
    teacherId: teacherId,
    coverImage: coverImage,
    dueDate: dueDate,
    isActive: isActive,
    estimatedDuration: estimatedDuration,
    tags: tags,
    xpReward: xpReward,
  );

  @override
  Map<String, dynamic> toFirestore() {
    final baseMap = super.toFirestore();
    return {
      ...baseMap,
      'type': 'flashcard_game',
      'cards': cards.map((card) => card.toMap()).toList(),
      'studyMode': studyMode,
      'designSettings': designSettings,
      'timePerCard': timePerCard,
      'allowSelfAssessment': allowSelfAssessment,
      'showProgress': showProgress,
      'showStatistics': showStatistics,
      'autoAdvance': autoAdvance,
      'flipAnimationStyle': flipAnimationStyle,
    };
  }

  factory FlashcardGame.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FlashcardGame(
      title: data['title'] as String,
      description: data['description'] as String,
      coverImage: data['coverImage'] as String?,
      teacherId: data['teacherId'] as String,
      subjectId: data['subjectId'] as String,
      gradeYear: data['gradeYear'] as int,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isActive: data['isActive'] as bool,
      estimatedDuration: data['estimatedDuration'] as int,
      tags: List<String>.from(data['tags'] ?? []),
      maxPoints: data['maxPoints'] as int,
      xpReward: data['xpReward'] as int,
      coinReward: data['coinReward'] as int,
      cards: (data['cards'] as List).map((card) => Flashcard.fromMap(card)).toList(),
      studyMode: data['studyMode'] as String,
      designSettings: data['designSettings'] as Map<String, dynamic>,
      timePerCard: data['timePerCard'] as int?,
      allowSelfAssessment: data['allowSelfAssessment'] as bool? ?? true,
      showProgress: data['showProgress'] as bool? ?? true,
      showStatistics: data['showStatistics'] as bool? ?? true,
      autoAdvance: data['autoAdvance'] as bool? ?? false,
      flipAnimationStyle: data['flipAnimationStyle'] as String? ?? 'flip',
    );
  }
}

class QuizSection {
  final String id;
  final String title;
  final String? description;
  final List<QuizQuestion> questions;
  final int position;

  QuizSection({
    required this.id,
    required this.title,
    required this.questions,
    this.description,
    required this.position,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toMap()).toList(),
      'position': position,
    };
  }

  factory QuizSection.fromMap(Map<String, dynamic> map) {
    return QuizSection(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      questions: (map['questions'] as List).map((q) => QuizQuestion.fromMap(q)).toList(),
      position: map['position'] as int,
    );
  }
}

class GeneralQuizGame extends GameTemplate {
  final List<QuizSection> sections;
  final bool hasTimeLimit;
  final int? timeLimitMinutes;
  final String navigationMode; // 'sequential', 'free', 'no_backtracking'
  final String displayMode; // 'one_per_page', 'all_on_one', 'sectioned'
  final bool randomizeQuestions;
  final bool randomizeAnswers;
  final int passThreshold;
  final bool allowReview;
  final bool showExplanations;
  final bool autoSubmit;
  final bool allowFlagging;

  GeneralQuizGame({
    required String title,
    required String description,
    required String teacherId,
    required String subjectId,
    required int gradeYear,
    required DateTime createdAt,
    required DateTime dueDate,
    required bool isActive,
    required int estimatedDuration,
    required List<String> tags,
    required int maxPoints,
    required int xpReward,
    required int coinReward,
    String? coverImage,
    required this.sections,
    required this.hasTimeLimit,
    this.timeLimitMinutes,
    required this.navigationMode,
    required this.displayMode,
    required this.randomizeQuestions,
    required this.randomizeAnswers,
    required this.passThreshold,
    required this.allowReview,
    required this.showExplanations,
    required this.autoSubmit,
    required this.allowFlagging,
  }) : super(
    id: const Uuid().v4(),
    title: title,
    description: description,
    type: 'general_quiz',
    subjectId: subjectId,
    gradeYear: gradeYear,
    coinReward: coinReward,
    maxPoints: maxPoints,
    createdAt: createdAt,
    teacherId: teacherId,
    coverImage: coverImage,
    dueDate: dueDate,
    isActive: isActive,
    estimatedDuration: estimatedDuration,
    tags: tags,
    xpReward: xpReward,
  );

  @override
  Map<String, dynamic> toFirestore() {
    final baseMap = super.toFirestore();
    return {
      ...baseMap,
      'type': 'general_quiz',
      'sections': sections.map((section) => section.toMap()).toList(),
      'hasTimeLimit': hasTimeLimit,
      'timeLimitMinutes': timeLimitMinutes,
      'navigationMode': navigationMode,
      'displayMode': displayMode,
      'randomizeQuestions': randomizeQuestions,
      'randomizeAnswers': randomizeAnswers,
      'passThreshold': passThreshold,
      'allowReview': allowReview,
      'showExplanations': showExplanations,
      'autoSubmit': autoSubmit,
      'allowFlagging': allowFlagging,
    };
  }

  factory GeneralQuizGame.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GeneralQuizGame(
      title: data['title'] as String,
      description: data['description'] as String,
      coverImage: data['coverImage'] as String?,
      teacherId: data['teacherId'] as String,
      subjectId: data['subjectId'] as String,
      gradeYear: data['gradeYear'] as int,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isActive: data['isActive'] as bool,
      estimatedDuration: data['estimatedDuration'] as int,
      tags: List<String>.from(data['tags'] ?? []),
      maxPoints: data['maxPoints'] as int,
      xpReward: data['xpReward'] as int,
      coinReward: data['coinReward'] as int,
      sections: (data['sections'] as List).map((section) => QuizSection.fromMap(section)).toList(),
      hasTimeLimit: data['hasTimeLimit'] as bool,
      timeLimitMinutes: data['timeLimitMinutes'] as int?,
      navigationMode: data['navigationMode'] as String,
      displayMode: data['displayMode'] as String,
      randomizeQuestions: data['randomizeQuestions'] as bool,
      randomizeAnswers: data['randomizeAnswers'] as bool,
      passThreshold: data['passThreshold'] as int,
      allowReview: data['allowReview'] as bool,
      showExplanations: data['showExplanations'] as bool,
      autoSubmit: data['autoSubmit'] as bool,
      allowFlagging: data['allowFlagging'] as bool,
    );
  }
}