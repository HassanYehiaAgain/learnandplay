// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'question.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
Question _$QuestionFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'trueFalse':
      return TrueFalseQuestion.fromJson(json);
    case 'dragDrop':
      return DragDropQuestion.fromJson(json);
    case 'matching':
      return MatchingQuestion.fromJson(json);
    case 'memory':
      return MemoryQuestion.fromJson(json);
    case 'flashCard':
      return FlashCardQuestion.fromJson(json);
    case 'fillBlank':
      return FillBlankQuestion.fromJson(json);
    case 'hangman':
      return HangmanQuestion.fromJson(json);
    case 'crossword':
      return CrosswordQuestion.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'Question',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$Question {
  /// Serializes this Question to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is Question);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'Question()';
  }
}

/// @nodoc
class $QuestionCopyWith<$Res> {
  $QuestionCopyWith(Question _, $Res Function(Question) __);
}

/// @nodoc
@JsonSerializable()
class TrueFalseQuestion implements Question {
  const TrueFalseQuestion(
      {required this.text,
      required this.correctAnswer,
      this.explanation,
      final String? $type})
      : $type = $type ?? 'trueFalse';
  factory TrueFalseQuestion.fromJson(Map<String, dynamic> json) =>
      _$TrueFalseQuestionFromJson(json);

  final String text;
  final bool correctAnswer;
  final String? explanation;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TrueFalseQuestionCopyWith<TrueFalseQuestion> get copyWith =>
      _$TrueFalseQuestionCopyWithImpl<TrueFalseQuestion>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TrueFalseQuestionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TrueFalseQuestion &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.correctAnswer, correctAnswer) ||
                other.correctAnswer == correctAnswer) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, text, correctAnswer, explanation);

  @override
  String toString() {
    return 'Question.trueFalse(text: $text, correctAnswer: $correctAnswer, explanation: $explanation)';
  }
}

/// @nodoc
abstract mixin class $TrueFalseQuestionCopyWith<$Res>
    implements $QuestionCopyWith<$Res> {
  factory $TrueFalseQuestionCopyWith(
          TrueFalseQuestion value, $Res Function(TrueFalseQuestion) _then) =
      _$TrueFalseQuestionCopyWithImpl;
  @useResult
  $Res call({String text, bool correctAnswer, String? explanation});
}

/// @nodoc
class _$TrueFalseQuestionCopyWithImpl<$Res>
    implements $TrueFalseQuestionCopyWith<$Res> {
  _$TrueFalseQuestionCopyWithImpl(this._self, this._then);

  final TrueFalseQuestion _self;
  final $Res Function(TrueFalseQuestion) _then;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? text = null,
    Object? correctAnswer = null,
    Object? explanation = freezed,
  }) {
    return _then(TrueFalseQuestion(
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      correctAnswer: null == correctAnswer
          ? _self.correctAnswer
          : correctAnswer // ignore: cast_nullable_to_non_nullable
              as bool,
      explanation: freezed == explanation
          ? _self.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class DragDropQuestion implements Question {
  const DragDropQuestion(
      {required final List<String> items,
      required final List<String> targets,
      required final List<int> correctMapping,
      final String? $type})
      : _items = items,
        _targets = targets,
        _correctMapping = correctMapping,
        $type = $type ?? 'dragDrop';
  factory DragDropQuestion.fromJson(Map<String, dynamic> json) =>
      _$DragDropQuestionFromJson(json);

  final List<String> _items;
  List<String> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  final List<String> _targets;
  List<String> get targets {
    if (_targets is EqualUnmodifiableListView) return _targets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_targets);
  }

  final List<int> _correctMapping;
  List<int> get correctMapping {
    if (_correctMapping is EqualUnmodifiableListView) return _correctMapping;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_correctMapping);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DragDropQuestionCopyWith<DragDropQuestion> get copyWith =>
      _$DragDropQuestionCopyWithImpl<DragDropQuestion>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DragDropQuestionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DragDropQuestion &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            const DeepCollectionEquality().equals(other._targets, _targets) &&
            const DeepCollectionEquality()
                .equals(other._correctMapping, _correctMapping));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      const DeepCollectionEquality().hash(_targets),
      const DeepCollectionEquality().hash(_correctMapping));

  @override
  String toString() {
    return 'Question.dragDrop(items: $items, targets: $targets, correctMapping: $correctMapping)';
  }
}

/// @nodoc
abstract mixin class $DragDropQuestionCopyWith<$Res>
    implements $QuestionCopyWith<$Res> {
  factory $DragDropQuestionCopyWith(
          DragDropQuestion value, $Res Function(DragDropQuestion) _then) =
      _$DragDropQuestionCopyWithImpl;
  @useResult
  $Res call(
      {List<String> items, List<String> targets, List<int> correctMapping});
}

/// @nodoc
class _$DragDropQuestionCopyWithImpl<$Res>
    implements $DragDropQuestionCopyWith<$Res> {
  _$DragDropQuestionCopyWithImpl(this._self, this._then);

  final DragDropQuestion _self;
  final $Res Function(DragDropQuestion) _then;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? items = null,
    Object? targets = null,
    Object? correctMapping = null,
  }) {
    return _then(DragDropQuestion(
      items: null == items
          ? _self._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<String>,
      targets: null == targets
          ? _self._targets
          : targets // ignore: cast_nullable_to_non_nullable
              as List<String>,
      correctMapping: null == correctMapping
          ? _self._correctMapping
          : correctMapping // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class MatchingQuestion implements Question {
  const MatchingQuestion(
      {required final List<String> leftItems,
      required final List<String> rightItems,
      required final List<int> correctMatches,
      final String? $type})
      : _leftItems = leftItems,
        _rightItems = rightItems,
        _correctMatches = correctMatches,
        $type = $type ?? 'matching';
  factory MatchingQuestion.fromJson(Map<String, dynamic> json) =>
      _$MatchingQuestionFromJson(json);

  final List<String> _leftItems;
  List<String> get leftItems {
    if (_leftItems is EqualUnmodifiableListView) return _leftItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_leftItems);
  }

  final List<String> _rightItems;
  List<String> get rightItems {
    if (_rightItems is EqualUnmodifiableListView) return _rightItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rightItems);
  }

  final List<int> _correctMatches;
  List<int> get correctMatches {
    if (_correctMatches is EqualUnmodifiableListView) return _correctMatches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_correctMatches);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MatchingQuestionCopyWith<MatchingQuestion> get copyWith =>
      _$MatchingQuestionCopyWithImpl<MatchingQuestion>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MatchingQuestionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MatchingQuestion &&
            const DeepCollectionEquality()
                .equals(other._leftItems, _leftItems) &&
            const DeepCollectionEquality()
                .equals(other._rightItems, _rightItems) &&
            const DeepCollectionEquality()
                .equals(other._correctMatches, _correctMatches));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_leftItems),
      const DeepCollectionEquality().hash(_rightItems),
      const DeepCollectionEquality().hash(_correctMatches));

  @override
  String toString() {
    return 'Question.matching(leftItems: $leftItems, rightItems: $rightItems, correctMatches: $correctMatches)';
  }
}

/// @nodoc
abstract mixin class $MatchingQuestionCopyWith<$Res>
    implements $QuestionCopyWith<$Res> {
  factory $MatchingQuestionCopyWith(
          MatchingQuestion value, $Res Function(MatchingQuestion) _then) =
      _$MatchingQuestionCopyWithImpl;
  @useResult
  $Res call(
      {List<String> leftItems,
      List<String> rightItems,
      List<int> correctMatches});
}

/// @nodoc
class _$MatchingQuestionCopyWithImpl<$Res>
    implements $MatchingQuestionCopyWith<$Res> {
  _$MatchingQuestionCopyWithImpl(this._self, this._then);

  final MatchingQuestion _self;
  final $Res Function(MatchingQuestion) _then;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? leftItems = null,
    Object? rightItems = null,
    Object? correctMatches = null,
  }) {
    return _then(MatchingQuestion(
      leftItems: null == leftItems
          ? _self._leftItems
          : leftItems // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rightItems: null == rightItems
          ? _self._rightItems
          : rightItems // ignore: cast_nullable_to_non_nullable
              as List<String>,
      correctMatches: null == correctMatches
          ? _self._correctMatches
          : correctMatches // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class MemoryQuestion implements Question {
  const MemoryQuestion(
      {required this.front, required this.back, final String? $type})
      : $type = $type ?? 'memory';
  factory MemoryQuestion.fromJson(Map<String, dynamic> json) =>
      _$MemoryQuestionFromJson(json);

  final String front;
  final String back;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MemoryQuestionCopyWith<MemoryQuestion> get copyWith =>
      _$MemoryQuestionCopyWithImpl<MemoryQuestion>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MemoryQuestionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MemoryQuestion &&
            (identical(other.front, front) || other.front == front) &&
            (identical(other.back, back) || other.back == back));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, front, back);

  @override
  String toString() {
    return 'Question.memory(front: $front, back: $back)';
  }
}

/// @nodoc
abstract mixin class $MemoryQuestionCopyWith<$Res>
    implements $QuestionCopyWith<$Res> {
  factory $MemoryQuestionCopyWith(
          MemoryQuestion value, $Res Function(MemoryQuestion) _then) =
      _$MemoryQuestionCopyWithImpl;
  @useResult
  $Res call({String front, String back});
}

/// @nodoc
class _$MemoryQuestionCopyWithImpl<$Res>
    implements $MemoryQuestionCopyWith<$Res> {
  _$MemoryQuestionCopyWithImpl(this._self, this._then);

  final MemoryQuestion _self;
  final $Res Function(MemoryQuestion) _then;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? front = null,
    Object? back = null,
  }) {
    return _then(MemoryQuestion(
      front: null == front
          ? _self.front
          : front // ignore: cast_nullable_to_non_nullable
              as String,
      back: null == back
          ? _self.back
          : back // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class FlashCardQuestion implements Question {
  const FlashCardQuestion(
      {required this.front, required this.back, final String? $type})
      : $type = $type ?? 'flashCard';
  factory FlashCardQuestion.fromJson(Map<String, dynamic> json) =>
      _$FlashCardQuestionFromJson(json);

  final String front;
  final String back;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FlashCardQuestionCopyWith<FlashCardQuestion> get copyWith =>
      _$FlashCardQuestionCopyWithImpl<FlashCardQuestion>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$FlashCardQuestionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FlashCardQuestion &&
            (identical(other.front, front) || other.front == front) &&
            (identical(other.back, back) || other.back == back));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, front, back);

  @override
  String toString() {
    return 'Question.flashCard(front: $front, back: $back)';
  }
}

/// @nodoc
abstract mixin class $FlashCardQuestionCopyWith<$Res>
    implements $QuestionCopyWith<$Res> {
  factory $FlashCardQuestionCopyWith(
          FlashCardQuestion value, $Res Function(FlashCardQuestion) _then) =
      _$FlashCardQuestionCopyWithImpl;
  @useResult
  $Res call({String front, String back});
}

/// @nodoc
class _$FlashCardQuestionCopyWithImpl<$Res>
    implements $FlashCardQuestionCopyWith<$Res> {
  _$FlashCardQuestionCopyWithImpl(this._self, this._then);

  final FlashCardQuestion _self;
  final $Res Function(FlashCardQuestion) _then;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? front = null,
    Object? back = null,
  }) {
    return _then(FlashCardQuestion(
      front: null == front
          ? _self.front
          : front // ignore: cast_nullable_to_non_nullable
              as String,
      back: null == back
          ? _self.back
          : back // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class FillBlankQuestion implements Question {
  const FillBlankQuestion(
      {required this.textWithBlanks,
      required final List<String> blanks,
      final String? $type})
      : _blanks = blanks,
        $type = $type ?? 'fillBlank';
  factory FillBlankQuestion.fromJson(Map<String, dynamic> json) =>
      _$FillBlankQuestionFromJson(json);

  final String textWithBlanks;
  final List<String> _blanks;
  List<String> get blanks {
    if (_blanks is EqualUnmodifiableListView) return _blanks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blanks);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FillBlankQuestionCopyWith<FillBlankQuestion> get copyWith =>
      _$FillBlankQuestionCopyWithImpl<FillBlankQuestion>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$FillBlankQuestionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FillBlankQuestion &&
            (identical(other.textWithBlanks, textWithBlanks) ||
                other.textWithBlanks == textWithBlanks) &&
            const DeepCollectionEquality().equals(other._blanks, _blanks));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, textWithBlanks,
      const DeepCollectionEquality().hash(_blanks));

  @override
  String toString() {
    return 'Question.fillBlank(textWithBlanks: $textWithBlanks, blanks: $blanks)';
  }
}

/// @nodoc
abstract mixin class $FillBlankQuestionCopyWith<$Res>
    implements $QuestionCopyWith<$Res> {
  factory $FillBlankQuestionCopyWith(
          FillBlankQuestion value, $Res Function(FillBlankQuestion) _then) =
      _$FillBlankQuestionCopyWithImpl;
  @useResult
  $Res call({String textWithBlanks, List<String> blanks});
}

/// @nodoc
class _$FillBlankQuestionCopyWithImpl<$Res>
    implements $FillBlankQuestionCopyWith<$Res> {
  _$FillBlankQuestionCopyWithImpl(this._self, this._then);

  final FillBlankQuestion _self;
  final $Res Function(FillBlankQuestion) _then;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? textWithBlanks = null,
    Object? blanks = null,
  }) {
    return _then(FillBlankQuestion(
      textWithBlanks: null == textWithBlanks
          ? _self.textWithBlanks
          : textWithBlanks // ignore: cast_nullable_to_non_nullable
              as String,
      blanks: null == blanks
          ? _self._blanks
          : blanks // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class HangmanQuestion implements Question {
  const HangmanQuestion(
      {required this.word, required this.hint, final String? $type})
      : $type = $type ?? 'hangman';
  factory HangmanQuestion.fromJson(Map<String, dynamic> json) =>
      _$HangmanQuestionFromJson(json);

  final String word;
  final String hint;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HangmanQuestionCopyWith<HangmanQuestion> get copyWith =>
      _$HangmanQuestionCopyWithImpl<HangmanQuestion>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$HangmanQuestionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HangmanQuestion &&
            (identical(other.word, word) || other.word == word) &&
            (identical(other.hint, hint) || other.hint == hint));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, word, hint);

  @override
  String toString() {
    return 'Question.hangman(word: $word, hint: $hint)';
  }
}

/// @nodoc
abstract mixin class $HangmanQuestionCopyWith<$Res>
    implements $QuestionCopyWith<$Res> {
  factory $HangmanQuestionCopyWith(
          HangmanQuestion value, $Res Function(HangmanQuestion) _then) =
      _$HangmanQuestionCopyWithImpl;
  @useResult
  $Res call({String word, String hint});
}

/// @nodoc
class _$HangmanQuestionCopyWithImpl<$Res>
    implements $HangmanQuestionCopyWith<$Res> {
  _$HangmanQuestionCopyWithImpl(this._self, this._then);

  final HangmanQuestion _self;
  final $Res Function(HangmanQuestion) _then;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? word = null,
    Object? hint = null,
  }) {
    return _then(HangmanQuestion(
      word: null == word
          ? _self.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      hint: null == hint
          ? _self.hint
          : hint // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class CrosswordQuestion implements Question {
  const CrosswordQuestion(
      {required final List<List<String?>> grid,
      required final Map<int, String> acrossClues,
      required final Map<int, String> downClues,
      final String? $type})
      : _grid = grid,
        _acrossClues = acrossClues,
        _downClues = downClues,
        $type = $type ?? 'crossword';
  factory CrosswordQuestion.fromJson(Map<String, dynamic> json) =>
      _$CrosswordQuestionFromJson(json);

  final List<List<String?>> _grid;
  List<List<String?>> get grid {
    if (_grid is EqualUnmodifiableListView) return _grid;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_grid);
  }

  final Map<int, String> _acrossClues;
  Map<int, String> get acrossClues {
    if (_acrossClues is EqualUnmodifiableMapView) return _acrossClues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_acrossClues);
  }

  final Map<int, String> _downClues;
  Map<int, String> get downClues {
    if (_downClues is EqualUnmodifiableMapView) return _downClues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_downClues);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CrosswordQuestionCopyWith<CrosswordQuestion> get copyWith =>
      _$CrosswordQuestionCopyWithImpl<CrosswordQuestion>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CrosswordQuestionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CrosswordQuestion &&
            const DeepCollectionEquality().equals(other._grid, _grid) &&
            const DeepCollectionEquality()
                .equals(other._acrossClues, _acrossClues) &&
            const DeepCollectionEquality()
                .equals(other._downClues, _downClues));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_grid),
      const DeepCollectionEquality().hash(_acrossClues),
      const DeepCollectionEquality().hash(_downClues));

  @override
  String toString() {
    return 'Question.crossword(grid: $grid, acrossClues: $acrossClues, downClues: $downClues)';
  }
}

/// @nodoc
abstract mixin class $CrosswordQuestionCopyWith<$Res>
    implements $QuestionCopyWith<$Res> {
  factory $CrosswordQuestionCopyWith(
          CrosswordQuestion value, $Res Function(CrosswordQuestion) _then) =
      _$CrosswordQuestionCopyWithImpl;
  @useResult
  $Res call(
      {List<List<String?>> grid,
      Map<int, String> acrossClues,
      Map<int, String> downClues});
}

/// @nodoc
class _$CrosswordQuestionCopyWithImpl<$Res>
    implements $CrosswordQuestionCopyWith<$Res> {
  _$CrosswordQuestionCopyWithImpl(this._self, this._then);

  final CrosswordQuestion _self;
  final $Res Function(CrosswordQuestion) _then;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? grid = null,
    Object? acrossClues = null,
    Object? downClues = null,
  }) {
    return _then(CrosswordQuestion(
      grid: null == grid
          ? _self._grid
          : grid // ignore: cast_nullable_to_non_nullable
              as List<List<String?>>,
      acrossClues: null == acrossClues
          ? _self._acrossClues
          : acrossClues // ignore: cast_nullable_to_non_nullable
              as Map<int, String>,
      downClues: null == downClues
          ? _self._downClues
          : downClues // ignore: cast_nullable_to_non_nullable
              as Map<int, String>,
    ));
  }
}

/// @nodoc
mixin _$GameQuestion {
  String get id;
  Question get question;
  int get points;

  /// Create a copy of GameQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GameQuestionCopyWith<GameQuestion> get copyWith =>
      _$GameQuestionCopyWithImpl<GameQuestion>(
          this as GameQuestion, _$identity);

  /// Serializes this GameQuestion to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GameQuestion &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.points, points) || other.points == points));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, question, points);

  @override
  String toString() {
    return 'GameQuestion(id: $id, question: $question, points: $points)';
  }
}

/// @nodoc
abstract mixin class $GameQuestionCopyWith<$Res> {
  factory $GameQuestionCopyWith(
          GameQuestion value, $Res Function(GameQuestion) _then) =
      _$GameQuestionCopyWithImpl;
  @useResult
  $Res call({String id, Question question, int points});

  $QuestionCopyWith<$Res> get question;
}

/// @nodoc
class _$GameQuestionCopyWithImpl<$Res> implements $GameQuestionCopyWith<$Res> {
  _$GameQuestionCopyWithImpl(this._self, this._then);

  final GameQuestion _self;
  final $Res Function(GameQuestion) _then;

  /// Create a copy of GameQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? question = null,
    Object? points = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      question: null == question
          ? _self.question
          : question // ignore: cast_nullable_to_non_nullable
              as Question,
      points: null == points
          ? _self.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of GameQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $QuestionCopyWith<$Res> get question {
    return $QuestionCopyWith<$Res>(_self.question, (value) {
      return _then(_self.copyWith(question: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _GameQuestion implements GameQuestion {
  const _GameQuestion(
      {required this.id, required this.question, this.points = 1});
  factory _GameQuestion.fromJson(Map<String, dynamic> json) =>
      _$GameQuestionFromJson(json);

  @override
  final String id;
  @override
  final Question question;
  @override
  @JsonKey()
  final int points;

  /// Create a copy of GameQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GameQuestionCopyWith<_GameQuestion> get copyWith =>
      __$GameQuestionCopyWithImpl<_GameQuestion>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GameQuestionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GameQuestion &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.points, points) || other.points == points));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, question, points);

  @override
  String toString() {
    return 'GameQuestion(id: $id, question: $question, points: $points)';
  }
}

/// @nodoc
abstract mixin class _$GameQuestionCopyWith<$Res>
    implements $GameQuestionCopyWith<$Res> {
  factory _$GameQuestionCopyWith(
          _GameQuestion value, $Res Function(_GameQuestion) _then) =
      __$GameQuestionCopyWithImpl;
  @override
  @useResult
  $Res call({String id, Question question, int points});

  @override
  $QuestionCopyWith<$Res> get question;
}

/// @nodoc
class __$GameQuestionCopyWithImpl<$Res>
    implements _$GameQuestionCopyWith<$Res> {
  __$GameQuestionCopyWithImpl(this._self, this._then);

  final _GameQuestion _self;
  final $Res Function(_GameQuestion) _then;

  /// Create a copy of GameQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? question = null,
    Object? points = null,
  }) {
    return _then(_GameQuestion(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      question: null == question
          ? _self.question
          : question // ignore: cast_nullable_to_non_nullable
              as Question,
      points: null == points
          ? _self.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of GameQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $QuestionCopyWith<$Res> get question {
    return $QuestionCopyWith<$Res>(_self.question, (value) {
      return _then(_self.copyWith(question: value));
    });
  }
}

// dart format on
