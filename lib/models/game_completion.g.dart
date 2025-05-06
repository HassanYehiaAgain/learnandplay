// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_completion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameCompletion _$GameCompletionFromJson(Map<String, dynamic> json) =>
    _GameCompletion(
      id: json['id'] as String,
      gameId: json['gameId'] as String,
      uid: json['uid'] as String,
      score: (json['score'] as num).toInt(),
      completedAt: _timestampFromJson(json['completedAt'] as Timestamp),
    );

Map<String, dynamic> _$GameCompletionToJson(_GameCompletion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gameId': instance.gameId,
      'uid': instance.uid,
      'score': instance.score,
      'completedAt': _timestampToJson(instance.completedAt),
    };
