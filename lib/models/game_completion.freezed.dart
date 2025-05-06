// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_completion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameCompletion {
  String get id;
  String get gameId;
  String get uid;
  int get score;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  DateTime get completedAt;

  /// Create a copy of GameCompletion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GameCompletionCopyWith<GameCompletion> get copyWith =>
      _$GameCompletionCopyWithImpl<GameCompletion>(
          this as GameCompletion, _$identity);

  /// Serializes this GameCompletion to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GameCompletion &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, gameId, uid, score, completedAt);

  @override
  String toString() {
    return 'GameCompletion(id: $id, gameId: $gameId, uid: $uid, score: $score, completedAt: $completedAt)';
  }
}

/// @nodoc
abstract mixin class $GameCompletionCopyWith<$Res> {
  factory $GameCompletionCopyWith(
          GameCompletion value, $Res Function(GameCompletion) _then) =
      _$GameCompletionCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String gameId,
      String uid,
      int score,
      @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
      DateTime completedAt});
}

/// @nodoc
class _$GameCompletionCopyWithImpl<$Res>
    implements $GameCompletionCopyWith<$Res> {
  _$GameCompletionCopyWithImpl(this._self, this._then);

  final GameCompletion _self;
  final $Res Function(GameCompletion) _then;

  /// Create a copy of GameCompletion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gameId = null,
    Object? uid = null,
    Object? score = null,
    Object? completedAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      gameId: null == gameId
          ? _self.gameId
          : gameId // ignore: cast_nullable_to_non_nullable
              as String,
      uid: null == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _self.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      completedAt: null == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _GameCompletion implements GameCompletion {
  const _GameCompletion(
      {required this.id,
      required this.gameId,
      required this.uid,
      required this.score,
      @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
      required this.completedAt});
  factory _GameCompletion.fromJson(Map<String, dynamic> json) =>
      _$GameCompletionFromJson(json);

  @override
  final String id;
  @override
  final String gameId;
  @override
  final String uid;
  @override
  final int score;
  @override
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime completedAt;

  /// Create a copy of GameCompletion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GameCompletionCopyWith<_GameCompletion> get copyWith =>
      __$GameCompletionCopyWithImpl<_GameCompletion>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GameCompletionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GameCompletion &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, gameId, uid, score, completedAt);

  @override
  String toString() {
    return 'GameCompletion(id: $id, gameId: $gameId, uid: $uid, score: $score, completedAt: $completedAt)';
  }
}

/// @nodoc
abstract mixin class _$GameCompletionCopyWith<$Res>
    implements $GameCompletionCopyWith<$Res> {
  factory _$GameCompletionCopyWith(
          _GameCompletion value, $Res Function(_GameCompletion) _then) =
      __$GameCompletionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String gameId,
      String uid,
      int score,
      @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
      DateTime completedAt});
}

/// @nodoc
class __$GameCompletionCopyWithImpl<$Res>
    implements _$GameCompletionCopyWith<$Res> {
  __$GameCompletionCopyWithImpl(this._self, this._then);

  final _GameCompletion _self;
  final $Res Function(_GameCompletion) _then;

  /// Create a copy of GameCompletion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? gameId = null,
    Object? uid = null,
    Object? score = null,
    Object? completedAt = null,
  }) {
    return _then(_GameCompletion(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      gameId: null == gameId
          ? _self.gameId
          : gameId // ignore: cast_nullable_to_non_nullable
              as String,
      uid: null == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _self.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      completedAt: null == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
