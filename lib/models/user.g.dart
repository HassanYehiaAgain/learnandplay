// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
      uid: json['uid'] as String,
      role: json['role'] as String,
      fullName: json['fullName'] as String,
      nickName: json['nickName'] as String?,
      email: json['email'] as String,
      gradeYears: (json['gradeYears'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[],
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
      'uid': instance.uid,
      'role': instance.role,
      'fullName': instance.fullName,
      if (instance.nickName case final value?) 'nickName': value,
      'email': instance.email,
      'gradeYears': instance.gradeYears,
      'subjects': instance.subjects,
      if (instance.createdAt?.toIso8601String() case final value?)
        'createdAt': value,
    };
