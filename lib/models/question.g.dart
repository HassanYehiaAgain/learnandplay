// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrueFalseQuestion _$TrueFalseQuestionFromJson(Map<String, dynamic> json) =>
    TrueFalseQuestion(
      text: json['text'] as String,
      correctAnswer: json['correctAnswer'] as bool,
      explanation: json['explanation'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$TrueFalseQuestionToJson(TrueFalseQuestion instance) =>
    <String, dynamic>{
      'text': instance.text,
      'correctAnswer': instance.correctAnswer,
      if (instance.explanation case final value?) 'explanation': value,
      'runtimeType': instance.$type,
    };

DragDropQuestion _$DragDropQuestionFromJson(Map<String, dynamic> json) =>
    DragDropQuestion(
      items: (json['items'] as List<dynamic>).map((e) => e as String).toList(),
      targets:
          (json['targets'] as List<dynamic>).map((e) => e as String).toList(),
      correctMapping: (json['correctMapping'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$DragDropQuestionToJson(DragDropQuestion instance) =>
    <String, dynamic>{
      'items': instance.items,
      'targets': instance.targets,
      'correctMapping': instance.correctMapping,
      'runtimeType': instance.$type,
    };

MatchingQuestion _$MatchingQuestionFromJson(Map<String, dynamic> json) =>
    MatchingQuestion(
      leftItems:
          (json['leftItems'] as List<dynamic>).map((e) => e as String).toList(),
      rightItems: (json['rightItems'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctMatches: (json['correctMatches'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$MatchingQuestionToJson(MatchingQuestion instance) =>
    <String, dynamic>{
      'leftItems': instance.leftItems,
      'rightItems': instance.rightItems,
      'correctMatches': instance.correctMatches,
      'runtimeType': instance.$type,
    };

MemoryQuestion _$MemoryQuestionFromJson(Map<String, dynamic> json) =>
    MemoryQuestion(
      front: json['front'] as String,
      back: json['back'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$MemoryQuestionToJson(MemoryQuestion instance) =>
    <String, dynamic>{
      'front': instance.front,
      'back': instance.back,
      'runtimeType': instance.$type,
    };

FlashCardQuestion _$FlashCardQuestionFromJson(Map<String, dynamic> json) =>
    FlashCardQuestion(
      front: json['front'] as String,
      back: json['back'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$FlashCardQuestionToJson(FlashCardQuestion instance) =>
    <String, dynamic>{
      'front': instance.front,
      'back': instance.back,
      'runtimeType': instance.$type,
    };

FillBlankQuestion _$FillBlankQuestionFromJson(Map<String, dynamic> json) =>
    FillBlankQuestion(
      textWithBlanks: json['textWithBlanks'] as String,
      blanks:
          (json['blanks'] as List<dynamic>).map((e) => e as String).toList(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$FillBlankQuestionToJson(FillBlankQuestion instance) =>
    <String, dynamic>{
      'textWithBlanks': instance.textWithBlanks,
      'blanks': instance.blanks,
      'runtimeType': instance.$type,
    };

HangmanQuestion _$HangmanQuestionFromJson(Map<String, dynamic> json) =>
    HangmanQuestion(
      word: json['word'] as String,
      hint: json['hint'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$HangmanQuestionToJson(HangmanQuestion instance) =>
    <String, dynamic>{
      'word': instance.word,
      'hint': instance.hint,
      'runtimeType': instance.$type,
    };

CrosswordQuestion _$CrosswordQuestionFromJson(Map<String, dynamic> json) =>
    CrosswordQuestion(
      grid: (json['grid'] as List<dynamic>)
          .map((e) => (e as List<dynamic>).map((e) => e as String?).toList())
          .toList(),
      acrossClues: (json['acrossClues'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), e as String),
      ),
      downClues: (json['downClues'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), e as String),
      ),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$CrosswordQuestionToJson(CrosswordQuestion instance) =>
    <String, dynamic>{
      'grid': instance.grid,
      'acrossClues':
          instance.acrossClues.map((k, e) => MapEntry(k.toString(), e)),
      'downClues': instance.downClues.map((k, e) => MapEntry(k.toString(), e)),
      'runtimeType': instance.$type,
    };

_GameQuestion _$GameQuestionFromJson(Map<String, dynamic> json) =>
    _GameQuestion(
      id: json['id'] as String,
      question: Question.fromJson(json['question'] as Map<String, dynamic>),
      points: (json['points'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$GameQuestionToJson(_GameQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question.toJson(),
      'points': instance.points,
    };
