import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'question.dart';

part 'game.freezed.dart';
part 'game.g.dart';

/// All eight templates, exactly as before.
enum GameTemplate {
  trueFalse,
  dragDrop,
  matching,
  memory,
  flashCard,
  fillBlank,
  hangman,
  crossword,
}

@freezed
abstract class Game with _$Game {
  const factory Game({
    required String id,
    required String ownerUid,
    
    @JsonKey(fromJson: _templateFromJson, toJson: _templateToJson)
    required GameTemplate template,
    
    required String title,
    required List<int> gradeYears,
    required String subject,

    /// We ignore this in JSON so the generator doesn't fail on the union type.
    @Default(<GameQuestion>[])
    @JsonKey(ignore: true)
    List<GameQuestion> questions,

    @Default(false) bool isTutorial,
    
    @JsonKey(fromJson: _tsFromJson, toJson: _tsToJson)
    required DateTime createdAt,
  }) = _Game;

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
}

DateTime _tsFromJson(Timestamp t) => t.toDate();
Timestamp _tsToJson(DateTime dt) => Timestamp.fromDate(dt);

GameTemplate _templateFromJson(String value) => GameTemplate.values.firstWhere(
      (e) => e.toString() == 'GameTemplate.$value',
      orElse: () => GameTemplate.trueFalse,
    );
String _templateToJson(GameTemplate template) => template.toString().split('.').last;