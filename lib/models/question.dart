import 'package:freezed_annotation/freezed_annotation.dart';
part 'question.freezed.dart';
part 'question.g.dart';

@freezed
abstract class Question with _$Question {
  const factory Question.trueFalse({
    required String text,
    required bool correctAnswer,
    String? explanation,
  }) = TrueFalseQuestion;

  const factory Question.dragDrop({
    required List<String> items,
    required List<String> targets,
    required List<int> correctMapping,
  }) = DragDropQuestion;

  const factory Question.matching({
    required List<String> leftItems,
    required List<String> rightItems,
    required List<int> correctMatches,
  }) = MatchingQuestion;

  const factory Question.memory({
    required String front,
    required String back,
  }) = MemoryQuestion;

  const factory Question.flashCard({
    required String front,
    required String back,
  }) = FlashCardQuestion;

  const factory Question.fillBlank({
    required String textWithBlanks,
    required List<String> blanks,
  }) = FillBlankQuestion;

  const factory Question.hangman({
    required String word,
    required String hint,
  }) = HangmanQuestion;

  const factory Question.crossword({
    required List<List<String?>> grid,
    required Map<int, String> acrossClues,
    required Map<int, String> downClues,
  }) = CrosswordQuestion;

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
}

@freezed
abstract class GameQuestion with _$GameQuestion {
  const factory GameQuestion({
    required String id,
    required Question question,
    @Default(1) int points,
  }) = _GameQuestion;

  factory GameQuestion.fromJson(Map<String, dynamic> json) =>
    _$GameQuestionFromJson(json);
}