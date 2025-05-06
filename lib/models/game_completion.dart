import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'game_completion.freezed.dart';
part 'game_completion.g.dart';

@freezed
abstract class GameCompletion with _$GameCompletion {
  const factory GameCompletion({
    required String id,
    required String gameId,
    required String uid,
    required int score,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime completedAt,
  }) = _GameCompletion;

  factory GameCompletion.fromJson(Map<String, dynamic> json) =>
      _$GameCompletionFromJson(json);

  factory GameCompletion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return GameCompletion.fromJson({
      'id': doc.id,
      'gameId': doc.reference.parent.parent!.id,
      ...?data,
    });
  }
}

DateTime _timestampFromJson(Timestamp timestamp) => timestamp.toDate();
Timestamp _timestampToJson(DateTime dateTime) => Timestamp.fromDate(dateTime);