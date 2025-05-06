// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Game {
  String get id;
  String get ownerUid;
  @JsonKey(fromJson: _templateFromJson, toJson: _templateToJson)
  GameTemplate get template;
  String get title;
  List<int> get gradeYears;
  String get subject;

  /// We ignore this in JSON so the generator doesn't fail on the union type.
  @JsonKey(ignore: true)
  List<GameQuestion> get questions;
  bool get isTutorial;
  @JsonKey(fromJson: _tsFromJson, toJson: _tsToJson)
  DateTime get createdAt;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GameCopyWith<Game> get copyWith =>
      _$GameCopyWithImpl<Game>(this as Game, _$identity);

  /// Serializes this Game to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Game &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ownerUid, ownerUid) ||
                other.ownerUid == ownerUid) &&
            (identical(other.template, template) ||
                other.template == template) &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality()
                .equals(other.gradeYears, gradeYears) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            const DeepCollectionEquality().equals(other.questions, questions) &&
            (identical(other.isTutorial, isTutorial) ||
                other.isTutorial == isTutorial) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      ownerUid,
      template,
      title,
      const DeepCollectionEquality().hash(gradeYears),
      subject,
      const DeepCollectionEquality().hash(questions),
      isTutorial,
      createdAt);

  @override
  String toString() {
    return 'Game(id: $id, ownerUid: $ownerUid, template: $template, title: $title, gradeYears: $gradeYears, subject: $subject, questions: $questions, isTutorial: $isTutorial, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $GameCopyWith<$Res> {
  factory $GameCopyWith(Game value, $Res Function(Game) _then) =
      _$GameCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String ownerUid,
      @JsonKey(fromJson: _templateFromJson, toJson: _templateToJson)
      GameTemplate template,
      String title,
      List<int> gradeYears,
      String subject,
      @JsonKey(ignore: true) List<GameQuestion> questions,
      bool isTutorial,
      @JsonKey(fromJson: _tsFromJson, toJson: _tsToJson) DateTime createdAt});
}

/// @nodoc
class _$GameCopyWithImpl<$Res> implements $GameCopyWith<$Res> {
  _$GameCopyWithImpl(this._self, this._then);

  final Game _self;
  final $Res Function(Game) _then;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerUid = null,
    Object? template = null,
    Object? title = null,
    Object? gradeYears = null,
    Object? subject = null,
    Object? questions = null,
    Object? isTutorial = null,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ownerUid: null == ownerUid
          ? _self.ownerUid
          : ownerUid // ignore: cast_nullable_to_non_nullable
              as String,
      template: null == template
          ? _self.template
          : template // ignore: cast_nullable_to_non_nullable
              as GameTemplate,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      gradeYears: null == gradeYears
          ? _self.gradeYears
          : gradeYears // ignore: cast_nullable_to_non_nullable
              as List<int>,
      subject: null == subject
          ? _self.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      questions: null == questions
          ? _self.questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<GameQuestion>,
      isTutorial: null == isTutorial
          ? _self.isTutorial
          : isTutorial // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Game implements Game {
  const _Game(
      {required this.id,
      required this.ownerUid,
      @JsonKey(fromJson: _templateFromJson, toJson: _templateToJson)
      required this.template,
      required this.title,
      required final List<int> gradeYears,
      required this.subject,
      @JsonKey(ignore: true)
      final List<GameQuestion> questions = const <GameQuestion>[],
      this.isTutorial = false,
      @JsonKey(fromJson: _tsFromJson, toJson: _tsToJson)
      required this.createdAt})
      : _gradeYears = gradeYears,
        _questions = questions;
  factory _Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

  @override
  final String id;
  @override
  final String ownerUid;
  @override
  @JsonKey(fromJson: _templateFromJson, toJson: _templateToJson)
  final GameTemplate template;
  @override
  final String title;
  final List<int> _gradeYears;
  @override
  List<int> get gradeYears {
    if (_gradeYears is EqualUnmodifiableListView) return _gradeYears;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gradeYears);
  }

  @override
  final String subject;

  /// We ignore this in JSON so the generator doesn't fail on the union type.
  final List<GameQuestion> _questions;

  /// We ignore this in JSON so the generator doesn't fail on the union type.
  @override
  @JsonKey(ignore: true)
  List<GameQuestion> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  @override
  @JsonKey()
  final bool isTutorial;
  @override
  @JsonKey(fromJson: _tsFromJson, toJson: _tsToJson)
  final DateTime createdAt;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GameCopyWith<_Game> get copyWith =>
      __$GameCopyWithImpl<_Game>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GameToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Game &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ownerUid, ownerUid) ||
                other.ownerUid == ownerUid) &&
            (identical(other.template, template) ||
                other.template == template) &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality()
                .equals(other._gradeYears, _gradeYears) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            const DeepCollectionEquality()
                .equals(other._questions, _questions) &&
            (identical(other.isTutorial, isTutorial) ||
                other.isTutorial == isTutorial) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      ownerUid,
      template,
      title,
      const DeepCollectionEquality().hash(_gradeYears),
      subject,
      const DeepCollectionEquality().hash(_questions),
      isTutorial,
      createdAt);

  @override
  String toString() {
    return 'Game(id: $id, ownerUid: $ownerUid, template: $template, title: $title, gradeYears: $gradeYears, subject: $subject, questions: $questions, isTutorial: $isTutorial, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$GameCopyWith<$Res> implements $GameCopyWith<$Res> {
  factory _$GameCopyWith(_Game value, $Res Function(_Game) _then) =
      __$GameCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String ownerUid,
      @JsonKey(fromJson: _templateFromJson, toJson: _templateToJson)
      GameTemplate template,
      String title,
      List<int> gradeYears,
      String subject,
      @JsonKey(ignore: true) List<GameQuestion> questions,
      bool isTutorial,
      @JsonKey(fromJson: _tsFromJson, toJson: _tsToJson) DateTime createdAt});
}

/// @nodoc
class __$GameCopyWithImpl<$Res> implements _$GameCopyWith<$Res> {
  __$GameCopyWithImpl(this._self, this._then);

  final _Game _self;
  final $Res Function(_Game) _then;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? ownerUid = null,
    Object? template = null,
    Object? title = null,
    Object? gradeYears = null,
    Object? subject = null,
    Object? questions = null,
    Object? isTutorial = null,
    Object? createdAt = null,
  }) {
    return _then(_Game(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ownerUid: null == ownerUid
          ? _self.ownerUid
          : ownerUid // ignore: cast_nullable_to_non_nullable
              as String,
      template: null == template
          ? _self.template
          : template // ignore: cast_nullable_to_non_nullable
              as GameTemplate,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      gradeYears: null == gradeYears
          ? _self._gradeYears
          : gradeYears // ignore: cast_nullable_to_non_nullable
              as List<int>,
      subject: null == subject
          ? _self.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      questions: null == questions
          ? _self._questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<GameQuestion>,
      isTutorial: null == isTutorial
          ? _self.isTutorial
          : isTutorial // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
