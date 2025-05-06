// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUser {
  String get uid;
  String get role;
  String get fullName;
  String? get nickName;
  String get email;
  List<int> get gradeYears;
  List<String> get subjects;
  DateTime? get createdAt;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AppUserCopyWith<AppUser> get copyWith =>
      _$AppUserCopyWithImpl<AppUser>(this as AppUser, _$identity);

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppUser &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.nickName, nickName) ||
                other.nickName == nickName) &&
            (identical(other.email, email) || other.email == email) &&
            const DeepCollectionEquality()
                .equals(other.gradeYears, gradeYears) &&
            const DeepCollectionEquality().equals(other.subjects, subjects) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uid,
      role,
      fullName,
      nickName,
      email,
      const DeepCollectionEquality().hash(gradeYears),
      const DeepCollectionEquality().hash(subjects),
      createdAt);

  @override
  String toString() {
    return 'AppUser(uid: $uid, role: $role, fullName: $fullName, nickName: $nickName, email: $email, gradeYears: $gradeYears, subjects: $subjects, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $AppUserCopyWith<$Res> {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) _then) =
      _$AppUserCopyWithImpl;
  @useResult
  $Res call(
      {String uid,
      String role,
      String fullName,
      String? nickName,
      String email,
      List<int> gradeYears,
      List<String> subjects,
      DateTime? createdAt});
}

/// @nodoc
class _$AppUserCopyWithImpl<$Res> implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._self, this._then);

  final AppUser _self;
  final $Res Function(AppUser) _then;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? role = null,
    Object? fullName = null,
    Object? nickName = freezed,
    Object? email = null,
    Object? gradeYears = null,
    Object? subjects = null,
    Object? createdAt = freezed,
  }) {
    return _then(_self.copyWith(
      uid: null == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _self.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      nickName: freezed == nickName
          ? _self.nickName
          : nickName // ignore: cast_nullable_to_non_nullable
              as String?,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      gradeYears: null == gradeYears
          ? _self.gradeYears
          : gradeYears // ignore: cast_nullable_to_non_nullable
              as List<int>,
      subjects: null == subjects
          ? _self.subjects
          : subjects // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _AppUser implements AppUser {
  const _AppUser(
      {required this.uid,
      required this.role,
      required this.fullName,
      this.nickName,
      required this.email,
      final List<int> gradeYears = const <int>[],
      final List<String> subjects = const <String>[],
      this.createdAt})
      : _gradeYears = gradeYears,
        _subjects = subjects;
  factory _AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  @override
  final String uid;
  @override
  final String role;
  @override
  final String fullName;
  @override
  final String? nickName;
  @override
  final String email;
  final List<int> _gradeYears;
  @override
  @JsonKey()
  List<int> get gradeYears {
    if (_gradeYears is EqualUnmodifiableListView) return _gradeYears;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gradeYears);
  }

  final List<String> _subjects;
  @override
  @JsonKey()
  List<String> get subjects {
    if (_subjects is EqualUnmodifiableListView) return _subjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subjects);
  }

  @override
  final DateTime? createdAt;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AppUserCopyWith<_AppUser> get copyWith =>
      __$AppUserCopyWithImpl<_AppUser>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AppUserToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AppUser &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.nickName, nickName) ||
                other.nickName == nickName) &&
            (identical(other.email, email) || other.email == email) &&
            const DeepCollectionEquality()
                .equals(other._gradeYears, _gradeYears) &&
            const DeepCollectionEquality().equals(other._subjects, _subjects) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uid,
      role,
      fullName,
      nickName,
      email,
      const DeepCollectionEquality().hash(_gradeYears),
      const DeepCollectionEquality().hash(_subjects),
      createdAt);

  @override
  String toString() {
    return 'AppUser(uid: $uid, role: $role, fullName: $fullName, nickName: $nickName, email: $email, gradeYears: $gradeYears, subjects: $subjects, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$AppUserCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$AppUserCopyWith(_AppUser value, $Res Function(_AppUser) _then) =
      __$AppUserCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String uid,
      String role,
      String fullName,
      String? nickName,
      String email,
      List<int> gradeYears,
      List<String> subjects,
      DateTime? createdAt});
}

/// @nodoc
class __$AppUserCopyWithImpl<$Res> implements _$AppUserCopyWith<$Res> {
  __$AppUserCopyWithImpl(this._self, this._then);

  final _AppUser _self;
  final $Res Function(_AppUser) _then;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? uid = null,
    Object? role = null,
    Object? fullName = null,
    Object? nickName = freezed,
    Object? email = null,
    Object? gradeYears = null,
    Object? subjects = null,
    Object? createdAt = freezed,
  }) {
    return _then(_AppUser(
      uid: null == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _self.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      nickName: freezed == nickName
          ? _self.nickName
          : nickName // ignore: cast_nullable_to_non_nullable
              as String?,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      gradeYears: null == gradeYears
          ? _self._gradeYears
          : gradeYears // ignore: cast_nullable_to_non_nullable
              as List<int>,
      subjects: null == subjects
          ? _self._subjects
          : subjects // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
